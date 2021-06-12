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
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
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
      quality: ["credo --strict", "compile --warnings-as-errors", "run -e 'IO.puts(\"LGTM 🤘!\")'"]
    ]
  end
end
