defmodule NewRelic do
  require Logger

  @new_relic_url "https://platform-api.newrelic.com/platform/v1/metrics"
  @micro_seconds_to_seconds 1_000_000

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
        "host" => Atmo.get(:host),
        "pid" => self,
        "version" => Atmo.get(:version, "1.0.0")
      },
      "components" => [
        %{
          "name" => stats["path"],
          "guid" => stats["path"],
          "duration" => stats["phoenix:responseTime"] / @micro_seconds_to_seconds,
          "metrics" => stats["metrics"]
        }
      ]
    }
  end
end
