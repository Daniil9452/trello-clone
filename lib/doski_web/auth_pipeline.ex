defmodule DoskiWeb.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :doski,
    module: Doski.Guardian,
    error_handler: DoskiWeb.AuthErrorHandler

  plug(Guardian.Plug.VerifyHeader, scheme: "Bearer")
  plug(Guardian.Plug.EnsureAuthenticated)
  plug(Guardian.Plug.LoadResource, allow_blank: false)
end
