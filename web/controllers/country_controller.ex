defmodule Worldvid.CountryController do
  require IEx
  use Worldvid.Web, :controller

  alias Worldvid.Country
  alias Worldvid.Repo

  def index(conn, _params) do
    countries = Repo.all Country
    render conn, "index.json", countries: countries
  end

  def show(conn, params) do
    query =
      from c in Country,
      where: c.id == ^params["id"],
      preload: :videos

    [country] = Repo.all query

    render conn, "show.json", country: country
  end
end
