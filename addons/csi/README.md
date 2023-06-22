# Container Storage Interface (CSI)

Here, we show how to install Outscale CSI for this specific cluster.

# Deployment

```
export KUBECONFIG=rke/kube_config_cluster.yml
kubectl apply -f addons/csi/secrets.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-6.1/client/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-6.1/client/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-6.1/client/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-6.1/deploy/kubernetes/snapshot-controller/rbac-snapshot-controller.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-6.1/deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml
ANSIBLE_CONFIG=ansible.cfg ansible-playbook addons/csi/playbook.yaml
```


# CSI Quick Test

You can first check that CSI pods are deployed and running:
```
$ kubectl get pods -n kube-system | grep osc-csi-
osc-csi-controller-7f8c5cb85f-dbzhw        6/6     Running     0          86s
osc-csi-controller-7f8c5cb85f-szrc5        6/6     Running     0          86s
osc-csi-node-4rvhg                         3/3     Running     0          86s
osc-csi-node-c79mf                         3/3     Running     0          86s
osc-csi-node-dgx92                         3/3     Running     0          86s
```

Then you can use a simple dynamic provisioning:
```
kubectl apply -f addons/csi/dynamic.yaml
kubectl describe pv -n dynamic-p
kubectl get pods -n dynamic-p
```

Note that creation of volume may take time.

# Uninstall CSI

```
export KUBECONFIG=rke/kube_config_cluster.yml
kubectl delete -f addons/csi/secrets.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-6.1/client/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-6.1/client/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-6.1/client/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-6.1/deploy/kubernetes/snapshot-controller/rbac-snapshot-controller.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-6.1/deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml
ANSIBLE_CONFIG=ansible.cfg ansible-playbook addons/csi/playbook-destroy.yaml
```
