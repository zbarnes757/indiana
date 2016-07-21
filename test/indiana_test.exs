defmodule IndianaTest do
  use ExUnit.Case, async: true
  use Plug.Test

  defmodule DemoPlug do
    use Plug.Builder

    plug Indiana

    plug :index
    defp index(conn, _opts), do: conn |> send_resp(200, "OK")
  end

  test "it works!" do
    conn =
      conn(:get, "/")
      |> DemoPlug.call([])

    assert conn.status == 200
  end

  test "we receive a custom header with content" do
    conn =
      conn(:get, "/")
      |> DemoPlug.call([])

    [ header ] = get_resp_header(conn, "x-hello-world")
    assert header === "YEAH IT WORKS!"
  end
end
