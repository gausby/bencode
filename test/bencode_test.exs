defmodule BencodeTest do
  use ExUnit.Case
  doctest Bencode

  test "calculate checksum of info directory when decoding" do
    input = %{"info" => %{"foo" => "bar"}}
    {:ok, data, checksum} = Bencode.decode_with_info_hash(Bencode.encode(input))
    assert data == input
    assert checksum == <<109, 34, 98, 18, 111, 235, 110, 199, 189, 52, 100, 147, 80, 37, 200, 198, 9, 192, 17, 157>>
  end

  test "returning error tuples on faulty input" do
    {:error, reason} = Bencode.decode("i1be")
    assert reason =~ "token at 2"

    {:error, reason} = Bencode.decode("3:fo")
    assert reason =~ "at 2 "
    assert reason =~ "out of bounds"
  end
end
