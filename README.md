![Github Actions](../../actions/workflows/terraform.yml/badge.svg)

# Terraform Sandbox Landing Zones

## Description

The purpose of this module to be provision a sandbox environment for developers to experiment with AWS resources. The module provisions a VPC, subnets, security groups, and other resources to allow developers to experiment with AWS resources in a safe and secure manner. We also provision a nuke service to automatically clean up resources from the accounts.

The intention of the module is to provisioned once per account, per region.

## Usage

You can find an example of how to use this module below

```hcl

provider "aws" {
  alias  = "test_sandbox"a
  region = var.region

  assume_role_with_web_identity {
    role_arn                = "arn:aws:iam::${var.aws_accounts["ho-sandbox"]}:role/${local.managed_role_name}"
    session_name            = var.provider_session_name
    web_identity_token_file = var.provider_web_identity_token_file
  }
}

module "test_sandbox" {
  source = "github.com/appvia/terraform-aws-landing-zone-sandbox?ref=main"

  environment = "Sandbox"
  owner       = "Solutions"
  product     = "Sandbox"
  region      = var.region
  tags        = var.tags

  anomaly_detection = {
    enable_default_monitors = true
  }

  providers = {
    aws.tenant     = aws.test_sandbox
    aws.identity   = aws.identity
    aws.network    = aws.network
    aws.management = aws.management
  }
}
```

## Update Documentation

The `terraform-docs` utility is used to generate this README. Follow the below steps to update:

1. Make changes to the `.terraform-docs.yml` file
2. Fetch the `terraform-docs` binary (https://terraform-docs.io/user-guide/installation/)
3. Run `terraform-docs markdown table --output-file ${PWD}/README.md --output-mode inject .`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.tenant"></a> [aws.tenant](#provider\_aws.tenant) | >= 5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_landing_zone"></a> [landing\_zone](#module\_landing\_zone) | github.com/appvia/terraform-aws-landing-zones | main |
| <a name="module_nuke_service"></a> [nuke\_service](#module\_nuke\_service) | github.com/appvia/terraform-aws-nuke | main |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_git_repository"></a> [git\_repository](#input\_git\_repository) | The git repository called this module | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | The owner of the product, and injected into all resource tags | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region we are provisioning the resources for the landing zone | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A collection of tags to apply to resources | `map(string)` | n/a | yes |
| <a name="input_cost_center"></a> [cost\_center](#input\_cost\_center) | The cost center of the product, and injected into all resource tags | `string` | `null` | no |
| <a name="input_dns"></a> [dns](#input\_dns) | A collection of DNS zones to provision and associate with networks | <pre>map(object({<br/>    comment = optional(string, "Managed by zone created by terraform")<br/>    # A comment associated with the DNS zone <br/>    network = string<br/>    # A list of network names to associate with the DNS zone <br/>    private = optional(bool, true)<br/>    # A flag indicating if the DNS zone is private or public<br/>  }))</pre> | `{}` | no |
| <a name="input_enable_nuke"></a> [enable\_nuke](#input\_enable\_nuke) | Indicates we should enable the automatic cleanup so resources | `bool` | `true` | no |
| <a name="input_networks"></a> [networks](#input\_networks) | A collection of networks to provision within the designated region | <pre>map(object({<br/>    firewall = optional(object({<br/>      capacity = number<br/>      # The capacity of the firewall rule group <br/>      rules_source = string<br/>      # The content of the suracata rules<br/>      ip_sets = map(list(string))<br/>      # A map of IP sets to apply to the firewall rule ie. WEBSERVERS = ["100.0.0.0/16"]<br/>      port_sets = map(list(number))<br/>      # A map of port sets to apply to the firewall rule ie. WEBSERVERS = [80, 443] <br/>      domains_whitelist = list(string)<br/>    }), null)<br/><br/>    subnets = map(object({<br/>      cidr = optional(string, null)<br/>      # The CIDR block of the subnet <br/>      netmask = optional(number, 0)<br/>    }))<br/><br/>    vpc = object({<br/>      availability_zones = optional(string, 2)<br/>      # The availability zone in which to provision the network, defaults to 2 <br/>      cidr = optional(string, null)<br/>      # The CIDR block of the VPC network if not using IPAM<br/>      enable_private_endpoints = optional(list(string), [])<br/>      # An optional list of private endpoints to associate with the network i.e ["s3", "dynamodb"]<br/>      enable_shared_endpoints = optional(bool, true)<br/>      # Indicates if the network should accept shared endpoints <br/>      enable_transit_gateway = optional(bool, true)<br/>      # A flag indicating if the network should be associated with the transit gateway <br/>      enable_transit_gateway_appliance_mode = optional(bool, false)<br/>      # A flag indicating if the transit gateway should be in appliance mode<br/>      enable_default_route_table_association = optional(bool, true)<br/>      # A flag indicating if the default route table should be associated with the network <br/>      enable_default_route_table_propagation = optional(bool, true)<br/>      # A flag indicating if the default route table should be propagated to the network<br/>      ipam_pool_name = optional(string, null)<br/>      # The name of the IPAM pool to use for the network<br/>      nat_gateway_mode = optional(string, "none")<br/>      # The NAT gateway mode to use for the network, defaults to none <br/>      netmask = optional(number, 0)<br/>      # The netmask of the VPC network if using IPAM<br/>      transit_gateway_routes = optional(map(string), null)<br/>      # A list of routes to associate with the transit gateway, optional <br/>    })<br/>  }))</pre> | `{}` | no |
| <a name="input_notifications"></a> [notifications](#input\_notifications) | A collection of notifications to send to users | <pre>object({<br/>    email = optional(object({<br/>      addresses = list(string)<br/>      # A list of email addresses to send notifications to <br/>      }), {<br/>      addresses = []<br/>    })<br/>    slack = optional(object({<br/>      webhook_url = string<br/>      # The slack webhook_url to send notifications to <br/>      }), {<br/>      webhook_url = ""<br/>    })<br/>  })</pre> | <pre>{<br/>  "email": {<br/>    "addresses": []<br/>  },<br/>  "slack": {<br/>    "webhook_url": ""<br/>  }<br/>}</pre> | no |
| <a name="input_rbac"></a> [rbac](#input\_rbac) | Provides the ability to associate one of more groups with a sso role in the account | <pre>map(object({<br/>    users = optional(list(string), [])<br/>    # A list of users to associate with the developer role<br/>    groups = optional(list(string), [])<br/>    # A list of groups to associate with the developer role <br/>  }))</pre> | `{}` | no |
| <a name="input_service_control_policies"></a> [service\_control\_policies](#input\_service\_control\_policies) | Provides the ability to associate one of more service control policies with an account | <pre>map(object({<br/>    name = string<br/>    # The policy name to associate with the account <br/>    policy = string<br/>    # The policy document to associate with the account <br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | The account id where the pipeline is running |
| <a name="output_networks"></a> [networks](#output\_networks) | A map of the network name to network details |
| <a name="output_private_hosted_zones_by_id"></a> [private\_hosted\_zones\_by\_id](#output\_private\_hosted\_zones\_by\_id) | A map of the hosted zone name to id |
| <a name="output_vpc_ids"></a> [vpc\_ids](#output\_vpc\_ids) | A map of the network name to vpc id |
<!-- END_TF_DOCS -->
