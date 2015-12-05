defmodule Bencode.Decoder do
  defstruct(
    rest: "",
    sha: nil,
    data: nil
  )

  def decode(data) do
    case do_decode(%__MODULE__{rest: data}) do
      %__MODULE__{data: nil} ->
        {:error, "no data"}

      %__MODULE__{data: data, rest: ""} ->
        {:ok, data}
    end
  end

  def decode!(data) do
    {:ok, data} = decode(data)
    data
  end

  defp do_decode(%__MODULE__{rest: <<"i", data::binary>>} = state),
    do: decode_integer(%__MODULE__{state|rest: data}, [])
  defp do_decode(%__MODULE__{rest: <<"l", data::binary>>} = state),
    do: decode_list(%__MODULE__{state|rest: data}, [])
  defp do_decode(%__MODULE__{rest: <<"d", data::binary>>} = state),
    do: decode_dictionary(%__MODULE__{state|rest: data}, %{})
  defp do_decode(%__MODULE__{rest: <<first, _::binary>>} = state) when first in ?0..?9,
    do: decode_string(state, [])

  # integers ===========================================================
  defp decode_integer(%__MODULE__{rest: <<"e", rest::binary>>} = state, acc),
    do: %__MODULE__{state|rest: rest, data: prepare_integer(acc)}
  defp decode_integer(%__MODULE__{rest: <<current, rest::binary>>} = state, acc)
  when current == ?- or current in ?0..?9,
    do: decode_integer(%__MODULE__{state|rest: rest}, [current|acc])

  # strings ============================================================
  defp decode_string(%__MODULE__{rest: <<":", data::binary>>} = state, acc) do
    length = prepare_integer acc
    <<string::size(length)-binary, rest::binary>> = data
    %__MODULE__{state|rest: rest, data: string}
  end
  defp decode_string(%__MODULE__{rest: <<number, rest::binary>>} = state, acc)
  when number in ?0..?9,
    do: decode_string(%__MODULE__{state|rest: rest}, [number|acc])

  # lists ==============================================================
  defp decode_list(%__MODULE__{rest: <<"e", rest::binary>>} = state, acc),
    do: %__MODULE__{state|rest: rest, data: acc |> Enum.reverse}
  defp decode_list(%__MODULE__{rest: data} = state, acc) do
    {item, rest} = case do_decode(%__MODULE__{rest: data}) do
      %__MODULE__{data: data, rest: rest} ->
        {data, rest}
    end
    decode_list(%__MODULE__{state|rest: rest}, [item|acc])
  end

  # dictionaries =======================================================
  defp decode_dictionary(%__MODULE__{rest: <<"e", rest::binary>>} = state, acc),
    do: %__MODULE__{state|rest: rest, data: acc}
  defp decode_dictionary(%__MODULE__{rest: rest} = state, acc) do
    %__MODULE__{data: key, rest: rest} = do_decode(%__MODULE__{rest: rest})
    %__MODULE__{data: value, rest: rest} = do_decode(%__MODULE__{rest: rest})

    decode_dictionary(%__MODULE__{state|rest: rest}, Map.put_new(acc, key, value))
  end

  # helpers
  defp prepare_integer(list) do
    list
    |> Enum.reverse
    |> List.to_integer
  end
end
