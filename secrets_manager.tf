resource "aws_secretsmanager_secret" "sbcntrMySqlSecret" {
  name        = "sbcntr/mysql"
  description = "コンテナユーザー用sbcntr-dbアクセスのシークレット"

  tags = {
    Name = "sbcntr-mysql"
  }
}

resource "aws_secretsmanager_secret_version" "sbcntrMySqlSecretVersion" {
  secret_id     = aws_secretsmanager_secret.sbcntrMySqlSecret.id
  secret_string = jsonencode(local.sbcntrMySqlSecretString)
}

locals {
  sbcntrMySqlSecretString = {
    engine   = "mysql"
    host     = aws_rds_cluster.sbcntrDbCluster.endpoint
    username = "sbcntruser"
    password = "sbcntrEncP"
    dbname   = "sbcntrapp"
  }
}
