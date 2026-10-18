defmodule FellowshipWeb.MixProject do
  use Mix.Project

  def project do
    [
      app: :fellowship_web,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:hologram, "~> 0.12.0"},
      {:jason, "~> 1.4"}
    ]
  end
end
