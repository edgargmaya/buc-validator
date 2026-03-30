variable "aws_region" {
  description = "AWS region for Secrets Manager."
  type        = string
  default     = "us-east-1"
}

variable "secret_name" {
  description = "Name of the Secrets Manager secret (e.g. redis-oss/auth-token)."
  type        = string
}

variable "recovery_window_in_days" {
  description = "Days to wait before permanent delete. Use 0 for immediate delete on destroy (typical for CI sandboxes)."
  type        = number
  default     = 0
}

variable "tags" {
  description = "Tags for the secret."
  type        = map(string)
  default     = {}
}
