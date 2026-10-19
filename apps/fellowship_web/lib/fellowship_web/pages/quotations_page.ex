defmodule FellowshipWeb.QuotationsPage do
  use Hologram.Page

  route("/quotations")
  layout(FellowshipWeb.MainLayout)
  middleware(FellowshipWeb.Middleware.RequireAuth)

  @page_size 20

  def init(_params, component, server) do
    member = FellowshipApi.Accounts.get_member(get_session(server, :member_id))
    {quotes, total} = FellowshipApi.Quotations.list_published(1, @page_size)

    quotes =
      Enum.map(quotes, fn quote ->
        %{
          text: quote.text,
          source: quote.source || "Scripture",
          published_date: format_date(quote.published_at)
        }
      end)

    component
    |> put_state(:member_name, member.full_name || "Fellowship member")
    |> put_state(:member_initials, initials(member.full_name))
    |> put_state(:quotes, quotes)
    |> put_state(:total_quotes, total)
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
          <a class="nav-item active" href="/quotations">
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
            <h2>Scripture</h2>
          </div>
          <div class="avatar top-avatar">{@member_initials}</div>
        </header>
        <div class="page-content">
          <section class="section-head">
            <div>
              <div class="eyebrow">SCRIPTURE FOR EVERY SEASON</div>
              <h1>Words to carry with you.</h1>
              <p class="muted">A moment in God's Word for the journey ahead.</p>
            </div>
          </section>
          {%if @quotes == []}
            <FellowshipWeb.Card cid="quotations_empty" class_name="empty-state">
              <h3>No published scripture yet</h3>
              <p>Published quotations will appear here.</p>
            </FellowshipWeb.Card>
          {%else}
            <div class="quotes-grid">
              {%for quote <- @quotes}
                <article class="quote-card">
                  <span class="quote-mark">“</span>
                  <blockquote>{quote.text}</blockquote>
                  <div class="quote-bottom">
                    <b>{quote.source}</b>
                    <small>{quote.published_date}</small>
                  </div>
                </article>
              {/for}
            </div>
          {/if}
          <p class="muted page-summary">
            Showing {length(@quotes)} of {@total_quotes} published quotations.
          </p>
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
        <a class="active" href="/quotations" aria-current="page">
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

  defp format_date(nil), do: "Recently published"
  defp format_date(value), do: Calendar.strftime(value, "%d %b %Y")
end
