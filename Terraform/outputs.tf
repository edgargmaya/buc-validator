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

output "redis_auth_secret_id" {
  description = "Secrets Manager identifier used for the Redis AUTH token (same as var.redis_auth_secret_id)."
  value       = var.redis_auth_secret_id
}

output "security_group_id" {
  description = "Security group attached to the cluster (adjust ingress if you did not set CIDRs)."
  value       = aws_security_group.redis.id
}
