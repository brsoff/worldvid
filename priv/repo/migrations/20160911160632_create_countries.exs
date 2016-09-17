defmodule Worldvid.Repo.Migrations.CreateCountries do
  use Ecto.Migration

  def change do
    create table(:countries) do
      add :name, :string
      add :region_code, :string

      timestamps
    end
  end
end
