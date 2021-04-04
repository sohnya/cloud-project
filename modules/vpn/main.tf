# VPN Gateway
resource "google_compute_vpn_gateway" "gateway" {
  name    = "vpn-${var.project_name}"
  network = "vpc-${var.project_name}"
}

# The VPN gateway needs these three forwarding rules. 
# They are created automatically in the UI, but not with the Terraform setup. 
resource "google_compute_forwarding_rule" "fr_esp" {
  name        = "forwarding-rule-esp"
  ip_protocol = "ESP"
  ip_address  = var.local_static_ip_address
  target      = google_compute_vpn_gateway.gateway.id
}

resource "google_compute_forwarding_rule" "fr_udp500" {
  name        = "forwarding-rule-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = var.local_static_ip_address
  target      = google_compute_vpn_gateway.gateway.id
}

resource "google_compute_forwarding_rule" "fr_udp4500" {
  name        = "forwarding-rule-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = var.local_static_ip_address
  target      = google_compute_vpn_gateway.gateway.id
}

## VPN Tunnel: Uses hard-coded IP from B 
resource "google_compute_vpn_tunnel" "tunnel" {
  name               = "tunnel-${var.project_name}"
  peer_ip            = var.remote_static_ip_address
  shared_secret      = var.vpn_shared_secret
  target_vpn_gateway = google_compute_vpn_gateway.gateway.id

  local_traffic_selector  = ["0.0.0.0/0"]
  remote_traffic_selector = ["0.0.0.0/0"]

  depends_on = [
    google_compute_forwarding_rule.fr_esp,
    google_compute_forwarding_rule.fr_udp500,
    google_compute_forwarding_rule.fr_udp4500,
  ]
}

resource "google_compute_route" "route_a" {
  name                = "route-${var.project_name}"
  network             = "vpc-${var.project_name}"
  dest_range          = var.vpn_destination_range
  priority            = 1000
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel.id
}