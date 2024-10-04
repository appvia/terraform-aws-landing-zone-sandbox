
## Ensure the labelling is consistent across all resources 
module "tagging" {
  source = "github.com/appvia/terraform-null-tagging?ref=v0.0.4"

  cost_center = var.cost_center
  environment = var.environment
  git_repo    = var.git_repository
  owner       = var.owner
  product     = var.product
  service     = var.service
}

## Provision the landing zone via the base module 
module "landing_zone" {
  source = "github.com/appvia/terraform-aws-landing-zones?ref=main"

  anomaly_detection        = var.anomaly_detection
  cost_center              = module.tagging.cost_center
  dns                      = var.dns
  environment              = module.tagging.environment
  kms                      = var.kms
  networks                 = var.networks
  notifications            = var.notifications
  owner                    = module.tagging.owner
  product                  = module.tagging.product
  rbac                     = var.rbac
  region                   = var.region
  service_control_policies = var.service_control_policies
  tags                     = module.tags.tags

  providers = {
    aws.tenant     = aws.tenant
    aws.identity   = aws.identity
    aws.management = aws.management
    aws.network    = aws.network
  }
}
