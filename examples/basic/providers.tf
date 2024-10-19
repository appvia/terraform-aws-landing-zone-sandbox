
provider "aws" {}

provider "aws" {
  alias   = "identity"
  profile = "appvia-io-audit"
}

provider "aws" {
  alias   = "network"
  profile = "appvia-io-network"
}

provider "aws" {
  alias   = "management"
  profile = "appvia-io-master"
}

provider "aws" {
  alias   = "sandbox"
  profile = "appvia-io-sandbox"
}

