import { useState } from "react";
import CCPContainer from "./CCPContainer";
import ProfileSwitcher from "./components/ProfileSwitcher";

function App() {
  const [agentInfo, setAgentInfo] = useState(null);
  const [isLoading, setIsLoading] = useState(true);

  const handleAgentReady = (info) => {
    setAgentInfo(info);
    setIsLoading(false);
  };

  return (
    <div style={{ fontFamily: "Arial, sans-serif", padding: "1rem" }}>
      <h2>Custom CCP with Routing Profile Switcher</h2>

      {/* Show loading spinner while agent info is loading */}
      {isLoading && (
        <div style={{ margin: "1rem 0", fontSize: "16px" }}>
          <span>Loading agent session...</span>
          <div className="spinner" />
        </div>
      )}

      {/* Show agent welcome banner */}
      {!isLoading && agentInfo && (
        <div style={{
          padding: "0.75rem 1rem",
          marginBottom: "1rem",
          backgroundColor: "#f0f0f0",
          borderLeft: "5px solid #0073e6",
          fontSize: "16px"
        }}>
          👋 Hello, <strong>{agentInfo.name}</strong> ({agentInfo.username})
        </div>
      )}

      {/* Profile switcher when agent is ready */}
      {agentInfo && <ProfileSwitcher userId={agentInfo.userId} />}

      {/* Always load CCP */}
      <CCPContainer onAgentReady={handleAgentReady} />
    </div>
  );
}

export default App;
