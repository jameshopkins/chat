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

  @registry_name Connections.Registry
  @supervisor_name Connections.Supervisor

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def registry_lookup(id) do
    {:via, Registry, {@registry_name, id}}
  end

  def add(connection) do
    GenServer.call(__MODULE__, {:add, connection})
  end

  def get_pid_by_key(key) do
    @registry_name
    |> Registry.lookup(key)
    |> List.first
    |> elem(0)
  end

  def get_key_by_pid(pid) do
    Registry.keys(@registry_name, pid) |> List.first
  end

  def broadcast(message) do
    GenServer.cast(__MODULE__, {:broadcast, message})
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:broadcast, :open}, _from, connection_keys) do
    Enum.each(connection_keys, fn {_key, connection} ->
      Connection.send(:new, connection)
    end)

    {:reply, :ok, connection_keys}
  end

  def handle_call({:broadcast, :close}, {pid, _ref}, connection_pool) do
    Supervisor.terminate_child(@supervisor_name, pid)
    key = get_key_by_pid(pid)

    new_connection_pool = Enum.filter(connection_pool, fn curr ->
      elem(curr, 0) !== key
    end)

    {:noreply, new_connection_pool}
  end

  def handle_call({:broadcast, {:message, content}}, _from, connections) do
    IO.inspect(content)
    {:reply, :ok, connections}
  end

  def handle_call({:broadcast, message}, _from, connections) do
    {:reply, :ok, connections}
  end

  def handle_call(:get_connection, {pid, _ref}, connections) do
    connection_key = get_key_by_pid(pid)

    {_key, connection} = Enum.find(connections, fn {key, _connection} ->
      key == connection_key
    end)

    {:reply, connection, connections}
  end

  def handle_call({:add, connection}, _from, connections) do
    key = Connection.generate_connection_key(connection)
    {status, _} = Supervisor.start_child(@supervisor_name, [key])
    new_connection = {key, connection}

    {:reply, status, [new_connection | connections]}
  end
end