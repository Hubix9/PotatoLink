defmodule ValidatorTest do
  use ExUnit.Case

  test "validate a correctly structured map with atom keys" do
    map = %{username: "test", password: "test", email: "test@test.test"}
    result = Validator.validate_map_keys(map, [:username, :password, :email])
    assert(result == true)
  end

  test "validate a correctly structured map with string keys keys" do
    map = %{"username" => "test", "password" => "test", "email" => "test@test.test"}
    result = Validator.validate_map_keys(map, ["username", "username", "email"])
    assert(result == true)
  end

  test "validate an incorrectly structured map with string keys keys" do
    map = %{"UsErNaMe" => "test", "pass____" => "test", "em@il" => "test@test.test"}
    result = Validator.validate_map_keys(map, ["username", "username", "email"])
    assert(result == false)
  end

  test "validate an incorrectly structured map with atom keys" do
    map = %{uSeRnAmE: "test", ____word: "test", ema1L: "test@test.test"}
    result = Validator.validate_map_keys(map, [:username, :password, :email])
    assert(result == false)
  end

  test "validate a correctly structured map with mixed keys" do
    map = %{username: "test", password: "test", email: "test@test.test"}
    result = Validator.validate_map_keys(map, ["username", :password, "email"])
    assert(result == false)
  end

  test "validate a map with too many keys" do
    map = %{username: "test", password: "test", email: "test@test.test", a_key_to_many: "some value"}
    result = Validator.validate_map_keys(map, [:username, :password, :email])
    assert(result == false)
  end

end
