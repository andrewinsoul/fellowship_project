defmodule FellowshipWeb.LoginPage do
  use Hologram.Page

  route("/login")
  layout(FellowshipWeb.MainLayout)
  middleware(FellowshipWeb.Middleware.RedirectIfAuthenticated)

  def init(_params, component, _server) do
    component
    |> put_state(:message, "")
    |> put_state(:message_type, "")
    |> put_state(:loading, false)
  end

  def template do
    ~HOLO"""
    <main class="auth-shell">
      <FellowshipWeb.BrandMark cid="login_brand" />
      <section class="auth-card">
        <p class="eyebrow">YOUR COMMUNITY AWAITS</p>
        <h2>Sign in</h2>
        <p>Use your email address or phone number.</p>
        <form class="form-stack" $submit={action: :submit_login}>
          <FellowshipWeb.Input
            cid="login_identifier"
            name="login"
            label="Email or phone number"
            type="text"
            autocomplete="username"
            required={true}
          />
          <FellowshipWeb.PasswordInput
            cid="login_password"
            label="Password"
            name="password"
            autocomplete="current-password"
            required={true}
            minlength={0}
          />
          <p class="auth-message {@message_type}">{@message}</p>
          <FellowshipWeb.Button cid="login_submit" type="submit" class_name="full" loading={@loading}>Sign in</FellowshipWeb.Button>
        </form>
        <p class="auth-switch">
          Don't have an account?
          <a href="/register">Create an account</a>
        </p>
        <p class="auth-switch">
          <a href="/forgot-password">Forgot your password?</a>
        </p>
        <p class="fineprint">A community of faith, fellowship, and service.</p>
      </section>
    </main>
    """
  end

  def action(:submit_login, params, component) do
    component
    |> put_state(:loading, true)
    |> put_command(:login, event: Map.get(params, :event, %{}))
  end

  def action(:auth_result, params, component) do
    if params.success do
      component
      |> put_state(:loading, false)
      |> put_page(FellowshipWeb.HomePage)
    else
      component
      |> put_state(:loading, false)
      |> put_state(:message, params.message)
      |> put_state(:message_type, "error")
    end
  end

  def command(:login, params, server) do
    event = Map.get(params, :event, %{})
    login = event_value(event, :login)
    password = event_value(event, :password)

    case FellowshipApi.Accounts.authenticate(login, password) do
      {:ok, member} ->
        token = FellowshipApiWeb.AuthController.issue_token(member)

        server
        |> put_session(:auth_token, token)
        |> put_session(:member_id, member.id)
        |> put_action(:auth_result,
          message: "You're signed in successfully. Your account session is ready.",
          success: true
        )

      {:error, _reason} ->
        put_action(server, :auth_result,
          message: "The details provided could not be verified.",
          success: false
        )
    end
  end

  defp event_value(event, key) when is_map(event) do
    value = Map.get(event, key, Map.get(event, Atom.to_string(key), ""))
    if is_binary(value), do: value, else: ""
  end
end
