defmodule FellowshipWeb.Middleware.RequireAuth do
  use Hologram.Middleware

  @token_max_age 60 * 60 * 24 * 30

  @impl Hologram.Middleware
  def call(server, _opts) do
    token = get_session(server, :auth_token)
    session_member_id = get_session(server, :member_id)

    case authenticated_member(token, session_member_id) do
      {:ok, _member} ->
        server

      :error ->
        server
        |> delete_session(:auth_token)
        |> delete_session(:member_id)
        |> put_redirect(FellowshipWeb.LoginPage)
    end
  end

  defp authenticated_member(token, session_member_id)
       when is_binary(token) and not is_nil(session_member_id) do
    with {:ok, %{id: token_member_id, token_version: token_version}} <-
           FellowshipApi.AuthToken.verify(token, max_age: @token_max_age),
         true <- token_member_id == session_member_id,
         %FellowshipApi.Accounts.Member{} = member <-
           FellowshipApi.Accounts.get_member(session_member_id),
         true <- member.status == "active",
         true <- member.token_version == token_version do
      {:ok, member}
    else
      _ -> :error
    end
  end

  defp authenticated_member(_token, _session_member_id), do: :error
end
