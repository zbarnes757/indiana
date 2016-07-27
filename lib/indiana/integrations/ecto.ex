defmodule Indiana.Integrations.Ecto do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      defoverridable [__log__: 1]
      def __log__(entry) do
        if entry.query_time, do: Indiana.update_metrics("Component/EctoQueryTime[milliseconds|call]", entry.query_time)

        super(entry)
      end
    end
  end
end
