output "s3_bucket_name" {
  value = aws_s3_bucket.immo24calculator.bucket
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.immo24calculator_distribution.id
}

output "cloudfront_distribution_domain_name" {
  value = aws_cloudfront_distribution.immo24calculator_distribution.domain_name
}