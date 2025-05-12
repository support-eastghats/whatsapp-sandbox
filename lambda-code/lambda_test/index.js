import { ConnectClient, ResumeContactRecordingCommand } from "@aws-sdk/client-connect";

const connectClient = new ConnectClient({ region: "eu-west-2" });

export const handler = async (event) => {
  console.log("📥 setresume event:", JSON.stringify(event));

  // Handle CORS preflight
  if (event.httpMethod === 'OPTIONS') {
    return {
      statusCode: 200,
      headers: corsHeaders(),
      body: JSON.stringify({ message: 'CORS preflight handled (setresume)' }),
    };
  }

  const response = {
    statusCode: 200,
    headers: corsHeaders(),
    body: ''
  };

  try {
    const body = typeof event.body === 'string' ? JSON.parse(event.body) : event.body;
    const { contactId, instanceId } = body;

    if (!contactId || !instanceId) {
      throw new Error("Missing contactId or instanceId");
    }

    const command = new ResumeContactRecordingCommand({
      ContactId: contactId,
      InitialContactId: contactId,
      InstanceId: instanceId
    });

    const result = await connectClient.send(command);
    console.log("✅ ResumeContactRecording result:", result);

    response.body = JSON.stringify({ message: 'Recording resumed successfully' });

  } catch (err) {
    console.error("❌ setresume error:", err);
    response.statusCode = 500;
    response.body = JSON.stringify({ error: err.message || 'Failed to resume recording' });
  }

  return response;
};

const corsHeaders = () => ({
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type,x-api-key',
  'Access-Control-Allow-Methods': 'POST,OPTIONS',
  'Content-Type': 'application/json'
});
