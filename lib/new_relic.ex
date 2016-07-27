defmodule NewRelic do
  require Logger

  @new_relic_url "https://platform-api.newrelic.com/platform/v1/metrics"
  @microseconds_to_milliseconds 1_000

  def post(stats) do
    headers = [
      {"Accept", "application/json"},
      {"Content-Type", "application/json"},
      {"X-License-Key", Atmo.get(:new_relic_license_key)}
    ]

    body = build_new_relic_body(stats)

    case HTTPoison.post(@new_relic_url, Poison.encode!(body), headers, []) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        Logger.debug "Successfully posted to New Relic."

      {_, %HTTPoison.Response{status_code: _, body: body}} ->
        error = body |> Poison.decode! |> Map.get("error")

        Logger.error "Error during New Relic post: #{error}"

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error "Error during New Relic post: #{reason}"
    end
  end

  defp build_new_relic_body(stats) do
    %{
      "agent" => %{
        "host" => Atmo.get(:host, "indiana"),
        "version" => Atmo.get(:version, "1.0.0")
      },
      "components" => [
        %{
          "name" => Atmo.get(:app_name, "indiana"),
          "guid" => "#{Atmo.get(:app_name, "indiana")}.indiana",
          "duration" => stats["phoenix:responseTime"] / @microseconds_to_milliseconds,
          "metrics" => Map.merge(%{"Component/phoenixRoute::#{stats["path"]}[milliseconds|call]" => stats["phoenix:responseTime"] / @microseconds_to_milliseconds}, stats["metrics"] || %{})
        }
      ]
    }
  end
end
