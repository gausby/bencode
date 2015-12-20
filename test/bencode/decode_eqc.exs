defmodule Bencode.DecodeEQC do
  use ExUnit.Case, async: true
  use EQC.ExUnit

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
end
