# --- External Application Load Balancer ---
resource "aws_lb" "ext-alb" {
  count    = var.enable_pro_services ? 1 : 0
  name     = "ext-alb"
  internal = false
  security_groups = [
    aws_security_group.ext-alb-sg.id,
  ]

  subnets = [
    aws_subnet.public[0].id,
    aws_subnet.public[1].id
  ]

  tags = merge(
    var.tags,
    {
      Name = "ACS-ext-alb"
    },
  )

  ip_address_type    = "ipv4"
  load_balancer_type = "application"
}

# --- Target Group for Nginx ---
resource "aws_lb_target_group" "nginx-tgt" {
  count = var.enable_pro_services ? 1 : 0
  health_check {
    interval            = 10
    path                = "/healthstatus"
    protocol            = "HTTPS"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
  name        = "nginx-tgt"
  port        = 443
  protocol    = "HTTPS"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id
}

# --- Listener for External ALB ---
resource "aws_lb_listener" "nginx-listner" {
  count             = var.enable_pro_services ? 1 : 0
  load_balancer_arn = aws_lb.ext-alb[0].arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.oyindamola.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx-tgt[0].arn
  }
}

# --- Internal Application Load Balancer ---
resource "aws_lb" "ialb" {
  count    = var.enable_pro_services ? 1 : 0
  name     = "ialb"
  internal = true
  security_groups = [
    aws_security_group.int-alb-sg.id,
  ]

  subnets = [
    aws_subnet.private[0].id,
    aws_subnet.private[1].id
  ]

  tags = merge(
    var.tags,
    {
      Name = "ACS-int-alb"
    },
  )

  ip_address_type    = "ipv4"
  load_balancer_type = "application"
}

# --- Target Group for WordPress ---
resource "aws_lb_target_group" "wordpress-tgt" {
  count = var.enable_pro_services ? 1 : 0
  health_check {
    interval            = 10
    path                = "/healthstatus"
    protocol            = "HTTPS"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  name        = "wordpress-tgt"
  port        = 443
  protocol    = "HTTPS"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id
}

# --- Target Group for Tooling ---
resource "aws_lb_target_group" "tooling-tgt" {
  count = var.enable_pro_services ? 1 : 0
  health_check {
    interval            = 10
    path                = "/healthstatus"
    protocol            = "HTTPS"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  name        = "tooling-tgt"
  port        = 443
  protocol    = "HTTPS"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id
}

# --- Listener for Internal ALB ---
resource "aws_lb_listener" "web-listener" {
  count             = var.enable_pro_services ? 1 : 0
  load_balancer_arn = aws_lb.ialb[0].arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.oyindamola.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress-tgt[0].arn
  }
}

# --- Listener Rule for Tooling ---
resource "aws_lb_listener_rule" "tooling-listener" {
  count        = var.enable_pro_services ? 1 : 0
  listener_arn = aws_lb_listener.web-listener[0].arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tooling-tgt[0].arn
  }

  condition {
    host_header {
      values = ["tooling.oyindamola.gq"]
    }
  }
}