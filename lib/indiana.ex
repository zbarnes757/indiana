defmodule Indiana do
  @moduledoc false

  use Application

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Indiana.Counter, []),
      worker(Indiana.Gauge, []),
      worker(Indiana.TimeSeries, []),
      worker(Indiana.TimeSeries.Aggregated, []),
      worker(Indiana.TimeSeries.Aggregator, []),
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
