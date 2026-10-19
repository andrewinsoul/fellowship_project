defmodule FellowshipWeb.Select do
  @moduledoc """
  Reusable labelled select control; options are provided as children.
  """

  use Hologram.Component

  prop(:name, :string)
  prop(:label, :string)
  prop(:class_name, :string, default: "")
  prop(:required, :boolean, default: false)
  prop(:disabled, :boolean, default: false)

  def template do
    ~HOLO"""
    <label class={@class_name}>
      {@label}
      <select name={@name} required={@required} disabled={@disabled}>
        <slot />
      </select>
    </label>
    """
  end
end
