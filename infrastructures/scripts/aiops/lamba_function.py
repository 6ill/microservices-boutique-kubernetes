import json
import os
import urllib.request
import boto3

bedrock = boto3.client('bedrock-runtime', region_name=os.environ['AWS_REGION'])

def lambda_handler(event, context):
    try:
        # Parse the incoming webhook payload from Grafana
        body = json.loads(event.get('body', '{}'))
        alerts = body.get('alerts', [])
        
        if not alerts:
            return {"statusCode": 200, "body": "No alerts found in payload."}

        # For simplicity, process the first alert in the batch
        alert = alerts[0]
        alert_name = alert.get('labels', {}).get('alertname', 'Unknown Alert')
        alert_desc = alert.get('annotations', {}).get('description', 'No description provided')
        
        # Construct the prompt for Amazon Bedrock
        prompt_text = (
            f"You are a Senior Site Reliability Engineer. Analyze the following Kubernetes alert:\n"
            f"Alert Name: {alert_name}\n"
            f"Description: {alert_desc}\n\n"
            f"Please provide:\n"
            f"1. Potential Root Cause\n"
            f"2. Three immediate troubleshooting steps."
        )
        
        payload = {
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": 512,
            "messages": [
                {
                    "role": "user",
                    "content": [{"type": "text", "text": prompt_text}]
                }
            ]
        }

        response = bedrock.invoke_model(
            modelId='anthropic.claude-3-haiku-20240307-v1:0',
            contentType='application/json',
            accept='application/json',
            body=json.dumps(payload)
        )
        
        response_body = json.loads(response['body'].read())
        ai_analysis = response_body['content'][0]['text']

        # Format and send the message to Slack
        slack_webhook_url = os.environ['SLACK_WEBHOOK_URL']
        slack_message = {
            "text": f"🚨 *AIOps Alert Analysis: {alert_name}*\n\n*Grafana Description:*\n{alert_desc}\n\n*Bedrock Analysis:*\n{ai_analysis}"
        }
        
        req = urllib.request.Request(
            slack_webhook_url, 
            data=json.dumps(slack_message).encode('utf-8'), 
            headers={'Content-Type': 'application/json'}
        )
        urllib.request.urlopen(req)

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "AIOps pipeline executed successfully."})
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }