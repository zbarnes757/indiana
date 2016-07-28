defmodule NewRelicSpec do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  test "send metrics to new relic" do
    use_cassette "new_relic_post", match_requests: [:headers, :body] do
      stats = %{
        "path" => "/some/path",
        "phoenix:responseTime" => 1000
      }

      assert NewRelic.post(stats) === :ok
    end
  end

  test "post multiple metrics" do
    use_cassette "new_relic_post_multimetric", match_requests: [:headers, :body] do
      stats = %{
        "path" => "/some/path",
        "phoenix:responseTime" => 1000,
        "metrics" => %{
          "Component/EctoQueryTime[milliseconds|call]" => 1000
        }
      }

      assert NewRelic.post(stats) === :ok
    end
  end

  test "return an error when new relic responds with an error" do
    # forced failure in fixture
    use_cassette "new_relic_fail", match_requests: [:headers] do
      assert NewRelic.post(%{}) === :error
    end
  end
end
