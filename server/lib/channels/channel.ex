defmodule Channel do
  @moduledoc """
  Orchestrating channel processes
  """
  require Logger
  use Agent
  alias Channels.Registry, as: Channels

  def start_link(name) do
    Agent.start_link(fn -> [] end, name: via_tuple(name))
  end

  def add_message(name, content) do
    new_message = %Message{
      created_at: :calendar.universal_time(),
      content: content
    }

    Agent.update(via_tuple(name), fn messages ->
      [new_message | messages]
    end)
  end

  def list_messages(name) do
    Agent.get(via_tuple(name), fn messages -> messages end)
  end

  defp via_tuple(name) do
    {:via, Registry, {Channels, name}}
  end
end
