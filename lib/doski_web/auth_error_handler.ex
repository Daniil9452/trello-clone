defmodule DoskiWeb.AuthErrorHandler do
  @behaviour Guardian.Plug.ErrorHandler

  import Plug.Conn

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {_type, _reason}, _opts) do
    body = Jason.encode!(%{error: "Требуется авторизация"})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, body)
  end
end
