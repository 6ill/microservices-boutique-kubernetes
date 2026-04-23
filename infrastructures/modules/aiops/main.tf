# Package the Python script into a ZIP file
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.root}/scripts/aiops"
  output_path = "${path.root}/scripts/aiops_payload.zip"
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "aiops_lambda_exec_role_${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach Basic Execution Policy (CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Inline Policy to allow Lambda to invoke Amazon Bedrock
resource "aws_iam_role_policy" "bedrock_invoke" {
  name = "aiops_bedrock_invoke_policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["bedrock:InvokeModel"]
      Resource = ["arn:aws:bedrock:*::foundation-model/anthropic.claude-3-haiku-20240307-v1:0"]
    }]
  })
}

# The Lambda Function
resource "aws_lambda_function" "aiops_handler" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "aiops_grafana_webhook_handler"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 30 # Bedrock invocations can take a few seconds

  environment {
    variables = {
      SLACK_WEBHOOK_URL = var.slack_webhook_url
    }
  }
}

resource "aws_apigatewayv2_api" "aiops_api" {
  name          = "aiops_webhook_api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.aiops_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.aiops_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.aiops_handler.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "webhook_route" {
  api_id    = aws_apigatewayv2_api.aiops_api.id
  route_key = "POST /webhook"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.aiops_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.aiops_api.execution_arn}/*/*"
}