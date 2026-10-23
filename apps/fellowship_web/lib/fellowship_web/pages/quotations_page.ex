defmodule FellowshipWeb.QuotationsPage do
  use Hologram.Page

  alias Hologram.UI.Link
  alias FellowshipWeb.{LoginPage, Card}

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
      <FellowshipWeb.Sidebar cid="sidebar" active_page="quotations" member_name={@member_name} member_initials={@member_initials} />
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
            <Card cid="quotations_empty" class_name="empty-state">
              <h3>No published scripture yet</h3>
              <p>Published quotations will appear here.</p>
            </Card>
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
        <Link to={FellowshipWeb.HomePage}>
          <span aria-hidden="true">⌂</span>
          <small>Home</small>
        </Link>
        <Link to={FellowshipWeb.AttendancePage}>
          <span aria-hidden="true">▦</span>
          <small>Attendance</small>
        </Link>
        <Link to={FellowshipWeb.QuotationsPage} class="active">
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

  def action(:logged_out, _params, component), do: put_page(component, LoginPage)

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
