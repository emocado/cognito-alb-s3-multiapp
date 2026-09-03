# Import self-signed certificate into AWS Certificate Manager
# (Generated with 24h past start-time to prevent clock-skew validation errors)
resource "aws_acm_certificate" "alb_cert" {
  private_key      = file("${path.module}/cert_key.pem")
  certificate_body = file("${path.module}/cert.pem")

  tags = {
    Name = "self-signed-${local.site_domain}"
  }
}
