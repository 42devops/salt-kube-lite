## salt-kube-lite Project

the lite version for cleanup salt-kube project and support new kubernetes, full binaries packages provision kubernetes cluster using saltstack.

## 1. Package version

- Ubuntu 18.04
- Saltstack 2018.3.3
- Etcd v3.3.12
- Docker v18.0.6-ce
- Flannel v0.11.0
- Kubernetes v1.17.5
- CoreDNS v1.5.0

## 2. How to quickstart on local

- install `git` and `vagrant`.
- clone repo and download binaries package
- build for env

### Download binaries package

setting version on `scripts/download.sh` if you want, and update `Makefile` for version

```bash
make download
```
