defmodule Reginald.MixProject do
  use Mix.Project

  def project do
    [
      app: :reginald,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :plug_cowboy],
      mod: {Reginald.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:nostrum, "~> 0.4"},
      {:httpoison, "~> 1.6"},
      {:poison, "~> 3.1"},
      {:telemetry, "~> 0.4.1"}
    ]
  end
end
