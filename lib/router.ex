defmodule Router do
  use Plug.Router
  require Logger

  plug(Plug.Static, from: "frontend/dist", at: "/")
  plug(Plug.Session, store: :cookie, key: "KEY", signing_salt: "SIGNING_SALT", secret_key_base: "SECRET_KEY_BASE________________________________________________________________")
  plug(:match)
  plug(:dispatch)

  get "/" do
    Logger.info("Received a home page GET request")
    conn = put_resp_content_type(conn, "text/html")
    Plug.Conn.send_file(conn, 200, "frontend/dist/index.html")
    #send_resp(conn, 200, "Welcome to PotatoLink")
  end

  get "/pog" do
    Logger.info("Received a pog test page GET request")
    conn = put_resp_header(conn, "location", "https://google.com")
    send_resp(conn, 301, "")
  end

  post "/api/register" do
    Logger.info("Received a register POST request")
    RequestHandler.handle_user_registration(conn)
  end

  post "/api/login" do
    Logger.info("Received a login POST request")
    RequestHandler.handle_user_login(conn)
  end

  get "/api/private" do
    Logger.info("Received GET private request")
    RequestHandler.handle_private_path(conn)
  end

  post "/api/link" do
    Logger.info("Received POST link request")
    RequestHandler.handle_create_link(conn)
  end

  get "/logout" do
    Logger.info("Received GET logout request")
    RequestHandler.handle_logout(conn)
  end

  get "/api/links" do
    Logger.info("Received GET links list request")
    RequestHandler.handle_user_links(conn)
  end

  post "/api/delete_link" do
    Logger.info("Received POST link deletion request")
    RequestHandler.handle_delete_link(conn)
  end

  get "/:access_id" do
    Logger.info("Received GET request to the following link_access_id: #{access_id}")
    RequestHandler.handle_link_access(conn, access_id)
  end

  match _ do
    Logger.info("Received a GET request to a non matching route")
    send_resp(conn, 404, "Nope")
  end
end
