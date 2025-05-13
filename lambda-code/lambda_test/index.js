// Lambda: getAvailableRoutingProfiles with detailed logging
import {
  ConnectClient,
  DescribeUserCommand,
  DescribeUserHierarchyGroupCommand,
  ListRoutingProfilesCommand,
  DescribeRoutingProfileCommand,
} from "@aws-sdk/client-connect";

const connect = new ConnectClient({ region: "eu-west-2" });

export const handler = async (event) => {
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
    console.info("📥 Incoming event:", JSON.stringify(event));
    const { userId, instanceId } = JSON.parse(event.body);
    console.info("🧾 Parsed Payload:", { userId, instanceId });

    // Step 1: Describe User
    const userRes = await connect.send(
      new DescribeUserCommand({ InstanceId: instanceId, UserId: userId })
    );
    const currentProfile = userRes.User?.RoutingProfileId;
    const hierarchyGroupId = userRes.User?.HierarchyGroupId;
    console.info("👤 DescribeUser:", {
      currentProfile,
      hierarchyGroupId,
    });

    // Step 2: Describe Hierarchy Group
    const hierarchyRes = await connect.send(
      new DescribeUserHierarchyGroupCommand({
        InstanceId: instanceId,
        HierarchyGroupId: hierarchyGroupId,
      })
    );

    const hierarchy = hierarchyRes.HierarchyGroup?.HierarchyPath || {};
    const parsedHierarchy = {
      LevelOne: hierarchy.LevelOne?.Name,
      LevelTwo: hierarchy.LevelTwo?.Name,
      LevelThree: hierarchy.LevelThree?.Name,
    };
    console.info("📊 Parsed Hierarchy:", parsedHierarchy);

    // Step 3: List all Routing Profiles
    const profilesRes = await connect.send(
      new ListRoutingProfilesCommand({ InstanceId: instanceId })
    );
    console.info("📦 Total Routing Profiles:", profilesRes.RoutingProfileSummaryList?.length);

    const allowedProfiles = [];

    for (const profile of profilesRes.RoutingProfileSummaryList || []) {
      try {
        // Step 4: Describe each routing profile to get its tags
        const fullProfile = await connect.send(
          new DescribeRoutingProfileCommand({
            InstanceId: instanceId,
            RoutingProfileId: profile.Id,
          })
        );

        const tags = fullProfile.RoutingProfile?.Tags || {};
        console.info(`🏷️ Tags for profile ${profile.Name} [${profile.Id}]:`, tags);

        // Step 5: Match hierarchy tags
        const match = (
          (parsedHierarchy.LevelOne && (
            tags.LevelOne === parsedHierarchy.LevelOne ||
            tags.LevelTwo === parsedHierarchy.LevelTwo ||
            tags.LevelThree === parsedHierarchy.LevelThree
          )) ||
          (parsedHierarchy.LevelTwo && (
            tags.LevelTwo === parsedHierarchy.LevelTwo ||
            tags.LevelThree === parsedHierarchy.LevelThree
          )) ||
          (parsedHierarchy.LevelThree && tags.LevelThree === parsedHierarchy.LevelThree)
        );

        if (match) {
          allowedProfiles.push({ id: profile.Id, name: profile.Name });
        }
      } catch (err) {
        console.error(
          `❌ Failed to get tags for profile: ${profile.Arn} [${profile.Id}]`,
          err
        );
      }
    }

    // Step 6: Final response
    response.body = JSON.stringify({ currentProfile, allowedProfiles });
    console.info("✅ Response ready:", response.body);
  } catch (err) {
    console.error("🔥 Unexpected error:", err);
    response.statusCode = 500;
    response.body = JSON.stringify({ error: "Internal server error" });
  }

  return response;
};
