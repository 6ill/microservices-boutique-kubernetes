output "webhook_url" {
  description = "The URL to paste into Grafana Alerting Contact Points"
  value       = "${aws_apigatewayv2_api.aiops_api.api_endpoint}/webhook"
}