# Terraform configuration to provision an s3 bucket in aws

resource "aws_s3_bucket" "random_user_bucket" {
  bucket = "random-profile-extraction"

  tags = {
    Name        = "My buckets"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.random_user_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
