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

  @spec encode!(encodable) :: binary | no_return
  defdelegate encode!(data),
    to: Bencode.Encoder

  @spec decode(binary) :: encodable | {:error, binary}
  defdelegate decode(data),
    to: Bencode.Decoder

  @spec decode!(binary) :: encodable | {:error, binary}
  defdelegate decode!(data),
    to: Bencode.Decoder

  @spec decode_with_info_hash(binary) :: {:ok, encodable, <<_::20 * 8>> | nil} | {:error, binary}
  defdelegate decode_with_info_hash(data),
    to: Bencode.Decoder
end
