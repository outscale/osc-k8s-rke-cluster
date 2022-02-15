# destroy_cluster

## Description
This Github action allows you to destroy **a previously created** k8s cluster in the Outscale Cloud.
See [action.yml](action.yml)

## Inputs

| Parameter           | Description                                                           | Required | Default   |
| :------------------ | :-------------------------------------------------------------------- | :------- | :-------- |
| `osc_access_key`    | OSC Access Key                                                        | `true`   | `""`      |
| `osc_secret_key`    | OSC Secret Key                                                        | `true`   | `""`      |
| `osc_region`        | OSC region                                                            | `true`   | `""`      |
| `repository_folder` | Folder where this repo is stored                                      | `false`  | `"./"`    |

## Output
N/A

## Example
### Basic Example
```yaml
name: basic example
on:
  push:
    branches:    
      - 'master'

jobs:
  deploy:
    runs-on:  ubuntu-latest
    needs: code-quality
    steps:
    - uses: actions/checkout@v2
    - name: Destroy Cluster
      uses: outscale-dev/osc-k8s-rke-cluster/github_actions/destroy_cluster@master
      with:
        repository_folder: "./"
        osc_access_key: ${{ secrets.OSC_ACCESS_KEY }}
        osc_secret_key: ${{ secrets.OSC_SECRET_KEY }}
        osc_region: ${{ secrets.OSC_REGION }}
```