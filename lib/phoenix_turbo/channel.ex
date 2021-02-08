defmodule PhoenixTurbo.Channel do
  use Phoenix.Channel

  @doc """
  The channel that is used for tracking stream updates.
  Add `channel "turbo-streams:*", PhoenixTurbo.Channel` to `[my_app]/lib/[my_app]_web/channels/user_socket.ex

  See `PhoenixTurbo.StreamHelper` for more information.
  """
  def join("turbo-streams:" <> channel, %{"sign" => sign}, socket) do
    case Phoenix.Token.verify(socket, "stream token", sign, max_age: 86400) do
      {:ok, ^channel} -> {:ok, socket}
      {:error, reason} -> {:error, %{reason: reason}}
      _ -> {:error, %{reason: :invalid}}
    end
  end
end
