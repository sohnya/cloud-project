
## Introduction

Set up the infrastructure manually -> Error prone and boring. 

Another way of setting up gCloud infrastructure is using [Terraform google-modules](https://registry.terraform.io/namespaces/terraform-google-modules). 

A Google Virtual Private Network (VPC)
Subnets within the VPC

See example for [main.tf](https://registry.terraform.io/modules/terraform-google-modules/network/google/latest). 

For example, firewall rules can set up using [firewall-rule](https://registry.terraform.io/modules/terraform-google-modules/network/google/latest/submodules/firewall-rules)). 

## Using Terraform with my account 

- https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started

## Network setup

The ask was to create two projects in Google Cloud and set up networking for those two projects. 

```
```
_Figure 1: Networks_

## VPN 

Classic VPN. The service in Google is called 

- https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_vpn_gateway
- https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_vpn_tunnel

## Firewall rules

- yolo

## Open questions 
- How is priority used in Firewall rules? 
- What is a forwarding rule in a VPN?

## Additional reading
- https://cloud.google.com/vpc/docs/using-firewalls
- https://cloud.google.com/network-connectivity/docs/vpn/how-to/creating-static-vpns
- https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance