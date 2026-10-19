defmodule FellowshipWeb.Input do
  @moduledoc """
  Reusable labelled form input with consistent accessibility and styling.
  """

  use Hologram.Component

  prop(:name, :string)
  prop(:label, :string)
  prop(:type, :string, default: "text")
  prop(:autocomplete, :string, default: "off")
  prop(:placeholder, :string, default: "")
  prop(:value, :string, default: "")
  prop(:class_name, :string, default: "")
  prop(:required, :boolean, default: false)
  prop(:disabled, :boolean, default: false)
  prop(:minlength, :integer, default: 0)

  def template do
    ~HOLO"""
    <label class={@class_name}>
      {@label}
      <input
        type={@type}
        name={@name}
        autocomplete={@autocomplete}
        placeholder={@placeholder}
        value={@value}
        required={@required}
        disabled={@disabled}
        minlength={@minlength}
      />
    </label>
    """
  end
end
