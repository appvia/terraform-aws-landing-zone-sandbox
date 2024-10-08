
## Get the current account for the current account 
data "aws_caller_identity" "current" {
  provider = aws.tenant
}

## Get the current region for the current account 
data "aws_region" "current" {
  provider = aws.tenant
}
