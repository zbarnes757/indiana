defmodule Indiana.Integrations.PhoenixSpec do
  use ESpec
  use Plug.Test

  import Plug.Conn

  before do: Application.put_env(:indiana, :send_to_new_relic, "false")
  finally do: Indiana.clear_stats

  describe "Phoenix Plug" do
    # TODO: add a test that properly builds paths with parameters
    it "should record stats after the route completes" do
      conn = conn(:get, "/stuff")

      Indiana.Integrations.Phoenix.call(conn, %{})
      |> Plug.Conn.resp(200, "hello")
      |> Plug.Conn.send_resp

      stats = Indiana.get_stats

      expect stats["path"] |> to(eq "/stuff")
      expect stats["phoenix:responseTime"] |> to(be :>, 0)
      expect stats["metrics"] |> to(eq nil)
    end

    it "should build a proper path with an index route" do
      conn = conn(:get, "/")

      Indiana.Integrations.Phoenix.call(conn, %{})
      |> Plug.Conn.resp(200, "hello")
      |> Plug.Conn.send_resp

      stats = Indiana.get_stats

      expect stats["path"] |> to(eq "/")
    end

    it "should skip paths set to ignore" do
      conn(:get, "/not_indiana")
      |> TestPipeWithPath.call([])
      |> Plug.Conn.send_resp(200, "OK")

      stats = Indiana.get_stats

      expect stats |> to(eq %{})
    end
  end
end

defmodule TestPipeWithPath do
  use Plug.Builder

  plug Indiana.Integrations.Phoenix, ignore_path: "not_indiana"
end
