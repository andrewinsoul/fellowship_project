defmodule FellowshipWeb.MeetingsPage do
  use Hologram.Page

  alias Hologram.UI.Link

  route("/meetings")
  layout(FellowshipWeb.MainLayout)
  middleware(FellowshipWeb.Middleware.RequireAuth)

  def init(_params, component, server) do
    member = FellowshipApi.Accounts.get_member(get_session(server, :member_id))

    meetings =
      FellowshipApi.Meetings.list_upcoming(12)
      |> Enum.map(fn meeting ->
        %{
          title: meeting.title,
          day: format_day(meeting.starts_at),
          month: format_month(meeting.starts_at),
          date: format_date(meeting.starts_at),
          start_time: format_time(meeting.starts_at),
          end_time: format_time(meeting.ends_at)
        }
      end)

    component
    |> put_state(:member_name, member.full_name || "Fellowship member")
    |> put_state(:member_initials, initials(member.full_name))
    |> put_state(:meetings, meetings)
  end

  def template do
    ~HOLO"""
    <div class="app-shell">
      <FellowshipWeb.Sidebar cid="sidebar" active_page="meetings" member_name={@member_name} member_initials={@member_initials} />
      <main class="main-area">
        <header class="topbar">
          <div>
            <span class="eyebrow">FULL GOSPEL BUSINESS MEN’S FELLOWSHIP</span>
            <h2>Meetings</h2>
          </div>
          <div class="avatar top-avatar">{@member_initials}</div>
        </header>
        <div class="page-content">
          <section class="section-head">
            <div>
              <div class="eyebrow">COME TOGETHER</div>
              <h1>Upcoming fellowship meetings</h1>
              <p class="muted">Plan ahead and make room for fellowship.</p>
            </div>
          </section>
          {%if @meetings == []}
            <FellowshipWeb.Card cid="meetings_empty" class_name="empty-state">
              <h3>No upcoming meeting found</h3>
              <p>Meeting details will appear here when scheduled.</p>
            </FellowshipWeb.Card>
          {%else}
            <section class="card meetings-list">
              {%for meeting <- @meetings}
                <article class="attendance-row meeting-list-row">
                  <div class="calendar-tile">
                    <b>{meeting.day}</b>
                    <span>{meeting.month}</span>
                  </div>
                  <div class="row-main">
                    <b>{meeting.title}</b>
                    <small>{meeting.date}</small>
                    <small>{meeting.start_time} – {meeting.end_time} · Africa/Lagos</small>
                  </div>
                  <span class="status-pill">Scheduled</span>
                </article>
              {/for}
            </section>
          {/if}
          <p class="muted page-summary">
            Meeting times are shown in West Africa Time (Africa/Lagos).
          </p>
        </div>
        <footer class="main-footer">A community of faith, fellowship, and service.</footer>
      </main>

      <nav class="mobile-nav" aria-label="Mobile navigation">
        <Link to={FellowshipWeb.HomePage}>
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

  def command(:logout, _params, server),
    do:
      server
      |> delete_session(:auth_token)
      |> delete_session(:member_id)
      |> put_action(:logged_out)

  def action(:logged_out, _params, component), do: put_page(component, FellowshipWeb.LoginPage)

  defp initials(nil), do: "F"

  defp initials(name),
    do:
      name
      |> String.split()
      |> Enum.take(2)
      |> Enum.map(&String.first/1)
      |> Enum.join()
      |> String.upcase()

  defp format_day(nil), do: "--"
  defp format_day(value), do: Calendar.strftime(value, "%d")
  defp format_month(nil), do: "TBA"
  defp format_month(value), do: Calendar.strftime(value, "%b")
  defp format_date(nil), do: "Date to be announced"
  defp format_date(value), do: Calendar.strftime(value, "%A, %d %B %Y")
  defp format_time(nil), do: "--:--"
  defp format_time(value), do: Calendar.strftime(value, "%H:%M")
end
