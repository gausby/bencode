defmodule Bencode.Decoder.Options do
  @moduledoc """
  A struct for defining option keys and default values for the
  bencode decoder.

  The following options are defined:

    * `calculate_info_hash` (Boolean), default: false
      The sha sum of the info dictionary will be returned along
      with the content of the bencode if this option is set to
      true. `nil` will be returned if no *info*-dictionary was
      found doing decoding.

  """
  defstruct(
    calculate_info_hash: false
  )
end
