defmodule Bootstrap do
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      {Channels.Supervisor, []},
      {WebSocketServer, []},
      Plug.Adapters.Cowboy.child_spec(:http, Router, [], port: 8080),
      {Registry, [keys: :unique, name: Channels.Registry]}
    ]

    Logger.info("Started application on 8080")

    Supervisor.start_link(children, strategy: :one_for_one, name: __MODULE__)
  end
end