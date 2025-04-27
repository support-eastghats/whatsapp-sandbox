import { useEffect } from "react";
console.log("CCP URL:", process.env.REACT_APP_CCP_URL);
export default function CCPContainer({ onAgentReady }) {
  useEffect(() => {
    window.connect.core.initCCP(document.getElementById("ccp-container"), {
      ccpUrl: process.env.REACT_APP_CCP_URL,
      region: process.env.REACT_APP_REGION,
      loginPopup: false,
      loginPopupAutoClose: false
    });

    window.connect.agent((agent) => {
      const info = {
        name: agent.getName(),
        username: agent.getUsername(),
        routingProfile: agent.getRoutingProfile().name,
        userId: agent.getConfiguration().agentId
      };

      onAgentReady(info);
    });
  }, [onAgentReady]);

  return <div id="ccp-container" style={{ height: "500px", width: "100%" }} />;
}
