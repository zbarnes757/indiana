Mix.Task.run "ecto.drop", ["quiet", "-r", "Indiana.TestRepo"]
Mix.Task.run "ecto.create", ["quiet", "-r", "Indiana.TestRepo"]
Mix.Task.run "ecto.migrate", ["-r", "Indiana.TestRepo"]

Indiana.TestRepo.start_link
ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Indiana.TestRepo, :manual)
