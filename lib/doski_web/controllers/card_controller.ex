defmodule DoskiWeb.CardController do
  use DoskiWeb, :controller

  alias Doski.Boards
  alias Doski.Guardian
  alias DoskiWeb.JSON
  alias DoskiWeb.Realtime

  action_fallback(DoskiWeb.FallbackController)

  def create(conn, %{"list_id" => list_id} = params) do
    attrs = params["card"] || Map.drop(params, ["list_id"])

    with {:ok, card} <- Boards.create_card(current_user(conn), list_id, attrs) do
      payload = %{card: JSON.card(card)}
      Realtime.broadcast(board_id_for_card(card), "card:created", payload)
      conn |> put_status(:created) |> json(payload)
    end
  end

  def update(conn, %{"id" => id} = params) do
    attrs = Map.take(params["card"] || params, ["name", "description"])

    with {:ok, card} <- Boards.update_card(current_user(conn), id, attrs) do
      payload = %{card: JSON.card(card)}
      Realtime.broadcast(board_id_for_card(card), "card:updated", payload)
      json(conn, payload)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, card} <- Boards.delete_card(current_user(conn), id) do
      payload = %{id: card.id, list_id: card.list_id}
      Realtime.broadcast(board_id_for_card(card), "card:deleted", payload)
      json(conn, payload)
    end
  end

  def move(conn, %{"id" => id} = params) do
    attrs = params["move"] || Map.delete(params, "id")

    with {:ok, %{card: card, lists: lists}} <- Boards.move_card(current_user(conn), id, attrs) do
      payload = %{
        card: JSON.card(card),
        lists: Enum.map(lists, &JSON.list/1)
      }

      Realtime.broadcast(board_id_for_card(card), "card:moved", payload)
      json(conn, payload)
    end
  end

  defp current_user(conn), do: Guardian.Plug.current_resource(conn)

  defp board_id_for_card(card) do
    card = Doski.Repo.preload(card, :list)
    card.list.board_id
  end
end
