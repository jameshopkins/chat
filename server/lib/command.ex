defmodule Command do
  @moduledoc """
  Decode and parse commands into meaningful instructions
  """
  require Poison

  defstruct action: nil, entity: nil, status: nil

  @schema %{
    action: ["create", "delete", "edit"]
  }

  @entities %{
    "channel" => Channel,
    "message" => Message
  }

  def mark_transation_status(command, status) do
    status = if status == :ok, do: "success", else: "failure"
    Map.put(command, :status, status)
  end

  def execute(%Command{} = command) do
    case command.entity do
      %Channel{} -> Channels.execute_command(command)
      %Message{} -> Channel.execute_command(command)
    end
  end

  def encode(message) do
    message |> serialise_command() |> Poison.encode()
  end

  @doc """
  Serialise a command struct

    iex> %Command{action: "create", entity: %Channel{content: "nice"}, status: nil}
    ...> |> Command.serialise_command
    %{action: "create", entity: "channel", content: "nice", status: nil}
  """

  def serialise_command(%Command{} = command) do
    content = command.entity.content

    command
    |> Map.from_struct()
    |> Map.put(:content, content)
    |> Map.update!(:entity, &serialise_command/1)
  end

  def serialise_command(entity) do
    @entities
    |> Enum.find(fn {_, val} -> val == entity.__struct__ end)
    |> elem(0)
  end

  @doc """
  Deserialise a command struct

    iex> %{
    ...> :channel => "naughty",
    ...> :content => "first channel",
    ...> :action => "create",
    ...> :entity => "message"
    ...> }
    ...> |> Command.deserialise_command
    %Command{
      action: "create",
      entity: %Message{:content => "first channel", :channel => "naughty"}
    }
  """
  def deserialise_command(command) do
    struct(__MODULE__, command)
    |> Map.update!(:entity, &get_entity(&1, command))
  end

  defp get_entity(entity, command) do
    struct(Map.get(@entities, entity), command)
  end

  @doc ~S"""
  Decode a JSON string into a meaningful representation of a command
  }
  """

  def decode(command) when is_binary(command) do
    with {:ok, decoded_command} <- Poison.Parser.parse(command, keys: :atoms!) do
      deserialise_command(decoded_command)
    end
  end

  defp validate_command(%__MODULE__{} = command, {type, vals}) do
    case Map.fetch(command, type) do
      {:ok, val} -> Enum.member?(vals, val)
      :error -> false
    end
  end

  @doc ~S"""
  Validate the decoded command against a schema
  """
  def is_valid?(command, schema \\ @schema) do
    Enum.all?(schema, &validate_command(command, &1))
  end
end
