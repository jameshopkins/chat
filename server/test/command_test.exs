defmodule CommandTest do
  use ExUnit.Case
  doctest Command

  test "JSON string is decoded into a representation of a command" do
    raw =
      ~s({"channel": "naughty", "content": "first channel", "action": "create", "entity": "message"})

    expected = %Command{
      action: "create",
      entity: %Message{:content => "first channel", :channel => "naughty"},
      created_at: 0
    }

    assert Command.decode(raw) == expected
  end

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
