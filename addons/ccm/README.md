# Cloud Controller Manager (CCM)

Here, we show how to install Outscale CCM for this specific cluster.

# Deployment

```
export KUBECONFIG=rke/kube_config_cluster.yml
kubectl apply -f addons/ccm/secrets.yaml
kubectl apply -f https://raw.githubusercontent.com/outscale-dev/cloud-provider-osc/v0.0.9beta/deploy/osc-ccm-manifest.yml
```

# CCM Quick Test

You can use a simple deployment app using a Service of type LoadBalancer with 2048 game:
```
kubectl apply -f addons/ccm/2048.yaml
kubectl get svc -n 2048
```

Note that load balancer may take time to expose the service.

# Uninstall CCM

```
kubectl delete -f https://raw.githubusercontent.com/outscale-dev/cloud-provider-osc/v0.0.9beta/deploy/osc-ccm-manifest.yml
kubectl delete -f addons/ccm/secrets.yaml
```
