# Bencode

[![Hex.pm](https://img.shields.io/hexpm/l/bencode.svg "Apache 2.0 Licensed")](https://github.com/gausby/bencode/blob/master/LICENSE)
[![Hex version](https://img.shields.io/hexpm/v/bencode.svg "Hex version")](https://hex.pm/packages/bencode)

A Bencode encoder and decoder for Elixir.

The encoder is implemented as a protocol, allowing implementations for custom structs.

The decoder should handle malformed data, either by raising an error, or returning an 2-tuple with status, both containing detailed information about the error. The decoder is also capable of calculating the hash of the info dictionary.

## API

* `Bencode.encode/1` will encode a given data structure to the b-code representation and return a `{:ok, data}`-tuple on success, or an `{:error, reason}`-tuple if the data was invalid.

* `Bencode.encode!/1` will encode a given data structure to the b-code representation; it will raise an error if the given input is invalid.

* `Bencode.decode/1` will decode a b-code encoded string and return a 2-tuple; containing the status (`:ok`) and its Elixir data structure representation. Should the data be invalid a 2-tuple will get returned with `{:error, reason}`

* `Bencode.decode!/1` will decode a b-code encoded string and return the decoded result as a Elixir data structure; if the input is invalid an it will raise with the reason.

* `Bencode.decode_with_info_hash/1` will decode a b-code encoded string and return a 3-tuple; containing the status (`:ok`), its Elixir data structure representation along with the checksum of the info dictionary. If no info-dictionary was found the last value will be `nil`. `{:error, reason}` will get returned if the input data was invalid b-code.

## Installation

Bencode is [available in Hex](https://hex.pm/packages/bencode), and can be installed by adding it to the list of  dependencies in `mix.exs`:

``` elixir
  def deps do
    [{:bencode, "~> 0.2.0"}]
  end
```

Notice that there are other bencode implementations on [hex](https://hex.pm/). Please check them out:

* [bencodex](https://hex.pm/packages/bencodex) by [Patrick Gombert](https://github.com/patrickgombert/)

* [bencoder](https://hex.pm/packages/bencoder) by [Alexander Ivanov](https://github.com/alehander42)

* [elixir_bencode](https://hex.pm/packages/elixir_bencode) by [Anton Fagerberg](https://github.com/AntonFagerberg/)

## License

Copyright 2016 Martin Gausby

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
