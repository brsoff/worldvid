defmodule Worldvid.CountryController do
  use Worldvid.Web, :controller

  alias Worldvid.Country
  alias Worldvid.Video
  alias Worldvid.Repo

  def index(conn, _params) do
    countries = Repo.all Country
    render conn, "index.json", countries: countries
  end

  def show(conn, params) do
    query =
      from v in Video,
      join: cv in assoc(v, :countries_videos),
      where: cv.country_id == ^params["id"],
      order_by: [asc: cv.position],
      preload: [countries_videos: cv]

    videos = Repo.all query

    render conn, "show.json", videos: videos
  end
end
