defmodule Mix.Tasks.Worldvid.MatchCategories do
  def run(_args) do
    # matches countries with their youtube category ids

    HTTPotion.start

    categories = ["Music", "Comedy", "News & Politics", "Sports", "Movies"]

    countries = File.read("fixtures/countries.json")
                |> elem(1)
                |> Poison.decode!
                |> Map.get("countries")

    map = Enum.map countries, fn country ->
      key = System.get_env("YOUTUBE_API_KEY")
      base_url = "https://www.googleapis.com/youtube/v3/videoCategories?key=" <> key
      region_code = country["regionCode"]
      params = "&part=snippet&regionCode=" <> region_code
      url = base_url <> params

      Mix.shell.info "Fetching category data for " <> region_code <> "..."

      response = HTTPotion.get url
      items = Poison.decode!(response.body)["items"]

      country_categories = Enum.map categories, fn category ->
        cat = get_category items, category
        m = Map.new

        if cat === nil do
          Mix.shell.info "category " <> cat <> " not found in " <> region_code
          Map.put(m, category, "")
        else
          Map.put(m, category, cat["id"])
        end
      end

      Map.put(country, "categories", country_categories)
    end

    File.write("priv/static/json/countries.json", Poison.encode!(map))

    Mix.shell.info "Done"
  end

  def get_category items, category do
    Enum.find items, fn item ->
      item["snippet"]["title"] === category
    end
  end
end