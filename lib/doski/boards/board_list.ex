defmodule Doski.Boards.BoardList do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lists" do
    field(:name, :string)
    field(:position, :integer, default: 1)

    belongs_to(:board, Doski.Boards.Board)
    has_many(:cards, Doski.Boards.Card, foreign_key: :list_id)

    timestamps(type: :utc_datetime)
  end

  def changeset(list, attrs) do
    list
    |> cast(attrs, [:name, :position, :board_id])
    |> validate_required([:name, :board_id], message: "обязательно для заполнения")
    |> validate_length(:name, min: 1, max: 120, message: "от 1 до 120 символов")
    |> validate_number(:position, greater_than: 0)
  end
end
