defmodule Worldvid.Country do
  use Worldvid.Web, :model

  schema "countries" do
    field :name, :string
    field :region_code, :string

    has_many :countries_videos, Worldvid.CountryVideo
    has_many :videos, through: [:countries_videos, :video]

    timestamps
  end
end
