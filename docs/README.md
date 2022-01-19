# Kubernetes Cluster With RKE On Outscale Cloud

This reprository contain a way to deploy a [kubernetes](https://kubernetes.io/) cluster using [rke](https://rancher.com/docs/rke/) on [Outscale cloud provider](https://outscale.com/).

# Architecture

The Kubernetes cluster is deployed inside a [Net](https://wiki.outscale.net/display/EN/About+VPCs) with three [Subnets](https://wiki.outscale.net/display/EN/Getting+Information+About+Your+Subnets):
- One subnet (10.0.0.0/24) containing a bastion host, and a [NAT Service](https://wiki.outscale.net/display/EN/About+NAT+Gateways)
- One subnet (10.0.0.1/24) containing control plane nodes
- One subnet (10.0.0.2/24) containing woker nodes

# Use the project

- [Deploy](deploy.md)
- [Testing](testing.md)
- [Contributing](contributing.md)
