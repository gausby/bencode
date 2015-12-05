defmodule BencodeEQC do
  use ExUnit.Case
  use EQC.ExUnit

  # numbers
  property "encode numbers" do
    forall input <- int do
      ensure Bencode.encode(input) == "i#{input}e"
    end
  end

  property "encode strings" do
    forall input <- utf8 do
      ensure Bencode.encode(input) == "#{byte_size input}:#{input}"
    end
  end

  # property "encode lists" do
  #   forall input <- list(utf8) do
  #     ensure Bencode.encode(input) == "le"
  #   end
  # end

  # property "encode maps" do
  #   forall input <- map(utf8, utf8) do
  #     ensure Bencode.encode(input) == "de"
  #   end
  # end

  # Decode
  property "decode numbers" do
    forall input <- int do
      encoded_input = "i#{input}e"
      ensure Bencode.decode(encoded_input) == input
    end
  end

  property "decode strings" do
    forall input <- utf8 do
      encoded_input = "#{byte_size input}:#{input}"
      ensure Bencode.decode(encoded_input) == input
    end
  end


  property "lists" do
    forall input <- list(int) do
      ensure Bencode.decode(Bencode.encode(input), []) == input
    end
  end

  property "maps" do
    forall input <- map(utf8, int) do
      ensure Bencode.decode(Bencode.encode(input), []) == input
    end
  end

  # ints
  # property "Output of encoding ints followed by a decode should result in the input" do
  #   forall input <- int do
  #     ensure Bencode.decode(Bencode.encode(input)) == input
  #   end
  # end

  # property "Output of encoding lists of ints followed by a decode should result in the input" do
  #   forall input <- list(int) do
  #     ensure Bencode.decode(Bencode.encode(input)) == input
  #   end
  # end

  # # strings
  # property "encode strings" do
  #   forall input <- utf8 do
  #     expected = "#{Integer.to_string(byte_size(input))}:#{input}"
  #     ensure Bencode.encode(input) == expected
  #   end
  # end

  # property "Encoding strings followed by a decode should result in the input" do
  #   forall input <- utf8 do
  #     ensure Bencode.decode(Bencode.encode(input)) == input
  #   end
  # end

  # property "Encoding lists of strings followed by a decode should result in the input" do
  #   forall input <- list(utf8) do
  #     ensure Bencode.decode(Bencode.encode(input)) == input
  #   end
  # end

  # property "Encoded maps should decode to the input" do
  #   forall input <- map(utf8, utf8) do
  #     ensure Bencode.decode(Bencode.encode(input)) == input
  #   end
  # end

  # # misc
  # property "random nested data structures" do
  #   structure =
  #     frequency(
  #       [{1, list(
  #            frequency(
  #              [{1, utf8},
  #               {1, int},
  #               {1, list(frequency([{1, utf8}, {1, int}]))},
  #               {1, map(utf8, frequency([{1, utf8}, {1, int}]))}]))},
  #        {1, map(
  #            utf8, frequency(
  #              [{1, utf8},
  #               {1, int},
  #               {1, list(
  #                   frequency(
  #                     [{1, utf8},
  #                      {1, int},
  #                      {1, list(frequency([{1, utf8}, {1, int}]))},
  #                      {1, map(utf8, frequency([{1, utf8}, {1, int}]))}]))},
  #               {1, map(utf8, frequency([{1, utf8}, {1, int}]))}]))}])

  #   forall input <- structure do
  #     ensure Bencode.decode(Bencode.encode(input)) == input
  #   end
  # end
end
