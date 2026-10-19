defmodule FellowshipWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :fellowship_web

  @session_options [
    store: :cookie,
    key: "_fellowship_api_key",
    signing_salt: "fellowship-session-salt",
    same_site: "Lax"
  ]

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Jason

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options

  plug Plug.Static,
    at: "/",
    from: :fellowship_web,
    gzip: false,
    only: ~w(hologram)

  plug Plug.Static,
    at: "/",
    from: :fellowship_api,
    gzip: false,
    only: ~w(assets images icon.svg manifest.webmanifest sw.js)

  plug Hologram.Router
  plug FellowshipApiWeb.Router
end
