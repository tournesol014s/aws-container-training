resource "aws_vpc" "sbcntrVpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "sbcntrVpc"
  }
}

resource "aws_internet_gateway" "sbcntrIgw" {
  vpc_id = aws_vpc.sbcntrVpc.id

  tags = {
    Name = "sbcntr-igw"
  }
}
