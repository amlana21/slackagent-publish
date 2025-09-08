const { App } = require("@slack/bolt");
const { InvokeAgentCommand, BedrockAgentRuntimeClient } = require("@aws-sdk/client-bedrock-agent-runtime");

// get uuid
const { v4: uuidv4 } = require("uuid");


const app = new App({
  token: process.env.SLACK_OAUTH_TOKEN,
  signingSecret: process.env.SLACK_SIGNING_SECRET,
  socketMode: true,
  appToken: process.env.SLACK_APP_TOKEN
});

const lambda_url = process.env.LAMBDA_URL || "http://localhost:9001/2015-03-31/functions/function/invocations";



// Listens to incoming messages that contain "hello"
app.message("hello", async ({ message, say }) => {
  // say() sends a message to the channel where the event was triggered
  console.log(message);
  await say(`Hey there <@${message.user}>!`);
});

app.event("app_mention", async ({ event, client, logger }) => {
  console.log(event);
  console.log("Received app_mention event");
  // Extract the message text (removing the bot mention)
  const userMessage = event.text.replace(/<@[^>]+>\s*/, "").trim();

  const lambdaPayload = {
    inputText: userMessage,
    sessionId: uuidv4().toString(), // Generate a unique session ID for each interaction
  };
  console.log("Lambda payload:", lambdaPayload);
  // Invoke the Bedrock Agent
  const agentResp = await fetch(lambda_url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(lambdaPayload),
  })
  console.log("Lambda response status:", agentResp.status);
  if (!agentResp.ok) {
    console.error("Error invoking agent:", agentResp.statusText);
    await client.chat.postMessage({
      channel: event.channel,
      text: `Sorry, I couldn't process your request: ${agentResp.statusText}`,
      thread_ts: event.ts // reply in thread
    });
    return;
  }
  const agentRespText = await agentResp.text();


  console.log("Agent response:", agentRespText);

  await client.chat.postMessage({
    channel: event.channel,
    text: agentRespText || 'No response from agent.',
    thread_ts: event.ts // reply in thread
  });
});


(async () => {
  // Start your app
  await app.start(process.env.PORT || 3000);
  console.log(`⚡️ Bot app is running on port ${process.env.PORT || 3000}!`);
})();
