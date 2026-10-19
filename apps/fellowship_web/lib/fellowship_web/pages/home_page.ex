defmodule FellowshipWeb.HomePage do
  use Hologram.Page

  route "/home"
  layout FellowshipWeb.MainLayout
  middleware FellowshipWeb.Middleware.RequireAuth

  def init(_params, component, server) do
    member_id = get_session(server, :member_id)
    member = FellowshipApi.Accounts.get_member(member_id)
    auth_token = get_session(server, :auth_token)
    meeting = FellowshipApi.Meetings.next_meeting()
    current_meeting = FellowshipApi.Meetings.current_check_in_meeting()
    quotation = FellowshipApi.Quotations.latest()

    checked_in =
      if current_meeting do
        not is_nil(FellowshipApi.Attendance.get_attendance(member.id, current_meeting.id))
      else
        false
      end

    member_name = member.full_name || "Fellowship member"
    member_first_name = member_name |> String.split() |> List.first() || "friend"
    member_initials =
      member_name
      |> String.split()
      |> Enum.take(2)
      |> Enum.map(&String.first/1)
      |> Enum.join()
      |> String.upcase()

    greeting =
      case DateTime.utc_now().hour do
        hour when hour < 12 -> "morning"
        hour when hour < 17 -> "afternoon"
        _ -> "evening"
      end

    component
    |> put_state(:auth_token, auth_token || "")
    |> put_state(:member_name, member_name)
    |> put_state(:member_first_name, member_first_name)
    |> put_state(:member_initials, member_initials)
    |> put_state(:greeting, greeting)
    |> put_state(:member_email, member.email)
    |> put_state(:meeting_title, if(meeting, do: meeting.title, else: "No upcoming meeting scheduled"))
    |> put_state(:meeting_time, if(meeting, do: DateTime.to_string(meeting.starts_at), else: "Check back for the next scheduled fellowship"))
    |> put_state(:check_in_status, check_in_status(current_meeting, checked_in))
    |> put_state(:quotation_text, if(quotation, do: quotation.text, else: "No quotation is available right now."))
    |> put_state(:quotation_source, if(quotation && quotation.source, do: quotation.source, else: "FGBMFI Connect"))
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
            <h2>Home</h2>
          </div>
          <div class="avatar top-avatar">{@member_initials}</div>
        </header>

        <div class="content-grid">
          <section class="welcome-heading">
            <div>
              <div class="eyebrow">YOUR FELLOWSHIP, CLOSER THAN EVER</div>
              <h1>Good {@greeting}, {@member_first_name}.</h1>
              <p>We're glad you're here. Keep growing, keep connecting.</p>
            </div>
          </section>

          <section class="card meeting-card">
            <div class="card-kicker">
              UP NEXT
              <span class="status-pill">Coming soon</span>
            </div>
            <div class="meeting-row">
              <div class="icon-tile">▦</div>
              <div class="meeting-info">
                <h3>{@meeting_title}</h3>
                <p>Meeting details will appear here</p>
                <small>{@meeting_time}</small>
              </div>
            </div>
            <button class="button primary full" type="button" data-qr-open>
              <span aria-hidden="true">▦</span>
              Scan QR to Check In
            </button>
          </section>

          <section class="card scripture-card">
            <div class="card-kicker">
              SCRIPTURE FOR THE SOUL
              <span>✦</span>
            </div>
            <blockquote>“{@quotation_text}”</blockquote>
            <div class="quote-source">{@quotation_source}</div>
            <a class="text-button scripture-link" href="/quotations">Explore scripture →</a>
          </section>

          <section class="card quick-card">
            <div class="card-kicker">QUICK ACCESS</div>
            <div class="quick-grid">
              <a href="/attendance">
                <span>▦</span>
                <b>My attendance</b>
                <small>View your history</small>
              </a>
              <a href="/quotations">
                <span>▤</span>
                <b>Scripture</b>
                <small>Read and reflect</small>
              </a>
              <a href="/settings">
                <span>♧</span>
                <b>Reminders</b>
                <small>Manage preferences</small>
              </a>
              <a href="/profile">
                <span>○</span>
                <b>My profile</b>
                <small>Your information</small>
              </a>
            </div>
          </section>

          <section class="verse-banner">
            <div>
              <span class="eyebrow light">ONE BODY. ONE FELLOWSHIP.</span>
              <h3>“And let us consider how we may spur one another on toward love and good deeds.”</h3>
              <p>HEBREWS 10:24</p>
            </div>
            <div class="banner-cross" aria-hidden="true">✝</div>
          </section>
        </div>
        <footer class="main-footer">A community of faith, fellowship, and service.</footer>
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

      <section
        id="qr-scan-modal"
        class="qr-modal"
        hidden
        data-auth-token="{@auth_token}"
        aria-hidden="true"
        role="dialog"
        aria-modal="true"
        aria-labelledby="qr-modal-title"
      >
        <div class="qr-modal-backdrop" data-qr-close></div>
        <div class="qr-modal-card">
          <button
            class="qr-modal-close"
            type="button"
            data-qr-close
            aria-label="Close scanner"
          >
            ×
          </button>
          <p class="eyebrow">FELLOWSHIP ATTENDANCE</p>
          <h2 id="qr-modal-title">Scan meeting QR code</h2>
          <p class="qr-modal-description">Scan the official QR code displayed at your fellowship meeting.</p>
          <div id="fgbmfi-qr-reader" class="qr-reader"></div>
          <p id="qr-scan-message" class="qr-scan-message" role="status" aria-live="polite">Preparing your camera…</p>
          <button id="qr-scan-retry" class="button secondary full" type="button" hidden>Try again</button>
          <button class="button secondary full qr-cancel" type="button" data-qr-close>Cancel</button>
        </div>
      </section>
    </div>
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

  defp check_in_status(nil, _checked_in), do: "Check-in is currently closed."
  defp check_in_status(_meeting, true), do: "You are already checked in for the current fellowship."
  defp check_in_status(_meeting, false), do: "Check-in is open for the current fellowship."
end
