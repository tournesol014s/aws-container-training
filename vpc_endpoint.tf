resource "aws_vpc_endpoint" "sbcntrVpceEcrApi" {
  vpc_id              = aws_vpc.sbcntrVpc.id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.sbcntrSubnetPrivateEgress1a.id,
    aws_subnet.sbcntrSubnetPrivateEgress1c.id,
  ]

  security_group_ids = [
    aws_security_group.sbcntrSgEgress.id,
  ]

  tags = {
    Name = "sbcntr-vpce-ecr-api"
  }
}

resource "aws_vpc_endpoint" "sbcntrVpceEcrDkr" {
  vpc_id              = aws_vpc.sbcntrVpc.id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.sbcntrSubnetPrivateEgress1a.id,
    aws_subnet.sbcntrSubnetPrivateEgress1c.id,
  ]
  security_group_ids = [
    aws_security_group.sbcntrSgEgress.id,
  ]

  tags = {
    Name = "sbcntr-vpce-ecr-dkr"
  }
}

resource "aws_vpc_endpoint" "sbcntrVpceS3" {
  vpc_id       = aws_vpc.sbcntrVpc.id
  service_name = "com.amazonaws.ap-northeast-1.s3"

  route_table_ids = [
    aws_route_table.sbcntrRouteApp.id,
  ]

  tags = {
    Name = "sbcntr-vpce-s3"
  }
}
