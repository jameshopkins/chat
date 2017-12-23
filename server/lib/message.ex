defmodule Message do
  @moduledoc """
  Parse and transform socket messages into meaningful instructions
  """

  defstruct channel: nil, content: nil

  @doc ~S"""
  Validate a mutative instruction
  ## Examples

  iex> Message.parse_command "CREATE"
  {:ok, "CREATE"}
  """
  def parse_command(command) do
    {:ok, command}
  end
end
