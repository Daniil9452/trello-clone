import Config

config :doski,
  ecto_repos: [Doski.Repo]

config :doski, DoskiWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: DoskiWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Doski.PubSub

config :doski, Doski.Guardian,
  issuer: "doski",
  secret_key: "dev-guardian-secret-key-change-in-production-0123456789abcdef"

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
