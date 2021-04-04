resource "google_compute_instance" "webserver_vm" {
  name         = var.name
  machine_type = "f1-micro"
  tags         = [var.name]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    subnetwork = var.subnet_name
    access_config {
      // This section is included to give the VM an external ephemeral IP address
    }
  }

  metadata_startup_script = file("/Users/sonjahiltunen/personal/cloud-project/startup.sh")
}
