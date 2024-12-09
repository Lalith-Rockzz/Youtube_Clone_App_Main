terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"                       # Specifies AWS as the cloud provider.
      version = "~> 5.0"                              # Restricts to compatible AWS provider versions (major version 5).
    }
  }
}

provider "aws" {
  region = "ap-south-1"                               # AWS region for resource provisioning; change as needed.
}
