defmodule Doski.Boards do
  import Ecto.Query
  alias Doski.Accounts
  alias Doski.Accounts.User
  alias Doski.Boards.Board
  alias Doski.Boards.BoardList
  alias Doski.Boards.Card
  alias Doski.Boards.Membership
  alias Doski.Repo

  def list_for_user(%User{} = user) do
    owned =
      Board
      |> where([b], b.user_id == ^user.id)
      |> order_by([b], asc: b.inserted_at)
      |> preload([:owner, :members])
      |> Repo.all()

    shared =
      Board
      |> join(:inner, [b], m in Membership, on: m.board_id == b.id)
      |> where([b, m], m.user_id == ^user.id and b.user_id != ^user.id)
      |> order_by([b], asc: b.inserted_at)
      |> preload([:owner, :members])
      |> Repo.all()

    %{owned: owned, shared: shared}
  end

  def create_board(%User{} = user, attrs) do
    %Board{}
    |> Board.changeset(attrs)
    |> Ecto.Changeset.put_change(:user_id, user.id)
    |> Repo.insert()
    |> preload_ok()
  end

  def update_board(%User{} = user, id, attrs) do
    with {:ok, board} <- fetch_board(user, id),
         :ok <- owner_only(user, board) do
      board
      |> Board.changeset(attrs)
      |> Repo.update()
      |> preload_ok()
    end
  end

  def delete_board(%User{} = user, id) do
    with {:ok, board} <- fetch_board(user, id),
         :ok <- owner_only(user, board),
         {:ok, board} <- Repo.delete(board) do
      {:ok, board}
    end
  end

  def get_board(%User{} = user, id) do
    fetch_board(user, id)
  end

  def add_member(%User{} = user, board_id, email) do
    with {:ok, board} <- fetch_board(user, board_id),
         %User{} = member <- Accounts.get_user_by_email(email),
         :ok <- ensure_can_join(board, member),
         {:ok, _membership} <- insert_member(board, member) do
      {:ok, get_board!(board.id), member}
    else
      nil -> {:error, :user_not_found}
      other -> other
    end
  end

  def remove_member(%User{} = user, board_id, member_id) do
    with {:ok, board} <- fetch_board(user, board_id),
         :ok <- owner_only(user, board),
         member_id <- to_int(member_id),
         true <- member_id != board.user_id || {:error, :is_owner},
         {count, _} when count > 0 <- delete_member(board.id, member_id) do
      {:ok, get_board!(board.id), member_id}
    else
      false -> {:error, :is_owner}
      {:error, :is_owner} -> {:error, :is_owner}
      {0, _} -> {:error, :not_found}
      other -> other
    end
  end

  def create_list(%User{} = user, board_id, attrs) do
    with {:ok, board} <- fetch_board(user, board_id) do
      position = next_position(from(l in BoardList, where: l.board_id == ^board.id))

      %BoardList{}
      |> BoardList.changeset(
        Map.put(attrs, "position", position)
        |> Map.put("board_id", board.id)
      )
      |> Repo.insert()
      |> case do
        {:ok, list} -> {:ok, Repo.preload(list, :cards)}
        error -> error
      end
    end
  end

  def update_list(%User{} = user, id, attrs) do
    with {:ok, list} <- fetch_list(user, id) do
      list
      |> BoardList.changeset(attrs)
      |> Repo.update()
      |> case do
        {:ok, list} -> {:ok, Repo.preload(list, :cards)}
        error -> error
      end
    end
  end

  def delete_list(%User{} = user, id) do
    with {:ok, list} <- fetch_list(user, id),
         {:ok, list} <- Repo.delete(list) do
      {:ok, list}
    end
  end

  def create_card(%User{} = user, list_id, attrs) do
    with {:ok, list} <- fetch_list(user, list_id) do
      position = next_position(from(c in Card, where: c.list_id == ^list.id))

      %Card{}
      |> Card.changeset(attrs |> Map.put("list_id", list.id) |> Map.put("position", position))
      |> Repo.insert()
    end
  end

  def update_card(%User{} = user, id, attrs) do
    with {:ok, card} <- fetch_card(user, id) do
      card
      |> Card.changeset(attrs)
      |> Repo.update()
    end
  end

  def delete_card(%User{} = user, id) do
    with {:ok, card} <- fetch_card(user, id),
         {:ok, card} <- Repo.delete(card) do
      {:ok, card}
    end
  end

  def move_card(%User{} = user, id, attrs) do
    with {:ok, card} <- fetch_card(user, id),
         {:ok, target} <- fetch_list(user, attrs["list_id"] || attrs[:list_id]),
         :ok <- same_board(card, target) do
      position = to_int(attrs["position"] || attrs[:position] || 1)
      source_id = card.list_id

      Repo.transaction(fn ->
        if source_id == target.id do
          reorder(target.id, card, position)
        else
          reindex_without(source_id, card.id)
          reorder(target.id, card, position)
        end
      end)
      |> case do
        {:ok, _} ->
          lists = reload_lists([source_id, target.id])
          card = Repo.get!(Card, card.id)
          {:ok, %{card: card, lists: lists}}

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  def can_access?(%User{} = user, %Board{} = board) do
    owner?(user, board) or member?(user, board)
  end

  defp fetch_board(user, id) do
    case Repo.get(Board, to_int(id)) do
      nil ->
        {:error, :not_found}

      board ->
        board = preload_board(board)
        if can_access?(user, board), do: {:ok, board}, else: {:error, :not_found}
    end
  end

  defp fetch_list(user, id) do
    case Repo.get(BoardList, to_int(id)) do
      nil ->
        {:error, :not_found}

      list ->
        list = Repo.preload(list, board: [:members, :owner])
        if can_access?(user, list.board), do: {:ok, list}, else: {:error, :not_found}
    end
  end

  defp fetch_card(user, id) do
    case Repo.get(Card, to_int(id)) do
      nil ->
        {:error, :not_found}

      card ->
        card = Repo.preload(card, list: [board: [:members, :owner]])

        if can_access?(user, card.list.board) do
          {:ok, card}
        else
          {:error, :not_found}
        end
    end
  end

  defp same_board(card, %BoardList{} = target) do
    card = Repo.preload(card, :list)
    if card.list.board_id == target.board_id, do: :ok, else: {:error, :invalid}
  end

  defp ensure_can_join(board, member) do
    cond do
      member.id == board.user_id -> {:error, :is_owner}
      member?(member, board) -> {:error, :already_member}
      true -> :ok
    end
  end

  defp insert_member(board, member) do
    %Membership{}
    |> Ecto.Changeset.change(user_id: member.id, board_id: board.id)
    |> Repo.insert()
    |> case do
      {:ok, _} -> {:ok, member}
      {:error, _} -> {:error, :already_member}
    end
  end

  defp delete_member(board_id, member_id) do
    Repo.delete_all(
      from(m in Membership,
        where: m.board_id == ^board_id and m.user_id == ^member_id
      )
    )
  end

  defp owner?(user, board), do: board.user_id == user.id

  defp member?(user, board) do
    Enum.any?(board.members, &(&1.id == user.id))
  end

  defp owner_only(user, board) do
    if owner?(user, board), do: :ok, else: {:error, :forbidden}
  end

  defp preload_ok({:ok, board}), do: {:ok, preload_board(board)}
  defp preload_ok(error), do: error

  defp preload_board(board) do
    cards = from(c in Card, order_by: [asc: c.position, asc: c.id])
    lists = from(l in BoardList, order_by: [asc: l.position, asc: l.id])

    Repo.preload(board, [:owner, :members, lists: {lists, cards: cards}])
  end

  defp get_board!(id), do: preload_board(Repo.get!(Board, id))

  defp next_position(query) do
    (Repo.aggregate(query, :max, :position) || 0) + 1
  end

  defp reorder(list_id, card, position) do
    cards =
      Repo.all(
        from(c in Card, where: c.list_id == ^list_id, order_by: [asc: c.position, asc: c.id])
      )

    without = Enum.reject(cards, &(&1.id == card.id))
    index = position - 1
    index = index |> max(0) |> min(length(without))
    {left, right} = Enum.split(without, index)

    (left ++ [card] ++ right)
    |> Enum.with_index(1)
    |> Enum.each(fn {item, pos} ->
      write_card(item, list_id, pos)
    end)
  end

  defp reindex_without(list_id, card_id) do
    Card
    |> where([c], c.list_id == ^list_id and c.id != ^card_id)
    |> order_by([c], asc: c.position, asc: c.id)
    |> Repo.all()
    |> Enum.with_index(1)
    |> Enum.each(fn {item, pos} ->
      if item.position != pos do
        item |> Ecto.Changeset.change(position: pos) |> Repo.update!()
      end
    end)
  end

  defp write_card(card, list_id, position) do
    if card.list_id != list_id or card.position != position do
      card
      |> Ecto.Changeset.change(list_id: list_id, position: position)
      |> Repo.update!()
    else
      card
    end
  end

  defp reload_lists(ids) do
    ids = Enum.uniq(ids)

    lists =
      BoardList
      |> where([l], l.id in ^ids)
      |> Repo.all()
      |> Repo.preload(cards: from(c in Card, order_by: [asc: c.position, asc: c.id]))

    Enum.sort_by(lists, & &1.position)
  end

  defp to_int(value) when is_integer(value), do: value

  defp to_int(value) when is_binary(value) do
    case Integer.parse(value) do
      {int, ""} -> int
      _ -> 0
    end
  end

  defp to_int(_), do: 0
end
