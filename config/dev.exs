import Config

config :doski, Doski.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "127.0.0.1",
  database: "doski_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :doski, DoskiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "dev-secret-key-base-must-be-at-least-64-bytes-long-for-phoenix-doski-app",
  watchers: []

config :doski, dev_routes: true
config :doski, :bind_ipv6_loopback, true

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime
