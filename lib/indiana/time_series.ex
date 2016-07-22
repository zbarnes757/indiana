defmodule Indiana.TimeSeries do
  @name :indiana_time_series

  @moduledoc """
  `Indiana.TimeSeries` is a simple time series. It's a metric that keeps track of values over time when sampled.
  It is commonly used to keep track of changing values over time to look at patterns and averages
  Examples are:
    * Response time across time
    * Download numbers over time
    * Error rates across time
  """

  ## Client API

  @doc false
  def start_link, do: GenServer.start_link(__MODULE__, :ok, name: @name)

  @doc """
  Retrieves all time series in the form of a Map.
  ## Examples
      iex> Indiana.TimeSeries.clear
      :ok
      iex> Indiana.TimeSeries.sample("all_series1", 10)
      :ok
      iex> Indiana.TimeSeries.sample("all_series2", 20)
      :ok
      iex> Indiana.TimeSeries.all |> Map.keys
      ["all_series1", "all_series2"]
  Returns `time_series` where time_series is a Map of all the time series currently existing.
  Each time series is returned as a list of pairs. Each pair is a timestamp in epoch and the value recorded.
  Each list is guaranteed to be in reverse chronological ordering, that is, the latest sample will be the first in the list.
  """
  def all, do: GenServer.call(@name, :all)

  @doc """
  Remove all time series currently stored in Indiana.
  ## Examples
      iex> Indiana.TimeSeries.sample("clear_series1", 10)
      :ok
      iex> Indiana.TimeSeries.sample("clear_series2", 20)
      :ok
      iex> Indiana.TimeSeries.all |> Enum.empty?
      false
      iex> Indiana.TimeSeries.clear
      :ok
      iex> Indiana.TimeSeries.all |> Enum.empty?
      true
  Returns `:ok`.
  """
  def clear, do: GenServer.cast(@name, :clear)

  @doc """
  Clears the specified time series from Indiana.
  ## Parameters
    * `key`: The name of the time series to clear.
  ## Examples
      iex> Indiana.TimeSeries.sample("clear_series1", 10)
      :ok
      iex> Indiana.TimeSeries.sample("clear_series2", 20)
      :ok
      iex> Indiana.TimeSeries.all |> Map.keys |> Enum.member?("clear_series1")
      true
      iex> Indiana.TimeSeries.all |> Map.keys |> Enum.member?("clear_series2")
      true
      iex> Indiana.TimeSeries.clear("clear_series1")
      :ok
      iex> Indiana.TimeSeries.all |> Map.keys |> Enum.member?("clear_series1")
      false
      iex> Indiana.TimeSeries.all |> Map.keys |> Enum.member?("clear_series2")
      true
  Returns `:ok`.
  """
  def clear(key), do: GenServer.cast(@name, {:clear, key})

  @doc """
  Get the time series for the given key.
  ## Parameters
    * `key`: The name of the time_series to retrieve.
  ## Examples
      iex> Indiana.TimeSeries.get("get_series")
      nil
      iex> Indiana.TimeSeries.sample("get_series", 10)
      :ok
      iex> Indiana.TimeSeries.get("get_series") |> Enum.count
      1
  Returns `time_series` where time_series is a list of the samples taken for the given key.
  """
  def get(key), do: GenServer.call(@name, {:get, key})

  @doc """
  Record a sample for the given key with the given value.
  ## Parameters
    * `key`: The name of the time_series to sample.
    * `value`: The value to save for the sample.
  ## Examples
      iex> Indiana.TimeSeries.sample("set_series", 5)
      :ok
      iex> Indiana.TimeSeries.get("set_series") |> hd |> elem(1)
      5
  Returns `time_series` where time_series is a list of the samples taken for that key.
  The list is guaranteed to be in reverse chronological ordering, that is, the latest sample will be the first in the list.
  Each sample is a pair that consists of a timestamp in epoch and the value recorded.
  """
  def sample(key, value), do: GenServer.cast(@name, {:sample, key, value})

  @doc """
  Times the provided function and samples the duration to the time series with the specified key.
  ## Parameters
    * `key`: The name of the time series to sample the duration to.
    * `func`: The function perform and time.
  ## Examples
      iex> Indiana.TimeSeries.time("time_time_series", fn -> :timer.sleep(50); 2 + 2 end)
      4
      iex> Indiana.TimeSeries.get("time_time_series") |> hd > 50
      true
      iex> Indiana.TimeSeries.time "time_time_series", do: :timer.sleep(50); 3 + 3
      6
  Returns `value` where value is the return value of the function that was performed.
  """
  defmacro time(key, do: block) do
    quote do
      Indiana.TimeSeries.time(unquote(key), fn -> unquote(block) end)
    end
  end
  defmacro time(key, func) do
    quote do
      {time, value} = :timer.tc(unquote(func))
      Indiana.TimeSeries.sample(unquote(key), time)

      value
    end
  end

  ## Server Callbacks

  @doc false
  def init(:ok), do: {:ok, Map.new}

  @doc false
  def handle_call(:all, _from, time_series) do
    results =
      time_series
      |> Enum.into(%{}, fn({name, queue}) -> {name, Map.get(queue, :items) |> :queue.to_list} end)

    {:reply, results, time_series}
  end

  @doc false
  def handle_call({:get, key}, _from, time_series) do
    queue =
      time_series
      |> Map.get(key)

    results = if queue do
      queue
      |> Map.get(:items)
      |> :queue.to_list
    end

    {:reply, results, time_series}
  end

  @doc false
  def handle_cast(:clear, _time_series), do: {:noreply, Map.new}

  @doc false
  def handle_cast({:clear, key}, time_series), do: {:noreply, Map.delete(time_series, key)}

  @doc false
  def handle_cast({:sample, key, value}, time_series) do
    entry = {Indiana.Time.now, value}
    duration = Indiana.Time.microseconds_from(minutes: 5)

    {:noreply, Map.update(time_series, key, Queue.timed(duration, entry), &(Queue.add(&1, entry)))}
  end

end
