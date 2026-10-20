defmodule FellowshipWeb.WelcomePage do
  use Hologram.Page
  alias FellowshipWeb.{Button, IconTile}

  route("/")
  layout(FellowshipWeb.MainLayout)

  def template do
    ~HOLO"""
    <main class="auth-shell">
      <section class="welcome-panel">
        <div class="welcome-art">
          <div class="sun-glow"></div>
          <IconTile cid="welcome_cross" symbol="✝" class_name="cross-art" label="Cross" />
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
            <Button cid="welcome_sign_in" href="/login" class_name="full">Sign in</Button>
            <Button cid="welcome_register" href="/register" variant="secondary" class_name="full">Create an account</Button>
          </div>
          <p class="fineprint">A community of faith, fellowship, and service.</p>
        </div>
      </section>
    </main>
    """
  end
end
