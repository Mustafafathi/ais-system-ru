/* QR Scanner helper — thin wrapper around the local Html5Qrcode adapter */
(function(window){
  async function initQrScanner(elementId, onScan, config = {}) {
    if (typeof window.Html5Qrcode !== 'function') {
      throw new Error('Local QR scanner adapter is not loaded.');
    }

    const html5QrCode = new Html5Qrcode(elementId);
    const cameraConfig = {
      facingMode: 'environment',
    };
    const scanConfig = {
      fps: config.fps || 10,
      qrbox: config.qrbox || 250,
    };

    try {
      await html5QrCode.start(cameraConfig, scanConfig, function(decodedText) {
        if (typeof onScan === 'function') onScan(decodedText);
      }, function(errorMessage) {
        if (errorMessage && typeof config.onError === 'function') {
          config.onError(errorMessage);
        }
      });
    } catch (err) {
      console.error('QR scanner start error', err);
      throw err;
    }

    return {
      stop: async function() {
        try { await html5QrCode.stop(); } catch(e){ console.warn('stop error', e); }
      }
    };
  }

  window.initQrScanner = initQrScanner;
})(window);

