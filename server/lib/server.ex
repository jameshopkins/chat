defmodule Server.Router do
  use Plug.Router
  import Slime, only: [function_from_file: 4]

  plug Plug.Static, at: "public", from: "../public"
  plug :match
  plug :dispatch

  function_from_file :def, :template, "template.slime", []

  def start(_, _) do
    IO.puts "Listening on 4000"
    Plug.Adapters.Cowboy.http(Server.Router, [])
  end

  get "*glob" do
    conn
    |> send_resp(200, Server.Router.template())
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end