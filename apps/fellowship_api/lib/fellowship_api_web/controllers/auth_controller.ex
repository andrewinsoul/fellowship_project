defmodule FellowshipApiWeb.AuthController do
  use FellowshipApiWeb, :controller
  alias FellowshipApi.Accounts

  def register_and_check_in(conn, params) do
    case Accounts.create_member(params) do
      {:ok, member} ->
        conn
        |> put_status(:created)
        |> json(%{
          data: %{
            member: member_json(member),
            token: issue_token(member),
            attendance: nil,
            message:
              "Your account has been created. You can check in when a meeting is accepting attendance."
          }
        })

      {:error, changeset} ->
        if unique_constraint_error?(changeset) do
          conn
          |> put_status(:conflict)
          |> json(%{
            error: %{
              code: "unique_constraint_violation",
              message: "A record with these details already exists."
            }
          })
        else
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{
            error: %{
              code: "validation_failed",
              message: "Please check the submitted details...",
              details: errors_on(changeset)
            }
          })
        end
    end
  end

  defp unique_constraint_error?(changeset) do
    Enum.any?(changeset.errors, fn {_field, {_message, opts}} ->
      opts[:constraint] == :unique
    end)
  end

  def login(conn, %{"login" => login, "password" => password}) do
    case Accounts.authenticate(login, password) do
      {:ok, member} ->
        json(conn, %{data: %{member: member_json(member), token: issue_token(member)}})

      {:error, _} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{
          error: %{
            code: "invalid_credentials",
            message: "The details provided could not be verified."
          }
        })
    end
  end

  def login(conn, _),
    do:
      conn
      |> put_status(:unprocessable_entity)
      |> json(%{
        error: %{code: "missing_credentials", message: "Login and password are required."}
      })

  def logout(conn, _params),
    do: json(conn, %{data: %{message: "Signed out. Discard the token on this device."}})

  def forgot_password(conn, %{"email" => email}) when is_binary(email) do
    if String.match?(String.trim(email), ~r/^[^\s]+@[^\s]+\.[^\s]+$/) do
      Accounts.request_password_reset(email)
    end

    json(conn, %{data: %{message: "If an account matches that email address, recovery instructions will be sent."}})
  end

  def forgot_password(conn, _params) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: %{code: "invalid_email", message: "A valid email address is required."}})
  end

  def reset_password(conn, %{"token" => token, "password" => password})
      when is_binary(token) and is_binary(password) and byte_size(password) >= 8 and byte_size(password) <= 72 do
    case Accounts.reset_password(token, password) do
      {:ok, :ok} -> json(conn, %{data: %{message: "Password updated. Please sign in again on your devices."}})
      _ -> conn |> put_status(:unprocessable_entity) |> json(%{error: %{code: "invalid_or_expired_token", message: "This reset link is invalid or has expired. Request a new one."}})
    end
  end

  def reset_password(conn, _params) do
    conn |> put_status(:unprocessable_entity) |> json(%{error: %{code: "invalid_reset_request", message: "Provide a valid reset token and a password of at least 8 characters."}})
  end

  def issue_token(member), do: FellowshipApi.AuthToken.sign(member)

  def member_json(member) do
    %{
      id: member.id,
      full_name: member.full_name,
      email: member.email,
      phone_number: member.phone_number,
      status: member.status
    }
  end

  def attendance_json(attendance, meeting) do
    %{
      id: attendance.id,
      checked_in_at: attendance.checked_in_at,
      meeting: %{
        id: meeting.id,
        title: meeting.title,
        starts_at: meeting.starts_at,
        ends_at: meeting.ends_at
      }
    }
  end

  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
