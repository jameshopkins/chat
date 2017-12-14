defmodule WebSocketServer do
  use Task
  require Logger
  require Poison

  def start_link(_) do
    Task.start_link(__MODULE__, :init, [])
  end

  def init() do
    server = Socket.Web.listen! 8000
    client = server |> Socket.Web.accept!
    client |> Socket.Web.accept!
    receive_message(server, client)
  end

  defp process_message({:ok, %{"entity" => "channel"} = instruction}) do
    case instruction["action"] do
      "create" -> Channels.Supervisor.create_channel(instruction["content"])
      "delete" -> IO.puts "Delete"
      "edit" -> IO.puts "Edit"
      _ -> Logger.error "Invalid command"
    end
  end

  defp process_message({:ok, _instruction}) do
    Logger.info "Matching something other than a create action!"
  end

  defp process_message({:error, reason, _pos}) do
    Logger.error("Whoops! #{reason}")
  end

  defp receive_message(server, client) do
    with {:text, msg} <- client |> Socket.Web.recv!,
         decoded_msg <- Poison.decode(msg) |> process_message,
    do: decoded_msg

    receive_message(server, client)
  end
end