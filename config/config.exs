use Mix.Config

config :reginald,
  external_minecraft_server: System.get_env("minecraft_server_external_base"),
  internal_minecraft_server: System.get_env("minecraft_server_internal_base"),
  discord_minecraft_channel: "minecraft-server",
  server_api_token: System.get_env("api_key"),
  server_api_port: 8080,
  server_port: 25565,
  prefix: "!"

config :nostrum,
  token: System.get_env("bot_token"),
  num_shards: :auto
