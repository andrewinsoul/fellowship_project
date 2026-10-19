defmodule FellowshipWeb.RegisterPage do
  use Hologram.Page

  route("/register")
  layout(FellowshipWeb.MainLayout)

  def init(_params, component, _server) do
    component
    |> put_state(:message, "")
    |> put_state(:message_type, "")
    |> put_state(:loading, false)
  end

  def template do
    ~HOLO"""
    <main class="auth-shell">
    <FellowshipWeb.BrandMark cid="register_brand" />
      <section class="auth-card register-card" id="register-id">
        <p class="eyebrow">JOIN THE COMMUNITY</p>
        <h2>Create an account</h2>
        <p>Enter your details to get started.</p>
        <form class="form-stack" $submit={action: :submit_register} novalidate>
          <FellowshipWeb.Input
            cid="register_full_name"
            name="full_name"
            label="Full name"
            type="text"
            autocomplete="name"
            required={true}
            minlength={2}
          />
          <FellowshipWeb.Input
            cid="register_email"
            name="email"
            label="Email address"
            type="email"
            autocomplete="email"
            required={true}
          />
          <FellowshipWeb.PasswordInput
            cid="register_password"
            label="Password"
            name="password"
            autocomplete="new-password"
            required={true}
            minlength={8}
          />
          <FellowshipWeb.Input
            cid="register_phone"
            placeholder="08012345678"
            name="phone_number"
            label="Phone number"
            type="tel"

            autocomplete="tel"
            required={true}
            minlength={7}
          />
          <FellowshipWeb.Select cid="register_gender" name="gender" label="Gender" required={true}>
            <option value="">Select gender</option>
            <option value="male">Male</option>
            <option value="female">Female</option>
          </FellowshipWeb.Select>
          <FellowshipWeb.Input
            cid="register_address"
            name="residence_address"
            label="Residence address"
            type="text"
            autocomplete="street-address"
            required={true}
          />
          <p class="auth-message {@message_type}" role="status" aria-live="polite">
            {@message}
          </p>
          <FellowshipWeb.Button cid="register_submit" type="submit" class_name="full" loading={@loading}>Create account</FellowshipWeb.Button>
        </form>
        <p class="auth-switch">
          Already have an account?
          <a href="/login">Sign in</a>
        </p>
        <p class="fineprint">A community of faith, fellowship, and service.</p>
      </section>
    </main>
    """
  end

  def action(:submit_register, params, component) do
    component
    |> put_state(:loading, true)
    |> put_command(:register, event: Map.get(params, :event, %{}))
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
