##############################
# Security Group(Ingress)
##############################
resource "aws_security_group" "sbcntrSgIngress" {
  name        = "ingress"
  description = "Security group for ingress"
  vpc_id      = aws_vpc.sbcntrVpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
  }

  tags = {
    Name = "sbcntr-sg-ingress"
  }
}

resource "aws_security_group_rule" "ssbcntrSgIngressFromInternet" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.clientIpAddress]
  security_group_id = aws_security_group.sbcntrSgIngress.id
  description       = "HTTP for Internet"
}

##############################
# Security Group(Management)
##############################
resource "aws_security_group" "sbcntrSgManagement" {
  name        = "management"
  description = "Security Group of management server"
  vpc_id      = aws_vpc.sbcntrVpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
  }

  tags = {
    Name = "sbcntr-sg-management"
  }
}

##############################
# Security Group(Backend Container)
##############################
resource "aws_security_group" "sbcntrSgContainer" {
  name        = "container"
  description = "Security Group of backend app"
  vpc_id      = aws_vpc.sbcntrVpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
  }

  tags = {
    Name = "sbcntr-sg-container"
  }
}

resource "aws_security_group_rule" "sbcntrSgContainerFromSgFrontContainer" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sbcntrSgInternal.id
  security_group_id        = aws_security_group.sbcntrSgContainer.id
  description              = "HTTP for internal lb"
}

##############################
# Security Group(Frontend Container)
##############################
resource "aws_security_group" "sbcntrSgFrontContainer" {
  name        = "front-container"
  description = "Security Group of front container app"
  vpc_id      = aws_vpc.sbcntrVpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
  }

  tags = {
    Name = "sbcntr-sg-front-container"
  }
}

resource "aws_security_group_rule" "sbcntrSgFrontContainerFromSgFrontContainer" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sbcntrSgIngress.id
  security_group_id        = aws_security_group.sbcntrSgFrontContainer.id
  description              = "HTTP for Ingress"
}

##############################
# Security Group(Internal ALB)
##############################
resource "aws_security_group" "sbcntrSgInternal" {
  name        = "internal"
  description = "Security group for internal load balancer"
  vpc_id      = aws_vpc.sbcntrVpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
  }

  tags = {
    Name = "sbcntr-sg-internal"
  }
}

resource "aws_security_group_rule" "sbcntrSgInternalFromSgFrontContainer" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sbcntrSgFrontContainer.id
  security_group_id        = aws_security_group.sbcntrSgInternal.id
  description              = "HTTP for front container"
}

resource "aws_security_group_rule" "sbcntrSgInternalFromSgManagementTCP" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sbcntrSgManagement.id
  security_group_id        = aws_security_group.sbcntrSgInternal.id
  description              = "HTTP for management server"
}

resource "aws_security_group_rule" "sbcntrSgInternalFromSgManagementTCPTestPort" {
  type                     = "ingress"
  from_port                = 10080
  to_port                  = 10080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sbcntrSgManagement.id
  security_group_id        = aws_security_group.sbcntrSgInternal.id
  description              = "Test port for management server"
}

##############################
# Security Group(DB)
##############################
resource "aws_security_group" "sbcntrSgDb" {
  name        = "database"
  description = "Security Group of database"
  vpc_id      = aws_vpc.sbcntrVpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic by default"
  }

  tags = {
    Name = "sbcntr-sg-db"
  }
}

resource "aws_security_group_rule" "sbcntrSgDbFromSgContainerTCP" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sbcntrSgContainer.id
  security_group_id        = aws_security_group.sbcntrSgDb.id
  description              = "MySQL protocol from backend App"
}

resource "aws_security_group_rule" "sbcntrSgDbFromSgFrontContainerTCP" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sbcntrSgFrontContainer.id
  security_group_id        = aws_security_group.sbcntrSgDb.id
  description              = "MySQL protocol from frontend App"
}

resource "aws_security_group_rule" "sbcntrSgDbFromSgManagementTCP" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sbcntrSgManagement.id
  security_group_id        = aws_security_group.sbcntrSgDb.id
  description              = "MySQL protocol from management server"
}
