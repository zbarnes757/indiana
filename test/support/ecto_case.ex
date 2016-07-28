defmodule Indiana.EctoCase do
  use ExUnit.CaseTemplate

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Indiana.TestRepo)
  end
end
