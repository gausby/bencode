defmodule Bencode.Mixfile do
  use Mix.Project

  def project do
    [app: :bencode,
     version: "0.2.2",
     elixir: "~> 1.2",
     test_pattern: "*_{test,eqc}.exs",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp description do
    """
    A bencode encoder and decoder.

    The decoder will return the info hash with along with the decoded data, and
    the encoder is implemented as a protocol, allowing any data structure to be
    bcode encoded.
    """
  end

  def package do
    [files: ["lib", "mix.exs", "README*", "LICENSE"],
     maintainers: ["Martin Gausby"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/gausby/bencode",
              "Issues" => "https://github.com/gausby/bencode/issues"}]
  end

  defp deps do
    [{:eqc_ex, "~> 1.2.4"}]
  end
end
