defmodule BtgsProxyTest do
  use ExUnit.Case
  doctest BtgsProxy

  test "greets the world" do
    assert BtgsProxy.hello() == :world
  end
end
