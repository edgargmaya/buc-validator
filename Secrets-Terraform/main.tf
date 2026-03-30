resource "random_password" "redis_auth" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "redis_auth" {
  name                    = var.secret_name
  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(var.tags, { Name = var.secret_name })
}

resource "aws_secretsmanager_secret_version" "redis_auth" {
  secret_id = aws_secretsmanager_secret.redis_auth.id
  # JSON so consumers (ElastiCache TF, CSI jmesPath "password", scripts) can read the same key.
  secret_string = jsonencode({
    password = random_password.redis_auth.result
  })
}
