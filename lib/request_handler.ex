defmodule RequestHandler do
  require Logger

  def handle_user_registration(conn) do
    {:ok, body, _} = Plug.Conn.read_body(conn)
    {:valid, _} = Validator.validate_json(body)
    data = RouterHelper.decode_register_request(body)
    Validator.validate_registration_request(data)

    result =
      DbManager.register_user(
        Map.get(data, "username"),
        Map.get(data, "password"),
        Map.get(data, "email")
      )

    case result do
      {:ok} -> Plug.Conn.send_resp(conn, 200, "Registered successfully")
      {:error, :already_exists} -> Plug.Conn.send_resp(conn, 409, "Credentials already taken")
    end
  end

  def handle_user_login(conn) do
    {:ok, body, _} = Plug.Conn.read_body(conn)
    {:valid, _} = Validator.validate_json(body)
    data = RouterHelper.decode_login_request(body)
    Validator.validate_login_request(data)

    result = SessionManager.login_user(Map.get(data, "username"), Map.get(data, "password"), conn)

    case result do
      {:ok, conn, _} -> Plug.Conn.send_resp(conn, 200, "Login successfull")
      {:error, _} -> Plug.Conn.send_resp(conn, 409, "Invalid credentials")
    end
  end

  def handle_private_path(conn) do
    with true <- SessionManager.verify_session(conn) do
      Plug.Conn.send_resp(conn, 200, "Welcome to the PrIvAtE section")
    else
      _ ->
        Plug.Conn.send_resp(conn, 404, "Not Found")
    end
  end

  def handle_create_link(conn) do
    with Logger.info("Starting link creation flow for an authenticated user"),
         {:ok, body, _} <- Plug.Conn.read_body(conn),
         {:valid, _} <- Validator.validate_json(body),
         data <- RouterHelper.decode_link_request(body) do
      with true <- SessionManager.verify_session(conn) do
        session_id = SessionManager.get_session_id(conn)
        {:ok, access_id} = LinkManager.create_link(data, session_id)
        Logger.info("Created a link with access_id: #{access_id}")
        Plug.Conn.send_resp(conn, 200, access_id)
      else
        _ ->
          {:ok, access_id} = LinkManager.create_link(data)
          Logger.info("Created a link with access_id: #{access_id}")
          Plug.Conn.send_resp(conn, 200, access_id)
      end
    else
      _ -> Plug.Conn.send_resp(conn, 409, "Invalid link creation request")
    end
  end

  # Validation should be added here later
  def handle_link_access(conn, access_id) do
    with {:valid, _} = Validator.validate_access_id(access_id),
         access_id = String.upcase(access_id),
         {:ok, target} <- LinkManager.fetch_link(access_id) do
      conn = Plug.Conn.put_resp_header(conn, "location", target)
      Plug.Conn.send_resp(conn, 301, "")
    else
      _ -> Plug.Conn.send_resp(conn, 404, "Not found")
    end
  end

  def handle_logout(conn) do
    with true <- SessionManager.verify_session(conn),
         session_id = SessionManager.get_session_id(conn) do
      SessionManager.delete_session(session_id)
      Plug.Conn.send_resp(conn, 200, "Session deleted successfully")
    else
      _ -> Plug.Conn.send_resp(conn, 404, "Not found")
    end
  end

  def handle_user_links(conn) do
    with true <- SessionManager.verify_session(conn),
         session_id <- SessionManager.get_session_id(conn) do
      link_map = LinkManager.fetch_user_links(session_id)
      link_json = Jason.encode!(link_map)
      Plug.Conn.send_resp(conn, 200, link_json)
    else
      _ -> Plug.Conn.send_resp(conn, 404, "Not Found")
    end
  end

  def handle_delete_link(conn) do
    with true <- SessionManager.verify_session(conn),
         session_id <- SessionManager.get_session_id(conn),
         {:ok, body, _} <- Plug.Conn.read_body(conn),
         {:valid, _} = Validator.validate_json(body),
         data <- RouterHelper.decode_delete_link_request(body),
         access_id <- Map.get(data, :access_id),
         {:valid, _} = Validator.validate_access_id(access_id) do
      result = LinkManager.delete_link(access_id, session_id)
      Logger.info("Attempting to delete link with access_id: #{access_id}")

      case result do
        true -> Plug.Conn.send_resp(conn, 200, "Link deletion successfull")
        false -> Plug.Conn.send_resp(conn, 400, "Link deletion error")
      end
    else
      _ -> Plug.Conn.send_resp(conn, 404, "Not Found")
    end
  end
end
