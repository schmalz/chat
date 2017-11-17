defmodule ChatWeb.ChatPresence do
  use Phoenix.Presence, otp_app: :chat,
                        pubsub_server: Chat.PubSub

  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](http://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
end
