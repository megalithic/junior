defmodule JuniorTest do
  use ExUnit.Case
  doctest Junior

  test "greets the world" do
    assert Junior.hello() == :world
  end
end
