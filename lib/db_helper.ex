defmodule DbHelper do
  def get_db_conn_pid(state) do
    Map.get(state, :db_conn_pid)
  end

  def get_password_hash_from_db_result(result) do
    list = Map.get(result, :rows)

    cond do
      length(list) > 0 -> {:ok, hd(hd(list))}
      length(list) == 0 -> {:error, :hash_not_found}
    end
  end

  def get_existance_check_from_db_result(result) do
    list = Map.get(result, :rows)

    cond do
      length(list) > 0 -> {:ok, hd(hd(list))}
      length(list) == 0 -> {:error, :no_row_found}
    end
  end

  # This is a race condition waiting to happen, should refactor in the future
  def generate_link_access_id() do
    charset = 'ABCDEFGHIJKLMNOPQRSTUWXYZ'
    charset_length = Enum.count(charset)
    access_id = for _ <- 1..6, into: "", do: <<Enum.at(charset, :rand.uniform(charset_length) - 1)>>

    result =
      Postgrex.query!(
        DbManager,
        "select exists(select access_id from links where access_id=$1)",
        [access_id]
      )

    case get_existance_check_from_db_result(result) do
      {:ok, true} -> generate_link_access_id()
      {:ok, false} -> access_id
    end
  end

  def convert_link_expiry_dates_to_strings(link_list) do
    Enum.map(link_list, fn(elements) ->
      [
        Enum.at(elements, 0),
        Enum.at(elements, 1),
        NaiveDateTime.to_string(Enum.at(elements, 2))
      ]
    end
      )
  end
end
