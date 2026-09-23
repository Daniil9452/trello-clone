import Config

if System.get_env("PHX_SERVER") do
  config :doski, DoskiWeb.Endpoint, server: true
end

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise "Переменная DATABASE_URL не задана"

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise "Переменная SECRET_KEY_BASE не задана"

  guardian_secret =
    System.get_env("GUARDIAN_SECRET") ||
      raise "Переменная GUARDIAN_SECRET не задана"

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")
  pool_size = String.to_integer(System.get_env("POOL_SIZE") || "5")

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  repo_config = [
    url: database_url,
    pool_size: pool_size,
    socket_options: maybe_ipv6
  ]

  repo_config =
    if System.get_env("ECTO_SSL") == "true" do
      Keyword.put(repo_config, :ssl, verify: :verify_none)
    else
      repo_config
    end

  config :doski, Doski.Repo, repo_config

  config :doski, DoskiWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [ip: {0, 0, 0, 0}, port: port],
    secret_key_base: secret_key_base,
    server: true,
    check_origin: ["https://#{host}", "http://#{host}"]

  config :doski, Doski.Guardian,
    issuer: "doski",
    secret_key: guardian_secret
end
