defmodule Worldvid.Video do
  use Worldvid.Web, :model

  schema "videos" do
    field :title, :string
    field :description, :string
    field :youtube_id, :string
    field :thumb_url, :string
    field :category, :string
    field :view_count, :integer

    has_many :countries_videos, Worldvid.CountryVideo
    has_many :countries, through: [:countries_videos, :country]

    timestamps
  end
end
