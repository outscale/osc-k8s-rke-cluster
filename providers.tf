terraform {
  required_providers {
    outscale = {
      source = "outscale/outscale"
    }
    shell = {
      source  = "scottwinkler/shell"
      version = "1.7.10"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
  }
}

provider "outscale" {
  access_key_id = var.access_key_id
  secret_key_id = var.secret_key_id
  region        = var.region
}
