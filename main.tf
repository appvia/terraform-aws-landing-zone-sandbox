
## Provision the landing zone via the base module 
module "landing_zone" {
  source = "github.com/appvia/terraform-aws-landing-zones?ref=main"

  cost_center                     = var.cost_center
  dns                             = var.dns
  environment                     = "Sandbox"
  home_region                     = local.home_region
  identity_center_permitted_roles = local.sso_permitted_permissionsets
  networks                        = local.networks
  notifications                   = local.notifications
  owner                           = var.owner
  product                         = "Sandbox"
  rbac                            = local.rbac
  region                          = var.region
  service_control_policies        = var.service_control_policies
  tags                            = local.tags

  ## Ensure all accounts have cost anomaly detection enabled 
  cost_anomaly_detection = {
    enable   = true
    monitors = local.cost_anomaly_default_monitors
  }

  ## Ensure all accounts have a default KMS key adminstrator, assumable 
  ## by the audit account
  kms_administrator = {
    assume_accounts = [local.audit_account_id]
    enable          = true
    name            = "lza-kms-administrator"
  }

  ## Ensure all accounts have a default kms key for encryption 
  kms_key = {
    enable    = false
    key_alias = "lza/account/default"
  }

  providers = {
    aws.tenant     = aws.tenant
    aws.identity   = aws.identity
    aws.management = aws.management
    aws.network    = aws.network
  }
}

## Provision the resources requried to run the scheduled nuke task within 
## the account region
module "nuke_service" {
  source = "github.com/appvia/terraform-aws-nuke?ref=main"

  ## The account id we are provisioning in 
  account_id = local.account_id
  ## Indicates we should assign a public IP to the nuke service 
  assign_public_ip = true
  ## Indicates if the KMS key should be created for the log group 
  create_kms_key = false
  ## The region we are provisioning in 
  region = local.region
  ## The ssubnet_ids to use for the nuke service 
  subnet_ids = module.landing_zone.networks[local.nuke_vpc_name].public_subnet_ids
  ## The tags for the resources created by this module 
  tags = local.operation_tags
  ## The tasks to run 
  tasks = local.nuke_tasks

  providers = {
    aws = aws.tenant
  }

  depends_on = [
    module.landing_zone,
  ]
}
