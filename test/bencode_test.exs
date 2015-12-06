defmodule BencodeTest do
  use ExUnit.Case
  doctest Bencode

  test "calculate checksum of info directory when decoding" do
    input = %{"info" => %{"foo" => "bar"}}
    {:ok, data, checksum} = Bencode.decode(Bencode.encode(input))
    assert data == input
    assert checksum == <<109, 34, 98, 18, 111, 235, 110, 199, 189, 52, 100, 147, 80, 37, 200, 198, 9, 192, 17, 157>>
  end
end
