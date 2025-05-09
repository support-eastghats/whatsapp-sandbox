import { ConnectClient, ResumeContactRecordingCommand } from "@aws-sdk/client-connect";

const connectClient = new ConnectClient({ region: "eu-west-2" });

export const handler = async (event) => {
  console.log("setresume event:", JSON.stringify(event));

  const response = {
    statusCode: 200,
    headers: { 'Access-Control-Allow-Origin': '*', 'Content-Type': 'application/json' },
    body: ''
  };

  try {
    const body = JSON.parse(event.body || '{}');
    const { contactId, instanceId } = JSON.parse(body.body || '{}');

    const command = new ResumeContactRecordingCommand({
      ContactId: contactId,
      InitialContactId: contactId,
      InstanceId: instanceId
    });

    await connectClient.send(command);
    response.body = JSON.stringify({ message: 'Recording resumed successfully' });

  } catch (err) {
    console.error("setresume error:", err);
    response.statusCode = 500;
    response.body = JSON.stringify({ error: 'Failed to resume recording' });
  }

  return response;
};
