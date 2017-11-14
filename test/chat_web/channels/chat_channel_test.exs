defmodule ChatWeb.ChatChannelTest do
  use ChatWeb.ChannelCase

  alias ChatWeb.ChatChannel

  setup do
    {:ok, _, socket} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(ChatChannel, "chat:lobby")

    {:ok, socket: socket}
  end

  test "msg broadcasts to chat:lobby", %{socket: socket} do
    push(socket, "msg", %{"hello" => "all"})
    assert_broadcast("msg", %{"hello" => "all"})
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from!(socket, "broadcast", %{"some" => "data"})
    assert_push("broadcast", %{"some" => "data"})
  end
end
