defmodule Indiana.Integrations.PhoenixTest do
  use ExUnit.Case
  use Plug.Test

  import Plug.Conn

  setup do
    Application.put_env(:indiana, :send_to_new_relic, "false")
    on_exit fn ->
      Indiana.clear_stats
    end
  end

  test "record stats after the route completes" do
    conn = conn(:get, "/stuff")

    Indiana.Integrations.Phoenix.call(conn, %{})
    |> Plug.Conn.resp(200, "hello")
    |> Plug.Conn.send_resp

    stats = Indiana.get_stats

    assert stats["path"] === "/stuff"
    assert stats["phoenix:responseTime"] > 0
    assert stats["metrics"] === nil
  end

  test "build a proper path with an index route" do
    conn = conn(:get, "/")

    Indiana.Integrations.Phoenix.call(conn, %{})
    |> Plug.Conn.resp(200, "hello")
    |> Plug.Conn.send_resp

    stats = Indiana.get_stats

    assert stats["path"] === "/"
  end

  test "skip paths set to ignore" do
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
