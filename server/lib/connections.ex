defmodule Connections.Supervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      worker(Connection, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end

defmodule Connections do
  use GenServer

  def start_link(_) do
    GenServer.start_link(Connections, [], name: Connections)
  end

  def add(connection) do
    status = GenServer.call(__MODULE__, {:add, connection})
    case status do
      :ok -> broadcast({:open, connection})
    end
  end

  def broadcast(message) do
    GenServer.cast(__MODULE__, {:broadcast, message})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:broadcast, {:open, _connection}}, connections) do
    Enum.each(connections, fn connection ->
      Connection.send(:new, connection)
    end)
    {:noreply, connections}
  end

  def handle_cast({:broadcast, {:close, connection}}, connections) do
    IO.inspect("wahey naughty!")
    {:noreply, connections}
  end

  def handle_cast({:broadcast, message}, connections) do
    {:noreply, connections}
  end

  def handle_call({:add, connection}, from, connections) do
    {status, _} = Supervisor.start_child(Connections.Supervisor, [connection])
    {:reply, status, [connection | connections]}
  end
end