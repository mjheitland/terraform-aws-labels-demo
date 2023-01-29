terraform {
  required_version = "~> 1.0"
  backend "local" {}
}

provider "aws" {
  default_tags {
    tags = module.labels.tags
  }
}
