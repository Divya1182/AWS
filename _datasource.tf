# used to get the account id
data "aws_caller_identity" "current" {}
data "aws_region" "current_region" {}

data "aws_iam_role" "bef_lambda_role" {
  name = "BEFStorageSolution"
}

# This is to make bucket name unique across accounts
locals {
  s3_bucket_name = "${var.bef_bucket_name}-${data.aws_caller_identity.current.account_id}"
}

# ----------------------------------------------------------------------------------------------------------------------
# Load the Central Logging Destination ARN
# ----------------------------------------------------------------------------------------------------------------------
data "aws_ssm_parameter" "org_logging_arn" {
  name = "/Enterprise/OrgCentralLoggingDestinationArn"
}
 
data "aws_ssm_parameter" "org_logging_role" {
  name = "/Enterprise/OrgCentralLoggingRole"
}