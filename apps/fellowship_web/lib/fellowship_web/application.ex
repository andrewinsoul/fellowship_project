defmodule FellowshipWeb.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FellowshipWeb.Endpoint
    ]

    Supervisor.start_link(
      children,
      strategy: :one_for_one,
      name: FellowshipWeb.Supervisor
    )
  end

  @impl true
  def config_change(changed, _new, removed) do
    FellowshipWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
