defmodule ChatWeb.UserController do
  use ChatWeb, :controller

  @moduledoc """
  The user controller.
  """

  @doc """
  Create a user.

  Returns, in the 'location' HHTP header, the identifier for the user (its name).
  """
  def create(conn, params) do
    case Chat.Users.create(params) do
      {:ok, name} ->
        conn
        |> put_resp_header("location", ChatWeb.Router.Helpers.user_path(conn, :show, name))
        |> send_resp(201, "")
      {:error, error} ->
        conn
        |> send_resp(409, error)
    end
  end
end
