defmodule EmbedServerTest do
  use ExUnit.Case
  doctest EmbedServer

  test "greets the world" do
    assert EmbedServer.hello() == :world
  end
end
