defmodule Worldvid.Repo.Migrations.CreateVideos do
  use Ecto.Migration

  def change do
    create table(:videos) do
      add :title, :string
      add :description, :text
      add :youtube_id, :string
      add :thumb_url, :string
      add :category, :string

      timestamps
    end
  end
end
