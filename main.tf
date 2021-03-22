provider "google" {
  project = "org-a-308321"
  region  = "us-east1"
  zone    = "us-east1-b"
}

module "vpc" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 3.0"
  project_id   = "org-a-308321"
  network_name = "vpc-a"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "network-aa",
      subnet_ip             = "10.0.10.0/24",
      subnet_region         = "us-east1",
      subnet_private_access = "true"
    },
    {
      subnet_name           = "network-ab",
      subnet_ip             = "10.0.20.0/24",
      subnet_region         = "us-east1",
      subnet_private_access = "true"
    }
  ]

  firewall_rules = []
  # https://registry.terraform.io/modules/GMafra/firewall-rules/gcp/latest
}

resource "google_compute_instance" "vm-aa1" {
  name         = "vm-aa1"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    subnetwork = "network-aa"
  }
}

resource "google_compute_instance" "vm-ab1" {
  name         = "vm-ab1"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    subnetwork = "network-ab"
    access_config {
      // This section is included to give the VM an external ephemeral IP address
    }
  }
}

# Direction: Ingress
resource "google_compute_firewall" "http" {
  name    = "vpc-a-firewall-http"
  network = "vpc-a"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags   = ["vpc-a-firewall-http"]
  source_ranges = ["0.0.0.0/0"]
}

# VPN Gateway

resource "google_compute_vpn_gateway" "gateway_a" {
  name    = "vpn-1"
  network = "vpc-a"
}

resource "google_compute_address" "vpn_static_ip" {
  name = "vpn-static-ip"
}

# The VPN gateway needs these three forwarding rules. 
# They are created automatically in the UI, but not with the Terraform setup. 
resource "google_compute_forwarding_rule" "fr_esp" {
  name        = "forwarding-rule-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.gateway_a.id
}

resource "google_compute_forwarding_rule" "fr_udp500" {
  name        = "forwarding-rule-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.gateway_a.id
}

resource "google_compute_forwarding_rule" "fr_udp4500" {
  name        = "forwarding-rule-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.gateway_a.id
}

