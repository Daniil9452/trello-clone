defmodule Doski.AccountsTest do
  use Doski.DataCase, async: true

  alias Doski.Accounts

  test "регистрация и вход по почте" do
    assert {:ok, user} =
             Accounts.register_user(%{
               "first_name" => "Олег",
               "last_name" => "Смирнов",
               "email" => "Oleg@Example.com",
               "password" => "parol12345"
             })

    assert user.email == "oleg@example.com"
    assert {:ok, logged_in} = Accounts.authenticate("oleg@example.com", "parol12345")
    assert logged_in.id == user.id
    assert {:error, :invalid} = Accounts.authenticate("oleg@example.com", "неверный")
  end

  test "короткий пароль не принимается" do
    assert {:error, changeset} =
             Accounts.register_user(%{
               "first_name" => "Олег",
               "last_name" => "Смирнов",
               "email" => "short@example.com",
               "password" => "123"
             })

    assert "минимум 8 символов" in errors_on(changeset).password
  end

  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
  end
end
