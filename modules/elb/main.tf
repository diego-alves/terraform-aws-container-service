# ---------------------------------------------------------------------------------------------------------------------
# LOAD BALANCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lb" "lb" {
  name               = "${var.name}-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.secgroup.id]
  subnets            = var.subnets

  enable_deletion_protection = false

}

# ---------------------------------------------------------------------------------------------------------------------
# LOAD BALANCE LISTENERS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.selected.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default_lb_gt.arn
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

}

resource "aws_lb_listener_rule" "rules" {
  for_each     = var.rules
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tgs[each.key].arn
  }

  condition {
    path_pattern {
      values = each.value.paths
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# TARGET GROUPS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lb_target_group" "default_lb_gt" {
  name        = "${var.name}-lb-tg"
  port        = var.default_rule.port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    path                = var.default_rule.hc_path
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

}

resource "aws_lb_target_group" "tgs" {
  for_each    = var.rules
  name        = "${var.name}-${each.key}-lb-tg"
  port        = each.value.port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    path                = each.value.hc_path
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

}

# ---------------------------------------------------------------------------------------------------------------------
# SECURITY GROUP
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "secgroup" {
  name   = "${var.name}-lb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CERTIFICATE
# ---------------------------------------------------------------------------------------------------------------------

data "aws_acm_certificate" "selected" {
  domain      = "*.${data.aws_route53_zone.selected.name}"
  statuses    = ["ISSUED"]
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

data "aws_route53_zone" "selected" {
  name         = var.zone
  private_zone = true
}