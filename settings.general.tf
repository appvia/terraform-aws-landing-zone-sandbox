
locals {
  ## The home region for provisioning global resources such as IAM 
  home_region = "eu-west-2"

  ## The tags to apply to resources
  tags = merge(var.tags, {
    "Provisioner" = "Terraform"
  })

  ## The audit accound id 
  audit_account_id = "012140491173"

  ## The tags used for support related resources
  operation_tags = {
    "Environment" = "Production"
    "GitRepo"     = var.git_repository
    "Owner"       = "Support"
    "Product"     = "LandingZone"
  }
}
