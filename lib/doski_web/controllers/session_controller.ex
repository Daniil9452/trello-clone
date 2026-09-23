defmodule DoskiWeb.SessionController do
  use DoskiWeb, :controller

  alias Doski.Accounts
  alias Doski.Guardian
  alias DoskiWeb.JSON

  def create(conn, params) do
    session = params["session"] || params

    case Accounts.authenticate(session["email"], session["password"]) do
      {:ok, user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user)
        json(conn, %{token: token, user: JSON.user(user)})

      {:error, :invalid} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Неверная почта или пароль"})
    end
  end

  def show(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    json(conn, %{user: JSON.user(user)})
  end
end
