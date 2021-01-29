
terraform {
  required_providers{
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.24.0"
    }
     aws = {
      source = "hashicorp/aws"
      version = "3.24.0"
    }

    local = {
      source = "hashicorp/local"
      version = "2.0.0"
    }
  }
}

provider "local" {
}


provider "hcloud" {
  token = var.token_hc
}


variable "token_hc" { }

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = "eu-central-1"
}

variable "access_key" { }
variable "secret_key" { }




