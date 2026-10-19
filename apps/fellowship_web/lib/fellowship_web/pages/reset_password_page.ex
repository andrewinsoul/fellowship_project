defmodule FellowshipWeb.ResetPasswordPage do
  use Hologram.Page
  route "/reset-password"
  layout FellowshipWeb.MainLayout

  def init(params, component, _server) do
    component |> put_state(:token, Map.get(params, "token", "")) |> put_state(:message, "")
  end

  def template do
    ~HOLO"""
    <main class="auth-shell">
      <FellowshipWeb.BrandMark cid="reset_password_brand" />
      <section class="auth-card">
        <p class="eyebrow">ACCOUNT RECOVERY</p>
        <h1>Choose a new password</h1>
        <p>Use at least 8 characters. This reset link can only be used once.</p>
        <form class="form-stack" $submit={command: :reset_password}>
          <FellowshipWeb.PasswordInput
            cid="reset_password"
            label="New password"
            name="password"
            autocomplete="new-password"
            required={true}
            minlength={8}
          />
          <p class="auth-message">{@message}</p>
          <FellowshipWeb.Button cid="reset_password_submit" type="submit" class_name="full">Reset password</FellowshipWeb.Button>
        </form>
        <p class="auth-switch">
          <a href="/login">Back to sign in</a>
        </p>
      </section>
    </main>
    """
  end

  def command(:reset_password, params, server) do
    event = Map.get(params, :event, %{})
    token = Map.get(params, :token, Map.get(event, :token, ""))
    password = event_value(event, :password)
    case FellowshipApi.Accounts.reset_password(token, password) do
      {:ok, :ok} -> put_action(server, :reset_result, message: "Password updated. Please sign in again on your devices.", success: true)
      _ -> put_action(server, :reset_result, message: "This reset link is invalid or expired. Request a new one.", success: false)
    end
  end

  def action(:reset_result, params, component) do
    if params.success do
      put_page(component, FellowshipWeb.LoginPage)
    else
      put_state(component, :message, params.message)
    end
  end

  defp event_value(event, key) do
    value = Map.get(event, key, Map.get(event, Atom.to_string(key), ""))
    if is_binary(value), do: value, else: ""
  end
end
