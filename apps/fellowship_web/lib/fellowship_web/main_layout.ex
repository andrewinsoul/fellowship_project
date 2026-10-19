defmodule FellowshipWeb.MainLayout do
  use Hologram.Component

  def template do
    ~HOLO"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="theme-color" content="#32135f" />
        <link rel="manifest" href="/manifest.webmanifest" />
        <link rel="icon" href="/icon.svg" type="image/svg+xml" />
        <link rel="stylesheet" href="/assets/fellowship.css" />
        <link rel="stylesheet" href="/assets/password-input.css" />
        <title>FGBMFI Connect</title>
        <Hologram.UI.Runtime />
        <script src="/assets/qr-scanner.js" defer></script>
      </head>
      <body>
        <slot />
      </body>
    </html>
    """
  end
end
