terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc01"
    }
  }
}

# provider "proxmox" {
#   pm_api_url          = var.proxmox_server_a.url
#   # pm_api_token_secret = var.proxmox_server_a.token_secret
#   # pm_api_token_id     = var.proxmox_server_a.token_id
#   pm_user             = var.proxmox_server_a.user
#   pm_password         = var.proxmox_server_a.password

#   pm_tls_insecure = true
# }

provider "proxmox" {
    alias = "pmx_a"
  pm_api_url          = var.proxmox_server_a.url
  # pm_api_token_secret = var.proxmox_server_a.token_secret
  # pm_api_token_id     = var.proxmox_server_a.token_id
  pm_user             = var.proxmox_server_a.user
  pm_password         = var.proxmox_server_a.password

  pm_tls_insecure = true
}

provider "proxmox" {
    alias = "pmx_b"
  pm_api_url          = var.proxmox_server_b.url
  # pm_api_token_secret = var.proxmox_server_b.token_secret
  # pm_api_token_id     = var.proxmox_server_b.token_id
  pm_user             = var.proxmox_server_b.user
  pm_password         = var.proxmox_server_b.password

  pm_tls_insecure = true
}