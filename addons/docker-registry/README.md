# Docker Registry
We can deploy in the cluster a private Docker registry in order to, for example, use development images in the pods of the cluster.

Right now the Docker registry will be configured as the following:
 - use of HTTP
 - accessible using NodePort
 - non persistent 


# Deployement
Deploy the registry into the cluster: 
```
ANSIBLE_CONFIG=ansible.cfg ansible-playbook addons/docker-registry/playbook.yaml
```

# Running
First, enable SSH port forwarding

```
./addons/docker-registry/start_port_forwarding.sh
```

Then, you can access the repo by using the IP and the port that is deplayed by the previous script.

# Uninstall

```
ANSIBLE_CONFIG=ansible.cfg ansible-playbook addons/docker-registry/playbook-destroy.yaml
```