defmodule Bencode.Mixfile do
  use Mix.Project

  def project do
    [app: :bencode,
     version: "0.3.1",
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
    A complete and correct Bencode encoder and decoder written in pure Elixir.

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
              "Issues" => "https://github.com/gausby/bencode/issues",
              "Contributors" => "https://github.com/gausby/bencode/graphs/contributors"}]
  end

  defp deps do
    [{:eqc_ex, "~> 1.2.4"},
     {:credo, "~> 0.3", only: [:dev, :test]}]
  end
end
