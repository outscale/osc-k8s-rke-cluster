# Cloud Controller Manager (CCM)

Here, we show how to install Outscale CCM for this specific cluster.

# Deployment

```
export KUBECONFIG=rke/kube_config_cluster.yml
kubectl apply -f addons/ccm/secrets.yaml
kubectl apply -f https://raw.githubusercontent.com/outscale/cloud-provider-osc/v0.2.7/deploy/osc-ccm-manifest.yml
```

# CCM Quick Test

You can check that CCM controller pods states are "running":
```
kubectl get pods -n kube-system | grep osc-cloud-controller
```

You can use a simple deployment app using a Service of type LoadBalancer with 2048 game:
```
kubectl apply -f addons/ccm/2048.yaml
```

Once applied, `kubectl get svc -n 2048` should show a hostname in `EXTERNAL-IP`column. e.g. `d90e2719f9714e80b3dd188169963c3a-460554626.us-east-2.lbu.outscale.com`. If the field still show `<pending>` after a while, check you CCM installation.

By visiting `http://<hostname>`with your browser, you should see the 2048 game. If the web page loads for a while and fails, check that you are using http/80 and not https/443.
Also note that the load balancer may take time to expose the service.

# Uninstall CCM

```
kubectl delete -f https://raw.githubusercontent.com/outscale/cloud-provider-osc/v0.2.7/deploy/osc-ccm-manifest.yml
kubectl delete -f addons/ccm/secrets.yaml
```
