defmodule BencodeEQC do
  use ExUnit.Case, async: true
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

  # figure out a way to model lists and property test them
  # figure out a way to model maps and property test them

  # Decode
  property "decode numbers" do
    forall input <- int do
      encoded_input = "i#{input}e"
      {:ok, decoded_result} = Bencode.decode(encoded_input)
      ensure decoded_result == input
    end
  end

  property "decode strings" do
    forall input <- utf8 do
      encoded_input = "#{byte_size input}:#{input}"
      {:ok, decoded_result} = Bencode.decode(encoded_input)
      ensure decoded_result == input
    end
  end

  property "lists" do
    forall input <- list(int) do
      encoded_input = Bencode.encode(input)
      {:ok, decoded_result} = Bencode.decode(encoded_input)
      ensure decoded_result == input
    end
  end

  property "maps" do
    forall input <- map(utf8, int) do
      encoded_input = Bencode.encode(input)
      {:ok, decoded_result} = Bencode.decode(encoded_input)
      ensure decoded_result == input
    end
  end

  # ints
  property "Output of encoding ints followed by a decode should result in the input" do
    forall input <- int do
      encoded_input = Bencode.encode(input)
      {:ok, decoded_result} = Bencode.decode(encoded_input)
      ensure decoded_result == input
    end
  end

  property "Output of encoding lists of ints followed by a decode should result in the input" do
    forall input <- list(int) do
      encoded_input = Bencode.encode(input)
      {:ok, decoded_result} = Bencode.decode(encoded_input)
      ensure decoded_result == input
    end
  end

  # strings

  property "Encoding strings followed by a decode should result in the input" do
    forall input <- utf8 do
      encoded_input = Bencode.encode(input)
      {:ok, decoded_result} = Bencode.decode(encoded_input)
      ensure decoded_result == input
    end
  end

  property "Encoding lists of strings followed by a decode should result in the input" do
    forall input <- list(utf8) do
      encoded_input = Bencode.encode(input)
      {:ok, decoded_result} = Bencode.decode(encoded_input)
      ensure decoded_result == input
    end
  end

  property "Encoded maps should decode to the input" do
    forall input <- map(utf8, utf8) do
      encoded_input = Bencode.encode(input)
      {:ok, decoded_result} = Bencode.decode(encoded_input)
      ensure decoded_result == input
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
      encoded_input = Bencode.encode(input)
      {:ok, decoded_result} = Bencode.decode(encoded_input)
      ensure decoded_result == input
    end
  end
end
