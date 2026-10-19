defmodule FellowshipWeb.BrandMark do
  @moduledoc """
  Reusable FGBMFI Connect brand header.
  """

  use Hologram.Component

  prop(:class_name, :string, default: "")

  def template do
    ~HOLO"""
    <header class="auth-brand {@class_name}">
      <div class="brand-mark">
        <span>✝</span>
        <i>●</i>
        <i>●</i>
      </div>
      <div>
        <strong>FGBMFI <span>Connect</span></strong>
        <small>Connected in fellowship. His Banner over us is LOVE.</small>
      </div>
    </header>
    """
  end
end
