
## Introduction

This is a fun project

**Table of contents**
- [Terraform](###Terraform)
- [Networks and VMs](###Networks-and-VMs)


---
## IAM

TODO: Describe your role assignments and the expected results in your Lab documents for each account

Role covered in Lab
- Project Owner
- Compute Admin
- Security Admin
- Network Management Admin

Can also be setup in Terraform but was done manually. 

---
## Terraform

Another way of setting up gCloud infrastructure is using [Terraform google-modules](https://registry.terraform.io/namespaces/terraform-google-modules). A Google Virtual Private Network (VPC), Subnets within the VPC, etc. 

- Note: I am a first time user
- First did everything manually, then switched to terraform 
- This readme will contain selected portions of the configuration code 

### Advantages
- Easy to tear down
- Less error prone and boring

### Challenges encountered
- How to use the same tf file for multiple projects
- Tear down all modules - needed to add "depends_on"
- Using variables instead of hard coding a and b everywhere :) 

### Using Terraform with my account 

- https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started

See example for [main.tf](https://registry.terraform.io/modules/terraform-google-modules/network/google/latest). 

---
## Networks and VMs

The ask was to create two projects in Google Cloud and set up networking for those two projects. 

### Network setup

```
```
_Figure 1: Networks_

Using a Terraform module

### VM setup

Resource in Terraform

---
## VPN gateway

- TODO: What is a forwarding rule in a VPN?
- TODO: What is the difference between static routing and policy based routing? 

Classic VPN. The service in Google is called 

The VPN was set up using the modules [compute_vpn_gateway](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_vpn_gateway) and [compute_vpn_tunnel](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_vpn_tunnel).

### Challenges encountered
- The terraform module does not contain choice of routing configuration. Need to resort to documentation to understand that static routing is obtained by setting local_traffic_selector and remote_traffic_selector to ["0.0.0.0/0"]
- The UI does not explictly ask to define the forwarding rules that are necessary to create a classic VPN (UDP 500, UDP 4500 and ESP)

### Forwarding rules
- UDP 4500 
- UDP 500
- ESP 

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