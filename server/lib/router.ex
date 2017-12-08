defmodule Server.Router do
  use Plug.Router
  import Slime, only: [function_from_file: 4]

  plug Plug.Static,
    at: "public",
    from: "../public"
  plug :match
  plug :dispatch

  function_from_file :def, :template, "template.slime", []

  post "/enter" do
    conn
    |> send_resp(200, "Success!")
  end

  get "*glob" do
    conn
    |> send_resp(200, Server.Router.template())
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end