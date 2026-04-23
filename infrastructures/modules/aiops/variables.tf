variable "slack_webhook_url" {
  description = "The Slack Webhook URL to send alert notifications"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "The environment name (e.g., production)"
  type        = string
  default     = "production"
}