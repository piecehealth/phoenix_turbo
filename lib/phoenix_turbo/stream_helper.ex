defmodule PhoenixTurbo.StreamHelper do
  @moduledoc """
  Broadcast stream updates to websockt clients.

  ## Setup
  1. Add `use PhoenixTurbo.StreamHelper` to `[my_app]lib/[my_app]_web/endpoint.ex`
  2. Add `channel "turbo-streams:*", PhoenixTurbo.Channel` to `[my_app]/lib/[my_app]_web/channels/user_socket.ex
  3. Add javascript code to your javascript bundle (see README.md)

  ## Usage
  1. Add `<%= turbo_stream_tag(@conn, @post) %>` to you template file.
  2. Broadcast changes from anywhere:
  ```
  YourApp.Endpoint.update_stream(post, MyApp.PostView, "create_turbo_stream.html", post: post)
  ```
  """
  defmacro __using__(_) do
    quote do
      import PhoenixTurbo, only: [dom_id: 1]

      def update_stream(streamable, view, template_name, assigns) do
        html = Phoenix.View.render_to_string(view, template_name, assigns)
        broadcast("turbo-streams:#{dom_id(streamable)}", "update_stream", %{data: html})
      end

      def update_stream!(streamable, view, template_name, assigns) do
        html = Phoenix.View.render_to_string(view, template_name, assigns)
        broadcast!("turbo-streams:#{dom_id(streamable)}", "update_stream", %{data: html})
      end
    end
  end
end
