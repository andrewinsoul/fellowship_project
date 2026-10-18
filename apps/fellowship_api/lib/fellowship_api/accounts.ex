defmodule FellowshipApi.Accounts do
  import Ecto.Query, warn: false
  alias FellowshipApi.Repo
  alias FellowshipApi.Accounts.Member

  def get_member(id), do: Repo.get(Member, id)

  def get_member_by_login(login) when is_binary(login) do
    normalized = String.trim(login)

    Repo.one(
      from m in Member,
        where:
          fragment("lower(?) = lower(?)", m.email, ^normalized) or m.phone_number == ^normalized
    )
  end

  def create_member(attrs) do
    %Member{}
    |> Member.registration_changeset(attrs)
    |> Repo.insert()
  end

  def update_member(%Member{} = member, attrs) do
    member
    |> Member.profile_changeset(attrs)
    |> Repo.update()
  end

  def request_password_reset(email) when is_binary(email) do
    normalized = String.trim(String.downcase(email))

    case Repo.one(from m in Member, where: fragment("lower(?) = ?", m.email, ^normalized)) do
      %Member{status: "active", email: member_email} = member when is_binary(member_email) ->
        token = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
        token_hash = :crypto.hash(:sha256, token) |> Base.encode16(case: :lower)
        expires_at = DateTime.add(DateTime.utc_now(), 30 * 60, :second) |> DateTime.truncate(:second)

        Repo.transaction(fn ->
          Repo.delete_all(from r in FellowshipApi.Accounts.PasswordResetToken, where: r.member_id == ^member.id)
          case %FellowshipApi.Accounts.PasswordResetToken{}
               |> FellowshipApi.Accounts.PasswordResetToken.changeset(%{member_id: member.id, token_hash: token_hash, expires_at: expires_at})
               |> Repo.insert() do
            {:ok, _reset} ->
              case FellowshipApi.Mailer.send_password_reset(member_email, token) do
                :ok -> :ok
                {:error, reason} -> Repo.rollback(reason)
              end
            {:error, changeset} -> Repo.rollback(changeset)
          end
        end)

      _ -> :ok
    end

    :ok
  end

  def reset_password(token, password) when is_binary(token) and is_binary(password) do
    token_hash = :crypto.hash(:sha256, token) |> Base.encode16(case: :lower)
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    Repo.transaction(fn ->
      reset = Repo.one(from r in FellowshipApi.Accounts.PasswordResetToken,
        where: r.token_hash == ^token_hash and r.expires_at > ^now,
        lock: "FOR UPDATE")

      if reset do
        member = Repo.one!(from m in Member, where: m.id == ^reset.member_id, lock: "FOR UPDATE")
        changeset = Ecto.Changeset.change(member,
          password_hash: Bcrypt.hash_pwd_salt(password),
          token_version: member.token_version + 1)

        case Repo.update(changeset) do
          {:ok, _member} ->
            Repo.delete_all(from r in FellowshipApi.Accounts.PasswordResetToken, where: r.member_id == ^member.id)
            :ok
          {:error, changeset} -> Repo.rollback(changeset)
        end
      else
        Repo.rollback(:invalid_or_expired_token)
      end
    end)
  end

  def authenticate(login, password) when is_binary(login) and is_binary(password) do
    case get_member_by_login(login) do
      %Member{password_hash: hash, status: "active"} = member when is_binary(hash) ->
        if Bcrypt.verify_pass(password, hash),
          do: {:ok, member},
          else: {:error, :invalid_credentials}

      _ ->
        Bcrypt.no_user_verify()
        {:error, :invalid_credentials}
    end
  end
end
