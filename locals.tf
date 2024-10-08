
locals {
  ## The current region for the current account 
  region = data.aws_region.current.name

  ## The tags used for support related resources
  operation_tags = {
    "Environment" = "Production"
    "GitRepo"     = var.git_repository
    "Owner"       = "Support"
    "Product"     = "LandingZone"
  }

  ## Indicates if the nuke module should be enabled 
  nuke_enabled = true
  ## Is the name of the vpc we use to run the caretaker task within 
  nuke_vpc_name = format("nuke-%s", local.region)
  ## This VPC CIDR block is used for the nuke module 
  nuke_network = {
    (local.nuke_vpc_name) : {
      vpc = {
        availability_zones     = 2
        cidr                   = "172.16.0.0/25"
        enable_ipam            = false
        enable_transit_gateway = false
        nat_gateway_mode       = "none"
        public_subnet_netmask  = 28
        tags                   = local.operation_tags
        transit_gateway_id     = null
      }
    }
  }
  ## The cron expression for the nuke task 
  nuke_schedule_expression = "cron(0 0 * * ? *)"

  ## The networks we should create within the sandbox account 
  networks = merge(var.networks, local.nuke_enabled ? local.nuke_network : {})
}
