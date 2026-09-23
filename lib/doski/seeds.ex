defmodule Doski.Seeds do
  alias Doski.Accounts
  alias Doski.Boards
  alias Doski.Boards.Board
  alias Doski.Boards.BoardList
  alias Doski.Boards.Card
  alias Doski.Repo

  def run do
    ivan =
      ensure_user(%{
        "first_name" => "Иван",
        "last_name" => "Петров",
        "email" => "demo@example.com",
        "password" => "parol12345"
      })

    maria =
      ensure_user(%{
        "first_name" => "Мария",
        "last_name" => "Соколова",
        "email" => "maria@example.com",
        "password" => "parol12345"
      })

    practice =
      ensure_board(ivan, %{
        "name" => "Практика: веб-разработка",
        "color" => "#0079bf"
      })

    todo = ensure_list(practice, "Нужно сделать")
    doing = ensure_list(practice, "В работе")
    done = ensure_list(practice, "Готово")

    ensure_card(todo, "Оформить README", "Кратко описать стек и команду запуска.")
    ensure_card(todo, "Снять короткую демонстрацию", "Показать вход, доску и карточку.")

    ensure_card(
      doing,
      "Проверить совместное редактирование",
      "Открыть доску под двумя пользователями."
    )

    ensure_card(done, "Собрать Phoenix и React", "Бэкенд, каналы и одностраничный интерфейс.")

    shared =
      ensure_board(maria, %{
        "name" => "Совместная доска",
        "color" => "#519839"
      })

    ideas = ensure_list(shared, "Идеи")
    ensure_card(ideas, "Добавить метки на карточки", "Цветные метки, как в канбане.")
    _ = Boards.add_member(maria, shared.id, ivan.email)

    :ok
  end

  defp ensure_user(attrs) do
    case Accounts.get_user_by_email(attrs["email"]) do
      nil ->
        {:ok, user} = Accounts.register_user(attrs)
        user

      user ->
        user
    end
  end

  defp ensure_board(owner, attrs) do
    case Repo.get_by(Board, user_id: owner.id, name: attrs["name"]) do
      nil ->
        {:ok, board} = Boards.create_board(owner, attrs)
        board

      board ->
        board
    end
  end

  defp ensure_list(board, name) do
    case Repo.get_by(BoardList, board_id: board.id, name: name) do
      nil ->
        owner = Repo.get!(Doski.Accounts.User, board.user_id)
        {:ok, list} = Boards.create_list(owner, board.id, %{"name" => name})
        list

      list ->
        list
    end
  end

  defp ensure_card(list, name, description) do
    case Repo.get_by(Card, list_id: list.id, name: name) do
      nil ->
        list = Repo.preload(list, board: :owner)

        {:ok, card} =
          Boards.create_card(list.board.owner, list.id, %{
            "name" => name,
            "description" => description
          })

        card

      card ->
        card
    end
  end
end
