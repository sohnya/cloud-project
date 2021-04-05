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

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.10.0/24"] 
  target_tags = ["vm-ba"]
}

# VM-BA1 CAN ping VM-BB1 using Firewall rules
resource "google_compute_firewall" "requirement_4_3_1a" {
  name    = "r4-3-1a-ba-can-ping-bb"
  network = var.network

  allow {
    protocol = "icmp"
  }

  source_tags = ["vm-ba"]
  target_tags = ["vm-bb"]
}

# VM-BB1 CAN ping VM-BA1 using Firewall rules
resource "google_compute_firewall" "requirement_4_3_1b" {
  name    = "r4-3-1b-bb-can-ping-ba"
  network = var.network

  allow {
    protocol = "icmp"
  }

  source_tags = ["vm-bb"]
  target_tags = ["vm-ba"]
}

# Internet CANNOT HTTP on port TCP-80 to VM-BB1 Public IP address
resource "google_compute_firewall" "requirement_4_4_2" {
  name    = "r4-4-2-internet-cannot-http-8-bb-public"
  network = var.network

  deny {
    protocol = "tcp"
    ports = [80]
  }

  source_ranges = ["0.0.0.0/0"] # Everyone on the internet
  target_tags = ["vm-bb"]
}

## Internet CAN ping to VM-BB1 Public IP address
resource "google_compute_firewall" "requirement_4_4_3" {
  name    = "r4-4-3-internet-can-ping-bb-public"
  network = var.network

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"] # Everyone on the internet
  target_tags = ["vm-bb"]
}

# Internet CANNOT SSH to VM-BB1 Public IP address
resource "google_compute_firewall" "requirement_4_4_4" {
  name    = "r4-4-4-internet-cannot-ssh-bb-public"
  network = var.network

  deny {
    protocol = "tcp"
    ports = [22]
  }

  source_ranges = ["0.0.0.0/0"] # Everyone on the internet
  target_tags = ["vm-bb"]
}

# VM-BB1 (using Public Internet) CANNOT HTTP on port TCP-80 to VM-AB1 Public IP address
resource "google_compute_firewall" "requirement_4_5_1" {
  name    = "r4-5-1-bb-cannot-http-80-ab-public"
  network = var.network
  direction = "EGRESS"

  deny {
    protocol = "tcp"
    ports = [80]
  }

  target_tags = ["vm-bb"]
  destination_ranges = ["35.231.62.201"]
}

# VM-BB1 (using Public Internet) CAN ping to VM-AB1 Public IP address
resource "google_compute_firewall" "requirement_4_5_2" {
  name    = "r4-5-2-bb-can-ping-ab-public"
  network = var.network
  direction = "EGRESS"

  allow {
    protocol = "icmp"
  }

  target_tags = ["vm-bb"]
  destination_ranges = ["35.231.62.201"]
}

# VM-BB1 (using Public Internet) CAN SSH to VM-AB1 Public IP address
resource "google_compute_firewall" "requirement_4_5_3" {
  name    = "r4-5-3-bb1-can-ssh-ab-public"
  network = var.network
  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports = [22]
  }

  target_tags = ["vm-bb"]
  destination_ranges = ["35.231.62.201"]
}

# VM-BB1 (using Public Internet) CANNOT ping 8.8.8.8 (Google's Public DNS)
resource "google_compute_firewall" "requirement_4_5_4" {
  name    = "r4-5-4-bb-cannot-ping-8-8-8-8"
  network = var.network
  direction = "EGRESS"
  destination_ranges = ["8.8.8.8"]

  deny {
    protocol = "icmp"
  }

  target_tags = ["vm-bb"]
}




























### VM-BA1 CANNOT ping VM-AA1 using Firewall rules
resource "google_network_management_connectivity_test" "r4-1-4" {
  name = "r4-1-4-ba-CANNOT-ping-aa"
  source {
      instance = "projects/principal-truck-309700/zones/us-east1-b/instances/vm-ba"
  }

  destination {
      instance = "projects/org-a-309016/zones/us-east1-b/instances/vm-aa"
  }

  protocol = "ICMP"
}

### VM-BA1 CAN ping VM-BB1 using Firewall rules
resource "google_network_management_connectivity_test" "r4-3-1a" {
  name = "r4-3-1a-ba-can-ping-bb"
  source {
      instance = "projects/principal-truck-309700/zones/us-east1-b/instances/vm-ba"
  }

  destination {
      instance = "projects/principal-truck-309700/zones/us-east1-b/instances/vm-bb"
  }

  protocol = "ICMP"
}

### VM-BB1 CAN ping VM-BA1 using Firewall rules
resource "google_network_management_connectivity_test" "r4-3-1b" {
  name = "r4-3-1b-bb-can-ping-ba"
  source {
      instance = "projects/principal-truck-309700/zones/us-east1-b/instances/vm-bb"
  }

  destination {
      instance = "projects/principal-truck-309700/zones/us-east1-b/instances/vm-ba"
  }

  protocol = "ICMP"
}

### Internet CANNOT HTTP on port TCP-80 to VM-BB1 Public IP address
resource "google_network_management_connectivity_test" "r4-4-2" {
  name = "r4-4-2-internet-cannot-http-80-bb-public"
  source {
      ip_address = "70.83.57.252"
  }

  destination {
      ip_address = "35.231.103.20"
      port = 80
  }

  protocol = "TCP"
}

##	Internet CAN ping VM-BB1 Public IP address
resource "google_network_management_connectivity_test" "r4-4-3" {
  name = "r4-4-3-internet-can-ping-bb-public"
  source {
      ip_address = "70.83.57.252"
  }

  destination {
      ip_address = "35.231.103.20"
  }

  protocol = "ICMP"
}

##	Internet CANNOT SSH VM-BB1 Public IP address
resource "google_network_management_connectivity_test" "r4-4-4" {
  name = "r4-4-4-internet-cannot-ssh-bb-public"
  source {
      ip_address = "70.83.57.252"
  }

  destination {
      ip_address = "35.231.103.20"
      port = 22
  }

  protocol = "TCP"
}


## VM-BB1 (using Public Internet) CANNOT HTTP on port TCP-80 to VM-AB1 Public IP address
resource "google_network_management_connectivity_test" "r4-5-1" {
  name = "r4-5-1-bb-cannot-http-80-ab-public"
  source {
      instance = "projects/principal-truck-309700/zones/us-east1-b/instances/vm-bb"
  }

  destination {
      ip_address = "35.231.62.201"
      port = 80
  }

  protocol = "TCP"
}

## VM-BB1 (using Public Internet) CAN ping to VM-AB1 Public IP address
resource "google_network_management_connectivity_test" "r4-5-2" {
  name = "r4-5-2-bb-can-ping-ab-public"
  source {
      instance = "projects/principal-truck-309700/zones/us-east1-b/instances/vm-bb"
  }

  destination {
      ip_address = "35.231.62.201"
  }

  protocol = "ICMP"
}

## VM-BB1 (using Public Internet) CAN SSH to VM-AB1 Public IP address
resource "google_network_management_connectivity_test" "r4-5-3" {
  name = "r4-5-3-bb-can-ssh-ab-public"
  source {
      instance = "projects/principal-truck-309700/zones/us-east1-b/instances/vm-bb"
  }

  destination {
      ip_address = "35.231.62.201"
      port = 22
  }

  protocol = "TCP"
}

## VM-BB1 (using Public Internet) CANNOT ping 8.8.8.8 (Google's Public DNS)
resource "google_network_management_connectivity_test" "r4-5-4" {
  name = "r4-5-4-bb-cannot-ping-8-8-8-8"
  source {
      instance = "projects/principal-truck-309700/zones/us-east1-b/instances/vm-bb"
  }

  destination {
      ip_address = "8.8.8.8"
  }

  protocol = "ICMP"
}
