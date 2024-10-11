
output "account_id" {
  description = "The account id where the pipeline is running"
  value       = data.aws_caller_identity.current.account_id
}

output "private_hosted_zones_by_id" {
  description = "A map of the hosted zone name to id"
  value       = module.landing_zone.private_hosted_zones_by_id
}

output "networks" {
  description = "A map of the network name to network details"
  value       = module.landing_zone.networks
}

output "vpc_ids" {
  description = "A map of the network name to vpc id"
  value       = module.landing_zone.vpc_ids
}

