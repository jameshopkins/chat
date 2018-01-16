defmodule Connection do
  use GenServer

  def start_link(key) do
    {:ok, pid} = GenServer.start_link(__MODULE__, key, name: Connections.registry_lookup(key))
    Kernel.send(pid, :start_message_loop)
    {:ok, pid}
  end

  def init(key) do
    {:ok, key}
  end

  def generate_connection_key(connection) do
    connection.headers["sec-websocket-key"]
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

  def dispatch_message({:text, content}) do
    GenServer.call(Connections, {:broadcast, {:message, content}})
  end

  def dispatch_message(:close) do
    GenServer.call(Connections, {:broadcast, :close})
  end

  def dispatch_message(:open) do
    GenServer.call(Connections, {:broadcast, :open})
  end

  defp start_message_loop(connection) do
    connection
    |> Socket.Web.recv!()
    |> Connection.dispatch_message

    start_message_loop(connection)
  end

  def handle_info(:start_message_loop, key) do
    dispatch_message(:open)
    connection = GenServer.call(Connections, :get_connection)
    start_message_loop(connection)

    {:noreply, connection}
  end

end