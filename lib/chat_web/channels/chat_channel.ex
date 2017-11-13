defmodule ChatWeb.ChatChannel do
  use ChatWeb, :channel

  @moduledoc """
  The chat application channel; handles incoming messages.
  """

  @doc """
  Handle a request to join a topic.
  """
  def join("chat:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end
  def join("chat:*", _payload, _socket), do: {:error, %{reason: "unauthorized"}}

  @doc """
  Handle a message, currently by broadcasting it to all subscibers to the topic.
  """
  def handle_in("msg" = event, payload, socket) do
    broadcast(socket, event, payload)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload), do: true
end

