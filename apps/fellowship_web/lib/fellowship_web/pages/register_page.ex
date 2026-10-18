defmodule FellowshipWeb.RegisterPage do
  use Hologram.Page

  route("/register")
  layout(FellowshipWeb.MainLayout)

  def init(_params, component, _server) do
    component
    |> put_state(:message, "")
    |> put_state(:message_type, "")
  end

  def template do
    ~HOLO"""
    <main class="auth-shell">
      <header class="auth-brand">
        <div class="brand-mark"><span>✝</span><i>●</i><i>●</i></div>
        <div><strong>FGBMFI <span>Connect</span></strong><small>Connected in fellowship. Growing in faith.</small></div>
      </header>
      <section class="auth-card register-card">
          <p class="eyebrow">JOIN THE COMMUNITY</p>
          <h2>Create an account</h2>
          <p>Enter your details to get started.</p>
          <form class="form-stack" $submit={command: :register, params: %{}} novalidate>
            <label> Full name
              <input type="text" name="full_name" autocomplete="name" required minlength="2" />
            </label>
            <label> Email address
              <input type="email" required name="email" autocomplete="email" />
            </label>
            <label> Phone number
              <input type="tel" name="phone_number" autocomplete="tel" required minlength="7" />
            </label>
            <label> Gender
              <select name="gender" required>
                <option value="">Select gender</option>
                <option value="male">Male</option>
                <option value="female">Female</option>
              </select>
            </label>
            <label> Residence address
              <input type="text" name="residence_address" autocomplete="street-address" required />
            </label>
            <FellowshipWeb.PasswordInput cid="register_password" label="Password" name="password" autocomplete="new-password" required={true} minlength={8} />
            <p class="auth-message {@message_type}" role="status" aria-live="polite">{@message}</p>
            <button class="button primary full" type="submit">Create account</button>
          </form>
          <p class="auth-switch">Already have an account? <a href="/login">Sign in</a></p>
          <p class="fineprint">A community of faith, fellowship, and service.</p>
      </section>
    </main>
    """
  end

  def command(:register, params, server) do
    event = event_params(params)

    attrs = %{
      "full_name" => event_value(event, :full_name),
      "email" => event_value(event, :email),
      "phone_number" => event_value(event, :phone_number),
      "gender" => event_value(event, :gender),
      "residence_address" => event_value(event, :residence_address),
      "password" => event_value(event, :password)
    }

    case FellowshipApi.Accounts.create_member(attrs) do
      {:ok, member} ->
        token = FellowshipApiWeb.AuthController.issue_token(member)

        server
        |> put_session(:auth_token, token)
        |> put_session(:member_id, member.id)
        |> put_action(:auth_result,
          message: "Your account has been created successfully. Your session is ready.",
          success: true
        )

      {:error, changeset} ->
        message = registration_error(changeset)
        put_action(server, :auth_result, message: message, success: false)
    end
  end

  def action(:auth_result, params, component) do
    if params.success do
      put_page(component, FellowshipWeb.HomePage)
    else
      component
      |> put_state(:message, params.message)
      |> put_state(:message_type, "error")
    end
  end

  defp event_params(params) when is_map(params) do
    params
    |> Map.get(:event, Map.get(params, "event", %{}))
    |> case do
      event when is_map(event) -> event
      _ -> %{}
    end
  end

  defp event_params(_params), do: %{}

  defp event_value(event, key) when is_map(event) do
    value = Map.get(event, key, Map.get(event, Atom.to_string(key), ""))
    if is_binary(value), do: String.trim(value), else: ""
  end

  defp registration_error(changeset) do
    cond do
      Enum.any?(changeset.errors, fn {field, _} -> field in [:email, :phone_number] end) ->
        "An account with those contact details may already exist, or the details are invalid."

      Enum.any?(changeset.errors, fn {field, _} -> field == :password end) ->
        "Choose a password with at least 8 characters."

      true ->
        "Please check your details and try again. All required fields must be completed."
    end
  end
end
