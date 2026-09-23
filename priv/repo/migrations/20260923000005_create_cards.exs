defmodule Doski.Repo.Migrations.CreateCards do
  use Ecto.Migration

  def change do
    create table(:cards) do
      add :name, :string, null: false
      add :description, :text, null: false, default: ""
      add :position, :integer, null: false, default: 1
      add :list_id, references(:lists, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:cards, [:list_id])
  end
end
