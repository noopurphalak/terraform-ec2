terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.13.0"
        }
        tls = {
            source = "hashicorp/tls"
            version = "~> 4.0.0"
        }
    }
    backend "remote" {
        organization = "pixeldust-tech"
        workspaces {
            name = "sample-ec2"
        }
    }
}

provider "aws" {
    region = "ap-south-1"
}