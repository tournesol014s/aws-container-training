resource "aws_s3_bucket" "sbcntrApplicationLogBucket" {
  bucket = "sbcntr-${data.aws_caller_identity.self.account_id}"
}

resource "aws_s3_bucket_acl" "sbcntrApplicationLogBucket" {
  bucket = aws_s3_bucket.sbcntrApplicationLogBucket.bucket
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sbcntrApplicationLogBucket" {
  bucket = aws_s3_bucket.sbcntrApplicationLogBucket.bucket

  rule {
    bucket_key_enabled = false

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
