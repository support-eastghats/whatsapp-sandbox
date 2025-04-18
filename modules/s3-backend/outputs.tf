output "bucket_name" {
  description = "Name of the backend S3 bucket"
  value = var.force_create ? aws_s3_bucket.this[0].bucket : data.aws_s3_bucket.existing[0].bucket
}
