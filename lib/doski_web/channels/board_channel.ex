defmodule DoskiWeb.BoardChannel do
  use DoskiWeb, :channel

  alias Doski.Boards
  alias DoskiWeb.Presence

  @impl true
  def join("board:" <> board_id, _payload, socket) do
    user = socket.assigns.current_user

    case Boards.get_board(user, board_id) do
      {:ok, _board} ->
        send(self(), :after_join)
        {:ok, assign(socket, :board_id, board_id)}

      {:error, :not_found} ->
        {:error, %{reason: "нет доступа"}}
    end
  end

  @impl true
  def handle_info(:after_join, socket) do
    user = socket.assigns.current_user

    {:ok, _} =
      Presence.track(socket, Integer.to_string(user.id), %{
        id: user.id,
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end
end
