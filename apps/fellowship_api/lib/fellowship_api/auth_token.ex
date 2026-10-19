defmodule FellowshipApi.AuthToken do
  @moduledoc """
  Signs and verifies member tokens using the web endpoint's configured secret.

  The API application must not use the endpoint module as the token secret
  provider because the API endpoint is no longer started in the two-app setup.
  """

  @salt "member auth"

  def sign(member) do
    Phoenix.Token.sign(secret_key_base(), @salt, %{
      id: member.id,
      token_version: member.token_version || 0
    })
  end

  def verify(token, opts \\ []) when is_binary(token) do
    Phoenix.Token.verify(secret_key_base(), @salt, token, opts)
  end

  defp secret_key_base do
    :fellowship_web
    |> Application.fetch_env!(FellowshipWeb.Endpoint)
    |> Keyword.fetch!(:secret_key_base)
  end
end
