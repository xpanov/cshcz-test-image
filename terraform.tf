terraform {
  required_version = ">= 0.13"
  backend "s3" {
    endpoint                    = "object-store.cloud.muni.cz"
    bucket                      = "tfstates"
    encrypt                     = true
    use_path_style              = true
    key                         = "main"
    region                      = "brno1"
    skip_credentials_validation = true
    skip_region_validation      = true
    workspace_key_prefix        = "main"
  }
  required_providers {
    crczp = {
      source = "cyberrangecz/crczp"
      version = "0.1.0"
    }
  }
}

variable "KYPO_ENDPOINT" {}
variable "CI_PROJECT_URL" {}
variable "CI_COMMIT_SHORT_SHA" {}

provider "crczp" {
}

module "sandbox" {
  source        = "cyberrangecz/sandbox/crczp"
  project_url   = var.CI_PROJECT_URL
  rev           = var.CI_COMMIT_SHORT_SHA
  version = "0.1.0"
}

output "sandbox_ids" {
  value = module.sandbox.sandbox_ids
}

