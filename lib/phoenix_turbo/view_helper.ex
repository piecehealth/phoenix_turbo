defmodule PhoenixTurbo.ViewHelper do
  import Phoenix.HTML.Tag
  import PhoenixTurbo, only: [dom_id: 1]

  @doc """
  Return "trubo-cable-stream-source" tag.

  `<%= turbo_stream_tag @conn, @post %>` would generate
  `<turbo-cable-stream-source channel="posts_1" signed-stream-name="xxxxx"></turbo-cable-stream-source>`
  """
  @spec turbo_stream_tag(Plug.Conn.t(), struct | list | binary) :: {:safe, list()}
  def turbo_stream_tag(conn, streamable)

  def turbo_stream_tag(conn, streamable) when is_struct(streamable) or is_list(streamable) do
    turbo_stream_tag(conn, dom_id(streamable))
  end

  def turbo_stream_tag(conn, streamable) when is_binary(streamable) do
    token = Phoenix.Token.sign(conn, "stream token", streamable)

    content_tag(:"turbo-cable-stream-source", "",
      "signed-stream-name": token,
      channel: streamable
    )
  end
end
