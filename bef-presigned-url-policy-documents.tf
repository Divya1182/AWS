# Used in KMS
data "aws_iam_policy_document" "presigned-url-kms-iam-policy" {
  #Root Access
  statement {
    sid    = "Root Access"
    effect = "Allow"
    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
      type        = "AWS"
    }
    actions = [
      "kms:*"
    ]
    resources = ["*"]
  }

  # Key Admin
  statement {
    sid    = "Key Administrator"
    effect = "Allow"
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/DEPLOYER"
      ]
      type = "AWS"
    }
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
      "kms:RotateKeyOnDemand",
      "kms:CreateAlias"
    ]
    resources = ["*"]
  }

  #User Roles
  statement {
    sid    = "User roles access"
    effect = "Allow"
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/DEPLOYER",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Enterprise/intentApiLambdaS3AccessPolicy",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Enterprise/BEFStorageSolution",
      ]
      type = "AWS"
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }


  #Allow attachment of persistent resources
  statement {
    sid    = "Allow attachment of persistent resources"
    effect = "Allow"
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/DEPLOYER",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Enterprise/intentApiLambdaS3AccessPolicy"
      ]
      type = "AWS"
    }
    actions = [
      "kms:ListGrants",
      "kms:CreateGrant",
      "kms:RevokeGrant"
    ]
    resources = ["*"]
  }



  #Serivce Users
  statement {
    sid    = "Allow access through S3, Dynamo, SQS for current account"
    effect = "Allow"
    principals {
      identifiers = ["${data.aws_caller_identity.current.id}"]
      type        = "AWS"
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:Get*",
      "kms:List*"
    ]
    resources = ["*"]
    condition {
      test = "StringEquals"
      values = [
        "s3.us-east-1.amazonaws.com",
        "sqs.us-east-1.amazonaws.com",
        "dynamodb.*.amazonaws.com"
      ]
      variable = "kms:ViaService"
    }
  }

  statement {
    sid    = "Allow access through S3 for Polaris and Databricks"
    effect = "Allow"
    principals {
      identifiers = [
        "arn:aws:iam::035074925037:role/UCLandzAccessrole",
        "arn:aws:iam::736713978530:role/hs-polaris-doc-parser_lambda-dev-lambda-role",
        "arn:aws:iam::736713978530:role/hs-polaris-doc-splitter_lambda-dev-lambda-role",
        "arn:aws:iam::736713978530:role/hs-polaris-doc-ingest_lambda-dev-lambda-role",
        "arn:aws:iam::736713978530:role/get-presigned-url-role"
        ]
      type        = "AWS"
    }
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Get*"
    ]
    resources = ["*"]
    condition {
      test = "StringEquals"
      values = [
        "s3.us-east-1.amazonaws.com"
      ]
      variable = "kms:ViaService"
    }
  }

}

# Used in VPC Gateway Endpoint
data "aws_iam_policy_document" "presigned-url-s3-endpoint-policy" {
  statement {
    sid       = "Allow S3 access"
    effect    = "Allow"
    actions   = ["s3:Get*", "s3:Put*", "s3:Delete*"]
    resources = ["arn:aws:s3:::bef*/*", "arn:aws:s3:::bef*/*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      values   = ["o-xl5jimff3q"]
      variable = "aws:PrincipalOrgID"
    }
  }
}


# S3 Bucket related configs
data "aws_iam_policy_document" "presigned-url-s3-policy" {
  statement {
    sid = "BEF Bucket Policy"
    principals {
      identifiers = [
        "${data.aws_caller_identity.current.id}",
        "arn:aws:iam::035074925037:role/UCLandzAccessrole"
        ]
      type        = "AWS"
    }
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:Put*",
      "s3:Delete*",
      "s3:GetObject*",
      "s3:AbortMultipartUpload"
    ]
    resources = [
      "arn:aws:s3:::${local.s3_bucket_name}",
      "arn:aws:s3:::${local.s3_bucket_name}/*"
    ]
  }

  statement {
    sid = "Deny Internet Access"
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    effect = "Deny"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::${local.s3_bucket_name}",
      "arn:aws:s3:::${local.s3_bucket_name}/*"
    ]
    condition {
      test      = "ForAnyValue:StringNotLike"
      variable  = "aws:PrincipalArn"
      values    = [
        	"${data.aws_iam_role.bef_lambda_role.arn}",
					"${data.aws_iam_role.bef_lambda_role.arn}/*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/DEPLOYER",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/DEPLOYER/*",
          "arn:aws:iam::035074925037:role/UCLandzAccessrole",
          "arn:aws:iam::736713978530:role/hs-polaris-doc-parser_lambda-dev-lambda-role",
          "arn:aws:iam::736713978530:role/hs-polaris-doc-ingest_lambda-dev-lambda-role",
          "arn:aws:iam::736713978530:role/hs-polaris-doc-splitter_lambda-dev-lambda-role",
          "arn:aws:iam::736713978530:role/get-presigned-url-role"
      ]
    }
  }
  
  statement {
    sid = "Access Point Policy"
    principals {
      identifiers = [
        "arn:aws:iam::736713978530:role/hs-polaris-doc-parser_lambda-dev-lambda-role",
        "arn:aws:iam::736713978530:role/hs-polaris-doc-splitter_lambda-dev-lambda-role",
        "arn:aws:iam::736713978530:role/hs-polaris-doc-ingest_lambda-dev-lambda-role",
        "arn:aws:iam::736713978530:role/get-presigned-url-role"
      ]
      type = "AWS"
    }
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*"
    ]
    resources = [
      "arn:aws:s3:::${local.s3_bucket_name}",
      "arn:aws:s3:::${local.s3_bucket_name}/*"
    ]
    condition {
      test = "StringEquals"
      variable = "s3:DataAccessPointAccount"
      values = ["${data.aws_caller_identity.current.account_id}"]
    }
  }
}