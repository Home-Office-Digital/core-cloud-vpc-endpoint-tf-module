terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.29"
    }
  }
  required_version = ">= 1.0"
}
