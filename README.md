This project is found on [github.com/sohnya/cloud-project](github.com/sohnya/cloud-project).

## Introduction

TODO: HELLO

Figure 1 outlines the required architecture for this lab project. The full project description can be found [here](project-overview.pdf)

![Alt text](images/architecture.png?raw=true "Networks")
_Figure 1: Networks_

---
## Google Cloud and Terraform
To begin with, I set up all infrastructure manually using the google cloud console. After setting up project A, its VPN tunnel and an example firewall rule, I realized that 
- Project B was almost exactly the same, with minor different
- Firewall rules were error prone to set up, and fiddly to change in the UI. 
This is why I decided to combine this project with another tool that I was interested in learning - Terraform. 

The advantages of setting up the infrastructure with Terraform 
- All configuration is in one place (easy to find especially for beginner)
- Mistakes are easy to find and fix
- Repetitive tasks become less error prone and boring

### Project structure
The desided project configuration had (almost) the same configuration for both sides, which is why a module `project` was created. The `project` module itself contains custom Terraform modules specific to our use case - `vm`, `webserver-vm` and `vpn`. In order to clean up the `main.tf` file, I also chose to move the firewall rules to their own modules. Since they were different between A and B, they were implemented with `firewall-rules-a` and `firewall-rules-b`. These two modules contained the firewall rules and their corresponding network connectivity tests. 

The `main.tf` file looks like follows:
```
module "project-a" {
  source = "./modules/project"
  project_id="org-a-309016"
  project_name="a"
  google_credentials_file = "/Users/sonjahiltunen/Secrets/gcloud/org-a-961b663ea9dd.json"
  region = "us-east1"
  zone = "us-east1-b"
  
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
```


- How to do Terraform for multiple projects in Google Cloud. 
- Tearing down all modules failed - needed to add "depends_on"
- Using variables instead of hard coding a and b everywhere :) 
- Adding Google Cloud credentials in main.tf
    - "A GCP service account key: Terraform will access your GCP account by using a service account key. Create one now in the console. When creating the key, use the following settings... [see more here](https://learn.hashicorp.com/tutorials/terraform/google-cloud-platform-build?in=terraform/gcp-get-started)

### Terraform references
- https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started
- https://learn.hashicorp.com/tutorials/terraform/google-cloud-platform-build?in=terraform/gcp-get-started
- See an [example module](https://registry.terraform.io/modules/terraform-google-modules/network/google/latest). 


### What do I want to do 
- Run root module 

---

## Projects
**Requirement 1.1**: The first lab requirement was to create two projects to represent sides A and B of the architecture diagram. The two projects were created in the Google Cloud UI. 

![Projects](images/1.1-projects.png?raw=true "Projects")

_Figure: Two projects in my organization_

## IAM
In order to add users, I created an organization related to the sonjahiltunen.com domain, and added four new users 
- project.owner@sonjahiltunen.com
- compute.admin@sonjahiltunen.com
- security.admin@sonjahiltunen.com
- network.admin@sonjahiltunen.com

The users were then added to the projects and given roles according to what they should be able to do with the resources in the projects. These are the roles, users and required permissions (taken from role definitions in [predefined roles](https://cloud.google.com/iam/docs/understanding-roles#predefined_roles)):
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

The main account (sonja@sonjahiltunen.com) is kept intact (with maximum permissions), as per the lab requirements. 

**Requirement 1.2**
- The four required roles can be seen in the screenshot below. 
![IAM](images/1-2-iam.png?raw=true "IAM")


**Notes**
- There is also a service account for Terraform. This was added in the [API credentials section](https://console.cloud.google.com/apis/credentials) in the cloud console (following the guidelines [here](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started)). 
- If I had more time, I would have looked into reducing the permissions so that they are specific to our use case. The required roles were very wide and do not follow the least priviledge principle. We want to [use IAM securely](https://cloud.google.com/iam/docs/using-iam-securely). 
- I ran `terraform apply` as an owner. The Terraform project structure could have been optimized so that different teams (with different roles / permissions) can easily use Terraform separate. This is for an advanced use case with Terraform that I will save for later. 
---
## Networks and VMs

### Network setup
The VPC and its subnets were created using the Terraform module [vpc](https://registry.terraform.io/modules/terraform-google-modules/network/google/latest/submodules/vpc). The configuration is as follows: 
```
module "vpc" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 3.0"
  project_id   = var.project_id
  network_name = "vpc-${var.project_name}"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "network-${var.project_name}a",
      subnet_ip             = var.subnet_a_ip_range,
      subnet_region         = "us-east1",
      subnet_private_access = "true"
    },
    {
      subnet_name           = "network-${var.project_name}b",
      subnet_ip             = var.subnet_b_ip_range,
      subnet_region         = "us-east1",
      subnet_private_access = "true"
    }
  ]

  firewall_rules = []
  # https://registry.terraform.io/modules/GMafra/firewall-rules/gcp/latest
}
```
and 

### VM setup
The VMs that didn't need external IPs were created using a module: `vm`, configured as follows:  
``` 
resource "google_compute_instance" "vm" {
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
  }
}
```
For the webserver, I created a module `webserver_vm`. It is similar to a VM, but the network interface contains an empty `access_config`, which produces an ephemeral external IP for that VM. 
```
  network_interface {
    subnetwork = "network-ab"
    access_config {
      // Gives the VM an external ephemeral IP address
    }
  }
```
It also contains a reference to the webserver startup script - 
`metadata_startup_script = file("./modules/webserver_vm/startup.sh")`.

**Requirement 3.1 - Create 4 networks**
![Networks A](images/3-1-networks-a.png?raw=true "Networks A")
![Networks B](images/3-1-networks-b.png?raw=true "Networks B")

---
## VPN

**Requirement 4.1 - VVM-AA1 & VM-BA1**
- Only use Private IP (Not directly accessible from Internet)
- Communicate together using a router with static routes & VPN Gateway to encrypt communication

**Open questions**
- What is a forwarding rule in a VPN?
- What is the difference between static routing and policy based routing? 

Classic VPN. The service in Google is called 

### VPN Gateway

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
![VPN-A](images/vpn-a.png?raw=true)
_VPN tunnel in project A_

![VPN-A](images/vpn-b.png?raw=true)
_VPN tunnel in project B_

---
## Firewall rules
The firewall rules were implemented in Terraform using the resource [compute_firewall](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall). Since the results are so many, I will not include the configuration for all of them in Terraform. Example configuration: 
```
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
```

The rules were configured as follows (in projects A and B):

![Firewall rules A](images/firewall-rules-a.png?raw=true "Firewall rules A")
_Figure: Firewall rules in org-a_

![Firewall rules B](images/firewall-rules-b.png?raw=true "Firewall rules B")
_Figure: Firewall rules in org-b_


To test the the configuration works as expected, I used the [network_management_connectivity_test](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_management_connectivity_test_resource) module in Terraform. Below are screenshots of the connectivity test results. 

![Connectivity tests A](images/connectivity-a.png?raw=true "Connectivity tests A")
_Figure: Connectivity tests in org-a_

![Connectivity tests B](images/connectivity-b.png?raw=true "Connectivity tests B")
_Figure: Connectivity tests in org-b_


## Web Server
In order to further test the firewall rules 4.4 and 4.5, I set up a dummy web server. To start a webserver at the startup of `vm-ab1` and `vm-bb1`, the project contains `startups.sh` with the following content: 
```
apt update
apt install -y apache2
cat <<EOF > /var/www/html/index.html
<html>
  ... 
</html>
EOF
```
To add a startup script to the VMs, we add the argument `metadata_startup_script` in our Terraform configuration.
```
resource "google_compute_instance" "vm-ab1" {
  ...

  metadata_startup_script = file("startup.sh")

  ... 
}  
```
![Webserver](images/webserver-ab.png?raw=true "Webserver") ![Webserver](images/webserver-bb.png?raw=true "Webserver")

_Web server AB: Open to the internet_ / _Web server BB: Blocked with firewall rule_



---
## Additional reading
- https://cloud.google.com/vpc/docs/using-firewalls
- https://cloud.google.com/network-connectivity/docs/vpn/how-to/creating-static-vpns
- https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance

# Part II : List of requirements




