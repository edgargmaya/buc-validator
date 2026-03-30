output "secret_arn" {
  description = "ARN of the Secrets Manager secret (pass to the Redis Terraform project as redis_auth_secret_id)."
  value       = aws_secretsmanager_secret.redis_auth.arn
}

output "secret_name" {
  description = "Friendly name of the secret."
  value       = aws_secretsmanager_secret.redis_auth.name
}

output "secret_id" {
  description = "Same as secret name; usable as redis_auth_secret_id."
  value       = aws_secretsmanager_secret.redis_auth.id
}
