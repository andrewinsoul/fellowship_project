defmodule FellowshipWeb.ForgotPasswordPage do
  use Hologram.Page

  route "/forgot-password"
  layout FellowshipWeb.MainLayout

  def init(_params, component, _server) do
    put_state(component, :message, "")
  end

  def template do
    ~HOLO"""
    <main class="auth-shell">
      <FellowshipWeb.BrandMark cid="forgot_password_brand" />
      <section class="auth-card">
        <p class="eyebrow">ACCOUNT RECOVERY</p>
        <h1>Forgot your password?</h1>
        <p>Enter the email address associated with your account.</p>
        <form class="form-stack" $submit={command: :forgot_password}>
          <FellowshipWeb.Input
            cid="recovery_email"
            name="email"
            label="Email address"
            type="email"
            autocomplete="email"
            required={true}
          />
          <p class="auth-message">{@message}</p>
          <FellowshipWeb.Button cid="forgot_password_submit" type="submit" class_name="full">Continue</FellowshipWeb.Button>
        </form>
        <p class="auth-switch">
          <a href="/login">Back to sign in</a>
        </p>
      </section>
    </main>
    """
  end

  def command(:forgot_password, params, server) do
    event = Map.get(params, :event, %{})
    email = event_value(event, :email)

    FellowshipApi.Accounts.request_password_reset(email)
    put_action(server, :recovery_submitted,
      message: "If an account matches that email address, recovery instructions will be sent."
    )
  end

  defp event_value(event, key) when is_map(event) do
    value = Map.get(event, key, Map.get(event, Atom.to_string(key), ""))
    if is_binary(value), do: value, else: ""
  end


  def action(:recovery_submitted, params, component) do
    put_state(component, :message, params.message)
  end
end
