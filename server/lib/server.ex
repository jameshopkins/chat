defmodule Server.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  def start(_, _) do
    IO.puts "Listening on 4000"
    Plug.Adapters.Cowboy.http(Server.Router, [])
  end

  get "/" do
    conn
    |> send_resp(200, "wahey")
  end

  get "/foo" do
    conn
    |> send_resp(200, "This is foo!")
  end
end