provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = file(var.google_credentials_file)
}

resource "google_compute_firewall" "requirement_4_1_3" {
  name    = "requirement-4-1-3"
  network = "vpc-a"

  allow {
    protocol = "icmp"
  }

  source_tags = ["vm-aa"] # Everyone on the internet
  target_tags = ["vm-ba"]
}

resource "google_compute_firewall" "requirement_4_4_1" {
  name    = "requirement-4-4-1"
  network = "vpc-a"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"] # Everyone on the internet
  target_tags = ["vm-ab"]
}
