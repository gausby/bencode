defmodule Bencode do
  @type encodable :: binary | atom | Map | List | Integer

  @doc """
  Encode a given data structure to the b-code representation and
  return a `{:ok, data}`-tuple on success.

  Returns an `{:error, reason}`-tuple if the data was invalid.
  """
  @spec encode(encodable) :: {:ok, binary} | {:error, binary}
  def encode(data) do
    try do
      result = Bencode.Encoder.encode!(data)

      {:ok, result}
    rescue
      e in Protocol.UndefinedError ->
        {:error, "protocol Bencode.Encoder is not implemented for #{inspect(e.value)}"}
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

  defdelegate decode_with_info_hash!(data),
    to: Bencode.Decoder
end
