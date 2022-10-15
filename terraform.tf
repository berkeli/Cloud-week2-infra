provider "aws" {
  region  = "eu-west-2"
  profile = "personal"

  default_tags {
    tags = {
      terraform = "true"
      project   = "cloud-week-2"
    }
  }
}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
