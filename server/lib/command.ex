defmodule Command do
  @moduledoc """
  Decode and parse commands into meaningful instructions
  """
  require Poison

  defstruct action: nil, created_at: 0, entity: nil

  @schema %{
    action: ["create", "delete", "edit"]
  }

  @entities %{
    "channel" => Channel,
    "message" => Message
  }

  def execute(%Command{} = command) do
    case command.entity do
      %Channel{} -> Channels.execute_command(command)
      %Message{} -> Channel.execute_command(command)
    end
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
      struct(__MODULE__, decoded_command)
      |> Map.update!(:entity, &get_entity(&1, decoded_command))
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
