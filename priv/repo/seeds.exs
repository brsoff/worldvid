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

api_key = System.get_env("YOUTUBE_API_KEY")
base_api_url = "https://www.googleapis.com/youtube/v3/videos?key=" <> api_key
base_params = Enum.join ["&part=id,snippet", "chart=mostPopular", "maxResults=10"], "&"
base_url = base_api_url <> base_params

countries = Repo.all Country
target_categories = ["1", "10", "17", "23", "25"]

defmodule Seeder do
  @categories File.read("fixtures/categories.json")
              |> elem(1)
              |> Poison.decode!
              |> Map.get("youtubeCategories")

  def get_categories do
    @categories
  end

  def seed_videos country_id, videos, top \\ false do
    Enum.each videos, fn data ->
      video = find_video data["id"]

      video =
        if video === nil do
          insert_video data
        else
          video
        end

      country_video = find_country_video country_id, video.id

      if country_video === nil do
        insert_country_video country_id, video.id, top
      end
    end
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
      category: category
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

  def insert_country_video country_id, video_id, top do
    %CountryVideo{
      country_id: country_id,
      video_id: video_id,
      top: top
    }
    |> Repo.insert!
  end

  def get_category_name category_id do
    cat = Enum.find get_categories, fn c ->
      c["id"] === category_id
    end

    cat["name"]
  end

  def fetch_videos url do
    response = HTTPotion.get url
    Poison.decode!(response.body)["items"]
  end
end

# get general top videos
Enum.each countries, fn country ->
  region_code = country.region_code
  url = base_url <> "&regionCode=" <> region_code
  videos = Seeder.fetch_videos url

  if videos === nil do
    Mix.shell.info("Error: No general data received for country " <> region_code)
  else
    Seeder.seed_videos country.id, videos, true
  end

  # get top videos by category
  Enum.each target_categories, fn id ->
    url = url <> "&videoCategoryId=" <> id
    videos = Seeder.fetch_videos url

    if videos === nil do
      Mix.shell.info("Error: No category data (" <> id <> ") received for country " <> region_code)
    else
      Seeder.seed_videos country.id, videos
    end
  end
end