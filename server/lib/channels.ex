defmodule Channels do
  require Logger
  use Agent

  defstruct created_at: 0, name: nil, id: 1

  def start_link(_) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def get_all_channels(), do: Agent.get(__MODULE__, fn state -> state end)

  def add_channel(name) do
    generate_id()
    |> create(name)
  end

  defp generate_id() do
    case get_all_channels() do
      [%Channels{ id: id }|_] -> id + 1
      [] -> 1
    end
  end

  defp create(id, name) do
    new_channel = %Channels{
      name: name,
      id: id,
      created_at: :calendar.universal_time()
    }
    Agent.update(__MODULE__, fn state -> 
      [ new_channel | state ]
    end)
  end
end