defmodule Doski.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)

    has_many(:owned_boards, Doski.Boards.Board, foreign_key: :user_id)
    many_to_many(:boards, Doski.Boards.Board, join_through: "board_members")

    timestamps(type: :utc_datetime)
  end

  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email, :password])
    |> update_change(:email, &normalize_email/1)
    |> validate_required([:first_name, :last_name, :email, :password],
      message: "обязательно для заполнения"
    )
    |> validate_length(:first_name, min: 1, max: 50, message: "от 1 до 50 символов")
    |> validate_length(:last_name, min: 1, max: 50, message: "от 1 до 50 символов")
    |> validate_length(:password, min: 8, max: 72, message: "минимум 8 символов")
    |> validate_format(:email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/, message: "неверный формат почты")
    |> unique_constraint(:email, message: "эта почта уже зарегистрирована")
    |> put_password_hash()
  end

  defp normalize_email(nil), do: nil
  defp normalize_email(email), do: String.downcase(String.trim(email))

  defp put_password_hash(changeset) do
    if password = get_change(changeset, :password) do
      put_change(changeset, :password_hash, Pbkdf2.hash_pwd_salt(password))
    else
      changeset
    end
  end
end
