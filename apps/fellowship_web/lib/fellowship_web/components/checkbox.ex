defmodule FellowshipWeb.Checkbox do
  @moduledoc """
  Reusable checkbox control with a descriptive content slot.
  """

  use Hologram.Component

  prop(:name, :string)
  prop(:value, :string, default: "true")
  prop(:class_name, :string, default: "")
  prop(:checked, :boolean, default: false)
  prop(:disabled, :boolean, default: false)

  def template do
    ~HOLO"""
    <label class={@class_name}>
      <span><slot /></span>
      <input
        type="checkbox"
        name={@name}
        value={@value}
        checked={@checked}
        disabled={@disabled}
      />
    </label>
    """
  end
end
