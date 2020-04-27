## SALT-KUBE-LITE Project

the lite version for cleanup salt-kube project and support new kubernetes, full binaries packages provision kubernetes cluster using saltstack.

## 1. Package version

- Ubuntu 18.04
- Saltstack 2018.3.3
- Etcd v3.3.20
- Containerd 1.3.4
- Cilium 1.5.5
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

### Startup local env using vagrant

if got some error, re-run `make init`

```bash
make init
make init
```

### Login local env to test

```bash
vagrant ssh salt
sudo su -
kubectl get no
```

### Other notes

1. init cluster manual by command

```bash
vagrant up
vagrant ssh salt
# testing salt minions
salt \* test.ping
# sync all modules for salt
salt-run saltutil.sync_all saltenv=local
# setting roles for def whith salt/<env>/roles.yaml
salt-run state.orchestrate orch.setting_roles saltenv=local
# run orchstate for kubernetes install
salt-run state.orchestrate orch.kubernetes saltenv=local
```

> pls notes setting local vm networks interfaces into Pillar files `pillar/local/common/init.sls`

2. if you want add requirements packages

add it into this files:

- `pillar/local/common/packages_ubuntu.sls`

## 3. TODO

- [x] remove Docker, add Containerd as default container runtime
- [x] remove Flannel, add Cilium as default network
- [ ] upgrade cilium version
- [ ] add terraform to provision cloud resources
- ...

## 4. Reference

- https://github.com/BadgerOps/salt-workspace
- https://github.com/mitodl/salt-ops
- https://github.com/kubic-project/salt
- https://github.com/kelseyhightower/kubernetes-the-hard-way
