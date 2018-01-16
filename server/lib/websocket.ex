defmodule WebSocketServer do
  require Logger
  require Poison
  use GenServer

  def start_link(_) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [])
    server = Socket.Web.listen!(8000)
    send(pid, {:start_socket_pool, server})
    {:ok, pid}
  end

  def init(_) do
    {:ok, nil}
  end

  defp handle_incoming_message(msg, client) do
    decoded_msg = Command.decode(msg)

    if Command.is_valid?(decoded_msg) do
      {:ok, status} = Command.execute(decoded_msg) |> Command.encode()
      Socket.Web.send!(client, {:text, status})
    else
      Logger.error("Invalid command!")
    end
  end

  defp socket_pool(server) do
    client = server |> Socket.Web.accept!()

    accept_client = true

    if accept_client do
      case client |> Socket.Web.accept!() do
        :ok ->
          Connections.add(client)
      end
    else
      client |> Socket.Web.close()
    end
  
    socket_pool(server)
  end

  def handle_info({:start_socket_pool, server}, state), do: socket_pool(server)
end
