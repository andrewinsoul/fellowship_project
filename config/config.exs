import Config

config :fellowship_api,
  ecto_repos: [FellowshipApi.Repo],
  generators: [timestamp_type: :utc_datetime]



config :fellowship_web, FellowshipWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [formats: [json: FellowshipApiWeb.ErrorJSON], layout: false],
  pubsub_server: FellowshipApi.PubSub,
  live_view: [signing_salt: "fellowship-live-salt"]

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase
config :phoenix, :json_library, Jason
config :bcrypt_elixir, log_rounds: 12

config :fellowship_api, Oban,
  repo: FellowshipApi.Repo,
  queues: [default: 5, notifications: 5],
  plugins: [
    {Oban.Plugins.Cron,
     crontab: [
       # Runs every Tuesday shortly after midnight in the server timezone.
       # The worker itself always calculates dates in Africa/Lagos.
       {"15 0 * * 2", FellowshipApi.Workers.EnsureUpcomingMeetings}
     ]}
  ]

config :nature_whistle,
  notifiers_config: [
    %{
      name: :slack_primary,
      service: :slack,
      config: %{
        webhook_url: System.get_env("NATURE_WHISTLE_SLACK_WEBHOOK_URL")
      }
    }
  ],
  alerts: [],
  packs: [
    {
      NatureWhistle.Packs.Beam,
      thresholds: [
        memory: 1_073_741_824
      ],
      notifiers: [:slack_primary]
    },
    {
      NatureWhistle.Packs.Ecto,
      repo: FellowshipApi.Repo,
      thresholds: [
        slow_query: 1_000,
        slow_queue: 50,
        slow_db_execution: false
      ],
      notifiers: [:slack_primary]
    }
  ]

import_config "#{config_env()}.exs"
