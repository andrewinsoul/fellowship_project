defmodule FellowshipWeb.SettingsPage do
  use Hologram.Page

  route("/settings")
  layout(FellowshipWeb.MainLayout)
  middleware(FellowshipWeb.Middleware.RequireAuth)

  def init(_params, component, server) do
    member = FellowshipApi.Accounts.get_member(get_session(server, :member_id))

    component
    |> put_state(:member_name, member.full_name || "Fellowship member")
    |> put_state(:member_initials, initials(member.full_name))
    |> put_state(:push_enabled, member.notification_push_enabled)
    |> put_state(:email_enabled, member.notification_email_enabled)
    |> put_state(:reminder_minutes, member.notification_reminder_minutes || 60)
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
          <a class="nav-item" href="/profile">
            <span class="nav-icon">○</span>
            Profile
          </a>
          <a class="nav-item" href="/meetings">
            <span class="nav-icon">◷</span>
            Meetings
          </a>
          <a class="nav-item active" href="/settings">
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
            <h2>Preferences</h2>
          </div>
          <div class="avatar top-avatar">{@member_initials}</div>
        </header>
        <div class="page-content">
          <section class="section-head">
            <div>
              <div class="eyebrow">MAKE IT YOURS</div>
              <h1>Notification preferences</h1>
              <p class="muted">Choose how and when you'd like to receive fellowship reminders.</p>
            </div>
          </section>
          <section class="card preferences-card">
            {%if @message != ""}
              <div class="notice {@message_type}">{@message}</div>
            {/if}
            <form class="form-stack" $submit={action: :submit_save_preferences}>
              <FellowshipWeb.Checkbox
                cid="push_notifications"
                class_name="toggle-row"
                name="push_enabled"
                checked={@push_enabled}
              >
                <b>Push notifications</b>
                <small>Receive updates on this device when supported.</small>
              </FellowshipWeb.Checkbox>
              <FellowshipWeb.Checkbox
                cid="email_notifications"
                class_name="toggle-row"
                name="email_enabled"
                checked={@email_enabled}
              >
                <b>Email notifications</b>
                <small>Receive fellowship updates by email.</small>
              </FellowshipWeb.Checkbox>
              <FellowshipWeb.Select cid="reminder_timing" name="reminder_minutes" label="Reminder timing">
                <option value="0" selected={@reminder_minutes == 0}>No advance reminder</option>
                <option value="15" selected={@reminder_minutes == 15}>15 minutes before</option>
                <option value="30" selected={@reminder_minutes == 30}>30 minutes before</option>
                <option value="60" selected={@reminder_minutes == 60}>1 hour before</option>
                <option value="120" selected={@reminder_minutes == 120}>2 hours before</option>
                <option value="1440" selected={@reminder_minutes == 1440}>1 day before</option>
              </FellowshipWeb.Select>
              <div class="form-actions">
                <FellowshipWeb.Button cid="settings_save" type="submit" loading={@loading}>Save preferences</FellowshipWeb.Button>
              </div>
            </form>
            <p class="muted settings-note">
              Notification delivery depends on the services configured by your fellowship.
            </p>
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
        <a href="/profile">
          <span aria-hidden="true">○</span>
          <small>Profile</small>
        </a>
      </nav>
    </div>
    """
  end

  def action(:submit_save_preferences, params, component) do
    component
    |> put_state(:loading, true)
    |> put_command(:save_preferences, event: Map.get(params, :event, %{}))
  end


  def command(:save_preferences, params, server) do
    event = Map.get(params, :event, %{})
    member = FellowshipApi.Accounts.get_member(get_session(server, :member_id))
    push = truthy?(event_value(event, :push_enabled))
    email = truthy?(event_value(event, :email_enabled))

    reminder =
      case Integer.parse(event_value(event, :reminder_minutes)) do
        {n, _} -> n
        _ -> 60
      end

    case FellowshipApi.Accounts.update_member(member, %{
           notification_push_enabled: push,
           notification_email_enabled: email,
           notification_reminder_minutes: reminder
         }) do
      {:ok, updated} ->
        put_action(server, :preferences_saved,
          push_enabled: updated.notification_push_enabled,
          email_enabled: updated.notification_email_enabled,
          reminder_minutes: updated.notification_reminder_minutes,
          message: "Your notification preferences have been saved.",
          message_type: "success"
        )

      {:error, _} ->
        put_action(server, :preferences_saved,
          push_enabled: push,
          email_enabled: email,
          reminder_minutes: reminder,
          message: "We couldn't save those preferences. Please try again.",
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

  def action(:preferences_saved, params, component) do
    component
    |> put_state(:loading, false)
    |> put_state(:push_enabled, params.push_enabled)
    |> put_state(:email_enabled, params.email_enabled)
    |> put_state(:reminder_minutes, params.reminder_minutes)
    |> put_state(:message, params.message)
    |> put_state(:message_type, params.message_type)
  end

  def action(:logged_out, _params, component), do: put_page(component, FellowshipWeb.LoginPage)

  defp event_value(event, key) when is_map(event) do
    value = Map.get(event, key, Map.get(event, Atom.to_string(key), ""))

    cond do
      is_binary(value) -> value
      is_boolean(value) -> to_string(value)
      is_number(value) -> to_string(value)
      true -> ""
    end
  end

  defp truthy?(value), do: value in ["true", "on", "1"]
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
