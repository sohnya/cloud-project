module "project-a" {
  source = "./modules/project"
  project_id="org-a-309016"
  project_name="a"
  google_credentials_file = "/Users/sonjahiltunen/Secrets/gcloud/org-a-961b663ea9dd.json"
  region = var.region
  zone = var.zone
  
  # Network
  subnet_a_ip_range = var.subnet_aa_ip_range
  subnet_b_ip_range = var.subnet_ab_ip_range

  ## VPN
  local_static_ip_address = var.a_static_ip
  remote_static_ip_address = var.b_static_ip
  vpn_destination_range = var.subnet_ba_ip_range
  vpn_shared_secret = var.vpn_shared_secret
}

module "firewall-rules-a" {
  source = "./modules/firewall-rules-a"
  project_id="org-a-309016"
  google_credentials_file = "/Users/sonjahiltunen/Secrets/gcloud/org-a-961b663ea9dd.json"
  region = var.region
  zone = var.zone
  network = "vpc-a"

  subnet_aa_ip_range = var.subnet_aa_ip_range
  subnet_ab_ip_range = var.subnet_ab_ip_range
  subnet_ba_ip_range = var.subnet_ba_ip_range
  subnet_bb_ip_range = var.subnet_bb_ip_range
  vm_ab_ip_address = var.vm_ab_ip_address
  vm_bb_ip_address = var.vm_bb_ip_address
} 

module "project-b" {
  source = "./modules/project"
  project_id="principal-truck-309700"
  project_name="b"
  google_credentials_file = "/Users/sonjahiltunen/Secrets/gcloud/org-b-a97c670bcb79.json"
  region = var.region
  zone = var.zone

  ## Network
  subnet_a_ip_range = var.subnet_ba_ip_range
  subnet_b_ip_range = var.subnet_bb_ip_range

  ## VPN 
  local_static_ip_address = var.b_static_ip
  remote_static_ip_address = var.a_static_ip
  vpn_destination_range = var.subnet_aa_ip_range
  vpn_shared_secret = var.vpn_shared_secret
}

module "firewall-rules-b" {
  source = "./modules/firewall-rules-b"
  project_id="principal-truck-309700"
  google_credentials_file = "/Users/sonjahiltunen/Secrets/gcloud/org-b-a97c670bcb79.json"
  region = var.region
  zone = var.zone
  network = "vpc-b"

  subnet_aa_ip_range = var.subnet_aa_ip_range
  subnet_ab_ip_range = var.subnet_ab_ip_range
  subnet_ba_ip_range = var.subnet_ba_ip_range
  subnet_bb_ip_range = var.subnet_bb_ip_range
  vm_ab_ip_address = var.vm_ab_ip_address
  vm_bb_ip_address = var.vm_bb_ip_address
} 
