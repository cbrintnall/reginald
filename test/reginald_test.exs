defmodule ReginaldTest do
  use ExUnit.Case
  doctest Reginald

  test "greets the world" do
    assert Reginald.hello() == :world
  end
end
