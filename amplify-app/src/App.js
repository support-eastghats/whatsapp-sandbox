import React, { useState } from "react";
import axios from "axios";

export default function WhatsAppSandboxApp() {
  const [phoneNumber, setPhoneNumber] = useState("");
  const [message, setMessage] = useState("");
  const [response, setResponse] = useState(null);
  const [loading, setLoading] = useState(false);

  const apiUrl = process.env.REACT_APP_API_URL;

  const sendMessage = async () => {
    setLoading(true);
    try {
      const result = await axios.post(apiUrl, {
        phoneNumber,
        message,
      });
      setResponse(result.data);
    } catch (error) {
      setResponse({ error: error?.response?.data || error.message });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ padding: "2rem", fontFamily: "Arial, sans-serif" }}>
      <h2>EastGhatsCX WhatsApp Sandbox</h2>
      <input
        type="text"
        value={phoneNumber}
        onChange={(e) => setPhoneNumber(e.target.value)}
        placeholder="Enter Phone Number"
        style={{ width: "100%", marginBottom: "1rem" }}
      />
      <textarea
        value={message}
        onChange={(e) => setMessage(e.target.value)}
        placeholder="Type message here"
        rows={4}
        style={{ width: "100%", marginBottom: "1rem" }}
      ></textarea>
      <button onClick={sendMessage} disabled={loading}>
        {loading ? "Sending..." : "Send Message"}
      </button>
      {response && (
        <pre style={{ marginTop: "2rem", background: "#f0f0f0", padding: "1rem" }}>
          {JSON.stringify(response, null, 2)}
        </pre>
      )}
    </div>
  );
}
