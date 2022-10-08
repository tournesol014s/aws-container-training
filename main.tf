terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.34.0"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      env = "container-training"
    }
  }
}

data "aws_caller_identity" "self" {}

variable "region" {
  default = "ap-northeast-1"
}
