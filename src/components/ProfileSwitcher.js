// src/components/ProfileSwitcher.js
import { useState, useEffect } from "react";

export default function ProfileSwitcher({ userId }) {
  const [profiles, setProfiles] = useState([]);
  const [currentProfile, setCurrentProfile] = useState(null);

  useEffect(() => {
    fetch(`${process.env.REACT_APP_API_BASE_URL}/getRoutingProfiles`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ userId }),
    })
      .then((res) => res.json())
      .then(data => {
        setProfiles(data.matchedProfiles);
        setCurrentProfile(data.currentProfile);
      });
  }, [userId]);

  const updateProfile = (profileId) => {
    fetch(`${process.env.REACT_APP_API_BASE_URL}/updateRoutingProfile`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ userId, routingProfileId: profileId }),
    }).then(() => alert("Routing profile updated!"));
  };

  return (
    <div>
      <p>Current: {currentProfile?.Name}</p>
      <select onChange={(e) => updateProfile(e.target.value)}>
        {profiles.map((p) => (
          <option key={p.Id} value={p.Id}>{p.Name}</option>
        ))}
      </select>
    </div>
  );
}
