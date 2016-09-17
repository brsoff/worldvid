defmodule Mix.Tasks.Worldvid.SeedCountries do
  use Mix.Task
  import Mix.Ecto

  def run(args) do
    # Seed countries into db from JSON file

    Mix.shell.info "Seeding countries..."

    repos = parse_repo args

    countries = File.read("fixtures/countries.json")
                |> elem(1)
                |> Poison.decode!
                |> Map.get("countries")

    Enum.each repos, fn repo ->
      ensure_repo repo, args
      ensure_started repo, all: true
      seed_countries repo, countries
    end

    Mix.shell.info "Done"
  end

  def seed_countries repo, countries do
    Enum.each countries, fn country ->
      Mix.shell.info("Seeding " <> country["name"])

      %Worldvid.Country{
        name: country["name"],
        region_code: country["regionCode"]
      }
      |> repo.insert!
    end
  end
end