import { ConnectClient, UpdateContactAttributesCommand } from "@aws-sdk/client-connect";

const connectClient = new ConnectClient({ region: "eu-west-2" });

export const handler = async (event) => {
  console.log("setpauseresumeattr event:", JSON.stringify(event));

  // Handle CORS preflight
  if (event.httpMethod === 'OPTIONS') {
    return {
      statusCode: 200,
      headers: corsHeaders(),
      body: JSON.stringify({ message: 'CORS preflight handled (setpauseresumeattr)' }),
    };
  }

  const response = {
    statusCode: 200,
    headers: corsHeaders(),
    body: '',
  };

  try {
    const { pauseCtrData, resumeCtrData, contactId, instanceId } = JSON.parse(event.body || '{}');

    const command = new UpdateContactAttributesCommand({
      InitialContactId: contactId,
      InstanceId: instanceId,
      Attributes: {
        'PAUSE-MISDATA': pauseCtrData,
        'RESUME-MISDATA': resumeCtrData,
      },
    });

    await connectClient.send(command);
    response.body = JSON.stringify({ message: 'Attributes updated successfully' });

  } catch (err) {
    console.error("setpauseresumeattr error:", err);
    response.statusCode = 500;
    response.body = JSON.stringify({ error: 'Failed to update attributes' });
  }

  return response;
};

const corsHeaders = () => ({
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type,x-api-key',
  'Access-Control-Allow-Methods': 'PUT,OPTIONS',
  'Content-Type': 'application/json',
});
