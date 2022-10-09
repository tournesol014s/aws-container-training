resource "aws_db_subnet_group" "sbcntrRdsSubnetGroup" {
  name        = "sbcntr-rds-subnet-group"
  subnet_ids  = [aws_subnet.sbcntrSubnetPrivateDb1a.id, aws_subnet.sbcntrSubnetPrivateDb1c.id]
  description = "DB subnet group for Aurora"

  tags = {
    Name = "sbcntr-rds-subnet-group"
  }
}

resource "aws_db_parameter_group" "sbcntrAuroraRdsParameterGroup" {
  name   = "sbcntr-aurora-rds-parameter-group"
  family = "aurora-mysql5.7"

  tags = {
    Name = "sbcntr-aurora-rds-parameter-group"
  }
}

resource "aws_rds_cluster_parameter_group" "sbcntrAuroraRdsClusterParameterGroup" {
  name   = "sbcntr-aurora-rds-cluster-parameter-group"
  family = "aurora-mysql5.7"

  tags = {
    Name = "sbcntr-aurora-rds-cluster-parameter-group"
  }
}

resource "aws_rds_cluster" "sbcntrDbCluster" {
  cluster_identifier               = "sbcntr-db"
  engine                           = "aurora-mysql"
  engine_version                   = "5.7.mysql_aurora.2.10.2"
  master_username                  = "admin"
  master_password                  = random_password.sbcntrDbPassword.result
  db_subnet_group_name             = aws_db_subnet_group.sbcntrRdsSubnetGroup.name
  vpc_security_group_ids           = [aws_security_group.sbcntrSgDb.id]
  port                             = 3306
  database_name                    = "sbcntrapp"
  db_cluster_parameter_group_name  = aws_rds_cluster_parameter_group.sbcntrAuroraRdsClusterParameterGroup.name
  db_instance_parameter_group_name = aws_db_parameter_group.sbcntrAuroraRdsParameterGroup.name
  backup_retention_period          = 1
  preferred_backup_window          = "05:00-07:00"
  copy_tags_to_snapshot            = true
  enabled_cloudwatch_logs_exports  = ["audit", "error", "slowquery"]
  storage_encrypted                = true
  deletion_protection              = false
  skip_final_snapshot              = true

  tags = {
    Name = "sbcntr-db"
  }

  lifecycle {
    ignore_changes = [
      master_password
    ]
  }
}

resource "aws_rds_cluster_instance" "sbcntrDbInstance" {
  count                        = 2
  identifier                   = "sbcntr-db-${count.index}"
  cluster_identifier           = aws_rds_cluster.sbcntrDbCluster.id
  instance_class               = "db.t3.small"
  engine                       = aws_rds_cluster.sbcntrDbCluster.engine
  engine_version               = aws_rds_cluster.sbcntrDbCluster.engine_version
  publicly_accessible          = false
  db_subnet_group_name         = aws_db_subnet_group.sbcntrRdsSubnetGroup.name
  monitoring_interval          = 60
  monitoring_role_arn          = aws_iam_role.rdsMonitoringRole.arn
  auto_minor_version_upgrade   = true
  preferred_maintenance_window = "Sat:17:00-Sat:17:30"

  tags = {
    Name = "sbcntr-db-${count.index}"
  }
}

resource "random_password" "sbcntrDbPassword" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
