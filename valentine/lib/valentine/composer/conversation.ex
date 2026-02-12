defmodule Valentine.Composer.Conversation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  schema "conversations" do
    belongs_to :workspace, Valentine.Composer.Workspace,
      type: Ecto.UUID,
      foreign_key: :workspace_id

    field :user_email, :string
    field :messages, {:array, :map}, default: []

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:workspace_id, :user_email, :messages])
    |> validate_required([:workspace_id, :user_email, :messages])
    |> unique_constraint([:workspace_id, :user_email])
  end
end
