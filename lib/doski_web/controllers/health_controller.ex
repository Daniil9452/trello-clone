defmodule DoskiWeb.HealthController do
  use DoskiWeb, :controller

  def show(conn, _params) do
    json(conn, %{status: "ok"})
  end
end
