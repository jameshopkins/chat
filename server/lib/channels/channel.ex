defmodule Channel do
  @moduledoc """
  Orchestrating channel processes
  """
  require Logger
  use Agent

  defstruct content: nil

  def start_link(name) do
    # Logger.info(~s("Started channel #{name}"))
    Agent.start_link(fn -> [] end, name: via_tuple(name))
  end

  def execute_command(command) do
    case command.action do
      "create" -> create_message(command)
    end
  end

  defp add_to_messages_stack(message, messages) do
    [{message, :calendar.universal_time()} | messages]
  end

  def create_message(command) do
    %Command{ entity: %Message{ channel: channel, content: message } } = command

    status =
      Agent.update(
        via_tuple(channel), &(add_to_messages_stack(message, &1))
      )

    Command.mark_transation_status(command, status) |> Command.encode()
  end

  def list_messages(name) do
    Agent.get(via_tuple(name), fn messages -> messages end)
  end

  defp via_tuple(name) do
    {:via, Registry, {Channels.Registry, name}}
  end
end
