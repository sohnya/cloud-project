module "project-a" {
  source = "./modules/project"
  project_id="org-a-309016"
  project_name="a"
  google_credentials_file = "/Users/sonjahiltunen/Secrets/gcloud/org-a-961b663ea9dd.json"
  region = "us-east1"
  zone = "us-east1-b"
  subnet_a_ip_range = "10.0.10.0/24"
  subnet_b_ip_range = "10.0.20.0/24"
  local_static_ip_address = var.a_static_ip
  remote_static_ip_address = var.b_static_ip
  vpn_destination_range = "10.1.10.0/24"
  vpn_shared_secret = var.vpn_shared_secret
}

module "project-b" {
  source = "./modules/project"
  project_id="principal-truck-309700"
  project_name="b"
  google_credentials_file = "/Users/sonjahiltunen/Secrets/gcloud/org-b-a97c670bcb79.json"
  region = "us-east1"
  zone = "us-east1-b"
  subnet_a_ip_range = "10.1.10.0/24"
  subnet_b_ip_range = "10.1.20.0/24"
  local_static_ip_address = var.b_static_ip
  remote_static_ip_address = var.a_static_ip
  vpn_destination_range = "10.0.10.0/24"
  vpn_shared_secret = var.vpn_shared_secret
}

