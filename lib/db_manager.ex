defmodule DbManager do
  require Logger

  def fetch_user_password_hash(username) do
    username = String.downcase(username)
    with {:ok, result} <-
           Postgrex.query(
             __MODULE__,
             "select password from users where username = $1;",
             [username]
           ),
         {:ok, pass_hash} <- DbHelper.get_password_hash_from_db_result(result) do
      Logger.info(
        "Successfully retrived password hash from db for username: #{username}"
      )

      {:ok, username, pass_hash}
    else
      {:error, :hash_not_found} ->
        Logger.info("Failed retrieving password hash, user not found for username: #{username}")
        {:error, :hash_not_found}

      {:error, error} ->
        Logger.error(
          "Failed retrieving password from db: #{inspect(error)}, for username: #{username}"
        )

        {:error, error}
    end
  end

  def check_if_already_registered(username, email) do
    username = String.downcase(username)
    email = String.downcase(email)
    Logger.info("#{username}, #{email}")

    result =
      Postgrex.query(
        __MODULE__,
        "select exists(select 1 from users where username = $1 or email = $2);",
        [username, email]
      )

    case result do
      {:ok, data} ->
        Logger.info("Successfully retrieved account information: #{inspect(data)}")
        user_exists = DbHelper.get_existance_check_from_db_result(data)

        case user_exists do
          {:ok, user_exists_value} ->
            Logger.info(
              "Successfully retrieved account existence state: #{inspect(user_exists_value)}"
            )

            user_exists_value
        end
    end
  end

  def insert_new_session(username) do
    username = String.downcase(username)
    result =
      Postgrex.query!(
        __MODULE__,
        "insert into sessions (user_id) select users.id from users where users.username = $1 returning id::text;",
        [username]
      )

    Logger.info("Successfully inserted a session record into db: #{inspect(result)}")
    {:ok, session_id} = DbHelper.get_password_hash_from_db_result(result)
    {:ok, session_id, "Session inserted succesfully"}
  end

  def delete_session(session_id) do
    result =
      Postgrex.query!(
        __MODULE__,
        "delete from sessions where id::text = $1;",
        [session_id]
      )

    num_rows = Map.get(result, :num_rows)

    case num_rows do
      num_rows when num_rows > 0 ->
        Logger.info(
          "Successfully deleted the following number of sessions: #{num_rows}, with id: #{session_id}"
        )
    end

    Logger.info("Successfully deleted session with session id: #{session_id}")
    {:ok, "Session deleted succesfully"}
  end

  def register_user(username, password, email) do
    username = String.downcase(username)
    email = String.downcase(email)
    case check_if_already_registered(username, email) do
      true ->
        {:error, :already_exists}

      false ->
        hash = password |> Bcrypt.hash_pwd_salt()

        result =
          Postgrex.query!(
            __MODULE__,
            "insert into users (username, password, email) values ($1, $2, $3);",
            [username, hash, email]
          )

        Logger.info("Successfully create a new user: #{inspect(result)}")

        {:ok}
    end
  end

  def fetch_session_expiry_time_for_id(session_id) do
    result =
      Postgrex.query!(
        __MODULE__,
        "select extract(epoch from sessions.expiry_time) from sessions where id::text = $1;",
        [session_id]
      )

    {:ok, expiry_time} = DbHelper.get_password_hash_from_db_result(result)

    Logger.info(
      "Successfully fetched session expiry time for session id: #{session_id}, #{trunc(expiry_time)}"
    )
  end

  def validate_session_expiry_time_for_id(session_id) do
    result =
      Postgrex.query!(
        __MODULE__,
        "select exists(select id from sessions where id::text=$1 and expiry_time > now())",
        [session_id]
      )

    session_valid = DbHelper.get_existance_check_from_db_result(result)

    case session_valid do
      {:ok, value} -> value
    end
  end

  def garbage_collect_sessions() do
    result =
      Postgrex.query!(__MODULE__, "delete from sessions where sessions.expiry_time < now();", [])

    Logger.info("Performed session garbage collection: #{inspect(result)}")
  end

  def garbage_collect_links() do
    result = Postgrex.query!(__MODULE__, "delete from links where links.expiry_time < now();", [])

    Logger.info("Performed link garbage collection: #{inspect(result)}")
  end

  def insert_link(target) do
    access_id = DbHelper.generate_link_access_id()
    Logger.info("inserting link for target url: #{target}, with access id: #{access_id}")

    Postgrex.query!(
      __MODULE__,
      "insert into links (access_id, target, expiry_time)
      select $1 as access_id ,
      $2 as target,
      (now() + '1 day') as expiry_time;",
      [access_id, target]
    )

    access_id
  end

  def insert_link(session_id, target) do
    access_id = DbHelper.generate_link_access_id()

    Postgrex.query!(
      __MODULE__,
      "insert into links (creator_id, access_id, target, expiry_time)
      select (select sessions.user_id from sessions where sessions.id::text = $1) as creator_id,
      $2 as access_id,
      $3 as target,
      (now() + '3 days') as expiry_time;",
      [session_id, access_id, target]
    )

    access_id
  end

  def fetch_target_link_for_access_id(access_id) do
    with {:ok, result} <-
           Postgrex.query(
             __MODULE__,
             "select target from links where access_id = $1;",
             [
               access_id
             ]
           ),
         {:ok, target} <- DbHelper.get_password_hash_from_db_result(result) do
      Logger.info("Successfully fetched link for access_id: #{access_id}")
      {:ok, target}
    else
      {:error, error} -> {:error, error}
    end
  end

  def fetch_list_of_links_created_by_user(session_id) do
    result =
      Postgrex.query!(
        __MODULE__,
        "select access_id, target, expiry_time from links where creator_id = (select user_id from sessions where id::text = $1) order by expiry_time DESC;",
        [session_id]
      )

    Logger.info(
      "Received links created by user with session id: #{session_id}, #{inspect(result)}"
    )

    link_list = Map.get(result, :rows) |> DbHelper.convert_link_expiry_dates_to_strings()
    Logger.info("#{inspect(link_list)}")
    link_list
  end

  def delete_link(access_id, session_id) do
    result =
      Postgrex.query!(
        __MODULE__,
        "delete from links where access_id = $1 and creator_id = (select user_id from sessions where id::text = $2)",
        [access_id, session_id]
      )

    Logger.info("#{inspect(result)}")
    num_rows = Map.get(result, :num_rows)

    cond do
      num_rows > 0 -> true
      num_rows <= 0 -> false
    end
  end

  def check_if_blacklisted_url(url) do
    result =
      Postgrex.query!(
        __MODULE__,
        "select exists(select name from blacklisted_domains where name = $1);",
        [url]
      )
    {:ok, result} = DbHelper.get_existance_check_from_db_result(result)
    result
  end

  def init() do
    result =
      Postgrex.start_link(
        hostname: "1.2.3.4",
        username: "username",
        password: "password",
        database: "database"
      )

    case result do
      {:ok, db_conn_pid} ->
        inspect(db_conn_pid)
        Process.register(db_conn_pid, __MODULE__)
        Logger.info("DB connection started")
        {:ok, db_conn_pid}

      {:error, error} ->
        Logger.error("An error occured while starting DB connection: #{error}")
    end
  end
end
