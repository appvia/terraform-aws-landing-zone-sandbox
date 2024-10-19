
locals {
  ## The networks we should create within the sandbox account 
  networks_all = merge(var.networks, local.nuke_enabled == true ? local.nuke_network : {})

  ## The network configuration for transit gateways
  transit_gateway_by_region = {
    "af-south-1"     = null
    "ap-east-1"      = null
    "ap-northeast-1" = null
    "ap-northeast-1" = null
    "ap-northeast-2" = null
    "ap-northeast-3" = null
    "ap-south-1"     = null
    "ap-southeast-1" = null
    "ap-southeast-2" = null
    "ap-southeast-3" = null
    "ap-southeast-5" = null
    "ca-central-1"   = null
    "cn-north-1"     = null
    "cn-northwest-1" = null
    "eu-central-1"   = null
    "eu-north-1"     = null
    "eu-south-1"     = null
    "eu-west-1"      = null
    "eu-west-2"      = "tgw-04ad8f026be8b7eb6"
    "eu-west-3"      = null
    "me-south-1"     = null
    "mt-east-1"      = null
    "sa-east-1"      = null
    "us-east-1"      = null
    "us-east-2"      = null
    "us-gov-east-1"  = null
    "us-gov-west-1"  = null
    "us-west-1"      = null
    "us-west-2"      = null
  }

  ## We use the lookup table above to derive the transit gateway id to use 
  transit_gateway_id = local.transit_gateway_by_region[local.region]

  ## When the transit gateway routes are not defined in the tenant configuration, we use the default 
  ## below - routing all private traffic to the hub and spoke network
  transit_gateway_default_routes = {
    "private" : "10.0.0.0/8",
  }

  ## The networks merged with the transit_gateway configuration 
  networks = { for k, v in local.networks_all : k => merge(v, {
    transit_gateway = {
      gateway_id     = local.transit_gateway_id
      gateway_routes = local.transit_gateway_default_routes
    }
  }) }

}
