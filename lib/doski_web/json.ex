defmodule DoskiWeb.JSON do
  alias Doski.Accounts.User
  alias Doski.Boards.Board
  alias Doski.Boards.BoardList
  alias Doski.Boards.Card

  def user(%User{} = user) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email
    }
  end

  def board_summary(%Board{} = board) do
    %{
      id: board.id,
      name: board.name,
      color: board.color,
      owner: user(board.owner),
      members: board.members |> Enum.sort_by(& &1.first_name) |> Enum.map(&user/1)
    }
  end

  def board(%Board{} = board) do
    Map.put(board_summary(board), :lists, Enum.map(board.lists, &list/1))
  end

  def list(%BoardList{} = list) do
    %{
      id: list.id,
      board_id: list.board_id,
      name: list.name,
      position: list.position,
      cards: Enum.map(list.cards || [], &card/1)
    }
  end

  def card(%Card{} = card) do
    %{
      id: card.id,
      list_id: card.list_id,
      name: card.name,
      description: card.description || "",
      position: card.position
    }
  end

  def errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
