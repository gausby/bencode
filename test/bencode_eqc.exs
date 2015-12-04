defmodule BencodeEQC do
  use ExUnit.Case
  use EQC.ExUnit

  # ints
  property "Output of encoding ints followed by a decode should result in the input" do
    forall input <- int do
      ensure Bencode.decode(Bencode.encode(input)) == input
    end
  end

  property "Output of encoding lists of ints followed by a decode should result in the input" do
    forall input <- list(int) do
      ensure Bencode.decode(Bencode.encode(input)) == input
    end
  end

  # strings
  property "encode strings" do
    forall input <- utf8 do
      expected = "#{Integer.to_string(byte_size(input))}:#{input}"
      ensure Bencode.encode(input) == expected
    end
  end

  property "Encoding strings followed by a decode should result in the input" do
    forall input <- utf8 do
      ensure Bencode.decode(Bencode.encode(input)) == input
    end
  end

  property "Encoding lists of strings followed by a decode should result in the input" do
    forall input <- list(utf8) do
      ensure Bencode.decode(Bencode.encode(input)) == input
    end
  end

  property "Encoded maps should decode to the input" do
    forall input <- map(utf8, utf8) do
      ensure Bencode.decode(Bencode.encode(input)) == input
    end
  end

  # misc
  property "random nested data structures" do
    structure =
      frequency(
        [{1, list(
             frequency(
               [{1, utf8},
                {1, int},
                {1, list(frequency([{1, utf8}, {1, int}]))},
                {1, map(utf8, frequency([{1, utf8}, {1, int}]))}]))},
         {1, map(
             utf8, frequency(
               [{1, utf8},
                {1, int},
                {1, list(
                    frequency(
                      [{1, utf8},
                       {1, int},
                       {1, list(frequency([{1, utf8}, {1, int}]))},
                       {1, map(utf8, frequency([{1, utf8}, {1, int}]))}]))},
                {1, map(utf8, frequency([{1, utf8}, {1, int}]))}]))}])

    forall input <- structure do
      ensure Bencode.decode(Bencode.encode(input)) == input
    end
  end
end
