defmodule FellowshipWeb.PasswordInput do
  @moduledoc """
  Reusable password input with an accessible show/hide control.
  """

  use Hologram.Component

  prop(:label, :string)
  prop(:name, :string)
  prop(:autocomplete, :string)
  prop(:required, :boolean, default: false)
  prop(:minlength, :integer, default: 0)

  def init(_props, component) do
    initialize_state(component)
  end

  def init(_props, component, server) do
    {initialize_state(component), server}
  end

  defp initialize_state(component) do
    put_state(component,
      password_visible: false,
      password_type: "password",
      visibility_label: "Show password"
    )
  end

  def template do
    ~HOLO"""
    <label class="password-field-label">
      {@label}
      <span class="password-input-wrap">
        <input
          type={@password_type}
          name={@name}
          autocomplete={@autocomplete}
          required={@required}
          minlength={@minlength}
        />
        <button
          class="password-visibility-toggle"
          type="button"
          aria-label={@visibility_label}
          title={@visibility_label}
          $click={action: :toggle_visibility}
        >
          <svg
            aria-hidden="true"
            viewBox="0 0 24 24"
            width="20"
            height="20"
            fill="none"
            stroke="currentColor"
            stroke-width="1.8"
          >
            <path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7S2 12 2 12Z" />
            <circle cx="12" cy="12" r="3" />
          </svg>
        </button>
      </span>
    </label>
    """
  end

  def action(:toggle_visibility, _params, component) do
    if component.state.password_visible do
      component
      |> put_state(:password_visible, false)
      |> put_state(:password_type, "password")
      |> put_state(:visibility_label, "Show password")
    else
      component
      |> put_state(:password_visible, true)
      |> put_state(:password_type, "text")
      |> put_state(:visibility_label, "Hide password")
    end
  end
end
