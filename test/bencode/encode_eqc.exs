defmodule Bencode.EncodeEQC do
  use ExUnit.Case, async: true
  use EQC.ExUnit

  # numbers
  property "encode numbers" do
    forall input <- int() do
      ensure Bencode.encode!(input) == "i#{input}e"
    end
  end

  property "encode strings" do
    forall input <- utf8() do
      ensure Bencode.encode!(input) == "#{byte_size input}:#{input}"
    end
  end

  # figure out a way to model lists and property test them
  # figure out a way to model maps and property test them
end
