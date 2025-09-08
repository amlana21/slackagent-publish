import json

import logging
import boto3
import os
import uuid

run_mode = os.getenv('RUN_MODE', 'local')

# Configure logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger()


if run_mode == 'local':
    client = boto3.client(
        'bedrock-agent-runtime',
        aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID", ""),
        aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY", ""),
        region_name=os.getenv("AWS_REGION", "us-east-1")
    )
else:
    client = boto3.client(
        'bedrock-agent-runtime'
    )

agent_id = os.getenv("AGENT_ID", "")
agentalias = os.getenv("AGENT_ALIAS", "")


def lambda_handler(event, context):
    logger.debug(f"Payload: {event}")
    print(f"Payload: {event}")
    payload_body=json.loads(event.get('body', '{}'))
    input_text = payload_body.get('inputText', 'Hello from Lambda!')
    session_id = payload_body.get('sessionId', str(uuid.uuid4()))
    logger.info(f"Input Text: {input_text}")
    logger.info(f"Session ID: {session_id}")
    try:
        response = client.invoke_agent(
            agentId=agent_id,
            agentAliasId=agentalias,
            inputText=input_text,
            sessionId=session_id
        )
        logger.info(f"Response: {response}")
        completion = ""
        for completion_event in response.get("completion", []):
            chunk = completion_event.get("chunk", {})
            if "bytes" in chunk:
                completion += chunk["bytes"].decode()
        logger.info(f"Completion: {completion}")
    except Exception as e:
        logger.error(f"Error invoking agent: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error invoking agent: {str(e)}')
        }
    return {
        'statusCode': 200,
        'body': str(completion),
        'sessionId': session_id
    }
