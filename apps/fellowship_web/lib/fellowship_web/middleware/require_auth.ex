defmodule FellowshipWeb.Middleware.RequireAuth do
  use Hologram.Middleware

  @impl Hologram.Middleware
  def call(server, _opts) do
    member_id = get_session(server, :member_id)

    if is_nil(member_id) or is_nil(FellowshipApi.Accounts.get_member(member_id)) do
      server
      |> delete_session(:auth_token)
      |> delete_session(:member_id)
      |> put_redirect(FellowshipWeb.LoginPage)
    else
      server
    end
  end
end
