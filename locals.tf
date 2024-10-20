
locals {
  ## The account id of the tenant account 
  account_id = data.aws_caller_identity.current.account_id
  ## The current region for the tenant account
  region = data.aws_region.current.name

  ## The notifications configuration for the landing zone 
  notifications = {
    email : var.notifications.email
    slack : var.notifications.slack
    services : {
      securityhub = {
        enable = true
      }
    }
  }
}
