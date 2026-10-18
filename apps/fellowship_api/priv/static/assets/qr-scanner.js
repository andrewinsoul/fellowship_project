(() => {
  "use strict";

  function initializeScannerModal(modal) {
  if (modal.dataset.qrScannerInitialized === "true") return;
  modal.dataset.qrScannerInitialized = "true";

  const readerId = "fgbmfi-qr-reader";
  const message = document.getElementById("qr-scan-message");
  const retryButton = document.getElementById("qr-scan-retry");
  const closeButtons = modal.querySelectorAll("[data-qr-close]");
  let scanner = null;
  let loadingLibrary = null;
  let starting = false;
  let requestInFlight = false;
  let closed = false;

  function setMessage(text, kind = "") {
    message.textContent = text;
    message.className = `qr-scan-message${kind ? ` ${kind}` : ""}`;
  }

  function showModal() {
    closed = false;
    modal.hidden = false;
    modal.setAttribute("aria-hidden", "false");
    document.body.classList.add("qr-modal-open");
  }

  async function stopScanner() {
    if (!scanner) return;
    try {
      const state = scanner.getState();
      // html5-qrcode states 2 and 3 represent scanning and paused.
      if (state === 2 || state === 3) await scanner.stop();
    } catch (error) {
      console.warn("[QR scanner] Could not stop scanner cleanly", error);
    }
  }

  async function closeModal() {
    closed = true;
    await stopScanner();
    if (scanner) {
      try { scanner.clear(); } catch (_) {}
      scanner = null;
    }
    modal.hidden = true;
    modal.setAttribute("aria-hidden", "true");
    document.body.classList.remove("qr-modal-open");
  }

  async function getScannerLibrary() {
    if (window.Html5Qrcode) return window.Html5Qrcode;
    if (loadingLibrary) return loadingLibrary;

    loadingLibrary = new Promise((resolve, reject) => {
      const script = document.createElement("script");
      script.src = "https://unpkg.com/html5-qrcode@2.3.8/html5-qrcode.min.js";
      script.async = true;
      script.onload = () => window.Html5Qrcode
        ? resolve(window.Html5Qrcode)
        : reject(new Error("The QR scanner library did not load."));
      script.onerror = () => reject(new Error("Could not download the QR scanner. Check your internet connection and try again."));
      document.head.appendChild(script);
    });

    return loadingLibrary;
  }

  async function handleDecodedQr(decodedText) {
    if (closed || requestInFlight) return;
    requestInFlight = true;
    retryButton.hidden = true;
    setMessage("Verifying your QR code…");
    await stopScanner();

    try {
      const token = modal.dataset.authToken;
      if (!token) throw new Error("Your session token is missing. Please sign in again.");

      const response = await fetch("/api/v1/attendance/check-in", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${token}`
        },
        body: JSON.stringify({ qr_code: decodedText })
      });

      const payload = await response.json().catch(() => ({}));
      if (!response.ok) {
        const error = payload.error || {};
        const err = new Error(error.message || "We couldn't verify this QR code.");
        err.code = error.code;
        throw err;
      }

      const status = payload.data?.status;
      setMessage(
        status === "already_checked_in"
          ? "You're already checked in for this meeting."
          : payload.data?.message || "Your attendance has been recorded.",
        "success"
      );
      window.setTimeout(() => closeModal(), 1200);
    } catch (error) {
      if (closed) return;
      const text = error.code === "invalid_qr_code"
        ? "Invalid QR code. Please scan the official FGBMFI Connect QR code."
        : error.message || "We couldn't verify this QR code. Please try again.";
      setMessage(text, "error");
      retryButton.hidden = false;
    } finally {
      requestInFlight = false;
    }
  }

  async function startScanner() {
    if (starting || closed) return;
    starting = true;
    retryButton.hidden = true;
    setMessage("Preparing your camera…");

    try {
      const Html5Qrcode = await getScannerLibrary();
      if (closed) return;

      if (!scanner) scanner = new Html5Qrcode(readerId);
      setMessage("Allow camera access when your browser asks, then point it at the meeting QR code.");

      await scanner.start(
        { facingMode: "environment" },
        { fps: 10, qrbox: { width: 240, height: 240 }, aspectRatio: 1 },
        handleDecodedQr,
        () => {}
      );
      if (!closed) setMessage("Camera is ready. Point it at the meeting QR code.");
    } catch (error) {
      if (!closed) {
        setMessage(error.message || "We couldn't access your camera. Check browser permissions and try again.", "error");
        retryButton.hidden = false;
      }
    } finally {
      starting = false;
    }
  }

  closeButtons.forEach(button => button.addEventListener("click", closeModal));
  document.querySelectorAll("[data-qr-open]").forEach(button => {
    button.addEventListener("click", () => {
      closed = false;
      showModal();
      startScanner();
    });
  });
  retryButton.addEventListener("click", async () => {
    await stopScanner();
    if (scanner) {
      try { scanner.clear(); } catch (_) {}
      scanner = null;
    }
    closed = false;
    const reader = document.getElementById(readerId);
    if (reader) reader.replaceChildren();
    startScanner();
  });

  // The Hologram HomePage is only available to authenticated members.
  // Open the scanner after the page has rendered, matching the Next.js flow.
  showModal();
  startScanner();

  window.addEventListener("pagehide", () => {
    closed = true;
    stopScanner();
  });
  }

  function findModal() {
    const modal = document.getElementById("qr-scan-modal");
    if (modal) {
      initializeScannerModal(modal);
      return true;
    }
    return false;
  }

  if (!findModal()) {
    // Hologram can swap pages without reloading the document. Watch for the
    // authenticated HomePage modal to be inserted after this script executes.
    const observer = new MutationObserver(() => {
      if (findModal()) observer.disconnect();
    });
    observer.observe(document.documentElement, { childList: true, subtree: true });
  }
})();
