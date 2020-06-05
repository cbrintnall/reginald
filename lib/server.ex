defmodule Reginald.Handler.Server do
  alias Nostrum.Api

  def up(msg) do
    internal = Application.fetch_env!(:reginald, :internal_minecraft_server)
    port = Application.fetch_env!(:reginald, :server_api_port)
    token = Application.fetch_env!(:reginald, :server_api_token)
    url = "http://#{internal}:#{port}/api/v5/info/stats"
    headers = ["X-WebAPI-Key": token, Accept: "Application/json; Charset=utf-8"]

    HTTPoison.start()
    resp = HTTPoison.get!(url, headers, [])

    case resp do
      %{status_code: 200} ->
        Api.create_message(msg.channel_id, "Server is operational.")

      _ ->
        Api.create_message(msg.channel_id, "Could not reach server!")
    end
  end

  def ip(msg) do
    Api.create_message(
      msg.channel_id,
      "Server ip is #{Application.fetch_env!(:reginald, :external_minecraft_server)}."
    )
  end

  def send_chat(message) do
    internal = Application.fetch_env!(:reginald, :internal_minecraft_server)
    port = Application.fetch_env!(:reginald, :server_api_port)
    token = Application.fetch_env!(:reginald, :server_api_token)
    url = "http://#{internal}:#{port}/api/v5/cmd"
    headers = [ "X-WebAPI-Key": token, "Content-Type": "Application/json; Charset=utf-8" ]

    HTTPoison.start()
    resp = HTTPoison.post!(
      url,
      Poison.encode!([
        %{
          "command": "say #{message}",
          "name": "say"
        }
      ]),
      headers
    )
  end
end
