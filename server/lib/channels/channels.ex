defmodule Channels do
  require Logger
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def execute_command(command) do
    task = case command.action do
      "create" -> &create_channel/1
    end
    task.(command) |> Command.mark_transation_status(command)
  end

  def create_channel(command) do
    {status, _} = Supervisor.start_child(__MODULE__, [command.entity.content])
    status
  end

  def find_channel(name) do
    case Registry.lookup(Channels.Registry, name) do
      [] -> {:error, :inexistent}
      [{pid, _meta} | _] -> {:ok, pid}
    end
  end

  def channel_exists?(name) do
    case find_channel(name) do
      {:error, _} -> false
      _ -> true
    end
  end

  def init(_) do
    children = [
      worker(Channel, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
