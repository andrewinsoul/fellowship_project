defmodule FellowshipWeb.ProfilePage do
  use Hologram.Page

  route("/profile")
  layout(FellowshipWeb.MainLayout)
  middleware(FellowshipWeb.Middleware.RequireAuth)

  def init(_params, component, server) do
    member = FellowshipApi.Accounts.get_member(get_session(server, :member_id))

    component
    |> put_state(:member_name, member.full_name || "Fellowship member")
    |> put_state(:member_initials, initials(member.full_name))
    |> put_state(:full_name, member.full_name || "")
    |> put_state(:email, member.email || "")
    |> put_state(:phone_number, member.phone_number || "")
    |> put_state(:status, member.status || "Member")
    |> put_state(:message, "")
    |> put_state(:message_type, "")
    |> put_state(:loading, false)
  end

  def template do
    ~HOLO"""
    <div class="app-shell">
      <aside class="sidebar">
        <div class="brand">
          <div class="brand-mark small">
            <span>✝</span>
            <i>●</i>
            <i>●</i>
          </div>
          <div>
            <b>FGBMFI</b>
            <small>Connect</small>
          </div>
        </div>
        <p class="chapter-label">YOUR FELLOWSHIP</p>
        <nav>
          <a class="nav-item" href="/home">
            <span class="nav-icon">⌂</span>
            Home
          </a>
          <a class="nav-item" href="/attendance">
            <span class="nav-icon">▦</span>
            Attendance
          </a>
          <a class="nav-item" href="/quotations">
            <span class="nav-icon">▤</span>
            Scripture
          </a>
          <a class="nav-item active" href="/profile">
            <span class="nav-icon">○</span>
            Profile
          </a>
          <a class="nav-item" href="/meetings">
            <span class="nav-icon">◷</span>
            Meetings
          </a>
          <a class="nav-item" href="/settings">
            <span class="nav-icon">⚙</span>
            Preferences
          </a>
        </nav>
        <div class="sidebar-bottom">
          <div class="mini-member">
            <div class="avatar">{@member_initials}</div>
            <div>
              <b>{@member_name}</b>
              <small>Member</small>
            </div>
          </div>
          <form $submit={command: :logout}>
            <button class="nav-item logout" type="submit">
              <span class="nav-icon">↪</span>
              Sign out
            </button>
          </form>
        </div>
      </aside>
      <main class="main-area">
        <header class="topbar">
          <div>
            <span class="eyebrow">FULL GOSPEL BUSINESS MEN’S FELLOWSHIP</span>
            <h2>Profile</h2>
          </div>
          <div class="avatar top-avatar">{@member_initials}</div>
        </header>
        <div class="page-content">
          <section class="section-head">
            <div>
              <div class="eyebrow">YOUR ACCOUNT</div>
              <h1>My profile</h1>
              <p class="muted">Keep your contact information up to date.</p>
            </div>
          </section>
          <section class="card profile-card">
            <div class="profile-hero">
              <div class="avatar profile-avatar">{@member_initials}</div>
              <div>
                <h1>{@full_name}</h1>
                <p class="muted">{@email}</p>
                <FellowshipWeb.StatusPill cid="profile_status" label={@status} />
              </div>
            </div>
            {%if @message != ""}
              <div class="notice {@message_type}">{@message}</div>
            {/if}
            <form class="form-grid" $submit={action: :submit_save_profile}>
              <FellowshipWeb.Input cid="profile_full_name" name="full_name" label="Full name" type="text" value={@full_name} required={true} />
              <FellowshipWeb.Input cid="profile_email" name="email" label="Email address" type="email" value={@email} required={true} />
              <FellowshipWeb.Input cid="profile_phone" name="phone_number" label="Phone number" type="tel" value={@phone_number} required={true} />
              <div class="form-actions">
                <FellowshipWeb.Button cid="profile_save" type="submit" loading={@loading}>Save changes</FellowshipWeb.Button>
              </div>
            </form>
            <div class="settings-links">
              <a href="/settings">
                ♧ Notification preferences
                <span>→</span>
              </a>
              <form $submit={command: :logout}>
                <button type="submit">
                  ↪ Sign out
                  <span>→</span>
                </button>
              </form>
            </div>
          </section>
        </div>
        <footer class="main-footer">A community of faith, fellowship, and service.</footer>
      </main>

      <nav class="mobile-nav" aria-label="Mobile navigation">
        <a href="/home">
          <span aria-hidden="true">⌂</span>
          <small>Home</small>
        </a>
        <a href="/attendance">
          <span aria-hidden="true">▦</span>
          <small>Attendance</small>
        </a>
        <a href="/quotations">
          <span aria-hidden="true">▤</span>
          <small>Scripture</small>
        </a>
        <a class="active" href="/profile" aria-current="page">
          <span aria-hidden="true">○</span>
          <small>Profile</small>
        </a>
      </nav>
    </div>
    """
  end

  def action(:submit_save_profile, params, component) do
    component
    |> put_state(:loading, true)
    |> put_command(:save_profile, event: Map.get(params, :event, %{}))
  end

  def action(:profile_saved, params, component) do
    component
    |> put_state(:loading, false)
    |> put_state(:full_name, params.full_name || "")
    |> put_state(:email, params.email || "")
    |> put_state(:phone_number, params.phone_number || "")
    |> put_state(:member_name, params.full_name || "Fellowship member")
    |> put_state(:member_initials, initials(params.full_name))
    |> put_state(:message, params.message)
    |> put_state(:message_type, params.message_type)
  end

  def action(:logged_out, _params, component), do: put_page(component, FellowshipWeb.LoginPage)

  def command(:save_profile, params, server) do
    event = Map.get(params, :event, %{})
    member = FellowshipApi.Accounts.get_member(get_session(server, :member_id))

    attrs = %{
      "full_name" => event_value(event, :full_name),
      "email" => event_value(event, :email),
      "phone_number" => event_value(event, :phone_number)
    }

    case FellowshipApi.Accounts.update_member(member, attrs) do
      {:ok, updated} ->
        put_action(server, :profile_saved,
          full_name: updated.full_name,
          email: updated.email,
          phone_number: updated.phone_number,
          message: "Your profile has been updated.",
          message_type: "success"
        )

      {:error, changeset} ->
        message =
          if changeset.errors == [],
            do: "Please review your details and try again.",
            else:
              "We couldn't save those details. Check the name, email, and phone number and try again."

        put_action(server, :profile_saved,
          full_name: attrs["full_name"],
          email: attrs["email"],
          phone_number: attrs["phone_number"],
          message: message,
          message_type: "error"
        )
    end
  end

  def command(:logout, _params, server),
    do:
      server
      |> delete_session(:auth_token)
      |> delete_session(:member_id)
      |> put_action(:logged_out)

  defp event_value(event, key) when is_map(event) do
    value = Map.get(event, key, Map.get(event, Atom.to_string(key), ""))
    if is_binary(value), do: String.trim(value), else: ""
  end

  defp initials(nil), do: "F"

  defp initials(name),
    do:
      name
      |> String.split()
      |> Enum.take(2)
      |> Enum.map(&String.first/1)
      |> Enum.join()
      |> String.upcase()
end
