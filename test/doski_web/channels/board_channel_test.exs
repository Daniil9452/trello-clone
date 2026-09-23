defmodule DoskiWeb.BoardChannelTest do
  use DoskiWeb.ChannelCase, async: false

  import Doski.Fixtures
  alias Doski.Boards

  test "участник подключается к доске и получает присутствие" do
    user = user_fixture()
    {:ok, board} = Boards.create_board(user, %{"name" => "Канал"})

    {:ok, _, socket} =
      DoskiWeb.UserSocket
      |> socket("user", %{current_user: user})
      |> subscribe_and_join(DoskiWeb.BoardChannel, "board:#{board.id}")

    assert_push("presence_state", payload)
    assert Map.has_key?(payload, to_string(user.id))

    DoskiWeb.Realtime.broadcast(board.id, "list:created", %{list: %{id: 1, name: "Новый"}})
    assert_push("list:created", %{list: %{name: "Новый"}})

    leave(socket)
  end

  test "посторонний не подключается" do
    owner = user_fixture()
    stranger = user_fixture()
    {:ok, board} = Boards.create_board(owner, %{"name" => "Закрытая"})

    assert {:error, %{reason: "нет доступа"}} =
             DoskiWeb.UserSocket
             |> socket("user", %{current_user: stranger})
             |> subscribe_and_join(DoskiWeb.BoardChannel, "board:#{board.id}")
  end
end
