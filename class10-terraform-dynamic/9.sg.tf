# RDS security group (inbound port 5432 from ECS SG only)

resource "aws_security_group" "rds" {
  name        = "${var.environment}-${var.app}-rds-sg"
  description = "Allow inbound PostgreSQL from ECS only"
  vpc_id      = aws_vpc.main.id

  # inbound rule from ecs sg only
  ingress {
    description     = "PostgreSQL from ECS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_service_sg.id]
  }

  # allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-${var.app}-db Security Group"
  }
}

# ECS security group (inbound port 8000 from ALB SG only)

resource "aws_security_group" "ecs_service_sg" {
  name        = "${var.environment}-${var.app}-ecs-sg"
  description = "Allow inbound traffic on port 8000 from ALB security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow inbound from ALB SG"
    from_port       = var.ecs_app_values["container_port"]
    to_port         = var.ecs_app_values["container_port"]
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-${var.app}-ecs-sg"
  }
}

# ALB security group (port 80 and 443 open to world)

resource "aws_security_group" "alb_sg" {
  name        = "${var.environment}-${var.app}-alb_security_group"
  description = "Allow HTTP and HTTPS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-${var.app}-alb-security-group"
  }
}