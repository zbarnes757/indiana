defmodule IndianaTest do
  use ExUnit.Case

  setup do
    on_exit fn ->
      Indiana.clear_stats
    end
  end

  test "starts with an empty map" do
    Indiana.start_link
    assert Indiana.get_stats === %{}
  end

  test "sets stats in a map" do
    Indiana.start_link
    Indiana.set_stat("foo", "bar")
    assert Indiana.get_stats === %{"foo" => "bar"}
  end

  test "clears stats to an empty map" do
    Indiana.start_link
    Indiana.set_stat("foo", "bar")
    assert Indiana.get_stats === %{"foo" => "bar"}
    Indiana.clear_stats
    assert Indiana.get_stats === %{}
  end
end
