resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

locals {
  # The domain name MUST match the S3 bucket name
  site_domain = var.domain_name != "" ? var.domain_name : "poc-apps-${random_string.suffix.result}.internal"
}

resource "aws_s3_bucket" "main" {
  bucket        = local.site_domain
  force_destroy = true

  tags = {
    Name = local.site_domain
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket policy allowing GetObject and ListBucket through S3 Interface VPC Endpoint
resource "aws_s3_bucket_policy" "main" {
  bucket     = aws_s3_bucket.main.id
  depends_on = [aws_s3_bucket_public_access_block.main]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowGetObjectFromVPCE"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.main.arn}/*"
        Condition = {
          StringEquals = {
            "aws:sourceVpce" = aws_vpc_endpoint.s3.id
          }
        }
      },
      {
        Sid       = "AllowListBucketFromVPCE"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:ListBucket"
        Resource  = aws_s3_bucket.main.arn
        Condition = {
          StringEquals = {
            "aws:sourceVpce" = aws_vpc_endpoint.s3.id
          }
        }
      }
    ]
  })
}

# Upload Central Catalog Artifact
resource "aws_s3_object" "main_index" {
  bucket       = aws_s3_bucket.main.id
  key          = "main/index.html"
  source       = "${path.module}/../artifacts/main/index.html"
  content_type = "text/html; charset=utf-8"
  etag         = filemd5("${path.module}/../artifacts/main/index.html")
}

# Upload Web App 1 (Project Phoenix)
resource "aws_s3_object" "web1_index" {
  bucket       = aws_s3_bucket.main.id
  key          = "web1/index.html"
  source       = "${path.module}/../artifacts/web1/index.html"
  content_type = "text/html; charset=utf-8"
  etag         = filemd5("${path.module}/../artifacts/web1/index.html")
}

# Upload Web App 2 (Project Orion)
resource "aws_s3_object" "web2_index" {
  bucket       = aws_s3_bucket.main.id
  key          = "web2/index.html"
  source       = "${path.module}/../artifacts/web2/index.html"
  content_type = "text/html; charset=utf-8"
  etag         = filemd5("${path.module}/../artifacts/web2/index.html")
}

# Upload Web App 3 (Project Nebula - tests dynamic discovery)
resource "aws_s3_object" "web3_index" {
  bucket       = aws_s3_bucket.main.id
  key          = "web3/index.html"
  source       = "${path.module}/../artifacts/web3/index.html"
  content_type = "text/html; charset=utf-8"
  etag         = filemd5("${path.module}/../artifacts/web3/index.html")
}
