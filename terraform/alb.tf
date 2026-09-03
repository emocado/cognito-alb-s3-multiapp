# Target Group pointing to S3 Interface VPC Endpoint ENI private IPs
resource "aws_lb_target_group" "s3_vpce" {
  name        = "s3-vpce-tg-${random_string.suffix.result}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 30
    path                = "/main/index.html"
    protocol            = "HTTP"
    port                = "80"
    matcher             = "200,301,307,400,403,405"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
  }

  tags = {
    Name = "poc-s3-vpce-tg"
  }
}

# Attach each S3 Interface VPC Endpoint ENI private IP to the Target Group
resource "aws_lb_target_group_attachment" "s3_vpce" {
  count            = 2
  target_group_arn = aws_lb_target_group.s3_vpce.arn
  target_id        = data.aws_network_interface.s3_vpce[count.index].private_ip
  port             = 80
}

# Internet-Facing Application Load Balancer
resource "aws_lb" "main" {
  name               = "poc-alb-${random_string.suffix.result}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "poc-cognito-alb"
  }
}

# HTTPS Listener (Port 443) terminating TLS with the Self-Signed Certificate
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.alb_cert.arn

  # Action 1: Authenticate against Cognito Hosted UI
  default_action {
    type  = "authenticate-cognito"
    order = 1

    authenticate_cognito {
      user_pool_arn              = aws_cognito_user_pool.pool.arn
      user_pool_client_id        = aws_cognito_user_pool_client.client.id
      user_pool_domain           = aws_cognito_user_pool_domain.domain.domain
      session_timeout            = 604800
      scope                      = "openid email profile"
      on_unauthenticated_request = "authenticate"
    }
  }

  # Action 2: Forward authenticated requests to S3 VPC Endpoint
  default_action {
    type             = "forward"
    order            = 2
    target_group_arn = aws_lb_target_group.s3_vpce.arn
  }
}

# HTTP Listener (Port 80) redirects all plaintext traffic to HTTPS 443
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
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

# Listener Rule: Forward S3 ListBucket API calls (/?list-type=2) to S3 VPCE
# Enables client-side dynamic discovery of new folders in the S3 bucket
resource "aws_lb_listener_rule" "s3_list_bucket" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 50

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.s3_vpce.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }

  condition {
    query_string {
      key   = "list-type"
      value = "2"
    }
  }
}

# Listener Rule: Root redirect '/' to '/main/index.html'
resource "aws_lb_listener_rule" "root_redirect" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 60

  action {
    type = "redirect"
    redirect {
      path        = "/main/index.html"
      status_code = "HTTP_302"
    }
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

# Convenience redirects for folder paths lacking index.html
resource "aws_lb_listener_rule" "main_redirect" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 70

  action {
    type = "redirect"
    redirect {
      path        = "/main/index.html"
      status_code = "HTTP_302"
    }
  }

  condition {
    path_pattern {
      values = ["/main", "/main/"]
    }
  }
}

resource "aws_lb_listener_rule" "web1_redirect" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 71

  action {
    type = "redirect"
    redirect {
      path        = "/web1/index.html"
      status_code = "HTTP_302"
    }
  }

  condition {
    path_pattern {
      values = ["/web1", "/web1/"]
    }
  }
}

resource "aws_lb_listener_rule" "web2_redirect" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 72

  action {
    type = "redirect"
    redirect {
      path        = "/web2/index.html"
      status_code = "HTTP_302"
    }
  }

  condition {
    path_pattern {
      values = ["/web2", "/web2/"]
    }
  }
}

resource "aws_lb_listener_rule" "web3_redirect" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 73

  action {
    type = "redirect"
    redirect {
      path        = "/web3/index.html"
      status_code = "HTTP_302"
    }
  }

  condition {
    path_pattern {
      values = ["/web3", "/web3/"]
    }
  }
}
