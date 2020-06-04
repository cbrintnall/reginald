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
    if String.length(string) > 0 && String.starts_with?(string, "!") do
      String.split(String.slice(string, 1..-1), " ")
    else
      :invalid
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
      ["ping"] ->
        Api.create_message(msg.channel_id, "Pong!")

      ["server" | _tail] ->
        handle_server_command(msg, event)

      _ ->
        :ignore
    end
  end

  # Default event handler, if you don't include this, your consumer WILL crash if
  # you don't have a method definition for each event type.
  def handle_event(_event) do
    :noop
  end
end
