locals {
  ACCOUNT_ID = data.aws_caller_identity.current.account_id
  REGION     = data.aws_region.current.name
}
