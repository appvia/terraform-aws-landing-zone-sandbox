
locals {
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
}
