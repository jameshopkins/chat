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

  defp create_process(%{"entity" => "channel"} = instruction) do
    case instruction["action"] do
      "create" -> Channels.Supervisor.create_channel(instruction["content"])
      "delete" -> IO.puts("Delete")
      "edit" -> IO.puts("Edit")
      _ -> Logger.error("Invalid command")
    end
  end

  defp create_process({:ok, _instruction}) do
    Logger.info("Matching something other than a create action!")
  end

  defp receive_message(server, client) do
    with {:text, msg} <- client |> Socket.Web.recv!(),
         {:ok, decoded_msg} <- Poison.decode(msg),
         {:ok, hello} <- create_process(decoded_msg) do
      IO.inspect(decoded_msg["content"])
    else
      err -> err
    end

    receive_message(server, client)
  end
end
