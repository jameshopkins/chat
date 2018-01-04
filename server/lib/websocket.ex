defmodule WebSocketServer do
  use Task
  require Logger
  require Poison

  def start_link(_) do
    Task.start_link(__MODULE__, :init, [])
  end

  def init() do
    server = Socket.Web.listen!(8000)
    client = server |> Socket.Web.accept!()
    client |> Socket.Web.accept!()
    receive_message(server, client)
  end

  defp create_process({:ok, _instruction}) do
    Logger.info("Matching something other than a create action!")
  end

  defp receive_message(server, client) do
    with {:text, msg} <- client |> Socket.Web.recv!(),
         decoded_msg <- Command.decode(msg) do
      if Command.is_valid?(decoded_msg) do
        {:ok, status} = Command.execute(decoded_msg)
        Socket.Web.send!(client, {:text, status})
      else
        IO.inspect(decoded_msg)
        Logger.error("Invalid command!")
      end
    else
      err -> handle_error(err)
    end

    receive_message(server, client)
  end

  defp handle_error(err) do
    IO.inspect(err)
    #  IO.puts("whoops there's an error!")
  end
end
