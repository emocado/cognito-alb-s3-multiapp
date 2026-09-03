resource "aws_cognito_user_pool" "pool" {
  name                     = "poc-user-pool-${random_string.suffix.result}"
  auto_verified_attributes = ["email"]
  username_attributes      = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  tags = {
    Name = "poc-cognito-user-pool"
  }
}

resource "aws_cognito_user_pool_domain" "domain" {
  domain       = "auth-${random_string.suffix.result}"
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_cognito_user_pool_client" "client" {
  name         = "alb-client"
  user_pool_id = aws_cognito_user_pool.pool.id

  # ALB strictly requires generate_secret = true
  generate_secret = true

  allowed_oauth_flows                  = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
  supported_identity_providers         = ["COGNITO"]

  callback_urls = [
    "https://${local.site_domain}/oauth2/idpresponse"
  ]

  logout_urls = [
    "https://${local.site_domain}/main/index.html"
  ]
}

# Pre-provision a test user for zero-friction testing
resource "aws_cognito_user" "test_user" {
  user_pool_id = aws_cognito_user_pool.pool.id
  username     = var.test_user_email
  password     = var.test_user_password

  attributes = {
    email          = var.test_user_email
    email_verified = "true"
  }

  message_action = "SUPPRESS"
}
