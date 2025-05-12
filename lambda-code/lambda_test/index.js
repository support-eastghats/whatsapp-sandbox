// Lambda: getAvailableRoutingProfiles
import {
  ConnectClient,
  ListRoutingProfilesCommand,
  ListTagsForResourceCommand,
  DescribeUserCommand,
  DescribeUserHierarchyGroupCommand,
} from "@aws-sdk/client-connect";

const connect = new ConnectClient({ region: "eu-west-2" });

export const handler = async (event) => {
  const { userId, instanceId } = JSON.parse(event.body);

  const response = {
    statusCode: 200,
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Headers": "Content-Type,x-api-key",
      "Access-Control-Allow-Methods": "POST,OPTIONS",
    },
    body: "",
  };

  try {
    const describeUser = await connect.send(new DescribeUserCommand({
      InstanceId: instanceId,
      UserId: userId,
    }));

    const currentProfile = describeUser.User.RoutingProfileId;
    const hierarchyGroupId = describeUser.User.HierarchyGroupId;

    let project = "", group = "", role = "";
    if (hierarchyGroupId) {
      const hierarchy = await connect.send(new DescribeUserHierarchyGroupCommand({
        InstanceId: instanceId,
        HierarchyGroupId: hierarchyGroupId,
      }));

      // Simulate split of name as Project > Group > Role (flat name format)
      [project, group, role] = hierarchy.HierarchyGroup.Name.split("-");
    }

    const rpCommand = new ListRoutingProfilesCommand({ InstanceId: instanceId });
    const routingProfiles = await connect.send(rpCommand);

    const filtered = [];
    for (const profile of routingProfiles.RoutingProfileSummaryList || []) {
      const tagsResp = await connect.send(new ListTagsForResourceCommand({
        ResourceArn: profile.Arn,
      }));

      const tags = tagsResp.Tags || {};
      const allowAgents = (tags.AllowAgents || "").split(",").map(a => a.trim());

      if (
        tags.Project === project ||
        tags.Group === group ||
        tags.Role === role ||
        allowAgents.includes(userId)
      ) {
        filtered.push({ id: profile.Id, name: profile.Name });
      }
    }

    response.body = JSON.stringify({
      currentProfile,
      allowedProfiles: filtered,
    });
  } catch (err) {
    console.error("getAvailableRoutingProfiles error:", err);
    response.statusCode = 500;
    response.body = JSON.stringify({ error: "Internal server error" });
  }

  return response;
};
