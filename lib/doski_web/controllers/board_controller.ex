defmodule DoskiWeb.BoardController do
  use DoskiWeb, :controller

  alias Doski.Boards
  alias Doski.Guardian
  alias DoskiWeb.JSON
  alias DoskiWeb.Realtime

  action_fallback(DoskiWeb.FallbackController)

  def index(conn, _params) do
    user = current_user(conn)
    data = Boards.list_for_user(user)

    json(conn, %{
      owned: Enum.map(data.owned, &JSON.board_summary/1),
      shared: Enum.map(data.shared, &JSON.board_summary/1)
    })
  end

  def create(conn, params) do
    attrs = params["board"] || params

    with {:ok, board} <- Boards.create_board(current_user(conn), attrs) do
      conn |> put_status(:created) |> json(%{board: JSON.board_summary(board)})
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, board} <- Boards.get_board(current_user(conn), id) do
      json(conn, %{board: JSON.board(board)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    attrs = params["board"] || Map.delete(params, "id")

    with {:ok, board} <- Boards.update_board(current_user(conn), id, attrs) do
      payload = %{board: JSON.board_summary(board)}
      Realtime.broadcast(board.id, "board:updated", payload)
      json(conn, payload)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, board} <- Boards.delete_board(current_user(conn), id) do
      Realtime.broadcast(board.id, "board:deleted", %{id: board.id})
      json(conn, %{id: board.id})
    end
  end

  defp current_user(conn), do: Guardian.Plug.current_resource(conn)
end
