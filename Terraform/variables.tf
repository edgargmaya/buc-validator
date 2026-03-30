variable "aws_region" {
  description = "AWS region where ElastiCache is deployed."
  type        = string
  default     = "us-east-1"
}

variable "subnet_ids" {
  description = "Exactly 3 subnet IDs (same VPC) for the ElastiCache subnet group."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) == 3
    error_message = "You must provide exactly 3 subnet IDs."
  }
}

variable "replication_group_id" {
  description = "Replication group identifier (lowercase, alphanumeric, and hyphens)."
  type        = string
  default     = "redis-oss-app"
}

variable "node_type" {
  description = "ElastiCache node type (must support encryption at rest)."
  type        = string
  default     = "cache.t4g.micro"
}

variable "engine_version" {
  description = "Redis major version (OSS engine)."
  type        = string
  default     = "7.1"
}

variable "redis_auth_secret_id" {
  description = "Secrets Manager secret name or ARN that already exists (created by RedisOSS/Secrets-Terraform or another pipeline). Must be readable by this Terraform run (e.g. secretsmanager:GetSecretValue). String must be JSON with a \"password\" key or a plain-text auth token."
  type        = string
}

variable "allow_vpc_internal_access" {
  description = "Adds an ingress rule to the SG allowing port 6379 from the VPC CIDR (useful if the app runs in the same VPC)."
  type        = bool
  default     = true
}

variable "allowed_ingress_cidr_blocks" {
  description = "Additional CIDR blocks allowed to reach Redis (port 6379)."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Common tags for resources."
  type        = map(string)
  default     = {}
}
