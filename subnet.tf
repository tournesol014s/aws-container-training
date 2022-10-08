
##############################
# AZ List
##############################
data "aws_availability_zones" "available" {
  state = "available"
}

##############################
# Public Subnet(Ingress)
##############################
resource "aws_subnet" "sbcntrSubnetPublicIngress1a" {
  vpc_id                  = aws_vpc.sbcntrVpc.id
  availability_zone       = data.aws_availability_zones.available.names[0]
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "sbcntr-subnet-public-ingress-1a"
    Type = "Public"
  }
}

resource "aws_subnet" "sbcntrSubnetPublicIngress1c" {
  vpc_id                  = aws_vpc.sbcntrVpc.id
  availability_zone       = data.aws_availability_zones.available.names[1]
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "sbcntr-subnet-public-ingress-1c"
    Type = "Public"
  }
}

##############################
# Private Subnet(App)
##############################
resource "aws_subnet" "sbcntrSubnetPrivateContainer1a" {
  vpc_id                  = aws_vpc.sbcntrVpc.id
  availability_zone       = data.aws_availability_zones.available.names[0]
  cidr_block              = "10.0.8.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "sbcntr-subnet-private-container-1a"
    Type = "Isolated"
  }
}

resource "aws_subnet" "sbcntrSubnetPrivateContainer1c" {
  vpc_id                  = aws_vpc.sbcntrVpc.id
  availability_zone       = data.aws_availability_zones.available.names[1]
  cidr_block              = "10.0.9.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "sbcntr-subnet-private-container-1c"
    Type = "Isolated"
  }
}

##############################
# Private Subnet(DB)
##############################
resource "aws_subnet" "sbcntrSubnetPrivateDb1a" {
  vpc_id                  = aws_vpc.sbcntrVpc.id
  availability_zone       = data.aws_availability_zones.available.names[0]
  cidr_block              = "10.0.16.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "sbcntr-subnet-private-db-1a"
    Type = "Isolated"
  }
}

resource "aws_subnet" "sbcntrSubnetPrivateDb1c" {
  vpc_id                  = aws_vpc.sbcntrVpc.id
  availability_zone       = data.aws_availability_zones.available.names[1]
  cidr_block              = "10.0.17.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "sbcntr-subnet-private-db-1c"
    Type = "Isolated"
  }
}

##############################
# Public Subnet(Management)
##############################
resource "aws_subnet" "sbcntrSubnetPublicManagement1a" {
  vpc_id                  = aws_vpc.sbcntrVpc.id
  availability_zone       = data.aws_availability_zones.available.names[0]
  cidr_block              = "10.0.240.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "sbcntr-subnet-public-management-1a"
    Type = "Public"
  }
}

resource "aws_subnet" "sbcntrSubnetPublicManagement1c" {
  vpc_id                  = aws_vpc.sbcntrVpc.id
  availability_zone       = data.aws_availability_zones.available.names[1]
  cidr_block              = "10.0.241.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "sbcntr-subnet-public-management-1c"
    Type = "Public"
  }
}

##############################
# Public Subnet(Egress)
##############################
resource "aws_subnet" "sbcntrSubnetPrivateEgress1a" {
  vpc_id                  = aws_vpc.sbcntrVpc.id
  availability_zone       = data.aws_availability_zones.available.names[0]
  cidr_block              = "10.0.248.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "sbcntr-subnet-private-egress-1a"
    Type = "Isolated"
  }
}

resource "aws_subnet" "sbcntrSubnetPrivateEgress1c" {
  vpc_id                  = aws_vpc.sbcntrVpc.id
  availability_zone       = data.aws_availability_zones.available.names[1]
  cidr_block              = "10.0.249.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "sbcntr-subnet-private-egress-1c"
    Type = "Isolated"
  }
}
