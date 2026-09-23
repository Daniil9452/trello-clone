defmodule Doski.Fixtures do
  alias Doski.Accounts

  def user_fixture(attrs \\ %{}) do
    unique = System.unique_integer([:positive])

    defaults = %{
      "first_name" => "Анна",
      "last_name" => "Иванова",
      "email" => "user#{unique}@example.com",
      "password" => "parol12345"
    }

    {:ok, user} = Accounts.register_user(Map.merge(defaults, attrs))
    user
  end
end
