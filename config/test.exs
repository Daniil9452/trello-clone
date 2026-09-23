import Config

config :doski, Doski.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "doski_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :pbkdf2_elixir, :rounds, 1

config :doski, DoskiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "test-secret-key-base-must-be-at-least-64-bytes-long-for-phoenix-doski",
  server: false

config :doski, Doski.Guardian,
  issuer: "doski",
  secret_key: "test-guardian-secret-key-for-jwt-signing-only"

config :logger, level: :warning
config :phoenix, :plug_init_mode, :runtime
