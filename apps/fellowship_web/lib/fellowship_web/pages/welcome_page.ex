defmodule FellowshipWeb.WelcomePage do
  use Hologram.Page

  route "/"
  layout FellowshipWeb.MainLayout

  def template do
    ~HOLO"""
    <main class="auth-shell">
      <section class="welcome-panel">
        <div class="welcome-art">
          <div class="sun-glow"></div>
          <div class="cross-art" aria-hidden="true">✝</div>
          <div class="welcome-copy">
            <p class="eyebrow light">FGBMFI CONNECT</p>
            <h1>Faith. Fellowship. Purpose.</h1>
            <p>Stay connected to your fellowship, keep up with meetings, and make every gathering count.</p>
          </div>
        </div>
        <div class="auth-card welcome-card">
          <div class="brand-mark">
            <img src="/images/fgbmfi-connect-logo.png" alt="FGBMFI Connect" />
          </div>
          <p class="eyebrow">WELCOME TO</p>
          <h2>FGBMFI Connect</h2>
          <p>One place for your fellowship activities.</p>
          <div class="form-stack">
            <a class="button primary full" href="/login">Sign in</a>
            <a class="button secondary full" href="/register">Create an account</a>
          </div>
          <p class="fineprint">A community of faith, fellowship, and service.</p>
        </div>
      </section>
    </main>
    """
  end
end
