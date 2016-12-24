# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Worldvid.Repo.insert!(%Worldvid.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

import Ecto.Query, only: [from: 2]

alias Worldvid.Country
alias Worldvid.Video
alias Worldvid.CountryVideo
alias Worldvid.Repo

defmodule VideosSeeder do
  @categories File.read("fixtures/categories.json")
              |> elem(1)
              |> Poison.decode!
              |> Map.get("youtubeCategories")

  def get_categories do
    @categories
  end

  def seed_videos country_id, videos do
    videos
    |> Stream.with_index
    |> Enum.each(fn data ->
      position = elem(data, 1) + 1
      video_data = elem(data, 0)
      video = find_video video_data["id"]

      video =
        if video === nil do
          insert_video video_data
        else
          video
        end

      country_video = find_country_video country_id, video.id

      if country_video === nil do
        insert_country_video country_id, video.id, position
      end
    end)
  end

  def find_video youtube_id do
    query = from v in Video,
            where: v.youtube_id == ^youtube_id,
            select: v

    Repo.one query
  end

  def insert_video data do
    snippet = data["snippet"]
    category = get_category_name snippet["categoryId"]

    %Video{
      title: snippet["title"],
      description: snippet["description"],
      youtube_id: data["id"],
      thumb_url: snippet["thumbnails"]["standard"]["url"],
      category: category,
      view_count: parse_view_count(data["statistics"]["viewCount"])
    }
    |> Repo.insert!
  end

  def find_country_video country_id, video_id do
    query = from cv in CountryVideo,
            where: cv.country_id == ^country_id,
            where: cv.video_id == ^video_id,
            select: cv

    Repo.one query
  end

  def insert_country_video country_id, video_id, position do
    %CountryVideo{
      country_id: country_id,
      video_id: video_id,
      position: position
    }
    |> Repo.insert!
  end

  def get_category_name category_id do
    cat = Enum.find get_categories, fn c ->
      c["id"] === category_id
    end

    cat["name"]
  end

  defp parse_view_count(view_count) do
    if view_count !== nil do
      elem(Integer.parse(view_count), 0)
    else
      nil
    end
  end
end

defmodule CountriesSeeder do
  def seed do
    Mix.shell.info "Seeding countries..."

    countries = File.read("fixtures/countries.json")
                |> elem(1)
                |> Poison.decode!
                |> Map.get("countries")

    start countries
  end

  defp start countries do
    Enum.each countries, fn country ->
      Mix.shell.info("Seeding " <> country["name"])

      %Worldvid.Country{
        name: country["name"],
        region_code: country["regionCode"]
      }
      |> Repo.insert!
    end
  end
end

CountriesSeeder.seed

api_key = System.get_env("YOUTUBE_API_KEY")
base_api_url = "https://www.googleapis.com/youtube/v3/videos?key=" <> api_key

full_url = Enum.join([
  base_api_url,
  "part=id,snippet,statistics",
  "chart=mostPopular",
  "maxResults=50"
  ], "&")

countries = Repo.all Country

Enum.each countries, fn country ->
  region_code = country.region_code
  url = full_url <> "&regionCode=" <> region_code
  response = HTTPotion.get url
  videos = Poison.decode!(response.body)["items"]

  if videos === nil do
    Mix.shell.info("Error: No data received for country " <> region_code)
  else
    VideosSeeder.seed_videos country.id, videos
  end
end