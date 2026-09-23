defmodule DoskiWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Plug.Conn
      import Phoenix.ConnTest
      import DoskiWeb.ConnCase

      @endpoint DoskiWeb.Endpoint
    end
  end

  setup tags do
    Doski.DataCase.setup_sandbox(tags)

    conn =
      Phoenix.ConnTest.build_conn()
      |> Plug.Conn.put_req_header("accept", "application/json")

    {:ok, conn: conn}
  end

  def auth_conn(conn, user) do
    {:ok, token, _claims} = Doski.Guardian.encode_and_sign(user)
    Plug.Conn.put_req_header(conn, "authorization", "Bearer " <> token)
  end
end
