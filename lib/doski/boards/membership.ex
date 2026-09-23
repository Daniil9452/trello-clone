defmodule Doski.Boards.Membership do
  use Ecto.Schema

  schema "board_members" do
    belongs_to(:user, Doski.Accounts.User)
    belongs_to(:board, Doski.Boards.Board)

    timestamps(type: :utc_datetime)
  end
end
