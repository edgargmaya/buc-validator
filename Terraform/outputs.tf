output "replication_group_id" {
  description = "ElastiCache replication group ID."
  value       = aws_elasticache_replication_group.redis.id
}

output "primary_endpoint" {
  description = "Primary endpoint of the Redis cluster."
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "redis_port" {
  description = "Redis port."
  value       = aws_elasticache_replication_group.redis.port
}

output "secrets_manager_secret_arn" {
  description = "ARN of the secret containing credentials and endpoint."
  value       = aws_secretsmanager_secret.redis.arn
}

output "secrets_manager_secret_name" {
  description = "Secret name in Secrets Manager."
  value       = aws_secretsmanager_secret.redis.name
}

output "security_group_id" {
  description = "Security group attached to the cluster (adjust ingress if you did not set CIDRs)."
  value       = aws_security_group.redis.id
}
