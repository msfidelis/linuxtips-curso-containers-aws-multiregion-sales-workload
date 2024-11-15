provider "aws" {
  region = var.region_primary
}

provider "aws" {
  alias  = "secondary"
  region = var.region_secondary
}