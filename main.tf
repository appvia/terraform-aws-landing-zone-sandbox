
## Provision the landing zone via the base module 
module "landing_zone" {
  source = "github.com/appvia/terraform-aws-landing-zones?ref=main"

  anomaly_detection        = var.anomaly_detection
  cost_center              = var.cost_center
  dns                      = var.dns
  environment              = "Sandbox"
  kms                      = var.kms
  networks                 = local.networks
  notifications            = var.notifications
  owner                    = var.owner
  product                  = "Sandbox"
  rbac                     = local.rbac
  region                   = var.region
  service_control_policies = var.service_control_policies
  tags                     = var.tags

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
