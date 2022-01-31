# Container Storage Interface (CSI)

Here, we show how to install Outscale CSI for this specific cluster.

# Deployment

```
export KUBECONFIG=rke/kube_config_cluster.yml
kubectl apply -f addons/csi/secrets.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-5.0/client/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-5.0/client/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-5.0/client/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-5.0/deploy/kubernetes/snapshot-controller/rbac-snapshot-controller.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-5.0/deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml
ANSIBLE_CONFIG=ansible.cfg ansible-playbook addons/csi/playbook.yaml
```


# CSI Quick Test

You can use a simple dynamic provisioning:
```
kubectl apply -f addons/csi/dynamic.yaml
kubectl describe pv -n dynamic-p
```

Note that creation of volume may take time.

# Uninstall CSI

```
export KUBECONFIG=rke/kube_config_cluster.yml
kubectl delete -f addons/csi/secrets.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-5.0/client/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-5.0/client/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-5.0/client/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-5.0/deploy/kubernetes/snapshot-controller/rbac-snapshot-controller.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/release-5.0/deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml
ANSIBLE_CONFIG=ansible.cfg ansible-playbook addons/csi/playbook-destroy.yaml

```
