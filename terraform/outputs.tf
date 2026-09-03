output "domain_name" {
  description = "Domain name that matches both the ALB self-signed cert and the S3 bucket name"
  value       = local.site_domain
}

output "s3_bucket_name" {
  description = "Amazon S3 bucket name (identical to domain_name)"
  value       = aws_s3_bucket.main.bucket
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Application Load Balancer Route53 Canonical Hosted Zone ID"
  value       = aws_lb.main.zone_id
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.pool.id
}

output "cognito_app_client_id" {
  description = "Cognito App Client ID used by ALB"
  value       = aws_cognito_user_pool_client.client.id
}

output "cognito_hosted_ui_domain" {
  description = "Cognito Hosted UI domain URL"
  value       = "https://${aws_cognito_user_pool_domain.domain.domain}.auth.${var.aws_region}.amazoncognito.com"
}

output "test_user_credentials" {
  description = "Pre-provisioned Cognito credentials for immediate testing"
  value = {
    email    = var.test_user_email
    password = var.test_user_password
  }
}

output "central_catalog_url" {
  description = "URL to access the central dynamic website catalog"
  value       = "https://${local.site_domain}/main/index.html"
}

output "hosts_file_instruction" {
  description = "Instruction on adding local DNS resolution to test with self-signed domain"
  value       = "Run in PowerShell (as Admin) or edit C:\\Windows\\System32\\drivers\\etc\\hosts: Add line '<ALB_PUBLIC_IP> ${local.site_domain}'"
}
