defmodule Reginald.Handler do
  use Nostrum.Consumer

  alias Reginald.Handler.Server
  alias Nostrum.Api

  def start_link do
    Consumer.start_link(__MODULE__, max_restarts: 0)
  end

  def send_server_message(msg) do
    # Probably a simpler way to do the following couple lines.
    {:ok, guilds} = Api.get_current_user_guilds()
    guilds = for guild <- guilds, do: guild.id

    notify_guild_channels(guilds, msg)
  end

  defp notify_guild_channels(guilds, msg) do
    case guilds do
      [target | rest] ->
        {:ok, channels} = Api.get_guild_channels(target)

        is_target = fn channel ->
          channel.name == Application.fetch_env!(:reginald, :discord_minecraft_channel)
        end

        channels = for channel <- channels, is_target.(channel), do: channel.id

        case channels do
          [ele | _] -> Api.create_message(ele, msg)
          _ -> []
        end

        notify_guild_channels(rest, msg)

      _ ->
        []
    end
  end

  defp validate(string) do
    prefix = Application.fetch_env!(:reginald, :prefix)

    cond do
      # A string whose first character is <prefix> is a command
      String.length(string) > 0 && String.starts_with?(string, prefix) -> 
        { :command, String.split(String.slice(string, 1..-1), " ") }
      
      # Otherwise take in the full text from the server, this gets sent to the minecraft chat
      String.length(string) > 0 -> { :chat, string }
    end
  end

  defp handle_server_command(msg, cmd) do
    case args = cmd |> Enum.slice(1, Kernel.length(cmd) - 1) do
      ["up"] -> Server.up(msg)
      ["ip"] -> Server.ip(msg)
      _ -> IO.puts(args)
    end
  end

  @impl true
  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    case event = validate(msg.content) do
      { :command,  ["ping"] } ->
        Api.create_message(msg.channel_id, "Pong!")

      { :command, ["help"] } ->
        Api.create_message(msg.channel_id, "Help yourself.")

      { :command, ["source"] } ->
        Api.create_message(msg.channel_id, "Here you go:\n `#{Application.fetch_env!(:reginald, :source)}`")

      { :command, ["server" | _tail] } ->
        handle_server_command(msg, event)

      { :chat, message } -> 
        if !invalid_chat(msg) do
          handle_chat(msg)
        end

      _ ->
        :ignore
    end
  end

  # Default event handler, if you don't include this, your consumer WILL crash if
  # you don't have a method definition for each event type.
  def handle_event(_event) do
    :noop
  end

  defp handle_chat(msg) do
    %{ author: %{ username: user }, content: message } = msg

    Server.send_chat("§d§lDiscord §d§l(§r#{user}§d§l): #{message}")
  end

  defp invalid_chat(msg) do
    %{ author: %{ bot: is_valid } } = msg

    is_valid || false
  end
end
