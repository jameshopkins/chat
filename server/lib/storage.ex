defmodule Server.Storage do
  require Logger
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def get_all_messages() do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def add_message(msg) do
    Agent.update(__MODULE__, fn state -> [msg | state] end)
  end
end