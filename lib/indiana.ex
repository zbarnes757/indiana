defmodule Indiana do
  use GenServer
  @name :indiana

  # Public API
  def start_link, do: GenServer.start_link(__MODULE__, :ok, name: @name)

  def set(key, value), do: GenServer.cast(@name, {:set, key, value})

  def send_stats, do: GenServer.cast(@name, {:send})

  # Genserver API
  def init(:ok), do: {:ok, Map.new}

  def handle_cast({:set, key, value}, info), do: {:noreply, Map.put(info, key, value)}
  def handle_cast({:send}, info) do
    Apex.ap info

    {:noreply, Map.new}
  end
end
