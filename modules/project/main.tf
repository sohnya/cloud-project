provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = file(var.google_credentials_file)
}


### Handled by network admins
module "vpc" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 3.0"
  project_id   = var.project_id
  network_name = "vpc-${var.project_name}"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "network-${var.project_name}a",
      subnet_ip             = var.subnet_a_ip_range,
      subnet_region         = "us-east1",
      subnet_private_access = "true"
    },
    {
      subnet_name           = "network-${var.project_name}b",
      subnet_ip             = var.subnet_b_ip_range,
      subnet_region         = "us-east1",
      subnet_private_access = "true"
    }
  ]

  firewall_rules = []
  # https://registry.terraform.io/modules/GMafra/firewall-rules/gcp/latest
}

module "vm" {
  source      = "../vm"
  name        = "vm-${var.project_name}a"
  subnet_name = "network-${var.project_name}a"
  depends_on  = [module.vpc]
}

module "webserver_vm" {
  source      = "../webserver_vm"
  name        = "vm-${var.project_name}b"
  subnet_name = "network-${var.project_name}b"
  depends_on  = [module.vpc]
}

module "vpn" {
  source = "../vpn"
  project_name = var.project_name
  local_static_ip_address = var.local_static_ip_address
  remote_static_ip_address = var.remote_static_ip_address
  vpn_shared_secret = var.vpn_shared_secret
  vpn_destination_range = var.vpn_destination_range
  depends_on = [module.vm]
}

