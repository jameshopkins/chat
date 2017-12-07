defmodule Server.Router do
  use Plug.Router
  import Slime, only: [function_from_file: 4]

  plug :match
  plug :dispatch

  function_from_file :def, :template, "template.slime", []

  def start(_, _) do
    IO.puts "Listening on 4000"
    Plug.Adapters.Cowboy.http(Server.Router, [])
  end

  get "/" do
    conn
    |> send_resp(200, Server.Router.template())
  end

  get "/foo" do
    conn
    |> send_resp(200, "This is foo!")
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end