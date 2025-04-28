import { useEffect } from "react";

export default function CCPContainer() {
  useEffect(() => {
    const interval = setInterval(() => {
      const container = document.getElementById("ccpContainer");

      if (window.connect && container) {
        window.connect.core.initCCP(container, {
          ccpUrl: process.env.REACT_APP_CCP_URL,
          region: process.env.REACT_APP_REGION,
          loginPopup: true,
          loginPopupAutoClose: true,
          softphone: { allowFramedSoftphone: true },
        });
        clearInterval(interval);
      }
    }, 300);

    return () => clearInterval(interval);
  }, []);

  return <div id="ccpContainer" style={{ width: "100%", height: "500px" }} />;
}
