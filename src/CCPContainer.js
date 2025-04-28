import { useEffect } from "react";

export default function CCPContainer({ onError }) {
  useEffect(() => {
    const interval = setInterval(() => {
      const container = document.getElementById("ccpContainer");

      // Wait for SDK and DOM to be ready
      if (window.connect && container) {
        console.log("✅ connect.embedCCP starting...");
        window.connect.core.initCCP(container, {
          ccpUrl: process.env.REACT_APP_CCP_URL,
          region: process.env.REACT_APP_REGION,
          loginPopup: true,
          loginPopupAutoClose: true,
          softphone: {
            allowFramedSoftphone: true,
          },
        });
        clearInterval(interval);
      }
    }, 300); // retry every 300ms

    // Timeout fail-safe after 10 seconds
    setTimeout(() => clearInterval(interval), 10000);

    return () => clearInterval(interval); // cleanup
  }, []);

  return (
    <div>
      <h2 style={{ fontFamily: "Arial", marginBottom: "10px" }}>
        Amazon Connect CCP
      </h2>
      <div
        id="ccpContainer"
        style={{
          width: "100%",
          height: "500px",
          border: "1px solid #ccc",
          borderRadius: "8px",
        }}
      />
    </div>
  );
}
