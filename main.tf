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

  depends_on = [
    module.vpc
  ]
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

  depends_on = [
    module.vpc
  ]
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

  depends_on = [
    module.vpc
  ]
}

# VPN Gateway

resource "google_compute_vpn_gateway" "gateway_a" {
  name    = "vpn-a"
  network = "vpc-a"
  depends_on = [
    module.vpc
  ]
}

# The VPN gateway needs these three forwarding rules. 
# They are created automatically in the UI, but not with the Terraform setup. 
resource "google_compute_forwarding_rule" "fr_esp" {
  name        = "forwarding-rule-esp"
  ip_protocol = "ESP"
  ip_address  = var.vpn_gateway_a_static_ip
  target      = google_compute_vpn_gateway.gateway_a.id
}

resource "google_compute_forwarding_rule" "fr_udp500" {
  name        = "forwarding-rule-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = var.vpn_gateway_a_static_ip
  target      = google_compute_vpn_gateway.gateway_a.id
}

resource "google_compute_forwarding_rule" "fr_udp4500" {
  name        = "forwarding-rule-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = var.vpn_gateway_a_static_ip
  target      = google_compute_vpn_gateway.gateway_a.id
}

## VPN Tunnel: Uses hard-coded IP from B 
resource "google_compute_vpn_tunnel" "tunnel_a" {
  name               = "tunnel-a"
  peer_ip            = var.vpn_gateway_b_static_ip
  shared_secret      = var.shared_secret
  target_vpn_gateway = google_compute_vpn_gateway.gateway_a.id
  # From https://cloud.google.com/network-connectivity/docs/vpn/how-to/creating-static-vpns
  # When you use the Cloud Console to create a route-based tunnel, 
  # Classic VPN performs the following tasks:
  # Sets the tunnel's local and remote traffic selectors to any IP address (0.0.0.0/0).
  # For each range in Remote network IP ranges, Google Cloud creates a custom static 
  # route whose destination (prefix) is the range's CIDR and whose next hop is the tunnel.
  local_traffic_selector  = ["0.0.0.0/0"]
  remote_traffic_selector = ["0.0.0.0/0"]

  depends_on = [
    google_compute_forwarding_rule.fr_esp,
    google_compute_forwarding_rule.fr_udp500,
    google_compute_forwarding_rule.fr_udp4500,
  ]
}

resource "google_compute_route" "route_a" {
  name                = "route-a"
  network             = "vpc-a"
  dest_range          = "10.1.10.0/24"
  priority            = 1000
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel_a.id
}

