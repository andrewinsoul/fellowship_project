defmodule FellowshipWeb.Button do
  @moduledoc """
  Reusable button with consistent styling and configurable behaviour.
  """

  use Hologram.Component

  prop(:type, :string, default: "button")
  prop(:variant, :string, default: "primary")
  prop(:class_name, :string, default: "")
  prop(:disabled, :boolean, default: false)
  prop(:href, :string, default: "")

  def template do
    ~HOLO"""
    {%if @href != ""}
      <a
        href={@href}
        class="button {@variant} {@class_name}"
      >
        <slot />
      </a>
    {%else}
      <button
        type={@type}
        class="button {@variant} {@class_name}"
        disabled={@disabled}
      >
        <slot />
      </button>
    {/if}
    """
  end
end
