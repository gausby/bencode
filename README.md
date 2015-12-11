# Bencode

A Bencode encoder and decoder for Elixir. The decoder will return the checksum value of the `info` dictionary, if an `info` dictionary was found in the input.

## API

* `Bencode.encode/1` will encode a given data structure to the b-code representation.

* `Bencode.decode/1` will decode a b-code encoded string and return a 2-tuple; containing the status (`:ok`) and its Elixir data structure representation. Should the data be invalid a 2-tuple will get returned with `{:error, reason}`

* `Bencode.decode!/1` will decode a b-code encoded string and return the decoded result as a Elixir data structure; if the input is invalid an it will raise with the reason.

* `Bencode.decode_with_info_hash/1` will decode a b-code encoded string and return a 3-tuple; containing the status (`:ok`), its Elixir data structure representation along with the checksum of the info dictionary. If no info-dictionary was found the last value will be `nil`. `{:error, reason}` will get returned if the input data was invalid b-code.

## Installation

Bencode is [available in Hex](https://hex.pm/bencode), and can be installed by adding it to the list of  dependencies in `mix.exs`:

``` elixir
  def deps do
    [{:bencode, "~> 0.1.0"}]
  end
```

Notice that there are other bencode implementations on [hex](https://hex.pm/). Please check them out:

* [bencodex](https://hex.pm/packages/bencodex) by [Patrick Gombert](https://github.com/patrickgombert/)

* [bencoder](https://hex.pm/packages/bencoder) by [Alexander Ivanov](https://github.com/alehander42)

* [elixir_bencode](https://hex.pm/packages/elixir_bencode) by [Anton Fagerberg](https://github.com/AntonFagerberg/)

## License

Copyright 2015 Martin Gausby

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
