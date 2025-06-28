exports.handler = async (event) => {
    const payload = JSON.parse(event.body || '{}');
  
    console.log("Received webhook event:", JSON.stringify(payload, null, 2));
  
    return {
      statusCode: 200,
      body: JSON.stringify({ received: true }),
    };
  };
  