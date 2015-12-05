defprotocol Bencode.Encoder do
  def encode(data)
end

defimpl Bencode.Encoder, for: Integer do
  def encode(number),
    do: "i#{number}e"
end

defimpl Bencode.Encoder, for: BitString do
  def encode(string),
    do: "#{byte_size string}:#{string}"
end

defimpl Bencode.Encoder, for: List do
  def encode(data),
    do: "l#{Enum.map_join(data, &Bencode.Encoder.encode/1)}e"
end

defimpl Bencode.Encoder, for: Map do
  def encode(data),
    do: "d#{Enum.map_join(data, &encode_pair/1)}e"

  defp encode_pair({key, value}) when is_bitstring(key),
    do: "#{Bencode.Encoder.encode key}#{Bencode.Encoder.encode value}"

  defp encode_pair({key, value}) when is_atom(key) do
    key_string = Atom.to_string key
    "#{Bencode.Encoder.encode key_string}#{Bencode.Encoder.encode value}"
  end
end