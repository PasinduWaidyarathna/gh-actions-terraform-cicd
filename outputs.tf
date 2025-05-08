output "bucket_name" {
  value = aws_s3_bucket.example.bucket
}

output "kms_key_id" {
  value = aws_kms_key.mykey.key_id
}
