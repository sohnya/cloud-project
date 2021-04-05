provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = file(var.google_credentials_file)
}

# VM-AA1 CAN ping VM-BA1 using Firewall rules
resource "google_compute_firewall" "requirement_4_1_3" {
  name    = "r4-1-3-aa-can-ping-ba"
  network = var.network
  direction = "EGRESS"

  allow {
    protocol = "icmp"
  }

  target_tags = ["vm-aa"]
}

# VM-BA1 CANNOT ping VM-AA1 using Firewall rules
resource "google_compute_firewall" "requirement_4_1_4" {
  name    = "r4-1-4-ba-cannot-ping-aa"
  network = var.network

  deny {
    protocol = "icmp"
  }

  source_ranges = [var.subnet_ba_ip_range]
  target_tags = ["vm-aa"]
}

# VM-AA1 CANNOT ping VM-AB1 using Firewall rules
resource "google_compute_firewall" "requirement_4_2_1a" {
  name    = "r4-2-1a-aa-cannot-ping-ab"
  network = var.network

  deny {
    protocol = "icmp"
  }

  source_tags = ["vm-aa"] 
  target_tags = ["vm-ab"]
}

# VM-AB1 CANNOT ping VM-AA1 using Firewall rules
resource "google_compute_firewall" "requirement_4_2_1b" {
  name    = "r4-2-1b-ab-cannot-ping-aa"
  network = var.network

  deny {
    protocol = "icmp"
  }

  source_tags = ["vm-ab"] 
  target_tags = ["vm-aa"]
}

# Internet CAN HTTP on port TCP-80 to VM-AB1 Public IP address
resource "google_compute_firewall" "requirement_4_4_1" {
  name    = "r4-4-1-internet-can-http-80-ab-public"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = [80]
  }

  source_ranges = ["0.0.0.0/0"] # Everyone on the internet
  target_tags = ["vm-ab"]
}

# Internet CAN ping to VM-AB1 Public IP address
resource "google_compute_firewall" "requirement_4_4_3" {
  name    = "r4-4-3-internet-can-ping-ab-public"
  network = var.network

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"] # Everyone on the internet
  target_tags = ["vm-ab"]
}

# Internet CANNOT SSH to VM-AB1 Public IP address
resource "google_compute_firewall" "requirement_4_4_4" {
  name    = "r4-4-4-internet-cannot-ssh-ab-public"
  network = var.network

  deny {  
    protocol = "tcp"
    ports = [22]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["vm-ab"]
}




















## Connectivity tests
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_management_connectivity_test_resource#attributes-reference

# VM-AA1 CAN ping VM-BA1 using Firewall rules
resource "google_network_management_connectivity_test" "r4-1-3" {
  name = "r4-1-3-aa-can-ping-ba"
  source {
      instance = "projects/org-a-309016/zones/us-east1-b/instances/vm-aa"
  }

  destination {
      instance = "projects/principal-truck-309700/zones/us-east1-b/instances/vm-ba"
  }

  protocol = "ICMP"
}

## VM-AA1 CANNOT ping VM-AB1 using Firewall rules
resource "google_network_management_connectivity_test" "r4-2-1a" {
  name = "r4-2-1a-aa-cannot-ping-ab"
  source {
      instance = "projects/org-a-309016/zones/us-east1-b/instances/vm-aa"
  }

  destination {
      instance = "projects/org-a-309016/zones/us-east1-b/instances/vm-ab"
  }

  protocol = "ICMP"
}

## VM-AB1 CANNOT ping VM-AA1 using Firewall rules
resource "google_network_management_connectivity_test" "r4-2-1b" {
  name = "r4-2-1b-ab-cannot-ping-aa"
  source {
      instance = "projects/org-a-309016/zones/us-east1-b/instances/vm-ab"
  }

  destination {
      instance = "projects/org-a-309016/zones/us-east1-b/instances/vm-aa"
  }

  protocol = "ICMP"
}

## Internet CAN HTTP on port TCP-80 to VM-AB1 Public IP address
resource "google_network_management_connectivity_test" "r4-4-1" {
  name = "r4-4-1-internet-can-http-80-ab-public"
  source {
      ip_address = "70.83.57.252"
  }

  destination {
      ip_address = "35.231.62.201"
      port = 80
  }

  protocol = "TCP"
}

##	Internet CAN ping to VM-AB1 Public IP address
resource "google_network_management_connectivity_test" "r4-4-3" {
  name = "r4-4-3-internet-can-ping-ab-public"
  source {
      ip_address = "70.83.57.252"
  }

  destination {
      ip_address = "35.231.62.201"
  }

  protocol = "ICMP"
}

##	Internet CANNOT SSH to VM-AB1 Public IP address
resource "google_network_management_connectivity_test" "r4-4-4" {
  name = "r4-4-4-internet-cannot-ssh-ab-public"
  source {
      ip_address = "70.83.57.252"
  }

  destination {
      ip_address = "35.231.62.201"
      port = 22
  }

  protocol = "TCP"
}

