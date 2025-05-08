resource "aws_s3_bucket" "example" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.example.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example
  ]
  bucket = aws_s3_bucket.example.id
  acl    = "public-read"
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.example.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  enable_key_rotation     = true
  deletion_window_in_days = 7
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.example.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Static Website Hosting
resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.example.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "404.html"
  }
}

# Public Read Access Policy (for website files)
resource "aws_s3_bucket_policy" "public_read" {
  # Add explicit dependency on public access block
  depends_on = [aws_s3_bucket_public_access_block.example]
  
  bucket = aws_s3_bucket.example.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.example.arn}/*"
      }
    ]
  })
}