defmodule Doski.BoardsTest do
  use Doski.DataCase, async: true

  alias Doski.Boards
  import Doski.Fixtures

  test "участник видит доску, посторонний нет" do
    owner = user_fixture(%{"email" => "owner@example.com"})
    guest = user_fixture(%{"email" => "guest@example.com"})
    stranger = user_fixture(%{"email" => "stranger@example.com"})

    assert {:ok, board} = Boards.create_board(owner, %{"name" => "Учёба", "color" => "#0079bf"})
    assert {:error, :not_found} = Boards.get_board(stranger, board.id)

    assert {:ok, _board, _guest} = Boards.add_member(owner, board.id, guest.email)
    assert {:ok, visible} = Boards.get_board(guest, board.id)
    assert visible.name == "Учёба"

    lists = Boards.list_for_user(guest)
    assert Enum.any?(lists.shared, &(&1.id == board.id))
  end

  test "карточка переносится в другой список" do
    owner = user_fixture()
    {:ok, board} = Boards.create_board(owner, %{"name" => "Доска"})
    {:ok, first} = Boards.create_list(owner, board.id, %{"name" => "Сделать"})
    {:ok, second} = Boards.create_list(owner, board.id, %{"name" => "Готово"})
    {:ok, card} = Boards.create_card(owner, first.id, %{"name" => "Отчёт"})

    assert {:ok, %{card: moved, lists: lists}} =
             Boards.move_card(owner, card.id, %{"list_id" => second.id, "position" => 1})

    assert moved.list_id == second.id
    assert moved.position == 1
    assert Enum.any?(lists, &(&1.id == second.id))
  end
end
