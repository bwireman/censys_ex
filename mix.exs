defmodule CensysEx.MixProject do
  use Mix.Project

  @pkg_version "2.0.1"

  def project do
    [
      app: :censys_ex,
      version: @pkg_version,
      elixir: "~> 1.11",
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
      dialyzer: dialyzer(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {CensysEx.Application, []}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.8"},
      {:jason, "~> 1.2"},
      {:timex, "~> 3.7"},
      {:finch, "~> 0.16.0"},
      {:dreamy, "~> 0.2.1"},
      {:mimic, "~> 1.7", only: :test},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.30.9", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      quality: [
        "clean",
        "compile --warnings-as-errors",
        "format --check-formatted",
        "credo --strict",
        "dialyzer",
        "run -e 'IO.puts(\"LGTM 🤘!\")'"
      ]
    ]
  end

  defp dialyzer() do
    [
      flags: ["-Wunmatched_returns", :error_handling, :underspecs]
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
