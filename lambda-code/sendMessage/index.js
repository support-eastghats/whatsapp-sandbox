const axios = require("axios");

exports.handler = async (event) => {
  try {
    const { to, message } = JSON.parse(event.body);

    const response = await axios.post("http://localhost:3000/send", {
      to,
      message
    });

    return {
      statusCode: 200,
      body: JSON.stringify({
        status: "sent",
        message_id: response.data.message_id || "mock123",
        to,
        message
      }),
    };
  } catch (err) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: err.message }),
    };
  }
};
