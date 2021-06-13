defmodule CensysEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :censys_ex,
      version: "0.1.0",
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
      licenses: ["MIT"],
      links: %{
        "Github" => "https://github.com/bwireman/censys_ex",
      }
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
      {:poison, "~> 4.0"},
      {:timex, "~> 3.0"},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:mox, "~> 1.0", only: :test},
      {:ex_doc, "~> 0.24.2", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      quality: [
        "clean",
        "compile --warnings-as-errors",
        "credo --strict",
        "run -e 'IO.puts(\"LGTM 🤘!\")'"
      ]
    ]
  end

  def description do
    "A small Elixir ⚗️ wrapper for Censys Search v2 APIs"
  end
end
