defmodule FellowshipUmbrella.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: [],
      aliases: aliases(),
      releases: [
        fellowship_api: [
          applications: [
            fellowship_api: :permanent,
            fellowship_web: :permanent
          ],
          overlays: ["apps/fellowship_api/rel/overlays"]
        ]
      ]
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["cmd --app fellowship_api mix ecto.setup"],
      "ecto.reset": ["cmd --app fellowship_api mix ecto.reset"],
      "phx.server": ["holo"],
      test: ["cmd --app fellowship_api mix test"]
    ]
  end
end
