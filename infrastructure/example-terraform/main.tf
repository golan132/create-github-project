terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "change-this-to-your-bucket-name"
    key    = "terraform.tfstate"
    region = "change-this-to-your-region"
  }
}

provider "aws" {
  region = "change-this-to-your-region"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

module "computing" {
  source     = "./modules/module-example"
  region     = local.REGION
  account_id = local.ACCOUNT_ID
  app        = "example-app"
}
