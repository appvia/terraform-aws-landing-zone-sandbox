
## Provision the landing zone via the base module 
module "landing_zone" {
  source = "github.com/appvia/terraform-aws-landing-zones?ref=main"

  anomaly_detection        = var.anomaly_detection
  cost_center              = var.cost_center
  dns                      = var.dns
  environment              = var.environment
  kms                      = var.kms
  networks                 = local.networks
  notifications            = var.notifications
  owner                    = var.owner
  product                  = var.product
  rbac                     = var.rbac
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
  count  = local.nuke_enabled ? 1 : 0
  source = "github.com/appvia/terraform-aws-nuke?ref=main"

  ## The account id we are provisioning in 
  account_id = local.account_id
  ## Indicates we should assign a public IP to the nuke service 
  assign_public_ip = true
  ## Indicates if the KMS key should be created for the log group 
  create_kms_key = false
  ## Indicates if we should skips deletion (default is false)
  enable_deletion = false
  ## This is the location of the aws-nuke configuration file, this is 
  ## copied into the container via a parameter store value
  nuke_configuration = "${path.module}/assets/nuke/config.yml"
  ## The region we are provisioning in 
  region = local.region
  ## This will create a task that runs every day at midnight
  schedule_expression = local.nuke_schedule_expression
  ## The ssubnet_ids to use for the nuke service 
  subnet_ids = module.landing_zone.networks[local.nuke_vpc_name].public_subnet_ids
  ## The tags for the resources created by this module 
  tags = local.operation_tags

  providers = {
    aws = aws.tenant
  }

  depends_on = [
    module.landing_zone,
  ]
}
