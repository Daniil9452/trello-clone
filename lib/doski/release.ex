defmodule Doski.Release do
  @moduledoc false

  @app :doski

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def seed do
    load_app()

    {:ok, _, _} =
      Ecto.Migrator.with_repo(Doski.Repo, fn _repo ->
        Doski.Seeds.run()
      end)
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
