defmodule Indiana do
  use GenServer
  @name :indiana

  # Public API
  def start_link, do: GenServer.start_link(__MODULE__, :ok, name: @name)

  def set_stat(key, value), do: GenServer.cast(@name, {:set, key, value})

  def get_stats, do: GenServer.call(@name, :stats)

  def send_stats, do: GenServer.cast(@name, :send)

  def clear_stats, do: GenServer.cast(@name, :clear)

  # Genserver API
  def init(:ok), do: {:ok, Map.new}

  def handle_call(:stats, _from, stats), do: {:reply, stats, stats}

  def handle_cast(:clear, _info), do: {:noreply, Map.new}
  def handle_cast({:set, key, value}, stats), do: {:noreply, Map.put(stats, key, value)}
  def handle_cast(:send, stats) do
    {:noreply, stats}
  end
end
