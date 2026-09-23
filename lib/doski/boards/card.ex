defmodule Doski.Boards.Card do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cards" do
    field(:name, :string)
    field(:description, :string, default: "")
    field(:position, :integer, default: 1)

    belongs_to(:list, Doski.Boards.BoardList, foreign_key: :list_id)

    timestamps(type: :utc_datetime)
  end

  def changeset(card, attrs) do
    card
    |> cast(attrs, [:name, :description, :position, :list_id])
    |> validate_required([:name, :list_id], message: "обязательно для заполнения")
    |> validate_length(:name, min: 1, max: 200, message: "от 1 до 200 символов")
    |> validate_length(:description, max: 5000, message: "не длиннее 5000 символов")
    |> validate_number(:position, greater_than: 0)
  end
end
