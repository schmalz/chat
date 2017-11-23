defmodule Chat.Users do
  use GenServer
  require Logger

  @moduledoc """
  A simple store of users.
  """

  # Client API

  def start_link(), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  @doc """
  Create a user.
  """
  def create(user), do: GenServer.call(__MODULE__, {:create, user})

  @doc """
  Read a user given its `name`.
  """
  def read(name), do: GenServer.call(__MODULE__, {:read, name})

  # Callbacks

  def init(_arg), do: {:ok, nil}

  def handle_call({:create, %{"name" => name} = user}, _from, _data) do
    case read_user(name) do
      %{} -> {:reply, {:ok, create_user(user)}, nil}
      _ -> {:reply, {:error, "name exists"}, nil}
    end
  end
  def handle_call({:read, name}, _from, _data), do: {:reply, {:ok, read_user(name)}, nil}
  def handle_call(_, _from, _data), do: {:reply, {:error, "unrecognised request"}, nil}

  # Private functions

  defp create_user(%{"name" => name, "password" => password}) do
    case Redix.command(:redix, ["HMSET", name, "name", name, "password", password, "created", DateTime.utc_now()]) do
      {:ok, _} -> name
      _ -> nil
    end
  end

  defp read_user(name) do
    case Redix.command(:redix, ["HGETALL", name]) do
      {:ok, []} ->
        %{}
      {:ok, attrs} ->
        to_user(attrs)
      {_, error} ->
      Logger.warn(fn() -> "failed to read user, #{inspect(error)}" end)
        nil
    end
  end

  defp to_user(attrs) do
    attrs
    |> Stream.chunk_every(2)
    |> Enum.into(%{}, fn([k, v]) -> {k, v} end)
  end
end
