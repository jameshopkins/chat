defmodule Channel do
  @moduledoc """
  Orchestrating channel processes
  """
  require Logger
  use Agent
  alias Channels.Registry, as: Channels

  defstruct content: nil

  def start_link(name) do
    # Logger.info(~s("Started channel #{name}"))
    Agent.start_link(fn -> [] end, name: via_tuple(name))
  end

  def execute_command(command) do
    case command.action do
      "create" -> create_message(command.entity.content, command.entity.channel)
    end
  end

  def create_message(content, channel) do
    Agent.update(via_tuple(channel), fn messages ->
      [{content, :calendar.universal_time()} | messages]
    end)
  end

  def list_messages(name) do
    Agent.get(via_tuple(name), fn messages -> messages end)
  end

  defp via_tuple(name) do
    {:via, Registry, {Channels, name}}
  end
end
