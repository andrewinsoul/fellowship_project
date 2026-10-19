defmodule FellowshipWeb.IconTile do
  @moduledoc """
  Reusable decorative icon tile.
  """

  use Hologram.Component

  prop(:symbol, :string)
  prop(:class_name, :string, default: "")
  prop(:label, :string, default: "")

  def template do
    ~HOLO"""
    <span class="icon-tile {@class_name}" aria-label={@label}>
      {@symbol}
    </span>
    """
  end
end
