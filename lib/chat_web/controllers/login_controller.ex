defmodule ChatWeb.LoginController do
  use ChatWeb, :controller

  @moduledoc """
  The login controller.
  """

  @doc """
  Create a login.

  Returns, in the 'location' HHTP header, the login token.
  """
  def create(conn, %{"name" => name, "password" => password}) do
    case Chat.Users.read(name) do
      {:ok, %{"name" => ^name, "password" => ^password}} ->
        token = Phoenix.Token.sign(ChatWeb.Endpoint, "user token salt", name)
        conn
        |> put_resp_header("location", ChatWeb.Router.Helpers.login_path(conn, :show, token))
        |> send_resp(201, "")
      _ ->
        conn
        |> send_resp(404, "login failed")
    end
  end
end
