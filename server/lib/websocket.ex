defmodule WebSocketServer do
  require Logger
  require Poison
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    Socket.Web.listen!(8000) |> socket_pool
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

  #defp receive_message(server, client) do
  #  case client |> Socket.Web.recv!() do
  #    {:text, msg} -> msg |> handle_incoming_message(client)
  #    :close -> handle_connection_close(client)
  #  end
  #  receive_message(server, client)
  #end
end
