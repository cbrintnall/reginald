defmodule Reginald.Webhooks.Router.Minecraft do
  use Plug.Router

  alias Reginald.Handler

  plug(:match)
  plug(:dispatch)

  post "/player/join" do
    msg = """
    ```diff
    + A player has joined the server.
    ```
    """

    Handler.send_server_message(msg)

    conn |> send_resp(201, Poison.encode!(%{}))
  end

  post "/player/leave" do
    msg = """
    ```diff
    - A player has left the server.
    ```
    """

    Handler.send_server_message(msg)

    conn |> send_resp(201, Poison.encode!(%{}))
  end

  # This route could use some clean up
  post "/chat" do
    # This class is invoked when a _player_ speaks, this is different from a server message.
    if conn.body_params["class"] == "org.spongepowered.api.event.MessageChannelEvent$Chat$Impl" do
      receivers = for receiver <- conn.body_params["receivers"], do: receiver["id"]

      if "Server" in receivers do
        internal = conn.body_params["message"]

        msg = "**Server Chat:**\n`#{internal}`"

        Handler.send_server_message(msg)

        conn |> send_resp(200, Poison.encode!(%{}))
      else
        conn |> send_resp(204, Poison.encode!(%{}))
      end
    else
      conn |> send_resp(204, Poison.encode!(%{}))
    end
  end

  # noop for now, this is fired when players leave oddly enough.
  post "/player/death" do
    conn |> send_resp(404, Poison.encode!(%{message: "Not found"}))
  end

  match _ do
    conn |> send_resp(404, Poison.encode!(%{message: "Not found"}))
  end

  defp message do
    %{
      text: "Hello world."
    }
  end

  def minecraft(conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(message()))
  end
end

defmodule Reginald.Webhooks.Endpoint do
  use Plug.Router

  @moduledoc """
    Not to be confused with Discord server commands,
    this is used as an endpoint for capturing arbitrary 
    incoming webhooks, which can be used for other things.
  """

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  forward("/minecraft", to: Reginald.Webhooks.Router.Minecraft)

  # If the request falls through, match here.
  match _ do
    conn |> send_resp(404, Poison.encode!(%{message: "Not found"}))
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(_opts) do
    Plug.Cowboy.http(__MODULE__, [])
  end
end