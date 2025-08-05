locals {
  servers_a = [
    { name = "kube-ctrl-4", provider = "pmx_a", type = "controller", ip = "192.168.68.47/24" },
    { name = "kube-ctrl-5", provider = "pmx_a", type = "controller", ip = "192.168.68.48/24" },
    # { name = "kube-worker-1", provider = "pmx_a", type = "worker", ip = "192.168.68.43/24" },
    # { name = "kube-worker-2", provider = "pmx_a", type = "worker", ip = "192.168.68.44/24" }
  ]

  servers_b = [
    { name = "kube-ctrl-1", provider = "pmx_b", type = "controller", ip = "192.168.68.40/24" },
    { name = "kube-ctrl-2", provider = "pmx_b", type = "controller", ip = "192.168.68.41/24" },
    { name = "kube-ctrl-3", provider = "pmx_b", type = "controller", ip = "192.168.68.42/24" },
    { name = "kube-worker-1", provider = "pmx_b", type = "worker", ip = "192.168.68.43/24" },
    { name = "kube-worker-2", provider = "pmx_b", type = "worker", ip = "192.168.68.44/24" },
    { name = "kube-worker-3", provider = "pmx_b", type = "worker", ip = "192.168.68.45/24" },
    { name = "kube-worker-4", provider = "pmx_b", type = "worker", ip = "192.168.68.46/24" }
  ]
}

resource "proxmox_lxc" "controller_a" {
  for_each = { for server in local.servers_a : server.name => server }

  provider = proxmox.pmx_a
  target_node = "proxmox-2"
  hostname = each.value.name
  ostemplate = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
  password = "whocares"
  unprivileged = false
  cores = 1
  memory = each.value.type == "controller" ? var.controller_vm_memory : var.worker_vm_memory
  start = true

  pool = "k0s-homelab"

  rootfs {
    storage = "local-lvm"
    size = each.value.type == "controller" ? var.controller_vm_disk_size : var.worker_vm_disk_size
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = each.value.ip
    gw     = var.vm_network.gw
  }

  features {
    nesting = true
    fuse = true
    mount = "nfs;cifs"
  }

  ssh_public_keys = var.ssh_public_key
}

# resource "proxmox_vm_qemu" "controllers_a" {
#   for_each = { for server in local.servers_a : server.name => server }

#   name         = each.key
#   provider     = proxmox.pmx_a
#   target_node  = "proxmox-2"
#   clone        = var.vm_template

#   memory       = var.controller_vm_memory
#   pool         = "k0s-homelab"
#   onboot       = true

#   # Essential cloud-init settings - these were missing!
#   os_type   = "cloud-init"
#   ciuser    = "root"
#   cipassword = var.vm_password  # Fallback password
  
#   # Your existing cloud-init config
#   ipconfig0 = "ip=${each.value.ip},gw=${var.vm_network.gw}"
#   sshkeys   = var.ssh_public_key

#   scsihw      = "virtio-scsi-single"
#   vm_state    = "running"
#   automatic_reboot = true

#   cpu {
#     cores = var.controller_vm_cpu
#   }

#   serial {
#     id = 0
#   }

#   network {
#     id = 0
#     firewall = false
#     model    = "virtio"
#     bridge   = "vmbr0"
#   }
  
#   disks {
#     scsi {
#       scsi0 {
#         # We have to specify the disk from our template, else Terraform will think it's not supposed to be there
#         disk {
#           storage = "local-lvm"
#           # The size of the disk should be at least as big as the disk in the template. If it's smaller, the disk will be recreated
#           size    = "20G" 
#         }
#       }
#     }
#     ide {
#       # Some images require a cloud-init disk on the IDE controller, others on the SCSI or SATA controller
#       ide1 {
#         cloudinit {
#           storage = "local-lvm"
#         }
#       }
#     }
#   }
# }

resource "proxmox_vm_qemu" "controllers_b" {
  for_each = { for server in local.servers_b : server.name => server }

  name         = each.key
  provider     = proxmox.pmx_b
  target_node  = "athena"
  clone        = var.vm_template

  memory       = each.value.type == "controller" ? var.controller_vm_memory : var.worker_vm_memory
  pool         = "k0s-homelab"
  onboot       = true

  # Essential cloud-init settings - these were missing!
  os_type   = "cloud-init"
  ciuser    = "root"
  cipassword = var.vm_password  # Fallback password
  
  # Your existing cloud-init config
  ipconfig0 = "ip=${each.value.ip},gw=${var.vm_network.gw}"
  sshkeys   = var.ssh_public_key

  scsihw      = "virtio-scsi-single"
  vm_state    = "running"
  automatic_reboot = true

  cpu {
    cores = var.controller_vm_cpu
  }

  serial {
    id = 0
  }

  network {
    id = 0
    firewall = false
    model    = "virtio"
    bridge   = "vmbr0"
  }
  
  disks {
    scsi {
      scsi0 {
        # We have to specify the disk from our template, else Terraform will think it's not supposed to be there
        disk {
          storage = "nvme"
          # The size of the disk should be at least as big as the disk in the template. If it's smaller, the disk will be recreated
          size    = each.value.type == "controller" ? var.controller_vm_disk_size : var.worker_vm_disk_size
        }
      }
    }
    ide {
      # Some images require a cloud-init disk on the IDE controller, others on the SCSI or SATA controller
      ide1 {
        cloudinit {
          storage = "nvme"
        }
      }
    }
  }
}

# resource "proxmox_lxc" "controllers_b" {
#   for_each = { for server in local.servers_b : server.name => server }

#   provider =  proxmox.pmx_b
#   hostname         = each.key
#   target_node  =  "athena"
#   ostemplate   = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
#   password     = "whocares"
#   unprivileged = false
#   cores        = each.value.type == "controller" ? var.controller_vm_cpu : var.worker_vm_cpu
#   memory       = each.value.type == "controller" ? var.controller_vm_memory : var.worker_vm_memory
#   start       = true  
#   network {
#     name   = var.vm_network.name
#     bridge = var.vm_network.bridge
#     ip    = each.value.ip
#     gw     = var.vm_network.gw
#   }

#   rootfs {
#     storage = "nvme"
#     size    = each.value.type == "controller" ? var.controller_vm_disk_size : var.worker_vm_disk_size
#   }

#   features {
#     nesting = true
#     keyctl = true
#     fuse = true
#     mount = "nfs;cifs"
#   }

#   ssh_public_keys = var.ssh_public_key
# }
