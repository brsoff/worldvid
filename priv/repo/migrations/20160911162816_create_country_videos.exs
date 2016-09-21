defmodule Worldvid.Repo.Migrations.CreateCountryVideos do
  use Ecto.Migration

  def change do
    create table(:countries_videos) do
      add :video_id, :integer
      add :country_id, :integer
      add :position, :integer

      timestamps
    end

    create index(:countries_videos, [:video_id, :country_id])
  end
end
