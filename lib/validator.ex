defmodule Validator do
  def validate_username(username) do
    validation_regex = ~r/^[a-zA-Z0-9]{0,255}$/

    matches = Regex.run(validation_regex, username)

    with true <- length(matches) > 0 do
      true
    else
      _ -> false
    end
  end
  def validate_email(email) do
    validation_regex = ~r/^([a-zA-Z0-9]{1,255})@(([a-zA-Z0-9\-]{2,64}\.)+([a-zA-Z]{2,64}))$/

    matches = Regex.run(validation_regex, email)

    with true <- length(matches) > 0 do
      true
    else
      _ -> false
    end
  end

  def validate_map_keys(map, keys) do
    Enum.all?(keys, fn key -> Map.has_key?(map, key) end) and
      length(keys) == length(Map.keys(map))
  end

  def validate_registration_request(data) do
    expected_keys = ["username", "password", "email"]
    result = validate_map_keys(data, expected_keys)
    true = validate_email(Map.get(data, "email"))
    true = validate_username(Map.get(data, "username"))

    case result do
      true -> {:ok}
      false -> {:error}
    end
  end

  def validate_login_request(data) do
    expected_keys = ["username", "password"]
    result = validate_map_keys(data, expected_keys)
    true = validate_username(Map.get(data, "username"))

    case result do
      true -> {:ok}
      false -> {:error}
    end
  end

  # Example match ["http://www.example.com/12345678@@@",
  # "http",
  # "www.",
  # "/12345678@@@"]

  def validate_url_with_protocol(url) do
    validation_regex =
      ~r/^((?:http|https):(?:\/\/))?([-a-zA-Z0-9]{2,64}\.)*(([-a-zA-Z0-9]{2,64})\.([a-zA-Z]{2,64}))((?:\/[\+~%\/.\w\-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[.\!\/\\w]*))?$/

    matches = Regex.run(validation_regex, url)
    domain_part = Enum.at(matches, 3)
    IO.puts("#{inspect(url)}")
    IO.puts("#{inspect(matches)}")

    with true <- length(matches) > 0, false <- DbManager.check_if_blacklisted_url(domain_part) do
      cond do
        String.length(Enum.at(matches, 1)) > 0 -> {:valid, :full_match}
        String.length(Enum.at(matches, 1)) == 0 -> {:valid, :match_no_protocol}
      end
    else
      _ -> {:invalid, :no_match}
    end
  end

  def validate_json(json) do
    validation_regex =
      ~r/(?<o>{\s{0,}((?<s>\"([^\0-\x1F\"\\]|\\[\"\\\/bfnrt]|\\u[0-9a-fA-F]{4})*\")\s{0,}:\s{0,}(?<v>\g<s>|(?<n>-?(0|[1-9]\d*)(.\d+)?([eE][+-]?\d+)?)|\g<o>|\g<a>|true|false|null))?\s*((?<c>,\s*)\g<s>(?<d>:\s*)\g<v>)*\s{0,1}})|(?<a>\[\g<v>?(\g<c>\g<v>)*\])/

    matches = Regex.run(validation_regex, json)
    IO.puts("#{inspect(matches)}")

    cond do
      length(matches) > 0 -> {:valid, :full_match}
      length(matches) == 0 -> {:invalid, :no_match}
    end
  end

  def validate_access_id(access_id) do
    validation_regex = ~r/^[a-zA-Z]{6}$/
    matches = Regex.run(validation_regex, access_id)
    IO.puts("#{inspect(matches)}")

    cond do
      length(matches) > 0 -> {:valid, :full_match}
      length(matches) == 0 -> {:invalid, :no_match}
    end
  end
end
