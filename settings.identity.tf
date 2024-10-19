
locals {
  ## The permitted permission sets that can be assigned to the account, and their 
  ## corresponding permission set in identity center; unless the permissionset is 
  ## mentioned here, it cannot be assigned to the account 
  sso_permitted_permissionsets = {
    "administrator"     = "Administrator"
    "devops_engineer"   = "DevOpsEngineer"
    "finops_engineer"   = "FinOpsEngineer"
    "network_engineer"  = "NetworkEngineer"
    "network_viewer"    = "NetworkViewer"
    "platform_engineer" = "PlatformEngineer"
    "security_auditor"  = "SecurityAuditor"
  }

  ## Iterate and filter out any unsupported roles 
  rbac = {
    for k, v in var.rbac : k => v if local.sso_permitted_permissionsets[k] != null
  }
}
