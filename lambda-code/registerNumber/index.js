exports.handler = async (event) => {
    const body = JSON.parse(event.body || '{}');
    const phoneNumber = body.phoneNumber || 'unknown';
  
    return {
      statusCode: 200,
      body: JSON.stringify({
        message: `Phone number ${phoneNumber} registered successfully.`,
        status: "registered"
      }),
    };
  };
  