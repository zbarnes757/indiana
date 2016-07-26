defmodule Indiana do
  use GenServer
  @name :indiana
  @micro_seconds_to_seconds 1_000_000

  # Public API
  def start(_type, _args), do: IndianaSupervisor.start_link

  def start_link, do: GenServer.start_link(__MODULE__, :ok, name: @name)

  def set_stat(key, value), do: GenServer.cast(@name, {:set, key, value})

  def update_metrics(component, duration), do: GenServer.cast(@name, {:update_metrics, component, duration})

  def get_stats, do: GenServer.call(@name, :stats)

  def send_stats, do: GenServer.cast(@name, :send)

  def clear_stats, do: GenServer.cast(@name, :clear)

  # Genserver API
  def init(:ok), do: {:ok, Map.new}

  def handle_call(:stats, _from, stats), do: {:reply, stats, stats}

  def handle_cast(:clear, _info), do: {:noreply, Map.new}
  def handle_cast({:set, key, value}, stats), do: {:noreply, Map.put(stats, key, value)}
  def handle_cast({:update_metrics, component, duration}, stats) do
    new_stats = Map.put(stats, "metrics", Map.merge(%{component => duration / @micro_seconds_to_seconds}, stats["metrics"] || %{}))
    {:noreply, new_stats}
  end
  def handle_cast(:send, stats) do
    IO.inspect stats
    {:noreply, stats}
  end
end
