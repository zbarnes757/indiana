defmodule IndianaSpec do
  use ESpec
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  before do
    Application.put_env(:indiana, :send_to_new_relic, "false")
    Indiana.start_link
  end

  finally do: Indiana.clear_stats

  describe "Indiana" do
    it "should initialize with an empty map for stats" do
      expect Indiana.get_stats |> to(eq %{})
    end

    it "should set stats in a map" do
      Indiana.set_stat("foo", "bar")
      expect Indiana.get_stats |> to(eq %{"foo" => "bar"})
    end

    it "should clear stats from the map" do
      Indiana.set_stat("foo", "bar")
      expect Indiana.get_stats |> to(eq %{"foo" => "bar"})
      Indiana.clear_stats
      expect Indiana.get_stats |> to(eq %{})
    end

    context "with send_to_new_relic env var set to false" do
      it "should not send stats to new relic and not clear state" do
        Indiana.set_stat("foo", "bar")
        expect Indiana.get_stats |> to(eq %{"foo" => "bar"})
        Indiana.send_stats
        expect Indiana.get_stats |> to(eq %{"foo" => "bar"})
      end
    end

    context "with send_to_new_relic env var set to true" do
      xit "should send stats to new relic and clear state" do
        use_cassette "indiana_send_stats", match_requests: [:headers, :body] do
          Indiana.set_stat("foo", "bar")
          assert Indiana.get_stats === %{"foo" => "bar"}
          Indiana.send_stats
          assert Indiana.get_stats === %{}
        end
      end
    end
  end
end
