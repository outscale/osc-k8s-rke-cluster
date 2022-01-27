# Kubernetes Cluster With RKE On Outscale Cloud

This reprository contain a way to deploy a [kubernetes](https://kubernetes.io/) cluster using [rke](https://rancher.com/docs/rke/) on [Outscale cloud provider](https://outscale.com/).

# Architecture

The Kubernetes cluster is deployed inside a [Net](https://wiki.outscale.net/display/EN/About+VPCs) with three [Subnets](https://wiki.outscale.net/display/EN/Getting+Information+About+Your+Subnets):
- One subnet (10.0.0.0/24) containing:
  - A bastion host
  - A [NAT Service](https://wiki.outscale.net/display/EN/About+NAT+Gateways) to provide internet access to nodes.
  - A load balancer for kube-apiserver
- One subnet (10.0.0.1/24) containing all nodes (control plane and worker nodes)

# Use the project

- [Deploy](deploy.md)
- [Testing](testing.md)
- [Contributing](contributing.md)
- [Addons](addons.md)
