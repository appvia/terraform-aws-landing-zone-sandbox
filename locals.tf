
locals {
  ## The current region for the current account 
  region = data.aws_region.current.name

  ## We only need to run the ecs cluster in two availability zones 
  availability_zones = slice(data.aws_availability_zones.current.names, 0, 2)

  ## Is the name of the vpc we use to run the caretaker task within 
  caretaker_vpc_name = format("caretaker-%s", local.region)

  ## This VPC CIDR block is used for the nuke module 
  caretaker_network = {
    (local.caretaker_vpc_name) : {
      subnets = {
        private = {
          availability_zones = local.availability_zones
          netmask            = 28
        }
      }

      vpc = {
        availability_zones       = length(local.availability_zones)
        enable_private_endpoints = []
        enable_shared_endpoints  = false
        enable_transit_gateway   = false
        nat_gateway_mode         = "none"
        netmask                  = 25
      }
    }
  }

  ## The networks we should create within the sandbox account 
  networks = merge(var.networks, var.enable_caretaker ? local.caretaker_network : {})
}
