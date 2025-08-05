variable "proxmox_server_a" {
    type = object({
      url = string
    #   token_id = string
    #   token_secret = string
      user = string
      password = string
    })
}

variable "proxmox_server_b" {
    type = object({
      url = string
    #   token_id = string
    #   token_secret = string
      user = string
      password = string
    })
}

variable "vm_template" {
    type = string
}

variable "worker_vm_cpu" {
    type = number
    default = 2
}

variable "controller_vm_cpu" {
    type = number
    default = 2
}

variable "worker_vm_memory" {
    type = number
    default = 4096
}

variable "controller_vm_memory" {
    type = number
    default = 4096
}

variable "controller_vm_disk_size" {
    type = string
    default = "32G"
}

variable "worker_vm_disk_size" {
    type = string
    default = "32G"
}

variable "vm_password" {
    type = string
}

variable "ssh_public_key" {
    type = string
    description = "SSH public key to be added to all VMs"
}

variable "vm_network" {
    type = object({
        name   = string
      bridge = string
      gw     = string
    })
}