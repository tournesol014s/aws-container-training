##############################
# Public Subnet Route(Ingress)
##############################
resource "aws_route_table" "sbcntrRouteIngress" {
  vpc_id = aws_vpc.sbcntrVpc.id

  tags = {
    Name = "sbcntr-route-ingress"
  }
}

resource "aws_route" "sbcntrRouteIngress" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.sbcntrRouteIngress.id
  gateway_id             = aws_internet_gateway.sbcntrIgw.id
}

resource "aws_route_table_association" "sbcntrSubnetPublicIngress1a" {
  subnet_id      = aws_subnet.sbcntrSubnetPublicIngress1a.id
  route_table_id = aws_route_table.sbcntrRouteIngress.id
}

resource "aws_route_table_association" "sbcntrSubnetPublicIngress1c" {
  subnet_id      = aws_subnet.sbcntrSubnetPublicIngress1c.id
  route_table_id = aws_route_table.sbcntrRouteIngress.id
}

##############################
# Public Subnet Route(App)
##############################
resource "aws_route_table" "sbcntrRouteApp" {
  vpc_id = aws_vpc.sbcntrVpc.id

  tags = {
    Name = "sbcntr-route-app"
  }
}

resource "aws_route_table_association" "sbcntrRouteAppAssociation1a" {
  subnet_id      = aws_subnet.sbcntrSubnetPrivateContainer1a.id
  route_table_id = aws_route_table.sbcntrRouteApp.id
}

resource "aws_route_table_association" "sbcntrRouteAppAssociation1c" {
  subnet_id      = aws_subnet.sbcntrSubnetPrivateContainer1c.id
  route_table_id = aws_route_table.sbcntrRouteApp.id
}

##############################
# Public Subnet Route(DB)
##############################
resource "aws_route_table" "sbcntrRouteDb" {
  vpc_id = aws_vpc.sbcntrVpc.id

  tags = {
    Name = "sbcntr-route-db"
  }
}

resource "aws_route_table_association" "sbcntrRouteDbAssociation1a" {
  subnet_id      = aws_subnet.sbcntrSubnetPrivateDb1a.id
  route_table_id = aws_route_table.sbcntrRouteDb.id
}

resource "aws_route_table_association" "sbcntrRouteDbAssociation1c" {
  subnet_id      = aws_subnet.sbcntrSubnetPrivateDb1c.id
  route_table_id = aws_route_table.sbcntrRouteDb.id
}

##############################
# Public Subnet Route(Management)
##############################
resource "aws_route_table_association" "sbcntrRouteManagementAssociation1a" {
  subnet_id      = aws_subnet.sbcntrSubnetPublicManagement1a.id
  route_table_id = aws_route_table.sbcntrRouteIngress.id
}

resource "aws_route_table_association" "sbcntrRouteManagementAssociation1c" {
  subnet_id      = aws_subnet.sbcntrSubnetPublicManagement1c.id
  route_table_id = aws_route_table.sbcntrRouteIngress.id
}
