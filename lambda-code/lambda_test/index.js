import {
  ConnectClient,
  UpdateUserRoutingProfileCommand
} from "@aws-sdk/client-connect";

const connect = new ConnectClient({ region: "eu-west-2" });

export const handler = async (event) => {
  console.log("[switchRoutingProfile] Event:", JSON.stringify(event));

  const { userId, instanceId, routingProfileId } = JSON.parse(event.body || '{}');
  const response = {
    statusCode: 200,
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Headers": "Content-Type,x-api-key",
      "Access-Control-Allow-Methods": "POST,OPTIONS",
      "Content-Type": "application/json"
    },
    body: ""
  };

  try {
    await connect.send(
      new UpdateUserRoutingProfileCommand({
        InstanceId: instanceId,
        UserId: userId,
        RoutingProfileId: routingProfileId
      })
    );

    response.body = JSON.stringify({ message: "Routing profile switched successfully." });
  } catch (err) {
    console.error("switchRoutingProfile error:", err);
    response.statusCode = 500;
    response.body = JSON.stringify({ error: "Failed to switch routing profile" });
  }

  return response;
};
