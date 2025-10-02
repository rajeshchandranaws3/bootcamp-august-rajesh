# Create the KMS key
resource "aws_kms_key" "rds_kms" {
  description             = "KMS key - RDS encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

# Create an alias for easier reference
resource "aws_kms_alias" "rds_kms_alias" {
  name          = "alias/rds-encryption-key"
  target_key_id = aws_kms_key.rds_kms.key_id
}

# rds instance

resource "aws_db_instance" "postgres_db_instance" {
  identifier            = "class8-august-rds"
  allocated_storage     = 30
  max_allocated_storage = 50
  engine                = "postgres"
  engine_version        = 14.15
  instance_class        = "db.t3.micro"
  username              = "postgres"
  password              = random_password.dbs_random_string.result
  port                  = 5432
  publicly_accessible   = false
  db_subnet_group_name  = aws_db_subnet_group.postgres_subnet_group.name
  ca_cert_identifier    = "rds-ca-rsa2048-g1"
  storage_encrypted     = true
  storage_type          = "gp3"
  kms_key_id            = aws_kms_key.rds_kms.arn
  skip_final_snapshot   = true
  vpc_security_group_ids = [
    aws_security_group.rds_security_group.id
  ]

  backup_retention_period    = 7
  auto_minor_version_upgrade = true
  deletion_protection        = false
  copy_tags_to_snapshot      = true


}

#  RDS subnet group -> put both rds subnets to  it

resource "aws_db_subnet_group" "postgres_subnet_group" {
  name       = "postgres-subnet-group"
  subnet_ids = [aws_subnet.rds_subnet_1.id, aws_subnet.rds_subnet_2.id]

  tags = {
    Name = "Postgres subnet group"
  }
}

# RDS security group (inbound port 5432 from ECS SG only)

resource "aws_security_group" "rds_security_group" {
  name        = "rds-sg"
  description = "Allow inbound PostgreSQL from ECS only"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description     = "PostgreSQL from ECS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_service_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS Security Group"
  }
}



# password for the master user and secret manager secret
# create a password -> random provider
resource "random_password" "dbs_random_string" {
  length           = 10
  special          = false
  override_special = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
}
# store the password in secret manager

resource "aws_secretsmanager_secret" "db_link_secret" {
  name                    = "db/${aws_db_instance.postgres_db_instance.identifier}"
  description             = "DB link"
  kms_key_id              = aws_kms_key.rds_kms.arn
  recovery_window_in_days = 7
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "db_link_secret_version" {
  secret_id = aws_secretsmanager_secret.db_link_secret.id
  secret_string = jsonencode({
    # db_link      = "postgresql://{username}:{password}@{address}:{port}/{dbname}"
    db_link = "postgresql://${aws_db_instance.postgres_db_instance.username}:${random_password.dbs_random_string.result}@${aws_db_instance.postgres_db_instance.address}:${aws_db_instance.postgres_db_instance.port}/${aws_db_instance.postgres_db_instance.db_name}"
  })
  depends_on = [aws_db_instance.postgres_db_instance]
}