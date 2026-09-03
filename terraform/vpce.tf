# S3 Interface VPC Endpoint (AWS PrivateLink)
resource "aws_vpc_endpoint" "s3" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.s3_vpce.id]
  private_dns_enabled = false

  tags = {
    Name = "poc-s3-interface-vpce"
  }
}

# Lookup ENI network interfaces created by the Interface VPC Endpoint to retrieve private IPs
data "aws_network_interface" "s3_vpce" {
  count = 2

  filter {
    name   = "subnet-id"
    values = [aws_subnet.private[count.index].id]
  }

  filter {
    name   = "interface-type"
    values = ["vpc_endpoint"]
  }

  depends_on = [aws_vpc_endpoint.s3]
}
