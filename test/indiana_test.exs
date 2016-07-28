defmodule IndianaTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup do
    Application.put_env(:indiana, :send_to_new_relic, "false")
    Indiana.start_link

    on_exit fn ->
      Indiana.clear_stats
    end
  end

    test "initialize with an empty map for stats" do
      assert Indiana.get_stats === %{}
    end

    test "set stats in a map" do
      Indiana.set_stat("foo", "bar")
      assert Indiana.get_stats === %{"foo" => "bar"}
    end

    test "clear stats from the map" do
      Indiana.set_stat("foo", "bar")
      assert Indiana.get_stats === %{"foo" => "bar"}
      Indiana.clear_stats
      assert Indiana.get_stats === %{}
    end

    test "not send stats to new relic and not clear state" do
      Indiana.set_stat("foo", "bar")
      assert Indiana.get_stats === %{"foo" => "bar"}
      Indiana.send_stats
      assert Indiana.get_stats === %{"foo" => "bar"}
    end

    # TODO: need to figure out how to change env var for just this test
    # test "should send stats to new relic and clear state" do
    #   use_cassette "indiana_send_stats", match_requests: [:headers, :body] do
    #     Indiana.set_stat("foo", "bar")
    #     assert Indiana.get_stats === %{"foo" => "bar"}
    #     Indiana.send_stats
    #     assert Indiana.get_stats === %{}
    #   end
    # end
end
