defmodule PhoenixTurbo do
  @moduledoc """
  Use Turbo in your Phoenix app.
  """

  @doc """
  import `PhoenixTurbo.ControllerHelper`.
  """
  def controller do
    quote do
      import PhoenixTurbo, only: [dom_id: 1]
      import PhoenixTurbo.ControllerHelper
    end
  end

  @doc """
  import `PhoenixTurbo.ViewHelper`.
  """
  def view do
    quote do
      import PhoenixTurbo, only: [dom_id: 1]
      import PhoenixTurbo.ViewHelper
    end
  end

  @doc """
  Define plug method `turbo_frame`. Remove the layout if it's a turbo-frame request.
  """
  def router do
    quote do
      defp handle_turbo_frame(conn, _opts) do
        if length(get_req_header(conn, "turbo-frame")) > 0 do
          put_layout(conn, false)
        else
          conn
        end
      end
    end
  end

  @doc false
  def channel do
    quote do: nil
  end

  @doc """
  See `PhoenixTurbo.dom_id/1`.
  """
  def dom_id(streamable, prefix) do
    "#{prefix}_#{dom_id(streamable)}"
  end

  @doc """
  Convert string/list/ecto struct to string.

    ## Examples

      dom_id("posts")                     # => "posts"
      dom_id(%Post{id: 1})                # => "posts_1"
      dom_id(%Post{})                     # => "posts_new"
      dom_id([%Post{id: 1}, %Comment{}])  # => "posts_id_comments_new"
  """
  def dom_id(streamable) when is_binary(streamable) do
    String.replace(streamable, ~r/\s/, "_")
  end

  def dom_id(%{__meta__: %{source: table_name}, id: id}) do
    "#{table_name}_#{id || "new"}"
  end

  def dom_id(streamable_list) when is_list(streamable_list) do
    streamable_list
    |> Enum.map(&dom_id(&1))
    |> Enum.join("_")
  end
end
