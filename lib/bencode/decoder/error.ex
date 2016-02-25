defmodule Bencode.Decoder.Error do
  @moduledoc false

  defexception(
    reason: nil,
    action: "",
    data: nil
  )

  def message(exception) do
    "could not #{exception.action} #{exception.data}: #{exception.reason}"
  end
end
