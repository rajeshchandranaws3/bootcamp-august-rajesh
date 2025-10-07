# ALB itself

resource "aws_lb" "alb" {
  name                       = "august-alb"
  subnets                    = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  enable_deletion_protection = false
}

# target group for ALB

resource "aws_lb_target_group" "alb" {
  name        = "august-alb-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold = "3"
    interval          = "90"
    protocol          = "HTTP"
    matcher           = "200-299"
    timeout           = "20"
    path              = "/login"
  }
}


# ALB listener for http

resource "aws_lb_listener" "http_forward" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb.arn
  }
}


# ALB listener for https

resource "aws_lb_listener" "https_forward" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb.arn
  }
}

