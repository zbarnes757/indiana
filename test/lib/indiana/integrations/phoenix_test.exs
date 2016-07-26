defmodule Beaker.Integrations.PhoenixTest do
  use ExUnit.Case
  use Plug.Test

  import Plug.Conn

  setup do
    on_exit fn ->
      Indiana.clear_stats
    end
  end

  test "records stats" do
    conn = conn(:get, "/stuff")

    Indiana.Integrations.Phoenix.call(conn, %{})
    |> Plug.Conn.resp(200, "hello")
    |> Plug.Conn.send_resp

    stats = Indiana.get_stats

    assert stats["Path"] === "/stuff"
    assert stats["Status"] === 200
    assert stats["Phoenix:ResponseTime"] != nil
  end

  test "Can customize the skip path" do
    conn(:get, "/not_indiana")
    |> TestPipeWithPath.call([])
    |> Plug.Conn.send_resp(200, "OK")

    stats = Indiana.get_stats

    assert stats === %{}
  end
end


defmodule TestPipeWithPath do
  use Plug.Builder

  plug Indiana.Integrations.Phoenix, ignore_path: "not_indiana"
end
