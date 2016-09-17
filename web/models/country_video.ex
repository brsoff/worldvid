defmodule Worldvid.CountryVideo do
  use Worldvid.Web, :model

  schema "countries_videos" do
    belongs_to :country, Worldvid.Country
    belongs_to :video, Worldvid.Video
    field :top, :boolean

    timestamps
  end
end
