defmodule DoskiWeb.SessionControllerTest do
  use DoskiWeb.ConnCase, async: true

  import Doski.Fixtures

  test "вход возвращает токен", %{conn: conn} do
    user = user_fixture(%{"email" => "login@example.com"})

    conn =
      post(conn, "/api/sessions", %{
        session: %{email: user.email, password: "parol12345"}
      })

    assert %{"token" => token, "user" => %{"email" => "login@example.com"}} =
             json_response(conn, 200)

    assert is_binary(token)
  end

  test "закрытый маршрут без токена отвечает 401", %{conn: conn} do
    conn = get(conn, "/api/boards")
    assert json_response(conn, 401)["error"] == "Требуется авторизация"
  end

  test "владелец создаёт список и карточку", %{conn: conn} do
    user = user_fixture()
    conn = auth_conn(conn, user)

    conn = post(conn, "/api/boards", %{board: %{name: "Практика", color: "#519839"}})
    assert %{"board" => %{"id" => board_id}} = json_response(conn, 201)

    conn =
      post(recycle(conn) |> auth_conn(user), "/api/boards/#{board_id}/lists", %{
        list: %{name: "В работе"}
      })

    assert %{"list" => %{"id" => list_id, "name" => "В работе"}} = json_response(conn, 201)

    conn =
      post(recycle(conn) |> auth_conn(user), "/api/lists/#{list_id}/cards", %{
        card: %{name: "Проверить каналы"}
      })

    assert %{"card" => %{"name" => "Проверить каналы"}} = json_response(conn, 201)
  end
end
