
## Provision the landing zone via the base module 
module "landing_zone" {
  source = "github.com/appvia/terraform-aws-landing-zones?ref=main"

  anomaly_detection        = var.anomaly_detection
  cost_center              = var.cost_center
  dns                      = var.dns
  environment              = var.environment
  kms                      = var.kms
  networks                 = var.networks
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
