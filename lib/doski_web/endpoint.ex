defmodule DoskiWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :doski

  socket("/socket", DoskiWeb.UserSocket,
    websocket: true,
    longpoll: false
  )

  plug(Plug.Static,
    at: "/",
    from: :doski,
    gzip: false,
    only: DoskiWeb.static_paths()
  )

  if code_reloading? do
    plug(Phoenix.CodeReloader)
    plug(Phoenix.Ecto.CheckRepoStatus, otp_app: :doski)
  end

  plug(Plug.RequestId)
  plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint])

  plug(CORSPlug,
    origin: [
      "http://localhost:8080",
      "http://127.0.0.1:8080",
      "http://localhost:4000",
      "http://127.0.0.1:4000"
    ]
  )

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)

  plug(Plug.Session,
    store: :cookie,
    key: "_doski_key",
    signing_salt: "doski-session-salt"
  )

  plug(DoskiWeb.Router)
end
