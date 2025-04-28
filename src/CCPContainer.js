import { useEffect } from "react";
import 'amazon-connect-streams';

export default function CCPContainer({ onAgentReady, onCcpError }) {
  useEffect(() => {
    const ccpUrl = process.env.REACT_APP_CCP_URL;
    const region = process.env.REACT_APP_REGION;

    console.log("🟡 CCP Init Attempt");
    console.log("🔗 CCP URL:", ccpUrl);
    console.log("🌍 Region:", region);

    setTimeout(() => {
      try {
        if (!window.connect || !window.connect.core) {
          const errMsg = "❌ Amazon Connect SDK not loaded (npm import failed)";
          console.error(errMsg);
          onCcpError?.(errMsg);
          return;
        }

        const container = document.getElementById("ccp-container");
        if (!container) {
          const errMsg = "❌ CCP container element not found in DOM";
          console.error(errMsg);
          onCcpError?.(errMsg);
          return;
        }

        window.connect.core.initCCP(container, {
          ccpUrl,
          region,
          loginPopup: true,
          loginPopupAutoClose: true,
        });

        window.connect.agent((agent) => {
          console.log("✅ Agent connected");
          const info = {
            name: agent.getName(),
            username: agent.getUsername(),
            routingProfile: agent.getRoutingProfile().name,
            userId: agent.getConfiguration().agentId,
          };
          onAgentReady(info);
        });
      } catch (error) {
        console.error("❌ CCP init failed:", error);
        onCcpError?.(error.message || "Unknown CCP error");
      }
    }, 500);
  }, [onAgentReady, onCcpError]);

  return <div id="ccp-container" style={{ height: "500px", width: "100%" }} />;
}
