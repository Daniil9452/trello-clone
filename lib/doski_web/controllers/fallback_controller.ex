defmodule DoskiWeb.FallbackController do
  use DoskiWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{errors: DoskiWeb.JSON.errors(changeset)})
  end

  def call(conn, {:error, :not_found}) do
    conn |> put_status(:not_found) |> json(%{error: "Не найдено"})
  end

  def call(conn, {:error, :forbidden}) do
    conn |> put_status(:forbidden) |> json(%{error: "Недостаточно прав"})
  end

  def call(conn, {:error, :user_not_found}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "Пользователь с такой почтой не найден"})
  end

  def call(conn, {:error, :already_member}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "Пользователь уже есть на доске"})
  end

  def call(conn, {:error, :is_owner}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "Владелец уже имеет доступ к доске"})
  end

  def call(conn, {:error, :invalid}) do
    conn |> put_status(:unprocessable_entity) |> json(%{error: "Некорректные данные"})
  end

  def not_found(conn, _params) do
    conn |> put_status(:not_found) |> json(%{error: "Не найдено"})
  end
end
