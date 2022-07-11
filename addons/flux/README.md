# Fluxv2

We will install fluxv2 and sync your own fluxv2 stack on the cluster.

## Deployment

Please change with your own values ansible-vars.yaml and use your own flux stack.

GITHUB_USER: your gitHub user or organization name

GITHUB_TOKEN: your gitHub personal access token with repo permissions

REPOSITORY: your gitHub repository name

BRANCH: your gitHub repository branch

PATH: repository root relative path where the cluster will sync

Please launch:
```
ANSIBLE_CONFIG=ansible.cfg ansible-playbook addons/flux/playbook.yaml 
```

