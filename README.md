# PhoenixTurbo

Use [Turbo](https://hotwire.dev/) in your Phoenix app. [Sample App](https://github.com/piecehealth/phoenix_turbo_chat)

## Installation
1. Add PhoenixTurbo to your list of dependencies in mix.exs:

```elixir
def deps do
  [
    {:phoenix_turbo, "~> 0.1.0"}
  ]
end
```

2. [Install Turbo via npm](https://turbo.hotwire.dev/handbook/installing#as-an-npm-package)
3. [Install Stimulus](https://stimulus.hotwire.dev/handbook/installing#using-webpack) (Optional) 

## Setup
in `lib/[my_app]_web.ex`
```diff
   @doc """
   When used, dispatch to the appropriate controller/view/etc.
   """
   defmacro __using__(which) when is_atom(which) do
-    apply(__MODULE__, which, [])
+    quote do
+      unquote(apply(__MODULE__, which, []))
+      unquote(apply(PhoenixTurbo, which, []))
+    end
   end
 end
```
in `lib/[my_app]_web/endpoint.ex`
```diff
 defmodule MyAppWeb.Endpoint do
   use Phoenix.Endpoint, otp_app: :chat
+  use PhoenixTurbo.StreamHelper
```
in `lib/[my_app]_web/channels/user_socket.ex`
```diff
 defmodule MyAppWeb.UserSocket do
   use Phoenix.Socket

+  channel "turbo-streams:*", PhoenixTurbo.Channel
+
   ## Channels
   # channel "room:*", ChatWeb.RoomChannel
```
in `lib/[my_app]_web/router.ex`
```diff
   pipeline :browser do
     plug :accepts, ["html"]
     plug :fetch_session
     plug :fetch_flash
     plug :protect_from_forgery
     plug :put_secure_browser_headers
+    plug :handle_turbo_frame
   end
```
Add javascript file:
```js
// cable_stream_source_element.js
import { connectStreamSource, disconnectStreamSource } from "@hotwired/turbo"
import socket from "./socket"

class TurboCableStreamSourceElement extends HTMLElement {
  connectedCallback() {
    connectStreamSource(this)
    const channelName = this.getAttribute("channel")
    const sign = this.getAttribute("signed-stream-name")
    this.channel = socket.channel(`turbo-streams:${channelName}`, { sign })
    this.channel.join()
    this.channel.on("update_stream", ({ data }) => {
      this.dispatchMessageEvent(data)
    })
  }

  disconnectedCallback() {
    disconnectStreamSource(this)
    if (this.channel) this.channel.leave()
  }

  dispatchMessageEvent(data) {
    const event = new MessageEvent("message", { data })
    return this.dispatchEvent(event)
  }
}

customElements.define("turbo-cable-stream-source", TurboCableStreamSourceElement)
```

## Usage:
### Controller helpers
1. `turbo_stream_request?/1`: Return true if it's a "turbo-stream" request.
2. `render_turbo_stream`: Render `turbo_stream` template. The same effect with `Phoenix.Controller.render/3` except subtracting layout and putting turbo stream content type to the HTTP response content type.

```elixir
defmodule ChatWeb.MessageController do
  use ChatWeb, :controller

  alias Chat.Rooms
  alias Chat.Rooms.Message

  plug :set_room

  def create(conn, %{"message" => message_params}) do
    room = conn.assigns.room
    message = Rooms.create_message!(Map.put(message_params, "room_id", room.id))

    if turbo_stream_request?(conn) do                                         # <- turbo_stream_request?
      render_turbo_stream(conn, "create_turbo_stream.html", message: message) # <- render_turbo_stream
    else
      redirect(conn, to: Routes.room_path(conn, :show, conn.assigns.room))
    end
  end

  defp set_room(conn, _) do
    room_id = conn.params["room_id"]
    room = Rooms.get_room!(room_id)
    assign(conn, :room, room)
  end
end
```

### View helpers
`turbo_stream_tag`: `<%= turbo_stream_tag @conn, @post %>` would generate
```html
<turbo-cable-stream-source channel="posts_1" signed-stream-name="xxxxx"></turbo-cable-stream-source>
```
which will work with `cable_stream_source_element.js`

### Others
`MyApp.Endpoint.update_stream`: Send stream updates via websocket.
```elixir
defmodule ChatWeb.MessageController do
  use ChatWeb, :controller

  alias Chat.Rooms
  alias Chat.Rooms.Message

  plug :set_room

  def create(conn, %{"message" => message_params}) do
    room = conn.assigns.room
    message = Rooms.create_message!(Map.put(message_params, "room_id", room.id))

    if turbo_stream_request?(conn) do
      ChatWeb.Endpoint.update_stream(               # <-- send stream updates
        room,                                       # <-- send stream updates
        ChatWeb.MessageView,                        # <-- send stream updates
        "create_turbo_stream.html",                 # <-- send stream updates
        message: message                            # <-- send stream updates
      )                                             # <-- send stream updates
      send_resp(conn, 201, message.content)
    else
      redirect(conn, to: Routes.room_path(conn, :show, conn.assigns.room))
    end
  end

  defp set_room(conn, _) do
    room_id = conn.params["room_id"]
    room = Rooms.get_room!(room_id)
    assign(conn, :room, room)
  end
end

```

## References
* [Turbo official homepage](https://hotwire.dev/)
* [Sample App](https://github.com/piecehealth/phoenix_turbo_chat)
* [HexDocs](https://hexdocs.pm/phoenix_turbo)
