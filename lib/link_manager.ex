defmodule LinkManager do
  require Logger

  def create_link(data, session_id \\ nil) do
    with target <- Map.get(data, :target),
         {:valid, validation_status} <- Validator.validate_url_with_protocol(target) do
      target =
        case validation_status do
          :full_match -> target
          :match_no_protocol -> "https://#{target}"
        end
      access_id = case session_id do
        nil -> DbManager.insert_link(target)
        _ -> DbManager.insert_link(session_id, target)
      end
      {:ok, access_id}
    else
      _ -> {:error, "Invalid url"}
    end
  end

  def fetch_link(access_id) do
    DbManager.fetch_target_link_for_access_id(access_id)
  end

  def fetch_user_links(session_id) do
    link_list = DbManager.fetch_list_of_links_created_by_user(session_id)
    link_map = %{"links" => link_list}
    link_map
  end

  def delete_link(access_id, session_id) do
    DbManager.delete_link(access_id, session_id)
  end
end
