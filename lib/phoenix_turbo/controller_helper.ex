defmodule PhoenixTurbo.ControllerHelper do
  import Plug.Conn
  import Phoenix.Controller

  @turbo_stream_content_type "text/vnd.turbo-stream.html"

  @doc """
  Return true if it's a "turbo-stream" request.
  E.g. Clicking link or submitting form inside the <turbo-frame> tag.
  """
  @spec turbo_stream_request?(Plug.Conn.t()) :: boolean()
  def turbo_stream_request?(conn) do
    [accept_types] = get_req_header(conn, "accept")
    # `accept_types` is "text/vnd.turbo-stream.html, text/html, application/xhtml+xml"
    String.starts_with?(accept_types, @turbo_stream_content_type)
  end

  @doc """
  The same effect with `Phoenix.Controller.render/3` except subtracting layout and putting turbo stream content type to the HTTP response content type.
  """
  @spec render_turbo_stream(Plug.Conn.t(), binary | atom, Keyword.t() | map | binary | atom) ::
          Plug.Conn.t()
  def render_turbo_stream(conn, template, assigns) do
    conn
    |> put_layout(false)
    |> put_resp_content_type(@turbo_stream_content_type)
    |> render(template, assigns)
  end

  @doc """
  The same effect with `Phoenix.Controller.render/2` except subtracting layout and putting turbo stream content type to the HTTP response content type.
  """
  @spec render_turbo_stream(Plug.Conn.t(), Keyword.t() | map | binary | atom) :: Plug.Conn.t()
  def render_turbo_stream(conn, template_or_assigns) do
    conn
    |> put_layout(false)
    |> put_resp_content_type(@turbo_stream_content_type)
    |> render(template_or_assigns)
  end
end
