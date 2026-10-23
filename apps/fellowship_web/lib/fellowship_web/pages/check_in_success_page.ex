defmodule FellowshipWeb.CheckInSuccessPage do
  use Hologram.Page

  route("/check-in-success")
  layout(FellowshipWeb.MainLayout)
  middleware(FellowshipWeb.Middleware.RequireAuth)

  def init(_params, component, server) do
    member = FellowshipApi.Accounts.get_member(get_session(server, :member_id))
    member_name = member.full_name || "Fellowship member"

    member_initials =
      member_name
      |> String.split()
      |> Enum.take(2)
      |> Enum.map(&String.first/1)
      |> Enum.join()
      |> String.upcase()

    component
    |> put_state(:member_name, member_name)
    |> put_state(:member_initials, member_initials)
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
          <a class="nav-item active" href="/home">
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
            <h2>Check-in successful</h2>
          </div>
          <div class="avatar top-avatar">{@member_initials}</div>
        </header>

        <div class="page-content check-in-success-content">
          <section class="card check-in-success-card">
            <div class="check-in-success-icon" aria-hidden="true">✓</div>
            <h1>Check-in successful!</h1>
            <p>You've been marked present for this fellowship meeting.</p>
            <a class="button primary full" href="/home">Back to home</a>
          </section>
        </div>

        <footer class="main-footer">
          FGBMFI Connect <span>•</span> Connected in fellowship. Growing in faith.
        </footer>
      </main>

      <nav class="mobile-nav" aria-label="Mobile navigation">
        <a class="active" href="/home" aria-current="page">
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

  def command(:logout, _params, server) do
    server
    |> delete_session(:auth_token)
    |> delete_session(:member_id)
    |> put_action(:logged_out)
  end

  def action(:logged_out, _params, component),
    do: put_page(component, FellowshipWeb.LoginPage)
end
