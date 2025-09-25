provider "aws" {
  alias  = "seoul"
  region = "ap-northeast-2"
}

resource "aws_kinesis_stream" "kinesis" {
  provider    = aws.seoul
  name        = "kinesis"
  shard_count = 1
}

resource "aws_s3_bucket" "bucket" {
  bucket = "bucket-pearl-woosupar"
}

data "aws_iam_policy_document" "firehose_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "firehose_role" {
  name               = "firehose_role"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role.json
}

resource "aws_iam_role_policy" "firehose_policy" {
  name = "firehose_policy"
  role = aws_iam_role.firehose_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kinesis:DescribeStream",
          "kinesis:GetShardIterator",
          "kinesis:GetRecords",
          "kinesis:ListShards"
        ]
        Resource = aws_kinesis_stream.kinesis.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.bucket.arn,
          "${aws_s3_bucket.bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_kinesis_firehose_delivery_stream" "kinesis_to_es3" {
  name        = "kinesis_to_es3"
  destination = "extended_s3"

  depends_on = [aws_iam_role_policy.firehose_policy]

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.bucket.arn

    buffering_size     = 5
    buffering_interval = 300
    compression_format = "GZIP"

    error_output_prefix = "error/"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "/aws/kinesisfirehose/pearl"
      log_stream_name = "S3Delivery"
    }
  }

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.kinesis.arn
    role_arn           = aws_iam_role.firehose_role.arn
  }
}


# Firehose가 필요한 권한 정책 추가