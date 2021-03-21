
## Introduction

## Network set up

The ask was to create two projects in Google Cloud and set up networking for those two projects. 

```
```
_Figure 1: Networks_

## VPN 

Classic VPN. The service in Google is called 

## Firewall rules

The google command line can be used to set up the firewall rules

```
gcloud compute firewall-rules create vm1-allow-ingress-tcp-port80-from-subnet1 \
    --network network-a \
    --action allow \
    --direction ingress \
    --rules tcp:80 \
    --source-ranges 10.240.10.0/24 \
    --target-tags webserver
```

## Open questions 
- How is priority used in Firewall rules? 

## Relevant reading
- https://cloud.google.com/vpc/docs/using-firewalls
- https://cloud.google.com/network-connectivity/docs/vpn/how-to/creating-static-vpns

## Appendix

Commands to create firewall 