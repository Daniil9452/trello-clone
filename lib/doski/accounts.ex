defmodule Doski.Accounts do
  import Ecto.Query
  alias Doski.Accounts.User
  alias Doski.Repo

  def get_user(id) when is_binary(id) do
    case Integer.parse(id) do
      {int, ""} -> get_user(int)
      _ -> nil
    end
  end

  def get_user(id) when is_integer(id), do: Repo.get(User, id)

  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: String.downcase(String.trim(email)))
  end

  def get_user_by_email(_), do: nil

  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def authenticate(email, password) do
    user = get_user_by_email(email || "")
    password = password || ""

    cond do
      user && Pbkdf2.verify_pass(password, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, :invalid}

      true ->
        Pbkdf2.no_user_verify()
        {:error, :invalid}
    end
  end

  def list_users_by_ids(ids) do
    Repo.all(from(u in User, where: u.id in ^ids))
  end
end
