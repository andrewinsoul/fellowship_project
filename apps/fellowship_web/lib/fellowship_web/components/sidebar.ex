defmodule FellowshipWeb.Sidebar do
  @moduledoc """
  Shared authenticated navigation for desktop layouts.
  """

  use Hologram.Component

  alias Hologram.UI.Link

  prop(:active_page, :string)
  prop(:member_name, :string)
  prop(:member_initials, :string)

  def template do
    ~HOLO"""
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
        <Link to={FellowshipWeb.HomePage} class={nav_class(@active_page, "home")}>
          <span class="nav-icon">⌂</span>
          Home
        </Link>
        <Link to={FellowshipWeb.AttendancePage} class={nav_class(@active_page, "attendance")}>
          <span class="nav-icon">▦</span>
          Attendance
        </Link>
        <Link to={FellowshipWeb.QuotationsPage} class={nav_class(@active_page, "quotations")}>
          <span class="nav-icon">▤</span>
          Scripture
        </Link>
        <Link to={FellowshipWeb.ProfilePage} class={nav_class(@active_page, "profile")}>
          <span class="nav-icon">○</span>
          Profile
        </Link>
        <Link to={FellowshipWeb.MeetingsPage} class={nav_class(@active_page, "meetings")}>
          <span class="nav-icon">◷</span>
          Meetings
        </Link>
        <Link to={FellowshipWeb.SettingsPage} class={nav_class(@active_page, "settings")}>
          <span class="nav-icon">⚙</span>
          Preferences
        </Link>
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
    """
  end

  def command(:logout, _params, server) do
    server
    |> delete_session(:auth_token)
    |> delete_session(:member_id)
    |> put_action(:logged_out)
  end

  def action(:logged_out, _params, component) do
    put_page(component, FellowshipWeb.LoginPage)
  end

  defp nav_class(active_page, page) do
    if active_page == page, do: "nav-item active", else: "nav-item"
  end
end
