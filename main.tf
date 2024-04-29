terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

# Create a VPC
# resource "aws_instance" "instance1" {
#   ami           = "ami-001843b876406202a"
#   instance_type = "t2.micro"
#   tags = {
#     name = "my-demo-instance"
#   }
# }