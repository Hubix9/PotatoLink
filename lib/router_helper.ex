defmodule RouterHelper do
  require Logger

  def decode_register_request(data) do
    result = Jason.decode(data)

    case result do
      {:ok, data} ->
        result = Validator.validate_registration_request(data)

        case result do
          {:ok} ->
            Logger.info("Successfully decoded data from user register request")
            data

          {:error} ->
            Logger.info("Received malformed request data")
            {:error, "Malformed request data"}
        end

      {:error, error} ->
        Logger.error("An error occured while decoding register request: #{inspect(error)}")
        {:error, error}
    end
  end

  def decode_login_request(data) do
    result = Jason.decode(data)

    case result do
      {:ok, data} ->
        result = Validator.validate_login_request(data)

        case result do
          {:ok} ->
            Logger.info("Successfully decoded data from user login request")
            data

          {:error} ->
            Logger.info("Received malformed request data")
            {:error, "Malformed request data"}
        end

      {:error, error} ->
        Logger.error("An error occured while decoding login request: #{inspect(error)}")
        {:error, error}
    end
  end

  def decode_link_request(data) do
    with {:ok, data} <- Jason.decode(data),
    target <- Map.get(data, "target")
     do
      %{target: target}
    else
      {:error, _} -> Logger.info("An error occured while trying to decode the link creation request")
    end
  end

  def decode_delete_link_request(data) do
    with {:ok, data} <- Jason.decode(data),
    access_id <- Map.get(data, "access_id")
    do
      %{access_id: access_id}
    else
      {:error, _} -> Logger.info("An error occured while trying to decode the link deletion request")
    end
  end
end
