defmodule FellowshipWeb.StatusPill do
  @moduledoc """
  Reusable status indicator.
  """

  use Hologram.Component

  prop(:label, :string)
  prop(:class_name, :string, default: "")

  def template do
    ~HOLO"""
    <span class="status-pill {@class_name}">{@label}</span>
    """
  end
end
