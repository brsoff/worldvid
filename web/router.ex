defmodule Worldvid.Router do
  use Worldvid.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Worldvid do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api", Worldvid do
    pipe_through :api

    get "/countries", CountryController, :index
    get "/countries/:id/videos", CountryController, :show
  end
end