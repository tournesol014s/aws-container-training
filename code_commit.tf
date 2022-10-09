resource "aws_codecommit_repository" "sbcntrBackend" {
  repository_name = "sbcntr-backend"
  description     = "Repository for sbcntr backend application"
}
