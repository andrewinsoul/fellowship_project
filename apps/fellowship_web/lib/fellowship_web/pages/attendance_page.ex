defmodule FellowshipWeb.AttendancePage do
  use Hologram.Page

  alias Hologram.UI.Link

  route("/attendance")
  layout(FellowshipWeb.MainLayout)
  middleware(FellowshipWeb.Middleware.RequireAuth)

  @page_size 20

  def init(_params, component, server) do
    member = FellowshipApi.Accounts.get_member(get_session(server, :member_id))
    {records, total} = FellowshipApi.Attendance.list_for_member(member.id, 1, @page_size)

    records =
      Enum.map(records, fn record ->
        %{
          title: record.meeting.title,
          meeting_date: format_date(record.meeting.starts_at),
          checked_in_time: format_datetime(record.checked_in_at)
        }
      end)

    component
    |> put_state(:member_name, member.full_name || "Fellowship member")
    |> put_state(:member_initials, initials(member.full_name))
    |> put_state(:records, records)
    |> put_state(:total_records, total)
  end

  def template do
    ~HOLO"""
    <div class="app-shell">
      <FellowshipWeb.Sidebar cid="sidebar" active_page="attendance" member_name={@member_name} member_initials={@member_initials} />
      <main class="main-area">
        <header class="topbar">
          <div>
            <span class="eyebrow">FULL GOSPEL BUSINESS MEN’S FELLOWSHIP</span>
            <h2>Attendance</h2>
          </div>
          <div class="avatar top-avatar">{@member_initials}</div>
        </header>
        <div class="page-content">
          <section class="section-head">
            <div>
              <div class="eyebrow">YOUR JOURNEY TOGETHER</div>
              <h1>My attendance</h1>
              <p class="muted">Every gathering is another step in fellowship.</p>
            </div>
          </section>
          <section class="card">
            {%if @records == []}
              <div class="empty-state">
                <span>▦</span>
                <h3>No attendance records yet</h3>
                <p>Your check-ins will appear here after you attend a fellowship meeting.</p>
              </div>
            {%else}
              <div class="attendance-list">
                {%for record <- @records}
                  <article class="attendance-row">
                    <div class="icon-tile">▦</div>
                    <div class="row-main">
                      <b>{record.title}</b>
                      <small>{record.meeting_date} · Checked in {record.checked_in_time}</small>
                    </div>
                    <span class="status-pill present">Present</span>
                  </article>
                {/for}
              </div>
            {/if}
            <p class="muted page-summary">
              Showing {length(@records)} of {@total_records} attendance records.
            </p>
          </section>
        </div>
        <footer class="main-footer">A community of faith, fellowship, and service.</footer>
      </main>

      <nav class="mobile-nav" aria-label="Mobile navigation">
        <Link to={FellowshipWeb.HomePage}>
          <span aria-hidden="true">⌂</span>
          <small>Home</small>
        </Link>
        <Link to={FellowshipWeb.AttendancePage} class="active">
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
    server |> delete_session(:auth_token) |> delete_session(:member_id) |> put_action(:logged_out)
  end

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

  defp format_date(nil), do: "Date to be announced"
  defp format_date(value), do: Calendar.strftime(value, "%a, %d %b %Y")
  defp format_datetime(nil), do: "time unavailable"
  defp format_datetime(value), do: Calendar.strftime(value, "%H:%M UTC")
end
