
## Introduction

This is a fun project

https://cloud.google.com/community/tutorials/managing-gcp-projects-with-terraform

The full project description can be found [here](project-overview.pdf)

**Table of contents**
- [Terraform](###Terraform)
- [Networks and VMs](###Networks-and-VMs)

---
## Terraform

One way of setting up Google Cloud infrastructure is using [Terraform google-modules](https://registry.terraform.io/namespaces/terraform-google-modules). A Google Virtual Private Network (VPC), Subnets within the VPC, etc. 

- Note: I am a first time user
- First did everything manually, then switched to terraform 
- This readme will contain selected portions of the configuration code 

### Advantages
- Easy to tear down
- Less error prone and boring

### Challenges encountered
- How to do Terraform for multiple projects in Google Cloud. 
- Tearing down all modules failed - needed to add "depends_on"
- Using variables instead of hard coding a and b everywhere :) 
- Adding Google Cloud credentials in main.tf
    - "A GCP service account key: Terraform will access your GCP account by using a service account key. Create one now in the console. When creating the key, use the following settings... [see more here](https://learn.hashicorp.com/tutorials/terraform/google-cloud-platform-build?in=terraform/gcp-get-started)

### Terraform references
- https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started
- https://learn.hashicorp.com/tutorials/terraform/google-cloud-platform-build?in=terraform/gcp-get-started
- See an [example module](https://registry.terraform.io/modules/terraform-google-modules/network/google/latest). 

---
## IAM

TODO: 
- If I run `terraform apply` with limited permissions, will it update what I have access to (or completely fail)? Do I need to divide the `main.tf` file into several files? 
- Describe your role assignments and the expected results in your Lab documents for each account. 

We want to [use IAM securely](https://cloud.google.com/iam/docs/using-iam-securely). In our organization, we have [separate network and security teams](https://cloud.google.com/iam/docs/job-functions/networking#separate_network_security_teams). 


Using [predefined roles](https://cloud.google.com/iam/docs/understanding-roles#predefined_roles). 

Can also be setup in Terraform but was done manually. 

**Roles**

* Project Owner `roles/owner` project.owner@sonjahiltunen.com
    - All editor permissions
    
    and permissions to:
    - Manage roles and permissions for a project and all resources within the project.
    - Set up billing for a project.
* Compute Admin `roles/compute.admin` compute.admin@sonjahiltunen.com
    - Full control of all Compute Engine resources.
* Security Admin `roles/iam.securityAdmin` security.admin@sonjahiltunen.com
    - Security admin role, with permissions to get and set any IAM policy.
* Network Management Admin `roles/networkmanagement.admin` network.admin@sonjahiltunen.com
    - Full access to Network Management resources.

---
## Networks and VMs

The ask was to create two projects in Google Cloud and set up networking for those two projects. 

### Network setup
Figure 1 outlines the required architecture for this lab project.

![Alt text](images/architecture.png?raw=true "Title")
_Figure 1: Networks_

The VPC and its subnets are created using a Terraform [module](https://www.terraform.io/docs/language/modules/index.html). 
```
module "vpc" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 3.0"
  project_id   = "org-a-309016"
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
}
```

### VM setup

Resource in Terraform
``` 
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
```
To add an external IP, the network interface also contains an empty `access_config`. 
```
  network_interface {
    subnetwork = "network-ab"
    access_config {
      // Gives the VM an external ephemeral IP address
    }
  }
```

---
## VPN gateway

- TODO: What is a forwarding rule in a VPN?
- TODO: What is the difference between static routing and policy based routing? 

Classic VPN. The service in Google is called 

The VPN was set up using the modules [compute_vpn_gateway](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_vpn_gateway)

```
resource "google_compute_vpn_gateway" "gateway_a" {
  name    = "vpn-a"
  network = "vpc-a"
  depends_on = [
    module.vpc
  ]
}
```
The Google Cloud UI automatically creates the necessary forwarding rules when we select a classic VPN. This is not the case for the Terraform configuration - the forwarding rules have to be explicitly created as follows: 
```
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
``` 

### VPN Tunnel
The Terraform module does not contain an explicit choice of routing configuration. As described [here](https://cloud.google.com/network-connectivity/docs/vpn/how-to/creating-static-vpns): "When you use the Cloud Console to create a route-based tunnel, Classic VPN [...]:
  - Sets the tunnel's local and remote traffic selectors to any IP address (0.0.0.0/0).
  - For each range in Remote network IP ranges, ccreates a custom static route whose destination (prefix) is the range's CIDR and whose next hop is the tunnel."

The [compute_vpn_tunnel](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_vpn_tunnel) was therefore set up as follows:
```
resource "google_compute_vpn_tunnel" "tunnel_a" {
  name               = "tunnel-a"
  peer_ip            = var.vpn_gateway_b_static_ip
  shared_secret      = var.shared_secret
  target_vpn_gateway = google_compute_vpn_gateway.gateway_a.id

  local_traffic_selector  = ["0.0.0.0/0"]
  remote_traffic_selector = ["0.0.0.0/0"]

  depends_on = [
    google_compute_forwarding_rule.fr_esp,
    google_compute_forwarding_rule.fr_udp500,
    google_compute_forwarding_rule.fr_udp4500,
  ]
}
```
and the static route added as
```
resource "google_compute_route" "route_a" {
  name                = "route-a"
  network             = "vpc-a"
  dest_range          = "10.1.10.0/24"
  priority            = 1000
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel_a.id
}
```

---
## Firewall rules
**Requirement 4.1 - VVM-AA1 & VM-BA11**
- Only use Private IP (Not directly accessible from Internet)
- Communicate together using Router with static routes & VPN Gateway to encrypt communication
- VM-AA1 CAN ping VM-BA1 using Firewall rules
- VM-BA1 CANNOT ping VM-AA1 using Firewall rules

**Requirement 4.2 - VM-AA1 & VM-AB11**
- CANNOT ping in both direction using Firewall rules

**Requirement 4.3 - VM-BA1 & VM-BB1-2**
CAN ping in both direction using Firewall rules

**Requirement 4.4 - Everyone on the Internet**
- CAN HTTP on port TCP-80 to VM-AB1 Public IP address
- CANNOT HTTP on port TCP-80 to VM-BB1 Public IP address
- CAN ping to VM-AB1 & VM-BB1 Public IP address
- CANNOT SSH to VM-AB1 & VM-BB1 Public IP address

**Requirement 4.5 - VM-BB1 (using Public Internet)**
- CANNOT HTTP on port TCP-80 to VM-AB1 Public IP address
- CAN ping to VM-AB1 Public IP address
- CAN SSH to VM-AB1 Public IP address
- CANNOT ping 8.8.8.8 (Google's Public DNS)


TODO
- How is priority used in Firewall rules? 


| Default (left-aligned)        | Centered           | Right-aligned  |
| ------------- |:-------------:| -----:|
| 1      | right-aligned | $1600 |
| 2      | centered      |   $12 |
| 3 | are neat      |    $1 |
_Table 1: Firewall rules_

### Firewall rule configuration
Firewall rules were set up using the terraform module [firewall-rule](https://registry.terraform.io/modules/terraform-google-modules/network/google/latest/submodules/firewall-rules). 

---
## Additional reading
- https://cloud.google.com/vpc/docs/using-firewalls
- https://cloud.google.com/network-connectivity/docs/vpn/how-to/creating-static-vpns
- https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance