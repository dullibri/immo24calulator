# Define the IAM user policy to ensure it has necessary permissions
resource "aws_iam_user_policy" "user_policy" {
  name = "s3_bucket_policy"
  user = "Dirk"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:PutObject",
          "s3:PutBucketPolicy",
          "s3:GetBucketPolicy",
          "s3:DeleteBucketPolicy"
        ],
        Resource = [
          "arn:aws:s3:::immo24calculator",
          "arn:aws:s3:::immo24calculator/*"
        ]
      }
    ]
  })
}

# Define the S3 Bucket
resource "aws_s3_bucket" "immo24calculator" {
  bucket = "immo24calculator"
}

# Define the S3 Bucket Website Configuration
resource "aws_s3_bucket_website_configuration" "immo24calculator_website" {
  bucket = aws_s3_bucket.immo24calculator.id

  index_document {
    suffix = "index.html"
  }
}

# Define the S3 Bucket Policy
resource "aws_s3_bucket_policy" "immo24calculator_policy" {
  bucket = aws_s3_bucket.immo24calculator.id
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = "*",
      Action    = "s3:GetObject",
      Resource  = "${aws_s3_bucket.immo24calculator.arn}/*",
      Sid       = "PublicReadGetObject"
    }]
  })
}

# CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "immo24calculator_oai" {
  comment = "OAI for S3 bucket"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "immo24calculator_distribution" {
  origin {
    domain_name = aws_s3_bucket.immo24calculator.bucket_regional_domain_name
    origin_id   = "S3-immo24calculator"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.immo24calculator_oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for immo24calculator"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-immo24calculator"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  depends_on = [aws_s3_bucket_policy.immo24calculator_policy]

  tags = {
    Name = "immo24calculator_distribution"
  }
}
