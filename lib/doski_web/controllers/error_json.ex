defmodule DoskiWeb.ErrorJSON do
  def render("404.json", _assigns), do: %{error: "Не найдено"}
  def render("500.json", _assigns), do: %{error: "Внутренняя ошибка сервера"}

  def render(template, _assigns) do
    %{error: Phoenix.Controller.status_message_from_template(template)}
  end
end
