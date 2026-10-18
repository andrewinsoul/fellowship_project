defmodule FellowshipApi.Repo.Migrations.AddPasswordResetTokensAndMemberTokenVersion do
  use Ecto.Migration

  def change do
    alter table(:members) do
      add :token_version, :integer, null: false, default: 0
    end

    create table(:password_reset_tokens) do
      add :member_id, references(:members, on_delete: :delete_all), null: false
      add :token_hash, :string, null: false
      add :expires_at, :utc_datetime, null: false
      timestamps(type: :utc_datetime)
    end

    create unique_index(:password_reset_tokens, [:token_hash])
    create index(:password_reset_tokens, [:member_id])
    create index(:password_reset_tokens, [:expires_at])
  end
end
