defmodule SessionHelper do
  def verify_login_data(username, password) do
    {:ok, _, hash} = DbManager.fetch_user_password_hash(username)
    case Bcrypt.verify_pass(password, hash) do
      true -> {:ok, "Password correct"}
      false -> {:error, "Invalid password"}
    end
  end
end
