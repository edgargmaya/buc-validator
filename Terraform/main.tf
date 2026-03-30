data "aws_subnet" "first" {
  id = var.subnet_ids[0]
}

data "aws_vpc" "redis" {
  id = data.aws_subnet.first.vpc_id
}

locals {
  redis_ingress_cidrs = distinct(concat(
    var.allow_vpc_internal_access ? [data.aws_vpc.redis.cidr_block] : [],
    var.allowed_ingress_cidr_blocks
  ))
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.replication_group_id}-subnet"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, { Name = "${var.replication_group_id}-subnet" })
}

resource "aws_security_group" "redis" {
  name_prefix = "${var.replication_group_id}-"
  description = "ElastiCache Redis (OSS)"
  vpc_id      = data.aws_subnet.first.vpc_id

  dynamic "ingress" {
    for_each = length(local.redis_ingress_cidrs) > 0 ? [1] : []
    content {
      description = "Redis (TLS) from configured CIDRs"
      from_port   = 6379
      to_port     = 6379
      protocol    = "tcp"
      cidr_blocks = local.redis_ingress_cidrs
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.replication_group_id}-sg" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "random_password" "redis_auth" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "redis" {
  name                    = var.secret_name
  recovery_window_in_days = 0

  tags = merge(var.tags, { Name = var.secret_name })
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = var.replication_group_id
  description          = "Redis OSS (cluster mode disabled)"

  engine         = "redis"
  engine_version = var.engine_version
  node_type      = var.node_type

  num_cache_clusters = 1
  port               = 6379
  subnet_group_name  = aws_elasticache_subnet_group.redis.name
  security_group_ids = [aws_security_group.redis.id]

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = random_password.redis_auth.result

  automatic_failover_enabled = false
  multi_az_enabled           = false

  apply_immediately = true

  tags = merge(var.tags, { Name = var.replication_group_id })
}

resource "aws_secretsmanager_secret_version" "redis" {
  secret_id = aws_secretsmanager_secret.redis.id
  secret_string = jsonencode({
    host     = aws_elasticache_replication_group.redis.primary_endpoint_address
    port     = aws_elasticache_replication_group.redis.port
    password = random_password.redis_auth.result
    tls      = true
    url      = "rediss://:${random_password.redis_auth.result}@${aws_elasticache_replication_group.redis.primary_endpoint_address}:${aws_elasticache_replication_group.redis.port}"
  })

  depends_on = [aws_elasticache_replication_group.redis]
}
