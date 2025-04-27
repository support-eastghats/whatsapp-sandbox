import { useEffect } from "react";

export default function CCPContainer({ onAgentReady, onCcpError }) {
  useEffect(() => {
    const ccpUrl = process.env.REACT_APP_CCP_URL;
    const region = process.env.REACT_APP_REGION;

    console.log("🟡 CCP Init Attempt", ccpUrl, region);

    if (!window.connect || !window.connect.core) {
      const msg = "Amazon Connect SDK not loaded";
      console.error("❌", msg);
      onCcpError?.(msg);
      return;
    }

    const container = document.getElementById("ccp-container");
    if (!container) {
      const msg = "CCP container not found in DOM";
      console.error("❌", msg);
      onCcpError?.(msg);
      return;
    }

    window.connect.core.initCCP(container, {
      ccpUrl,
      region,
      loginPopup: true,
      loginPopupAutoClose: true,
      softphone: {
        allowFramedSoftphone: true,
      }
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
  }, [onAgentReady, onCcpError]);

  return <div id="ccp-container" style={{ height: "500px", width: "100%" }} />;
}
