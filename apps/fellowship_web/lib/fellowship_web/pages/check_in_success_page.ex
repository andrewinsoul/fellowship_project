defmodule FellowshipWeb.CheckInSuccessPage do
  use Hologram.Page

  alias Hologram.UI.Link

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
      <FellowshipWeb.Sidebar cid="sidebar" active_page="home" member_name={@member_name} member_initials={@member_initials} />

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
            <Link to={FellowshipWeb.HomePage} class="button primary full">Back to home</Link>
          </section>
        </div>

        <footer class="main-footer">
          FGBMFI Connect <span>•</span> Connected in fellowship. Growing in faith.
        </footer>
      </main>

      <nav class="mobile-nav" aria-label="Mobile navigation">
        <Link to={FellowshipWeb.HomePage} class="active">
          <span aria-hidden="true">⌂</span>
          <small>Home</small>
        </Link>
        <Link to={FellowshipWeb.AttendancePage}>
          <span aria-hidden="true">▦</span>
          <small>Attendance</small>
        </Link>
        <Link to={FellowshipWeb.QuotationsPage}>
          <span aria-hidden="true">▤</span>
          <small>Scripture</small>
        </Link>
        <Link to={FellowshipWeb.ProfilePage}>
          <span aria-hidden="true">○</span>
          <small>Profile</small>
        </Link>
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
