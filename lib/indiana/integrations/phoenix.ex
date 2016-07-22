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
  require Logger

  def init(opts), do: Keyword.get(opts, :ignore_path)

  def call(%Plug.Conn{path_info: path_info, owner: owner} = conn, ignore_path) do
    cond do
      ignore(path_info, ignore_path) -> conn

      true ->
        IndianaSupervisor.start_link

        start_time = Indiana.Time.now

        register_before_send conn, fn %Plug.Conn{status: status} = conn ->
          end_time = Indiana.Time.now
          diff = end_time - start_time
          generic_path = generalize_path(conn)

          Indiana.set("path", generic_path)
          Indiana.set("status", status)
          Indiana.set("ResponseTime", diff / 1000)

          Indiana.send_stats

          conn
        end
    end
  end

  defp ignore(%Plug.Conn{path_info: []}, _), do: false
  defp ignore(path_info, ignore_path), do: hd(path_info) == ignore_path

  defp generalize_path(%Plug.Conn{params: params, path_info: path_info}) do
    params
    |> Enum.map(fn({key, value}) -> {key, Enum.find_index(path_info, &(&1 === value))} end)
    |> Enum.filter(fn({key, index}) -> index !== nil end)
    |> sanitize_path_info(path_info)
    |> Enum.join("/")
  end

  defp sanitize_path_info([], path_info), do: path_info
  defp sanitize_path_info([ {key, index} | tail], path_info), do: List.replace_at(sanitize_path_info(tail, path_info), index, "{#{key}}")
end
