
locals {
  ## The account id of the tenant account 
  account_id = data.aws_caller_identity.current.account_id
  ## The current region for the tenant account
  region = data.aws_region.current.name

  ## The tags used for support related resources
  operation_tags = {
    "Environment" = "Production"
    "GitRepo"     = var.git_repository
    "Owner"       = "Support"
    "Product"     = "LandingZone"
  }

  ## The permitted permission sets that can be assigned to the account, and their corresponding permission set 
  ## in identity center; unless the permissionset is mentioned here, it cannot be assigned to the account 
  sso_permitted_permission_sets = {
    "administrator"     = "Administrator"
    "devops_engineer"   = "DevOpsEngineer"
    "finops_engineer"   = "FinOpsEngineer"
    "network_engineer"  = "NetworkEngineer"
    "network_viewer"    = "NetworkViewer"
    "platform_engineer" = "PlatformEngineer"
    "security_auditor"  = "SecurityAuditor"
  }

  ## Iterate and filter out any unsupported roles 
  rbac = {
    for k, v in var.rbac : k => v if local.sso_permitted_permission_sets[k] != null
  }

  ## Indicates if the nuke module should be enabled 
  nuke_enabled = true
  ## Is the name of the vpc we use to run the caretaker task within 
  nuke_vpc_name = format("nuke-%s", local.region)
  ## This VPC CIDR block is used for the nuke module 
  nuke_network = {
    (local.nuke_vpc_name) : {
      subnets = {
        public = {
          netmask = 28
        }
        private = {
          netmask = 28
        }
      }

      vpc = {
        availability_zones     = 2
        cidr                   = "172.16.0.0/25"
        enable_ipam            = false
        enable_transit_gateway = false
        nat_gateway_mode       = "none"
        tags                   = local.operation_tags
      }
    }
  }

  nuke_tasks = merge({
    "dry-run" = {
      ## The path to the configuration file for the task
      configuration_file = "${path.module}/assets/nuke/config.yml"
      ## A description for the task 
      description = "Runs a dry run to validate what would be deleted"
      ## The log retention in days for the task 
      retention_in_days = 5
      ## The schedule expression for the task - every monday at 09:00
      schedule = "cron(0 9 ? * MON *)"
      ## The IAM permissions to attach to the task role 
      permission_arns = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess"
      ]
    },
    }, var.enable_nuke == false ? {} : {
    "default" = {
      ## The path to the configuration file for the task
      configuration_file = "${path.module}/assets/nuke/config.yml"
      ## A description for the task 
      description = "Runs the actual nuke service, deleting resources"
      ## The log retention in days for the task 
      retention_in_days = 14
      ## The schedule expression for the task, every friday at 10:00
      schedule = "cron(0 10 ? * FRI *)"
      ## The IAM permissions to attach to the task role 
      permission_arns = [
        "arn:aws:iam::aws:policy/AdministratorAccess"
      ]
    }
  })

  ## The networks we should create within the sandbox account 
  networks = merge(var.networks, local.nuke_enabled == true ? local.nuke_network : {})
}
