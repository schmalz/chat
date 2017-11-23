defmodule ChatWeb.Router do
  use ChatWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ChatWeb do
    pipe_through :api

    resources "/users", UserController, only: [:create, :show]
    resources "/logins", LoginController, only: [:create, :show]
  end
end
