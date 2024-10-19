#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

module "sandbox" {
  source = "../../"

  git_repository = "https://github.com/appvia/terraform-aws-landing-zone-sandbox.git"
  owner          = "Sandbox"
  region         = "eu-west-2"
  tags = {
    "Environment" = "Sandbox"
    "Owner"       = "Solutions"
    "Product"     = "Sandbox"
  }

  rbac = {
    "platform_engineer" = {
      "groups" = ["Cloud Sandboxes"]
    }
    "administrator" = {
      "groups" = ["Cloud Sandboxes"]
    }
  }

  providers = {
    aws.tenant     = aws.sandbox
    aws.identity   = aws.identity
    aws.network    = aws.network
    aws.management = aws.management
  }
}

