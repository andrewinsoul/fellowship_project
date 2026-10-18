defmodule FellowshipApi.Mailer do
  require Logger

  def send_password_reset(email, token) do
    api_key = System.get_env("RESEND_API_KEY")
    app_url = System.get_env("APP_BASE_URL", "http://localhost:4000") |> String.trim_trailing("/")
    from = System.get_env("RESEND_FROM_EMAIL", "FGBMFI Connect <onboarding@resend.dev>")

    if is_nil(api_key) or api_key == "" do
      Logger.warning("Password reset email not sent: RESEND_API_KEY is not configured")
      {:error, :email_not_configured}
    else
      url = app_url <> "/reset-password?token=" <> URI.encode(token)
      html = "<div style=\"font-family:Arial,sans-serif;max-width:560px;margin:auto;color:#242038\"><div style=\"background:#30205f;color:#fff;padding:24px;border-radius:12px 12px 0 0\"><strong>FGBMFI Connect</strong></div><div style=\"padding:24px;border:1px solid #eee\"><h2>Let’s get you back in.</h2><p>We received a request to reset your password.</p><p><a href=\"#{url}\" style=\"display:inline-block;background:#c59b3d;color:#fff;text-decoration:none;padding:12px 20px;border-radius:8px\">Reset password</a></p><p>This link expires in 30 minutes and can only be used once.</p><p>If you didn’t request this, you can ignore this email.</p></div></div>"
      text = "Reset your FGBMFI Connect password: #{url}

This link expires in 30 minutes and can only be used once. If you did not request this, ignore this email."
      body = Jason.encode!(%{from: from, to: [email], subject: "Reset your FGBMFI Connect password", html: html, text: text})
      :inets.start()
      :ssl.start()
      request = {~c"https://api.resend.com/emails", [{~c"authorization", String.to_charlist("Bearer " <> api_key)}, {~c"content-type", ~c"application/json"}], ~c"application/json", body}
      case :httpc.request(:post, request, [timeout: 10_000, connect_timeout: 5_000], body_format: :binary) do
        {:ok, {{_, status, _}, _headers, _response}} when status in 200..299 -> :ok
        {:ok, {{_, status, _}, _headers, response}} -> Logger.warning("Resend returned HTTP #{status}: #{inspect(response)}"); {:error, :email_delivery_failed}
        {:error, reason} -> Logger.warning("Resend request failed: #{inspect(reason)}"); {:error, :email_delivery_failed}
      end
    end
  end
end
