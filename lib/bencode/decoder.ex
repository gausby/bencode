defmodule Bencode.Decoder do
  defstruct(
    rest: "",
    position: 0,
    checksum: nil,
    data: nil,
    opts: %{}
  )

  def decode(data) do
    case do_decode(%__MODULE__{rest: data}) do
      %__MODULE__{data: data, rest: ""} ->
        {:ok, data}

      %__MODULE__{rest: <<char, _::binary>>, position: position} ->
        {:error, "unexpected character at #{position}, expected no more data, got: #{[char]}"}

      {:error, _} = error ->
        error
    end
  end

  def decode!(data) do
    case decode(data) do
      {:ok, result} ->
        result

      {:error, reason} ->
        raise Bencode.Decoder.Error, reason: reason, action: "decode data", data: data
    end
  end

  def decode_with_info_hash(data) do
    case do_decode(%__MODULE__{rest: data, opts: %{calculate_info_hash: true}}) do
      %__MODULE__{data: data, rest: "", checksum: checksum} ->
        {:ok, data, checksum}

      %__MODULE__{rest: <<char, _::binary>>, position: position} ->
        {:error, "unexpected character at #{position}, expected no more data, got: #{[char]}"}

      {:error, _} = error ->
        error
    end
  end

  # handle integers
  defp do_decode(%__MODULE__{rest: <<"i", data::binary>>} = state) do
    %__MODULE__{state|rest: data}
    |> advance_position
    |> decode_integer
  end
  # handle lists
  defp do_decode(%__MODULE__{rest: <<"l", data::binary>>} = state) do
    %__MODULE__{state|rest: data}
    |> advance_position
    |> decode_list
  end
  # handle dictionaries
  defp do_decode(%__MODULE__{rest: <<"d", data::binary>>} = state) do
    %__MODULE__{state|rest: data}
    |> advance_position
    |> decode_dictionary
  end
  # handle info dictionary, if present the checksum should get calculated
  # from the verbatim info data; not all benencoders are build the same
  defp do_decode(%__MODULE__{rest: <<"4:infod", data::binary>>, opts: %{calculate_info_hash: true}} = state) do
    case get_raw_source_data("d" <> data) do
      {:ok, raw_info_directory} ->
        checksum = :crypto.hash(:sha, raw_info_directory)
        # continue parsing the string
        decode_string(%__MODULE__{state|checksum: checksum})

      {:error, _} ->
        # the data is faulty, but we still attempt to decode it to get the
        # exact reason for the failure using the regular parser
        decode_string(state)
    end
  end
  # handle strings
  defp do_decode(%__MODULE__{rest: <<first, _::binary>>} = state) when first in ?0..?9 do
    decode_string(state)
  end
  defp do_decode(%__MODULE__{rest: <<char, _::binary>>, position: position}) do
    {:error, "unexpected character at #{position}, expected a string; an integer; a list; or a dictionary, got: #{[char]}"}
  end
  # handle empty strings
  defp do_decode(%__MODULE__{rest: <<>>} = state),
    do: state

  #=integers -----------------------------------------------------------
  defp decode_integer(state, acc \\ [])
  defp decode_integer(%__MODULE__{rest: <<"e", rest::binary>>} = state, acc) when length(acc) > 0 do
    %__MODULE__{state|rest: rest, data: prepare_integer(acc)}
    |> advance_position
  end
  defp decode_integer(%__MODULE__{rest: <<current, rest::binary>>} = state, acc) when current == ?- or current in ?0..?9 do
    %__MODULE__{state|rest: rest}
    |> advance_position
    |> decode_integer([current|acc])
  end
  # errors
  defp decode_integer(%__MODULE__{rest: <<"e", _::binary>>} = state, []),
    do: {:error, "empty integer starting at #{state.position - 1}"}
  defp decode_integer(%__MODULE__{rest: <<char, _::binary>>, position: position}, _),
    do: {:error, "unexpected character at #{position}, expected a number or an `e`, got: #{[char]}"}

  #=strings ------------------------------------------------------------
  defp decode_string(state, acc \\ [])
  defp decode_string(%__MODULE__{rest: <<":", data::binary>>} = state, acc) do
    length = prepare_integer acc
    case data do
      <<string::size(length)-binary, rest::binary>> ->
        %__MODULE__{state|rest: rest,data: string}
        |> advance_position(1 + length)

      _ ->
        {:error, "expected a string of length #{length} at #{state.position + 1} but got out of bounds"}
    end
  end
  defp decode_string(%__MODULE__{rest: <<number, rest::binary>>} = state, acc) when number in ?0..?9 do
    %__MODULE__{state|rest: rest}
    |> advance_position
    |> decode_string([number|acc])
  end
  defp decode_string(%__MODULE__{rest: <<char, _::binary>>, position: position}, _) do
    {:error, "unexpected character at #{position}, expected a number or an `:`, got: #{[char]}"}
  end

  #=lists --------------------------------------------------------------
  defp decode_list(state, acc \\ [])
  defp decode_list(%__MODULE__{rest: <<"e", rest::binary>>} = state, acc) do
    %__MODULE__{state|rest: rest, data: acc |> Enum.reverse}
    |> advance_position
  end
  defp decode_list(%__MODULE__{rest: data} = state, acc) when data != "" do
    with(
      %__MODULE__{data: list_item} = new_state <- do_decode(state),
      do: decode_list(new_state, [list_item|acc])
    )
  end
  # errors
  defp decode_list(%__MODULE__{rest: <<>>, position: position}, _) do
    {:error, "unexpected character at #{position}, expected data or an end character, got end of data"}
  end

  #=dictionaries -------------------------------------------------------
  defp decode_dictionary(state, acc \\ %{})
  defp decode_dictionary(%__MODULE__{rest: <<"e", rest::binary>>} = state, acc) do
    %__MODULE__{state|rest: rest, data: acc}
    |> advance_position
  end
  defp decode_dictionary(%__MODULE__{rest: rest} = state, acc) when rest != "" do
    with(
      %__MODULE__{data: key} = state <- do_decode(state),
      %__MODULE__{data: value} = state <- do_decode(state),
      do: decode_dictionary(state, Map.put_new(acc, key, value))
    )
  end
  # errors
  defp decode_dictionary(%__MODULE__{rest: <<>>, position: position}, _) do
    {:error, "unexpected character at #{position}, expected data or an end character, got end of data"}
  end

  #=helpers ============================================================
  defp prepare_integer(list) do
    list
    |> Enum.reverse
    |> List.to_integer
  end

  defp advance_position(%__MODULE__{position: current} = state, increment \\ 1) do
    %__MODULE__{state|position: current + increment}
  end

  defp get_raw_source_data(data) do
    with(
      {:ok, _, length} <- do_scan(data, 0),
      <<raw_source_data::binary-size(length), _::binary>> <- data,
      do: {:ok, raw_source_data}
    )
  end

  #=scan ===============================================================
  defp do_scan(<<"i", rest::binary>>, offset),
    do: do_scan_integer(rest, offset + 1)
  defp do_scan(<<"l", rest::binary>>, offset),
    do: do_scan_list(rest, offset + 1)
  defp do_scan(<<"d", rest::binary>>, offset),
    do: do_scan_dictionary(rest, offset + 1)
  defp do_scan(<<first, _::binary>> = data, offset) when first in ?0..?9,
    do: do_scan_string(data, offset)
  defp do_scan(_, _),
    do: {:error, "faulty info dictionary"}

  # scan integers
  defp do_scan_integer(<<"e", rest::binary>>, offset),
    do: {:ok, rest, offset + 1}
  defp do_scan_integer(<<number, rest::binary>>, offset) when number in ?0..?9,
    do: do_scan_integer(rest, offset + 1)
  defp do_scan_integer(_, _offset),
    do: {:error, "faulty info dictionary"}

  # scan strings
  defp do_scan_string(data, acc \\ [], offset)
  defp do_scan_string(<<":", data::binary>>, acc, offset) do
    length = prepare_integer(acc)
    case data do
      <<_::size(length)-binary, rest::binary>> ->
        {:ok, rest, offset + length + 1}

      _ ->
        {:error, "faulty info dictionary"}
    end
  end
  defp do_scan_string(<<number, rest::binary>>, acc, offset) when number in ?0..?9,
    do: do_scan_string(rest, [number|acc], offset + 1)
  defp do_scan_string(_, _acc, _offset),
    do: {:error, "faulty info dictionary"}

  # scan lists
  defp do_scan_list(<<"e", rest::binary>>, offset),
    do: {:ok, rest, offset + 1}
  defp do_scan_list(data, offset) when data != "" do
    with(
      {:ok, rest, offset} <- do_scan(data, offset),
      do: do_scan_list(rest, offset)
    )
  end
  defp do_scan_list(<<>>, _offset),
    do: {:error, "faulty info dictionary"}

  # scan dictionary
  defp do_scan_dictionary(<<"e", data::binary>>, offset),
    do: {:ok, data, offset + 1}
  defp do_scan_dictionary(data, offset) when data != "" do
    with(
      # scan key
      {:ok, rest, offset} <- do_scan(data, offset),
      # scan value
      {:ok, rest, offset} <- do_scan(rest, offset),
      do: do_scan_dictionary(rest, offset)
    )
  end
  defp do_scan_dictionary(<<>>, _offset),
    do: {:error, "faulty info dictionary"}

end
