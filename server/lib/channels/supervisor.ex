defmodule Channels.Supervisor do
  require Logger
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def create_channel(name) do
    Supervisor.start_child(__MODULE__, [name])
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
