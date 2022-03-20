defmodule CensysEx.MixProject do
  use Mix.Project

  @pkg_version "1.2.1"

  def project do
    [
      app: :censys_ex,
      version: @pkg_version,
      elixir: "~> 1.10",
      deps: deps(),
      aliases: aliases(),
      docs: [
        extras: ["README.md"],
        main: "readme"
      ],
      name: "censys_ex",
      description: description(),
      source_url: "https://github.com/bwireman/censys_ex",
      homepage_url: "https://hexdocs.pm/censys_ex/readme.html",
      package: package(),
      dialyzer: dialyzer()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.2"},
      {:timex, "~> 3.7"},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:mox, "~> 1.0", only: :test},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.28.2", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      quality: [
        "clean",
        "compile --warnings-as-errors",
        "format --check-formatted",
        "credo --strict",
        "dialyzer --quiet",
        "run -e 'IO.puts(\"LGTM 🤘!\")'"
      ]
    ]
  end

  defp dialyzer() do
    [
      flags: ["-Wunmatched_returns", :error_handling, :underspecs],
      plt_core_path: "priv/plts",
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end

  def description do
    "A small Elixir ⚗️ wrapper for Censys Search v2 APIs"
  end

  defp package() do
    [
      name: "censys_ex",
      licenses: ["MIT"],
      links: %{
        "Github" => "https://github.com/bwireman/censys_ex"
      }
    ]
  end
end
