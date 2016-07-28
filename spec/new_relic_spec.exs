defmodule NewRelicSpec do
  use ESpec
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  describe "New Relic" do
    it "should send metrics to new relic" do
      use_cassette "new_relic_post", match_requests: [:headers, :body] do
        stats = %{
          "path" => "/some/path",
          "phoenix:responseTime" => 1000
        }

        expect NewRelic.post(stats) |> to(eq :ok)
      end
    end

    it "should post multiple metrics" do
      use_cassette "new_relic_post_multimetric", match_requests: [:headers, :body] do
        stats = %{
          "path" => "/some/path",
          "phoenix:responseTime" => 1000,
          "metrics" => %{
            "Component/EctoQueryTime[milliseconds|call]" => 1000
          }
        }

        expect NewRelic.post(stats) |> to(eq :ok)
      end
    end

    it "should return an error when new relic responds with an error" do
      # forced failure in fixture
      use_cassette "new_relic_fail", match_requests: [:headers] do
        expect NewRelic.post(%{}) |> to(eq :error)
      end
    end
  end
end
