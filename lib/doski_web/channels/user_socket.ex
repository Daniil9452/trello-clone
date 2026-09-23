defmodule DoskiWeb.UserSocket do
  use Phoenix.Socket

  channel("board:*", DoskiWeb.BoardChannel)

  @impl true
  def connect(%{"token" => token}, socket, _connect_info) when is_binary(token) do
    with {:ok, claims} <- Doski.Guardian.decode_and_verify(token),
         {:ok, user} <- Doski.Guardian.resource_from_claims(claims) do
      {:ok, assign(socket, :current_user, user)}
    else
      _ -> :error
    end
  end

  def connect(_params, _socket, _connect_info), do: :error

  @impl true
  def id(socket), do: "user_socket:#{socket.assigns.current_user.id}"
end
