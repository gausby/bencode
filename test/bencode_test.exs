defmodule BencodeTest do
  use ExUnit.Case, async: true
  doctest Bencode

  test "calculate checksum of info directory when decoding" do
    input = %{"info" => %{"foo" => "bar"}}
    {:ok, data, checksum} = Bencode.decode_with_info_hash(Bencode.encode(input))
    assert data == input
    assert checksum == <<109, 34, 98, 18, 111, 235, 110, 199, 189, 52, 100, 147, 80, 37, 200, 198, 9, 192, 17, 157>>
  end

  test "returning error tuples on faulty input containing only integers" do
    # unexpected character
    {:error, reason} = Bencode.decode("i1be")
    assert reason =~ "character at 2"

    {:error, reason} = Bencode.decode("ie")
    assert reason =~ "empty integer"
    assert reason =~ "starting at 0"
  end

  test "returning error tuples on faulty input containing only strings" do
    # too short of a string
    {:error, reason} = Bencode.decode("3:fo")
    assert reason =~ "at 2 "
    assert reason =~ "out of bounds"
  end

  test "returning error tuples on faulty input containing lists with integers" do
    {:error, reason} = Bencode.decode("li28e") # missing `e` at end of data
    assert reason =~ "character at 5,"
    assert reason =~ "end of data"

    {:error, reason} = Bencode.decode("li42eiee")
    assert reason =~ "empty integer"
    assert reason =~ "starting at 5"
  end

  test "returning error tuples on faulty input containing dictionaries with integers" do
    {:error, reason} = Bencode.decode("d3:fooi28e") # missing `e` at end of data
    assert reason =~ "character at 10,"
    assert reason =~ "end of data"

    {:error, reason} = Bencode.decode("d3:fooiee") # empty integer as value
    assert reason =~ "empty integer"
    assert reason =~ "at 6"
  end

  test "returning error tuples on faulty input containing dictionaries with strings" do
    {:error, reason} = Bencode.decode("d3:foo2:bare") # too short of a string as value
    assert reason =~ "unexpected character"
    assert reason =~ "at 10"

    {:error, reason} = Bencode.decode("d1:foo2:bare") # faulty string as key
    assert reason =~ "unexpected character"
    assert reason =~ "at 4"
  end

  test "faulty data at top level" do
    {:error, reason} = Bencode.decode("e")
    assert reason =~ "unexpected character at 0"

    {:error, reason} = Bencode.decode("i1ei2e")
    assert reason =~ "unexpected character"
    assert reason =~ "expected no more data"
  end

  test "empty data should return nil" do
    assert {:ok, nil} = Bencode.decode("")
  end
end
