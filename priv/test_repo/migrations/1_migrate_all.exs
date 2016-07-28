defmodule Indiana.TestRepo.Migrations.MigrateAll do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
    end
  end
end
