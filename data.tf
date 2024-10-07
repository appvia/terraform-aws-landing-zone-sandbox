
## Get the current account for the current account 
data "aws_caller_identity" "current" {}

## Get the current region for the current account 
data "aws_region" "current" {}

## Get a list of availablility zones for the current region 
data "aws_availability_zones" "current" {
  state = "available"
}
