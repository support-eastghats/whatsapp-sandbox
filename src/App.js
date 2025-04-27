import { useState } from "react";
import CCPContainer from "./CCPContainer";
import ProfileSwitcher from "./components/ProfileSwitcher";

function App() {
  const [agentInfo, setAgentInfo] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [ccpStatus, setCcpStatus] = useState("🔄 Initializing CCP...");

  const handleAgentReady = (info) => {
    setAgentInfo(info);
    setIsLoading(false);
    setCcpStatus("✅ CCP Loaded");
  };

  const handleCcpError = (message) => {
    setCcpStatus(`❌ CCP Error: ${message}`);
  };

  return (
    <div style={{ fontFamily: "Arial, sans-serif", padding: "1rem" }}>
      <h2>Custom CCP with Routing Profile Switcher</h2>

      {/* Status message */}
      <div style={{ margin: "1rem 0", fontWeight: "bold", color: ccpStatus.startsWith("❌") ? "red" : "green" }}>
        {ccpStatus}
      </div>

      {/* Loading Spinner */}
      {isLoading && (
        <div style={{ margin: "1rem 0", fontSize: "16px" }}>
          <span>Loading agent session...</span>
          <div className="spinner" />
        </div>
      )}

      {/* Agent Greeting */}
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

      {/* Profile Switcher */}
      {agentInfo && <ProfileSwitcher userId={agentInfo.userId} />}

      {/* CCP Component */}
      <CCPContainer onAgentReady={handleAgentReady} onCcpError={handleCcpError} />
    </div>
  );
}

export default App;
