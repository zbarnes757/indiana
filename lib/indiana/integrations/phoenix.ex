defmodule Indiana.Integrations.Phoenix do
  @moduledoc """
  A Plug for adding Indiana stats to your Phoenix pipeline(s)
  plug Indiana.Integrations.Phoenix
  or
  plug Indiana.Integrations.Phoenix, ignore_path: "my_special_path"
  ## Options
    * `:ignore_path` - The top level of the URL to ignore.
  """
  @behaviour Plug
  import Plug.Conn

  def init(opts), do: Keyword.get(opts, :ignore_path)

  def call(conn, ignore_path) do

    cond  do
      ignore(conn, ignore_path) -> conn

      true ->
        start_time = Indiana.Time.now

        register_before_send(conn, fn(conn) ->
          end_time = Indiana.Time.now
          diff = end_time - start_time

          Indiana.TimeSeries.sample("Phoenix:ResponseTime", diff / 1000)
          Indiana.Counter.incr("Phoenix:Requests")

          conn
        end)
    end
  end

  defp ignore(%Plug.Conn{path_info: []}, _), do: false
  defp ignore(%Plug.Conn{path_info: path_info}, ignore_path), do: hd(path_info) == ignore_path
end
