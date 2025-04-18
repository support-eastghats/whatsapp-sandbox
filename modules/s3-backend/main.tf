data "aws_s3_bucket" "existing" {
  bucket = var.bucket_name
  count  = var.force_create ? 0 : 1
}

resource "aws_s3_bucket" "this" {
  count  = var.force_create ? 1 : 0
  bucket = var.bucket_name
  tags   = var.tags

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [tags]
  }
}

resource "aws_s3_bucket_versioning" "this" {
  count  = var.force_create ? 1 : 0
  bucket = aws_s3_bucket.this[0].id

  versioning_configuration {
    status = "Enabled"
  }
}
