import Config

config :swoosh, :api_client, false

config :fellowship_api, :mail_delivery, :local

config :fellowship_api,
       FellowshipApi.LocalMailer,
       adapter: Swoosh.Adapters.Local

config :fellowship_api, FellowshipApi.Repo,
  username: System.get_env("DB_USER", "postgres"),
  password: System.get_env("DB_PASSWORD", "postgres"),
  hostname: System.get_env("DB_HOST", "localhost"),
  database: System.get_env("DB_NAME", "fellowship_api_dev"),
  port: String.to_integer(System.get_env("DB_PORT", "5432")),
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :fellowship_web, FellowshipWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: String.to_integer(System.get_env("PORT", "4000"))],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "dev-secret-key-base-dev-secret-key-base-dev-secret-key-base-1234567890",
  watchers: []

config :nature_whistle,
  notifiers_config: [
    %{
      name: :console_primary,
      service: :console,
      config: %{}
    }
  ],
  alerts: [],
  packs: [
    {
      NatureWhistle.Packs.Beam,
      thresholds: [
        memory: 1_073_741_824
      ],
      notifiers: [:console_primary]
    },
    {
      NatureWhistle.Packs.Ecto,
      repo: FellowshipApi.Repo,
      thresholds: [
        slow_query: 1_000,
        slow_queue: 50,
        slow_db_execution: false
      ],
      notifiers: [:console_primary]
    }
  ]

config :logger, :default_formatter, format: "$time $metadata[$level] $message\n"
config :logger, level: :debug
config :phoenix, :plug_init_mode, :runtime
