defmodule Bencode do
  @spec encode(any) :: String.t
  defdelegate encode(data),
    to: Bencode.Encoder

  @spec decode(String.t) :: Integer | String.t | List | Map | no_return
  defdelegate decode(data),
    to: Bencode.Decoder
end
