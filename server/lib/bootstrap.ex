defmodule Server.Bootstrap do
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      {Server.Storage, []},
      Plug.Adapters.Cowboy.child_spec(:http, Server.Router, [], port: 8080)
    ]

    Logger.info("Started application on 8080")

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end