
variable "dns" {
  description = "A collection of DNS zones to provision and associate with networks"
  type = map(object({
    comment = optional(string, "Managed by zone created by terraform")
    # A comment associated with the DNS zone 
    network = string
    # A list of network names to associate with the DNS zone 
    private = optional(bool, true)
    # A flag indicating if the DNS zone is private or public
  }))
  default = {}

  ## Domain name (map key) must end with aws.appvia.local
  validation {
    condition     = alltrue([for domain in keys(var.dns) : can(regex(".*aws.appvia.local$", domain))])
    error_message = "The domain name must end with aws.appvia.local"
  }
}

variable "enable_nuke" {
  description = "Indicates we should enable the automatic cleanup so resources"
  type        = bool
  default     = true
}

variable "service_control_policies" {
  description = "Provides the ability to associate one of more service control policies with an account"
  type = map(object({
    name = string
    # The policy name to associate with the account 
    policy = string
    # The policy document to associate with the account 
  }))
  default = {}

  ## The name must be less than or equal to 12 characters 
  validation {
    condition     = alltrue([for policy in values(var.service_control_policies) : length(policy.name) <= 12])
    error_message = "The name must be less than or equal to 12 characters"
  }

  ## The policy must be less than or equal to 6,144 characters 
  validation {
    condition     = alltrue([for policy in values(var.service_control_policies) : length(policy.policy) <= 6144])
    error_message = "The policy must be less than or equal to 6,144 characters"
  }
}

variable "rbac" {
  description = "Provides the ability to associate one of more groups with a sso role in the account"
  type = map(object({
    users = optional(list(string), [])
    # A list of users to associate with the developer role
    groups = optional(list(string), [])
    # A list of groups to associate with the developer role 
  }))
  default = {}
}

variable "notifications" {
  description = "A collection of notifications to send to users"
  type = object({
    email = optional(object({
      addresses = list(string)
      # A list of email addresses to send notifications to 
      }), {
      addresses = []
    })
    slack = optional(object({
      webhook_url = string
      # The slack webhook_url to send notifications to 
      }), {
      webhook_url = ""
    })
  })
  default = {
    email = {
      addresses = []
    }
    slack = {
      webhook_url = ""
    }
  }
}
variable "owner" {
  description = "The owner of the product, and injected into all resource tags"
  type        = string

  validation {
    condition     = length(var.owner) > 0
    error_message = "The owner must be greater than 0"
  }

  validation {
    condition     = length(var.owner) <= 64
    error_message = "The owner must be less than or equal to 64"
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.owner))
    error_message = "The owner must be alphanumeric and contain only hyphens and underscores"
  }
}

variable "cost_center" {
  description = "The cost center of the product, and injected into all resource tags"
  type        = string
  default     = null
}

#variable "firewall_rules" {
#  description = "A collection of firewall rules to apply to networks"
#  type = object({
#    capacity = optional(number, 100)
#    # The name of the firewall rule 
#    rules_source = optional(string, null)
#    # The content of the suracata rules
#    ip_sets = optional(map(list(string)), null)
#    # A map of IP sets to apply to the firewall rule, optional ie. WEBSERVERS = ["10.0.0.0/16"]
#    port_sets = optional(map(list(number)), null)
#    # A map of port sets to apply to the firewall rule, optional ie. WEBSERVERS = [80, 443] 
#    domains_whitelist = optional(list(string), [])
#  })
#  default = null
#}

variable "networks" {
  description = "A collection of networks to provision within the designated region"
  type = map(object({
    firewall = optional(object({
      capacity = number
      # The capacity of the firewall rule group 
      rules_source = string
      # The content of the suracata rules
      ip_sets = map(list(string))
      # A map of IP sets to apply to the firewall rule ie. WEBSERVERS = ["100.0.0.0/16"]
      port_sets = map(list(number))
      # A map of port sets to apply to the firewall rule ie. WEBSERVERS = [80, 443] 
      domains_whitelist = list(string)
    }), null)

    subnets = map(object({
      cidr = optional(string, null)
      # The CIDR block of the subnet 
      netmask = optional(number, 0)
    }))

    vpc = object({
      availability_zones = optional(string, 2)
      # The availability zone in which to provision the network, defaults to 2 
      cidr = optional(string, null)
      # The CIDR block of the VPC network if not using IPAM
      enable_private_endpoints = optional(list(string), [])
      # An optional list of private endpoints to associate with the network i.e ["s3", "dynamodb"]
      enable_shared_endpoints = optional(bool, true)
      # Indicates if the network should accept shared endpoints 
      enable_transit_gateway = optional(bool, true)
      # A flag indicating if the network should be associated with the transit gateway 
      enable_transit_gateway_appliance_mode = optional(bool, false)
      # A flag indicating if the transit gateway should be in appliance mode
      enable_default_route_table_association = optional(bool, true)
      # A flag indicating if the default route table should be associated with the network 
      enable_default_route_table_propagation = optional(bool, true)
      # A flag indicating if the default route table should be propagated to the network
      ipam_pool_name = optional(string, null)
      # The name of the IPAM pool to use for the network
      nat_gateway_mode = optional(string, "none")
      # The NAT gateway mode to use for the network, defaults to none 
      netmask = optional(number, 0)
      # The netmask of the VPC network if using IPAM
      transit_gateway_routes = optional(map(string), null)
      # A list of routes to associate with the transit gateway, optional 
    })
  }))
  default = {}

  ## The availability zone must be greater than 0 
  validation {
    condition     = alltrue([for network in var.networks : network.vpc.availability_zones > 0])
    error_message = "The availability zone must be greater than 0"
  }

  ## We must have a private subnet defined in subnets 
  validation {
    condition     = alltrue([for network in var.networks : contains(keys(network.subnets), "private")])
    error_message = "We must have a 'private' subnet defined in subnets"
  }

  ## The private subnet netmask must be between 0 and 32 
  validation {
    condition     = alltrue([for network in var.networks : network.subnets["private"].netmask >= 0 && network.subnets["private"].netmask <= 32])
    error_message = "The private subnet netmask must be between 0 and 32"
  }

  ## The nat mode can only be none, single or all_azs 
  validation {
    condition     = alltrue([for network in var.networks : contains(["none", "single", "all_azs"], network.vpc.nat_gateway_mode)])
    error_message = "The nat mode can only be none, single or all_azs"
  }
}

variable "region" {
  description = "The region we are provisioning the resources for the landing zone"
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "The region must be in the format of a valid AWS region"
  }
}

variable "tags" {
  description = "A collection of tags to apply to resources"
  type        = map(string)

  # must not have a name tag 
  validation {
    condition     = !contains(keys(var.tags), "Name")
    error_message = "The tags must not have a name tag"
  }
}

variable "git_repository" {
  description = "The git repository called this module"
  type        = string
}
