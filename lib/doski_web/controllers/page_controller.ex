defmodule DoskiWeb.PageController do
  use DoskiWeb, :controller

  def index(conn, _params) do
    path = conn.path_info

    if path != [] and Enum.any?(path, &String.contains?(&1, ".")) do
      send_resp(conn, 404, "Не найдено")
    else
      send_index(conn)
    end
  end

  defp send_index(conn) do
    file = Application.app_dir(:doski, "priv/static/index.html")

    if File.exists?(file) do
      conn
      |> put_resp_content_type("text/html")
      |> send_file(200, file)
    else
      html = """
      <!doctype html>
      <html lang="ru"><meta charset="utf-8"><title>Trello Clone</title>
      <body style="font-family:sans-serif;padding:2rem">
      <h1>Trello Clone</h1>
      <p>Интерфейс ещё не собран. В разработке откройте <a href="http://localhost:8080">http://localhost:8080</a>.</p>
      </body></html>
      """

      conn
      |> put_resp_content_type("text/html")
      |> send_resp(200, html)
    end
  end
end
