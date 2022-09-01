terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.28.0"
    }
  }
}

provider "aws" {
      region     = var.region
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.staticbucket

  tags = {
    Name        = var.staticbucket
    Environment = "Poc"
  }
}

resource "aws_s3_bucket_acl" "StaticSiteS3" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}

// Static Web Site for bucket 

resource "aws_s3_bucket_website_configuration" "poc_terraform_august" {
  bucket = var.staticbucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}

// index file copy

resource "aws_s3_object_copy" "index" {
  bucket = var.staticbucket
  key    = "index.html"
  source = "pocbucket1437260622/index.html"

  grant {
    uri         = "http://acs.amazonaws.com/groups/global/AllUsers"
    type        = "Group"
    permissions = ["READ"]
  }
}

// IAM policy for bucket only

resource "aws_iam_policy" "staticsites_policy" {
  name        = "staticsites_policy"
  path        = "/"


  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${var.staticbucket}/*"
      },
    ]
  })

  tags = {
    Name = "value"
  }
}

