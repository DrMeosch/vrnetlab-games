# cilium on k8s with bgp with MikroTik

## Installation

Install [cilium-cli](https://github.com/cilium/cilium-cli). If you're on WSL2 - use this [workaround](https://wsl.dev/wslcilium/)

Install kind

```
go install sigs.k8s.io/kind@latest
```

Create lab

```
kind create cluster --name clab-bgp-cplane --image kindest/node:v1.28.7 --config ./config-kind.yaml
sudo containerlab -t topo.yaml deploy
helm upgrade --install cilium cilium/cilium --version 1.15.7 --namespace kube-system --values ./values-cilium.yaml
```