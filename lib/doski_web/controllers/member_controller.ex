defmodule DoskiWeb.MemberController do
  use DoskiWeb, :controller

  alias Doski.Boards
  alias Doski.Guardian
  alias DoskiWeb.JSON
  alias DoskiWeb.Realtime

  action_fallback(DoskiWeb.FallbackController)

  def create(conn, %{"board_id" => board_id} = params) do
    email = params["email"] || get_in(params, ["member", "email"])

    with {:ok, board, member} <- Boards.add_member(current_user(conn), board_id, email) do
      payload = %{member: JSON.user(member), board: JSON.board_summary(board)}
      Realtime.broadcast(board.id, "member:added", payload)
      conn |> put_status(:created) |> json(payload)
    end
  end

  def delete(conn, %{"board_id" => board_id, "user_id" => user_id}) do
    with {:ok, board, member_id} <- Boards.remove_member(current_user(conn), board_id, user_id) do
      payload = %{user_id: member_id, board: JSON.board_summary(board)}
      Realtime.broadcast(board.id, "member:removed", payload)
      json(conn, payload)
    end
  end

  defp current_user(conn), do: Guardian.Plug.current_resource(conn)
end
