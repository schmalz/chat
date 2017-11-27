defmodule ChatWeb.ChatChannel do
  use ChatWeb, :channel

  @moduledoc """
  The chat application channel; handles incoming messages.

  This is the simplest chat server that could work, it allows unfettered access to the lobby and simply broadcasts all
  messages it receives.
  """

  @doc """
  Handle a request to join a topic.
  """
  def join("chat:lobby", payload, socket) do
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
    broadcast(socket, event, Map.put(payload, "name", socket.assigns.name))
    {:noreply, socket}
  end

  @doc """
  Handle an information message.
  """
  def handle_info(:after_join, socket) do
    push(socket, "presence_state", ChatWeb.ChatPresence.list(socket))
    {:ok, _} = ChatWeb.ChatPresence.track(socket, socket.assigns.name, %{
      online_at: inspect(System.system_time(:seconds))
    })
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload), do: true
end
