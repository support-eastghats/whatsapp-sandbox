import { useEffect } from "react";
import 'amazon-connect-streams'; // ✅ This loads `window.connect`

export default function CCPContainer({ onAgentReady }) {
  useEffect(() => {
    const ccpUrl = process.env.REACT_APP_CCP_URL;
    const region = process.env.REACT_APP_REGION;

    console.log("🟡 CCP Init Attempt");
    console.log("🔗 CCP URL:", ccpUrl);
    console.log("🌍 Region:", region);

    if (!window.connect || !window.connect.core) {
      console.error("❌ Amazon Connect SDK not loaded (npm import failed)");
      return;
    }

    const container = document.getElementById("ccp-container");
    if (!container) {
      console.error("❌ CCP container element not found in DOM");
      return;
    }

    window.connect.core.initCCP(container, {
      ccpUrl: ccpUrl,
      region: region,
      loginPopup: true, // for Google SSO
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
  }, [onAgentReady]);

  return <div id="ccp-container" style={{ height: "500px", width: "100%" }} />;
}
