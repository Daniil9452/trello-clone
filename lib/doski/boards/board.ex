defmodule Doski.Boards.Board do
  use Ecto.Schema
  import Ecto.Changeset

  @colors ~w(#0079bf #519839 #d29034 #b04632 #89609e)

  schema "boards" do
    field(:name, :string)
    field(:color, :string, default: "#0079bf")

    belongs_to(:owner, Doski.Accounts.User, foreign_key: :user_id)
    many_to_many(:members, Doski.Accounts.User, join_through: "board_members")
    has_many(:lists, Doski.Boards.BoardList)

    timestamps(type: :utc_datetime)
  end

  def colors, do: @colors

  def changeset(board, attrs) do
    board
    |> cast(attrs, [:name, :color])
    |> validate_required([:name], message: "обязательно для заполнения")
    |> validate_length(:name, min: 1, max: 120, message: "от 1 до 120 символов")
    |> validate_inclusion(:color, @colors, message: "неизвестный цвет")
  end
end
