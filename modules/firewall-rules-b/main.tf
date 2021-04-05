provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = file(var.google_credentials_file)
}

resource "google_compute_firewall" "requirement_4_1_3" {
  name    = "requirement-4-1-3"
  network = var.network

  allow {
    protocol = "icmp"
  }

  source_tags = ["vm-aa"] 
  target_tags = ["vm-ba"]
}

resource "google_compute_firewall" "requirement_4_3_1a-1" {
  name    = "requirement-4-3-1a-1"
  network = var.network

  allow {
    protocol = "icmp"
  }

  source_tags = ["vm-ba"]
  target_tags = ["vm-bb"]
}

resource "google_compute_firewall" "requirement_4_3_1a-2" {
  name    = "requirement-4-3-1a-2"
  network = var.network
  direction = "EGRESS"

  allow {
    protocol = "icmp"
  }

  target_tags = ["vm-bb"]
}

resource "google_compute_firewall" "requirement_4_3_1b-1" {
  name    = "requirement-4-3-1b-1"
  network = var.network

  allow {
    protocol = "icmp"
  }

  source_tags = ["vm-bb"] 
  target_tags = ["vm-ba"]
}

resource "google_compute_firewall" "requirement_4_3_1b-2" {
  name    = "requirement-4-3-1b-2"
  network = var.network
  direction = "EGRESS"

  allow {
    protocol = "icmp"
  }

  target_tags = ["vm-ba"]
}

resource "google_compute_firewall" "requirement_4_4_2" {
  name    = "requirement-4-4-2"
  network = var.network

  deny {
    protocol = "tcp"
    ports = [80]
  }

  source_ranges = ["0.0.0.0/0"] # Everyone on the internet
  target_tags = ["vm-bb"]
}

resource "google_compute_firewall" "requirement_4_4_3" {
  name    = "requirement-4-4-3"
  network = var.network

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"] # Everyone on the internet
  target_tags = ["vm-ab"]
}

resource "google_compute_firewall" "requirement_4_4_4" {
  name    = "requirement-4-5-1"
  network = var.network

  deny {
    protocol = "tcp"
    ports = [22]
  }

  source_ranges = ["0.0.0.0/0"] # Everyone on the internet
  target_tags = ["vm-bb"]
}

resource "google_compute_firewall" "requirement_4_5_2" {
  name    = "requirement-4-5-2"
  network = var.network
  direction = "EGRESS"

  allow {
    protocol = "icmp"
  }

  target_tags = ["vm-bb"]
}

resource "google_compute_firewall" "requirement_4_5_3" {
  name    = "requirement-4-5-3"
  network = var.network
  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports = [22]
  }

  target_tags = ["vm-bb"]
}

resource "google_compute_firewall" "requirement_4_5_4" {
  name    = "requirement-4-5-4"
  network = var.network
  direction = "EGRESS"

  allow {
    protocol = "icmp"
  }

  target_tags = ["vm-bb"]
  # how to filter it to be a specific IP only
}
