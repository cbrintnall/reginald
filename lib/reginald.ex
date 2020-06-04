defmodule Reginald.Supervisor do
  use Supervisor

  @moduledoc """
    A supervisor that watches over the Discord bot, 
    and the webhook server.
  """

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    children = [
      Supervisor.child_spec({Reginald.Handler, []}, id: {:reginald, :handler, 0}),
      Supervisor.child_spec({Reginald.Webhooks.Endpoint, []}, id: {:reginald, :webhooks, 0})
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

defmodule Reginald.Application do
  use Application

  @moduledoc """
    The entrypoint for Reginald.
  """

  @impl true
  def start(_type, _args) do
    children = [
      Reginald.Supervisor
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
