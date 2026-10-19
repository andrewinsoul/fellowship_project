defmodule FellowshipWeb.MixProject do
  use Mix.Project

  def project do
    [
      app: :fellowship_web,
      compilers: Mix.compilers() ++ [:hologram],
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {FellowshipWeb.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:fellowship_api, in_umbrella: true},
      {:phoenix, "~> 1.7.21"},
      {:hologram, "~> 0.12.0"},
      {:bandit, "~> 1.5"},
      {:jason, "~> 1.4"}
    ]
  end
end
