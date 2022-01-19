# How to test your cluster

## Smoke tests

Smoke testing our newly created Kubernetes cluster can be done very similarely to [kubernetes-the-hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/13-smoke-test.md).

Note that workers has no public IP so you can test Nodeport service from bastion.

# CCM quicktest

You can test the CCM by creating a LoadBalancer Service:
```
scp -F ssh_config examples/2048.yaml bastion:./
ssh -F ssh_config bastion
kubectl apply -f 2048.yaml
kubectl get svc -n 2048
```

Note that load balancer may take time to expose the service.

## Sonobuoy

[Sonobuoy](https://sonobuoy.io/) allow us to validate cluster configuration. Those tests can be run from bastion and can be pretty long to end (can take 2h), make sure that your kubectl is configured.

```
ssh -F ssh_config bastion
```

From there, you can [Install](https://sonobuoy.io/docs/v0.55.1/#installation) the [latest version](https://github.com/vmware-tanzu/sonobuoy/releases):
"
```
wget -qO- https://github.com/vmware-tanzu/sonobuoy/releases/download/v0.55.1/sonobuoy_0.55.1_linux_amd64.tar.gz | tar zxvf - sonobuoy
sudo mv sonobuoy /usr/local/bin/
```

Finally, you can run tests and retrieve results:

```
sonobuoy run --wait
results=$(sonobuoy retrieve)
sonobuoy results $results
```
