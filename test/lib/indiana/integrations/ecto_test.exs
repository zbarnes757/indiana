defmodule Indiana.Integrations.EctoTest do
  use Indiana.EctoCase

  alias Indiana.User

  test "send query time metrics to indiana gen server" do
    Indiana.TestRepo.insert!(%User{name: "Zac Barnes"})

    assert Indiana.get_stats["metrics"]["Component/EctoQueryTime[milliseconds|call]"] > 0
  end
end
