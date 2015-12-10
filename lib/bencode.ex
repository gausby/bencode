defmodule Bencode do
  @spec encode(any) :: String.t
  defdelegate encode(data),
    to: Bencode.Encoder

  @spec decode(String.t) :: {:ok, Integer | String.t | List | Map | no_return}
  defdelegate decode(data),
    to: Bencode.Decoder

  @spec decode!(String.t) :: Integer | String.t | List | Map | nil | no_return
  defdelegate decode!(data),
    to: Bencode.Decoder

  @spec decode_with_info_hash(String.t) :: {:ok, Integer | String.t | List | Map | no_return, nil | binary}
  defdelegate decode_with_info_hash(data),
    to: Bencode.Decoder
end
