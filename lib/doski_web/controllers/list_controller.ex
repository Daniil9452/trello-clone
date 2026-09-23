defmodule DoskiWeb.ListController do
  use DoskiWeb, :controller

  alias Doski.Boards
  alias Doski.Guardian
  alias DoskiWeb.JSON
  alias DoskiWeb.Realtime

  action_fallback(DoskiWeb.FallbackController)

  def create(conn, %{"board_id" => board_id} = params) do
    attrs = params["list"] || Map.drop(params, ["board_id"])

    with {:ok, list} <- Boards.create_list(current_user(conn), board_id, attrs) do
      payload = %{list: JSON.list(list)}
      Realtime.broadcast(list.board_id, "list:created", payload)
      conn |> put_status(:created) |> json(payload)
    end
  end

  def update(conn, %{"id" => id} = params) do
    attrs = Map.take(params["list"] || params, ["name"])

    with {:ok, list} <- Boards.update_list(current_user(conn), id, attrs) do
      payload = %{list: JSON.list(list)}
      Realtime.broadcast(list.board_id, "list:updated", payload)
      json(conn, payload)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, list} <- Boards.delete_list(current_user(conn), id) do
      payload = %{id: list.id, board_id: list.board_id}
      Realtime.broadcast(list.board_id, "list:deleted", payload)
      json(conn, payload)
    end
  end

  defp current_user(conn), do: Guardian.Plug.current_resource(conn)
end
