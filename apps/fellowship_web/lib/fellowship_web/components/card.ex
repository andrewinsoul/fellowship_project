defmodule FellowshipWeb.Card do
  @moduledoc """
  Reusable semantic card container.
  """

  use Hologram.Component

  prop(:class_name, :string, default: "")

  def template do
    ~HOLO"""
    <section class="card {@class_name}">
      <slot />
    </section>
    """
  end
end
