defmodule DoskiWeb.RegistrationController do
  use DoskiWeb, :controller

  alias Doski.Accounts
  alias Doski.Guardian
  alias DoskiWeb.JSON

  action_fallback(DoskiWeb.FallbackController)

  def create(conn, params) do
    attrs = params["user"] || params

    with {:ok, user} <- Accounts.register_user(attrs),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      conn
      |> put_status(:created)
      |> json(%{token: token, user: JSON.user(user)})
    end
  end
end
