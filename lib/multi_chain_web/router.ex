defmodule MultiChainWeb.Router do
  use MultiChainWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", MultiChainWeb do
    pipe_through :api
  end
end
