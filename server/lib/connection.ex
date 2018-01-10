defmodule Connection do
  use GenServer

  def start_link(connection) do
    {:ok, pid} = GenServer.start_link(__MODULE__, connection)
    Kernel.send(pid, {:start_message_loop, connection})
    {:ok, pid}
  end

  def init(_) do
    {:ok, nil}
  end

  def send(:close, connection) do
    Socket.Web.send!(connection, {:text, "Connection closed!"})
  end

  def send(:new, connection) do
    Socket.Web.send!(connection, {:text, "New connection!"})
  end

  def send(foo, connection) do
    Socket.Web.send!(connection, {:text, "Another type of message"})
  end

  defp start_message_loop(connection) do
    connection
    |> Socket.Web.recv!()
    |> case do
         :close -> {:close, connection}
         other -> other 
       end
    |> Connections.broadcast

    start_message_loop(connection)
  end

  def handle_info({:start_message_loop, connection}, state) do
    start_message_loop(connection)
    {:noreply, state}
  end

end