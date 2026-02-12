defmodule Valentine.Repo.Migrations.CreateConversations do
  use Ecto.Migration

  def change do
    create table(:conversations, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false

      add :workspace_id, references(:workspaces, type: :binary_id, on_delete: :delete_all),
        null: false

      add :user_email, references(:users, type: :string, column: :email, on_delete: :delete_all),
        null: false

      add :messages, :jsonb, null: false, default: "[]"

      timestamps(type: :utc_datetime)
    end

    # Index for fetching conversations by workspace and user
    create index(:conversations, [:workspace_id, :user_email])

    # Unique constraint to ensure one conversation per workspace-user pair
    create unique_index(:conversations, [:workspace_id, :user_email])
  end
end
