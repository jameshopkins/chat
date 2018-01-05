defmodule CommandTest do
  use ExUnit.Case
  doctest Command

  test "validate the valid command" do
    input = %Command{
      entity: %Channel{:content => "first channel"},
      action: "create"
    }

    schema = %{
      action: ["create", "delete", "edit"]
    }

    assert Command.is_valid?(input, schema) == true
  end

  test "validate the invalid command" do
    input = %Command{
      entity: %Channel{:content => "first channel"},
      action: "creat"
    }

    schema = %{
      action: ["create", "delete", "edit"]
    }

    assert Command.is_valid?(input, schema) == false
  end
end
