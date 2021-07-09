defmodule TodoApp.Repo.Migrations.AddCompletedToTodos do
  use Ecto.Migration

  def change do
    alter table(:todos) do
      add :completed, :boolean, default: false
    end
  end
end
