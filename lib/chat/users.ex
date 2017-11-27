defmodule Chat.Users do
  use GenServer

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

  def init(_arg), do: {:ok, %{}}

  def handle_call({:create, %{"name" => name} = new_user}, _from, users) do
    case is_known?(name) do
      false ->
        user = create_user(new_user)
        {:reply, {:ok, name}, Map.put(users, name, user)}
      true -> {:reply, {:error, "name exists"}, users}
    end
  end
  def handle_call({:read, name}, _from, users) do
    user = read_user(name, users)
    {:reply, {:ok, user}, Map.put_new(users, name, user)}
  end
  def handle_call(_, _from, users), do: {:reply, {:error, "unrecognised request"}, users}

  # Private functions

  defp is_known?(name) do
    case Redix.command!(:redix, ["HEXISTS", name, "name"]) do
      1 -> true
      _ -> false
    end
  end

  defp create_user(%{"name" => name, "password" => password}) do
    case Redix.command(:redix, ["HMSET", name, "name", name, "password", password, "created", DateTime.utc_now()]) do
      {:ok, _} -> name
      _ -> nil
    end
  end

  defp read_user(name, users) do
    if Map.has_key?(users, name) do
      Map.get(users, name)
    else
      case Redix.command(:redix, ["HGETALL", name]) do
        {:ok, []} ->
          %{}
        {:ok, attrs} ->
          to_user(attrs)
        {_, _error} ->
          nil
      end
    end
  end

  defp to_user(hash_fields) do
    hash_fields
    |> Stream.chunk_every(2)
    |> Enum.into(%{}, fn([k, v]) -> {k, v} end)
  end
end
