variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources in"
  default     = "ap-southeast-1"
}

variable "domain_name" {
  type        = string
  description = "Custom domain name matching S3 bucket name and self-signed certificate. If left empty, a unique name will be generated automatically."
  default     = ""
}

variable "test_user_email" {
  type        = string
  description = "Email for the pre-provisioned Cognito test user"
  default     = "tester@example.com"
}

variable "test_user_password" {
  type        = string
  description = "Password for the pre-provisioned Cognito test user"
  default     = "P@ssw0rd1234!"
}
