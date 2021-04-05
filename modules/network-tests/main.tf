# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_management_connectivity_test_resource#attributes-reference
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address

resource "google_network_management_connectivity_test" "4-4-1" {
  name = "4-4-1"
  source {
      ip_address = google_compute_address.source-addr.address
      project_id = "principal-truck-309700"
      network = google_compute_network.vpc.id
      network_type = "vpc-b"
  }

  destination {
      project_id = "org-a-309016"
      ip_address = google_compute_address.dest-addr.address
      network = "vpc-a"
  }

  protocol = "TCP"
  port = 22
}

resource "google_compute_address" "vm_ab_public_IP" {
  name         = "vm-ab-public-IP"
  subnetwork   = "network-ab"
  address_type = "INTERNAL"
  address      = "10.0.43.43"
  region       = "us-central1"
}

resource "google_compute_address" "vm_bb_tag" {
  name         = "vm-bb-tag"
  subnetwork   = "network-bb"
  address_type = "INTERNAL"
  address      = "10.0.43.43"
  region       = "us-central1"
}