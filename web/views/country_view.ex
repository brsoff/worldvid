defmodule Worldvid.CountryView do
  use Worldvid.Web, :view

  def render("index.json", %{countries: countries}) do
    %{countries: Enum.map(countries, &country_json/1)}
  end

  def render("show.json", %{country: country}) do
    %{country: show_json country }
  end

  def country_json country do
    %{
      id: country.id,
      name: country.name,
      regionCode: country.region_code
    }
  end

  def video_json video do
    %{
      id: video.id,
      name: video.title,
      youtubeId: video.youtube_id,
      thumbUrl: video.thumb_url,
      category: video.category
    }
  end

  def show_json country do
    videos =  Enum.map(country.videos, &video_json/1)
    base = country_json country

    Map.put(base, :videos, videos)
  end
end