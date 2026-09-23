defmodule DoskiWeb.Realtime do
  def broadcast(board_id, event, payload) do
    DoskiWeb.Endpoint.broadcast("board:#{board_id}", event, payload)
  end
end
