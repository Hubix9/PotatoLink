defmodule SessionManager do
  require Logger
  # Performs the whole login process for the supplied username and password
  def login_user(username, password, conn) do
    with {:ok, _} <- SessionHelper.verify_login_data(username, password),
         {:ok, session_id, _} <- create_session(username) do
      conn = Plug.Conn.fetch_session(conn)
      conn = Plug.Conn.put_session(conn, :id, session_id)
      Logger.info("user id was put into the session data: #{inspect(session_id)}")
      {:ok, conn, "User logged in successfully"}
    else
      {:error, errormessage} -> {:error, errormessage}
    end
  end

  # Verifies the validity of a user session
  def verify_session(conn) do
    conn = Plug.Conn.fetch_session(conn)

    with session_id <- Plug.Conn.get_session(conn, :id),
         false <- is_nil(session_id),
         true <- DbManager.validate_session_expiry_time_for_id(session_id) do
      Logger.info("Session validated successfully for session_id: #{session_id}")
      true
    else
      _ ->
        Logger.info("Received an invalid session")
        false
    end
  end

  def get_session_id(conn) do
    conn = Plug.Conn.fetch_session(conn)
    Plug.Conn.get_session(conn, :id)
  end

  # Creates a new session for the given username and returns it's id
  def create_session(username) do
    {:ok, session_id, _} = DbManager.insert_new_session(username)
    {:ok, session_id, "Session created succesfully"}
  end

  # Delete the session with specified id
  def delete_session(session_id) do
    {:ok, _} = DbManager.delete_session(session_id)
  end
end
