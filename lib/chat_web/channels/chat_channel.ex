defmodule ChatWeb.ChatChannel do
  use ChatWeb, :channel
  require Logger

  @moduledoc """
  The chat application channel; handles incoming messages.

  This is the simplest chat server that could work, it allows unfettered access to the lobby and simply broadcasts all
  messages it receives.
  """

  @doc """
  Handle a request to join a topic.
  """
  def join("chat:lobby", payload, socket) do
    Logger.debug(fn() -> "++ join(#{inspect(payload)}, #{inspect(socket)})" end)
    if authorized?(payload) do
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end
  def join("chat:*", _payload, _socket), do: {:error, %{reason: "unauthorized"}}

  @doc """
  Handle a message, currently by broadcasting it to all subscribers to the topic.
  """
  def handle_in("msg" = event, payload, socket) do
    Logger.debug(fn() -> "++ handle_in(#{inspect(event)}, #{inspect(payload)}, #{inspect(socket)})" end)
    Logger.debug(fn() -> "socket.assigns.name #{inspect(socket.assigns.name)}" end)
    broadcast(socket, event, Map.put(payload, "name", socket.assigns.name))
    {:noreply, socket}
  end

  @doc """
  Handle an information message.
  """
  def handle_info(:after_join, socket) do
    Logger.debug(fn() -> "++ handle_info(:after_join, #{inspect(socket)})" end)
    push(socket, "presence_state", ChatWeb.ChatPresence.list(socket))
    Logger.debug(fn() -> "socket.assigns.name #{inspect(socket.assigns.name)}" end)
    {:ok, _} = ChatWeb.ChatPresence.track(socket, socket.assigns.name, %{
      online_at: inspect(System.system_time(:seconds))
    })
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload), do: true
end
