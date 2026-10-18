defmodule FellowshipApi.Accounts.PasswordResetToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "password_reset_tokens" do
    field :token_hash, :string
    field :expires_at, :utc_datetime
    belongs_to :member, FellowshipApi.Accounts.Member
    timestamps(type: :utc_datetime)
  end

  def changeset(token, attrs) do
    token
    |> cast(attrs, [:member_id, :token_hash, :expires_at])
    |> validate_required([:member_id, :token_hash, :expires_at])
    |> unique_constraint(:token_hash)
    |> foreign_key_constraint(:member_id)
  end
end
