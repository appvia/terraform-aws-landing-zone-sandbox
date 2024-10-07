
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

## Provision the nuke module to clean up the sandbox accounts 
module "nuke_bomber" {
  count = var.enable_caretaker ? 1 : 0

  source  = "masterpointio/nuke-bomber/aws"
  version = "0.2.0"

  availability_zones    = local.availability_zones
  log_retention_in_days = var.caretaker_log_retention_in_days
  name                  = format("caretaker-%s", local.region)
  namespace             = var.caretaker_namespace
  region                = local.region
  stage                 = var.environment
  schedule_expression   = var.caretaker_schedule_expression
  tags                  = var.tags
  vpc_cidr_block        = var.vpc_cidr_block
  # command = ["-c", "/home/aws-nuke/nuke-config.yml", "--force", "--force-sleep", "3", "--no-dry-run"]
}
