defmodule FellowshipApi.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FellowshipApiWeb.Telemetry,
      FellowshipApi.Repo,
      {Phoenix.PubSub, name: FellowshipApi.PubSub},
      {Oban, Application.fetch_env!(:fellowship_api, Oban)},
      {NatureWhistle.Supervisor, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: FellowshipApi.Supervisor)
  end

  @impl true
  def config_change(_changed, _new, _removed) do
    :ok
  end
end
