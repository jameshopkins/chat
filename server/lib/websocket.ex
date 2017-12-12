defmodule WebSocketServer do
  use Task

  def start_link(_) do
    Task.start_link(__MODULE__, :init, [])
  end

  def init() do
    server = Socket.Web.listen! 8000
    client = server |> Socket.Web.accept!
    client |> Socket.Web.accept!
    receive_message(server, client)
  end

  defp receive_message(server, client) do
    msg = client |> Socket.Web.recv!
    client |> Socket.Web.send!(msg)
    IO.inspect msg
    receive_message(server, client)
  end
end