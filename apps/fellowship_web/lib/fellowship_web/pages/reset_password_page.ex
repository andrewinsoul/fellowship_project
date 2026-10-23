defmodule FellowshipWeb.ResetPasswordPage do
  use Hologram.Page

  alias Hologram.UI.Link
  alias FellowshipWeb.{PasswordInput, Button, BrandMark}

  route("/reset-password/:token")
  param(:token, :string)

  layout(FellowshipWeb.MainLayout)

  def init(params, component, _server) do
    token = Map.get(params, :token, Map.get(params, "token", ""))

    component
    |> put_state(:token, token)
    |> put_state(:message, "")
    |> put_state(:loading, false)
  end

  def template do
    ~HOLO"""
    <main class="auth-shell">
      <BrandMark cid="reset_password_brand" />
      <section class="auth-card">
        <p class="eyebrow">ACCOUNT RECOVERY</p>
        <h1>Choose a new password</h1>
        <p>Use at least 8 characters. This reset link can only be used once.</p>
        <form class="form-stack" $submit={action: :submit_reset_password}>
          <PasswordInput
            cid="reset_password"
            label="New password"
            name="password"
            autocomplete="new-password"
            required={true}
            minlength={8}
          />
          <p class="auth-message">{@message}</p>
          <Button cid="reset_password_submit" type="submit" class_name="full" loading={@loading}>Reset password</Button>
        </form>
        <p class="auth-switch">
          <Link to={FellowshipWeb.LoginPage}>Back to sign in</Link>
        </p>
      </section>
    </main>
    """
  end

  def action(:submit_reset_password, params, component) do
    component
    |> put_state(:loading, true)
    |> put_command(:reset_password,
      token: component.state.token,
      event: Map.get(params, :event, %{})
    )
  end

  def action(:reset_result, params, component) do
    if params.success do
      component
      |> put_state(:loading, false)
      |> put_page(FellowshipWeb.LoginPage)
    else
      component
      |> put_state(:loading, false)
      |> put_state(:message, params.message)
    end
  end

  def command(:reset_password, params, server) do
    event = Map.get(params, :event, %{})
    token = Map.get(params, :token, Map.get(event, :token, ""))
    password = event_value(event, :password)

    case FellowshipApi.Accounts.reset_password(token, password) do
      {:ok, :ok} ->
        put_action(server, :reset_result,
          message: "Password updated. Please sign in again on your devices.",
          success: true
        )

      _ ->
        put_action(server, :reset_result,
          message: "This reset link is invalid or expired. Request a new one.",
          success: false
        )
    end
  end

  defp event_value(event, key) do
    value = Map.get(event, key, Map.get(event, Atom.to_string(key), ""))
    if is_binary(value), do: value, else: ""
  end
end
