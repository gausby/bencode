# Bencode

A Bencode encoder and decoder for Elixir. The decoder will return the checksum value of the `info` dictionary, if an `info` dictionary was found in the input.

## API

* `Bencode.encode/1` will encode a given data structure to the b-code representation.

* `Bencode.decode/1` will decode a b-code encoded string and return a 2-tuple; containing the status (`:ok`) and its Elixir data structure representation. Should the data be invalid a 2-tuple will get returned with `{:error, reason}`

* `Bencode.decode!/1` will decode a b-code encoded string and return the decoded result as a Elixir data structure; if the input is invalid an it will raise with the reason.

* `Bencode.decode_with_info_hash/1` will decode a b-code encoded string and return a 3-tuple; containing the status (`:ok`), its Elixir data structure representation along with the checksum of the info dictionary. If no info-dictionary was found the last value will be `nil`. `{:error, reason}` will get returned if the input data was invalid b-code.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add bencode to your list of dependencies in `mix.exs`:

        def deps do
          [{:bencode, "~> 0.1.0"}]
        end

  2. Ensure bencode is started before your application:

        def application do
          [applications: [:bencode]]
        end
