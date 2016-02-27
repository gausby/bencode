defmodule Bencode do
  @type encodable :: binary | atom | Map | List | Integer

  @spec encode(encodable) :: {:ok, binary} | {:error, binary}
  def encode(data) do
    try do
      Bencode.Encoder.encode!(data)
    rescue
      e in Protocol.UndefinedError ->
        {:error, "protocol Bencode.Encoder is not implemented for #{inspect e.value}"}
    else
      result ->
        {:ok, result}
    end
  end

  defdelegate encode!(data),
    to: Bencode.Encoder

  defdelegate decode(data),
    to: Bencode.Decoder

  defdelegate decode!(data),
    to: Bencode.Decoder

  defdelegate decode_with_info_hash(data),
    to: Bencode.Decoder
end
