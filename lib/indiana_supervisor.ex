defmodule IndianaSupervisor do
  use Supervisor

  @doc false
  def start_link, do: Supervisor.start_link(__MODULE__, [])

  @doc false
  def init([]) do
    children = [ worker(Indiana, []) ]

    supervise(children, strategy: :one_for_one)
  end
end
