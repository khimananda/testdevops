provider "aws" {
  region  = "us-east-1"
  version = "~> 3.20"
}

terraform {
  required_version = ">= 0.13"
}
