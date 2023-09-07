terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}
provider "proxmox" {
  # url is the hostname (FQDN if you have one) for the proxmox host you'd like to connect to to issue the commands. my proxmox host is 'prox-1u'. Add /api2/json at the end for the API
  pm_api_url = var.api_url
  # api token id is in the form of: <username>@pam!<tokenId>
  pm_api_token_id = var.token_id
  # this is the full secret wrapped in quotes. don't worry, I've already deleted this from my proxmox cluster by the time you read this post
  pm_api_token_secret = var.token_secret
  # leave tls_insecure set to true unless you have your proxmox SSL certificate situation fully sorted out (if you do, you will know)
  pm_tls_insecure = true
  pm_log_enable = true
}

resource "proxmox_lxc" "advanced_features" {
  target_node  = "pve"
  hostname     = "Alpine-LXC-Teste"
  ostemplate   = "local:vztmpl/alpine-3.18-default_20230607_amd64.tar.xz"
  password = var.root_password
  unprivileged = false
  cores = var.cores
  memory = var.memory
  vmid = "501"
  pool = var.pool
  #ssh_public_keys = var.ssh_key

  // Terraform will crash without rootfs defined
  rootfs {
    storage = "local-zfs"
    size    = "8G"
  }

features {
   nesting = true
 }

# // NFS share mounted on host
# mountpoint {
#   slot    = "0"
#   storage = "/mnt/host/nfs"
#   mp      = "/mnt/container/nfs"
#   size    = "250G"
# }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
    ip6    = "dhcp"
  }
}