defmodule Indiana.Counter do
  @name :indiana_counters

  @moduledoc """
  `Indiana.Counter` is a signed bi-directional integer counter.
  It can keep track of integers and increment and decrement them.
  It is commonly used for metrics that keep track of some cumulative value.
  Examples are:
    * Total number of downloads
    * Number of queued jobs
    * Quotas
  """

  ## Client API

  @doc false
  def start_link, do: GenServer.start_link(__MODULE__, :ok, name: @name)

  @doc """
  Retrieves all counters in the form of a map.
  ## Examples
      iex> Indiana.Counter.clear
      :ok
      iex> Indiana.Counter.set("all_counter1", 10)
      :ok
      iex> Indiana.Counter.incr("all_counter2")
      :ok
      iex> Indiana.Counter.all
      %{"all_counter1" => 10, "all_counter2" => 1}
  Returns `counters` where counters is a map of all the counters currently existing.
  """
  def all, do: GenServer.call(@name, :all)

  @doc """
  Clears all counters stored in Indiana.
  ## Examples
      iex> Indiana.Counter.clear
      :ok
      iex> Indiana.Counter.set("all_counter1", 10)
      :ok
      iex> Indiana.Counter.incr("all_counter2")
      :ok
      iex> Indiana.Counter.all
      %{"all_counter1" => 10, "all_counter2" => 1}
      iex> Indiana.Counter.clear
      :ok
      iex> Indiana.Counter.all
      %{}
  Returns `:ok`.
  """
  def clear, do: GenServer.cast(@name, :clear)

  @doc """
  Clears the specified counter from Indiana.
  ## Parameters
    * `key`: The name of the counter to clear.
  ## Examples
      iex> Indiana.Counter.clear
      :ok
      iex> Indiana.Counter.set("all_counter1", 10)
      :ok
      iex> Indiana.Counter.incr("all_counter2")
      :ok
      iex> Indiana.Counter.all
      %{"all_counter1" => 10, "all_counter2" => 1}
      iex> Indiana.Counter.clear("all_counter1")
      :ok
      iex> Indiana.Counter.all
      %{"all_counter2" => 1}
  Returns `:ok`.
  """
  def clear(key), do: GenServer.cast(@name, {:clear, key})

  @doc """
  Retrieves the current value of the specified counter.
  ## Parameters
    * `key`: The name of the counter to retrieve.
  ## Examples
      iex> Indiana.Counter.set("get_counter", 10)
      :ok
      iex> Indiana.Counter.get("get_counter")
      10
  Returns `count` where count is an integer if the counter exists, else `nil`.
  """
  def get(key), do: GenServer.call(@name, {:get, key})

  @doc """
  Sets the value of the specified counter to the specified value.
  ## Parameters
    * `key`: The name of the counter to set the value for.
    * `value`: The value to set to the counter.
  ## Examples
      iex> Indiana.Counter.set("set_counter", 10)
      :ok
      iex> Indiana.Counter.get("set_counter")
      10
  Returns `:ok`.
  """
  def set(key, value), do: GenServer.cast(@name, {:set, key, value})

  @doc """
  Increments the specified counter by 1.
  ## Parameters
    * `key`: The name of the counter to increment.
  ## Examples
      iex> Indiana.Counter.get("incr_counter")
      nil
      iex> Indiana.Counter.incr("incr_counter")
      :ok
      iex> Indiana.Counter.get("incr_counter")
      1
  Returns `:ok`.
  """
  def incr(key), do: GenServer.cast(@name, {:incr, key, 1})

  @doc """
  Increments the specified counter by the specified amount.
  ## Parameters
    * `key`: The name of the counter to increment.
    * `amount`: The amount to increment by.
  ## Examples
      iex> Indiana.Counter.get("incr_by_counter")
      nil
      iex> Indiana.Counter.incr_by("incr_by_counter", 10)
      :ok
      iex> Indiana.Counter.get("incr_by_counter")
      10
  Returns `:ok`.
  """
  def incr_by(key, amount), do: GenServer.cast(@name, {:incr, key, amount})

  @doc """
  Decrements the specified counter by 1.
  ## Parameters
    * `key`: The name of the counter to decrement.
  ## Examples
      iex> Indiana.Counter.get("decr_counter")
      nil
      iex> Indiana.Counter.decr("decr_counter")
      :ok
      iex> Indiana.Counter.get("decr_counter")
      -1
  Returns `:ok`.
  """
  def decr(key), do: GenServer.cast(@name, {:incr, key, -1})

  @doc """
  Decrements the specified counter by the specified amount.
  ## Parameters
    * `key`: The name of the counter to decrement.
    * `amount`: The amount to decrement by.
  ## Examples
      iex> Indiana.Counter.get("decr_by_counter")
      nil
      iex> Indiana.Counter.decr_by("decr_by_counter", 10)
      :ok
      iex> Indiana.Counter.get("decr_by_counter")
      -10
  Returns `:ok`.
  """
  def decr_by(key, amount), do: GenServer.cast(@name, {:incr, key, -amount})

  ## Server Callbacks

  @doc false
  def init(:ok), do: {:ok, Map.new}

  @doc false
  def handle_call(:all, _from, counters), do: {:reply, Enum.into(counters, %{}), counters}

  @doc false
  def handle_call({:get, key}, _from, counters), do: {:reply, Map.get(counters, key), counters}

  @doc false
  def handle_cast(:clear, _counters), do: {:noreply, Map.new}

  def handle_cast({:clear, key}, counters), do: {:noreply, Map.delete(counters, key)}

  @doc false
  def handle_cast({:set, key, value}, counters), do: {:noreply, Map.put(counters, key, value)}

  @doc false
  def handle_cast({:incr, key, amount}, counters), do: {:noreply, Map.update(counters, key, amount, fn(count) -> count + amount end)}
end
