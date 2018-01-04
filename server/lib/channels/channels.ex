defmodule Channels do
  require Logger
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def execute_command(command) do
    case command.action do
      "create" -> create_channel(command)
    end
  end

  def create_channel(command) do
    status = Supervisor.start_child(__MODULE__, [command.entity.content])
    create_message(command, status)
    |> Command.encode
  end

  def create_message(command, {status, _}) do
    status = if (status == :ok), do: "success", else: "failure"
    Map.put(command, :status, status)
  end

  def find_channel(name) do
    case Registry.lookup(Channels.Registry, name) do
      [] -> {:error, :inexistent}
      [{pid, _meta} | _] -> {:ok, pid}
    end
  end

  def channel_exists?(name) do
    case find_channel(name) do
      [] -> false
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
