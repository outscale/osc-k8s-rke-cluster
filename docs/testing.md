# How to test your cluster

## Smoke tests

Smoke testing our newly created Kubernetes cluster can be done very similarely to [kubernetes-the-hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/13-smoke-test.md).

Note that workers has no public IP so you can test Nodeport service from bastion.

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
sonobuoy run --wait  --e2e-skip "Ingress API should support creating Ingress API operations|ServiceAccountIssuerDiscovery should support OIDC discovery of service account issuer|\[Disruptive\]|NoExecuteTaintManager"
results=$(sonobuoy retrieve)
sonobuoy results $results
```

> **NOTE**: 
> 
> These two first tests are skipped because
> -  `Ingress API should support creating Ingress API operations`: the ingress controller does not accept duplicate ingress with different namespaces
> -  `ServiceAccounts ServiceAccountIssuerDiscovery should support OIDC discovery of service account issuer`: the OIDC is not enabled in our cluster
> 
> The two last are the default value.

To get more details about failed tests:
```
outfile=$(sonobuoy retrieve)
sonobuoy results --mode detailed --plugin e2e $outfile |  jq '.  | select(.status == "failed") | .details'
```

To get the logs of the e2e, you can find the logs file inside the archive with the path: `plugins/e2e/results/global/e2e.log`.

In order to re-run a specific test:
```
sonobuoy run --e2e-focus "your test name regex"
```
