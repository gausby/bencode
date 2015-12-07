defmodule Bencode.Decoder do
  defstruct(
    rest: "",
    checksum: nil,
    data: nil
  )

  def decode(data) do
    case do_decode(%__MODULE__{rest: data}) do
      %__MODULE__{data: nil} ->
        {:error, "no data"}

      %__MODULE__{data: data, rest: "", checksum: checksum} ->
        {:ok, data, checksum}
    end
  end

  defp do_decode(%__MODULE__{rest: <<"i", data::binary>>} = state),
    do: decode_integer(%__MODULE__{state|rest: data}, [])
  defp do_decode(%__MODULE__{rest: <<"l", data::binary>>} = state),
    do: decode_list(%__MODULE__{state|rest: data}, [])
  defp do_decode(%__MODULE__{rest: <<"d", data::binary>>} = state),
    do: decode_dictionary(%__MODULE__{state|rest: data}, %{})
  # handle info dictionary, if present the checksum should get calculated
  # from the verbatim info data; not all benencoders are build the same
  defp do_decode(%__MODULE__{rest: <<"4:infod", data::binary>>} = state) do
    # consume entire info-dictionary
    info_directory = "d" <> data
    data_length = get_data_length(info_directory)
    <<raw_info_directory::binary-size(data_length), _rest::binary>> = info_directory
    checksum = :crypto.hash(:sha, raw_info_directory)
    # continue parsing the string
    decode_string(%__MODULE__{state|checksum: checksum}, [])
  end
  # handle strings
  defp do_decode(%__MODULE__{rest: <<first, _::binary>>} = state) when first in ?0..?9,
    do: decode_string(state, [])

  #=integers -----------------------------------------------------------
  defp decode_integer(%__MODULE__{rest: <<"e", rest::binary>>} = state, acc),
    do: %__MODULE__{state|rest: rest, data: prepare_integer(acc)}
  defp decode_integer(%__MODULE__{rest: <<current, rest::binary>>} = state, acc)
  when current == ?- or current in ?0..?9,
    do: decode_integer(%__MODULE__{state|rest: rest}, [current|acc])

  #=strings ------------------------------------------------------------
  defp decode_string(%__MODULE__{rest: <<":", data::binary>>} = state, acc) do
    length = prepare_integer acc
    <<string::size(length)-binary, rest::binary>> = data
    %__MODULE__{state|rest: rest, data: string}
  end
  defp decode_string(%__MODULE__{rest: <<number, rest::binary>>} = state, acc)
  when number in ?0..?9,
    do: decode_string(%__MODULE__{state|rest: rest}, [number|acc])

  #=lists --------------------------------------------------------------
  defp decode_list(%__MODULE__{rest: <<"e", rest::binary>>} = state, acc),
    do: %__MODULE__{state|rest: rest, data: acc |> Enum.reverse}
  defp decode_list(%__MODULE__{rest: data} = state, acc) do
    {item, rest} = case do_decode(%__MODULE__{state|rest: data}) do
    %__MODULE__{data: data, rest: rest} ->
        {data, rest}
    end
    decode_list(%__MODULE__{state|rest: rest}, [item|acc])
  end

  #=dictionaries -------------------------------------------------------
  defp decode_dictionary(%__MODULE__{rest: <<"e", rest::binary>>} = state, acc) do
    %__MODULE__{state|rest: rest, data: acc}
  end
  defp decode_dictionary(%__MODULE__{rest: rest} = state, acc) do
    %__MODULE__{data: key, rest: rest, checksum: checksum} = do_decode(%__MODULE__{rest: rest})
    %__MODULE__{data: value, rest: rest} = do_decode(%__MODULE__{rest: rest, checksum: checksum})

    decode_dictionary(%__MODULE__{state|rest: rest, checksum: checksum}, Map.put_new(acc, key, value))
  end

  #=helpers ============================================================
  defp prepare_integer(list) do
    list
    |> Enum.reverse
    |> List.to_integer
  end

  #=consume ============================================================
  defp get_data_length(data) do
    {_, length} = do_consume(data, 0)
    length
  end

  defp do_consume(<<"i", rest::binary>>, offset),
    do: do_consume_integer(rest, offset + 1)
  defp do_consume(<<"l", rest::binary>>, offset),
    do: do_consume_list(rest, offset + 1)
  defp do_consume(<<"d", rest::binary>>, offset),
    do: do_consume_dictionary(rest, offset + 1)
  defp do_consume(<<first, _::binary>> = data, offset) when first in ?0..?9,
    do: do_consume_string(data, [], offset)

  # consume integers
  defp do_consume_integer(<<"e", rest::binary>>, offset),
    do: {rest, offset + 1}
  defp do_consume_integer(<<number, rest::binary>>, offset) when number in ?0..?9,
    do: do_consume_integer(rest, offset + 1)

  # consume strings
  defp do_consume_string(<<":", rest::binary>>, acc, offset) do
    length = prepare_integer(acc)
    <<_::binary-size(length), rest::binary>> = rest
    {rest, offset + length + 1}
  end
  defp do_consume_string(<<number, rest::binary>>, acc, offset) when number in ?0..?9,
    do: do_consume_string(rest, [number|acc], offset + 1)

  # consume lists
  defp do_consume_list(<<"e", rest::binary>>, offset),
    do: {rest, offset + 1}
  defp do_consume_list(data, offset) do
    {rest, offset} = do_consume(data, offset)
    do_consume_list(rest, offset)
  end

  # consume dictionary
  defp do_consume_dictionary(<<"e", data::binary>>, offset),
    do: {data, offset + 1}
  defp do_consume_dictionary(data, offset) do
    {rest, offset} = do_consume(data, offset) # consume key
    {rest, offset} = do_consume(rest, offset) # consume value
    do_consume_dictionary(rest, offset)
  end
end
