resource "aws_s3_access_point" "s3_access_point" {
  bucket = module.bef-storage-s3.s3_bucket_id
  name   = "${local.s3_bucket_name}-ap"

  public_access_block_configuration {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
  lifecycle {
    ignore_changes = [policy]
  }
  # vpc_configuration {
  #   vpc_id = module.presigned-url-vpc.id
  # }
}

resource "aws_s3control_access_point_policy" "s3_access_point_policy" {
  access_point_arn = aws_s3_access_point.s3_access_point.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "s3:GetObject"
        Principal = {
          AWS =     [
            "arn:aws:iam::736713978530:role/hs-polaris-doc-parser_lambda-dev-lambda-role",
            "arn:aws:iam::736713978530:role/hs-polaris-doc-splitter_lambda-dev-lambda-role",
            "arn:aws:iam::736713978530:role/hs-polaris-doc-ingest_lambda-dev-lambda-role",
            "arn:aws:iam::736713978530:role/get-presigned-url-role"
          ]
        }
        Resource = "${aws_s3_access_point.s3_access_point.arn}/object/*"
      },
      {
        Effect = "Allow"
        Action = "s3:ListBucket"
        Principal = {
          AWS =     [
            "arn:aws:iam::736713978530:role/hs-polaris-doc-parser_lambda-dev-lambda-role",
            "arn:aws:iam::736713978530:role/hs-polaris-doc-splitter_lambda-dev-lambda-role",
            "arn:aws:iam::736713978530:role/hs-polaris-doc-ingest_lambda-dev-lambda-role",
            "arn:aws:iam::736713978530:role/get-presigned-url-role"  
          ]
        }
        Resource = "${aws_s3_access_point.s3_access_point.arn}"
      }
    ]
  })
}


