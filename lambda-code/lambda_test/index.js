const AWS = require("aws-sdk");
const connect = new AWS.Connect();

exports.handler = async (event) => {
  try {
    const instanceId = process.env.CONNECT_INSTANCE_ID;
    const { userId, routingProfileId } = JSON.parse(event.body);

    await connect.updateUserRoutingProfile({
      InstanceId: instanceId,
      UserId: userId,
      RoutingProfileId: routingProfileId
    }).promise();

    return {
      statusCode: 200,
      body: JSON.stringify({ message: "Routing profile updated successfully" })
    };

  } catch (err) {
    console.error("Error in updateRoutingProfile:", err);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Failed to update routing profile" })
    };
  }
};
