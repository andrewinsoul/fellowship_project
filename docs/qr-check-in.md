# Permanent QR check-in setup

The authenticated `POST /api/v1/attendance/check-in` endpoint requires a valid `qr_code` payload before recording attendance. The same payload can be used for every weekly meeting; meeting-open and duplicate-attendance checks remain server-side.

## Configure the permanent QR payload

1. Generate a strong random value, for example with `openssl rand -hex 32`.
2. Set that exact value as the backend environment variable `CHECK_IN_QR_TOKEN` in Render. Keep it private and do not add it to frontend source code or frontend environment variables.
3. Create a QR code whose decoded text is exactly that value, with no spaces or extra newline. Display the same QR at each meeting.
4. Restart or redeploy the backend after setting the variable.

If the token is not configured, check-in fails closed with `qr_validation_unavailable`; attendance is not recorded. The API compares the supplied token using a constant-time comparison after checking the lengths.

## Expected outcomes

- Invalid QR: `422 invalid_qr_code` with the message `Invalid QR Code. Please scan the official FGBMFI Connect fellowship QR code.`; attendance is not written. The frontend should use the stable `error.code` value (`invalid_qr_code`) to identify this case rather than relying on message text.
- Missing or non-string QR payload: `422 qr_code_required`; attendance is not written.
- QR validation is not configured: `503 qr_validation_unavailable`; attendance is not written.
- Valid QR while check-in is closed: `422 check_in_closed`.
- Valid QR and an open meeting: `201 checked_in`, or `200 already_checked_in` for a duplicate.

**Security note:** This permanent shared QR is a shared secret, not proof of physical presence. Anyone who copies its contents could reuse it while authenticated. Rotate `CHECK_IN_QR_TOKEN` and reprint the QR if it is compromised. A short-lived or meeting-specific challenge would be needed to provide stronger proof of presence.
