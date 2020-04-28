SHELL := /bin/bash
GIT_SHA = $(shell git log --pretty=oneline | head -n1 | cut -c1-8)
PACKAGE = "salt_config-$(GIT_SHA).tgz"
SHASUM = $(shell test `uname` == 'Darwin' && echo shasum -a 256 || echo sha256sum)
ONI = "👹"
env := "local"
KUBE_VERSION := "1.17.5"
ETCD_VERSION := "3.3.20"
CNI_PLUGINS_VERSION := "v0.8.5"
CONTAINERD_VERSION := "1.3.4"
CRICTL_VERSION := "v1.17.0"


all: formulas
	@mkdir -p dist
	@rsync -a ./salt/$(env) ./dist/salt/ --delete
	@rsync -a ./_grains/ ./dist/salt/$(env)/_grains/ --delete
	@rsync -a ./_macros/ ./dist/salt/$(env)/_macros/ --delete
	@rsync -a ./_states/ ./dist/salt/$(env)/_states/ --delete
	@rsync -a ./_modules/ ./dist/salt/$(env)/_modules/ --delete
	@rsync -a ./_runners/ ./dist/_runners/ --delete
	@rsync -a ./reactor/ ./dist/reactor/ --delete
	@rsync -a ./formulas/ ./dist/formulas/ --delete
	@rsync -a ./pillar/$(env) ./dist/pillar/ --delete
	@echo "copy local install file to ./dist. Enjoy!"
	@rsync -a scripts/binaries/kube-apiserver dist/formulas/kube-apiserver/files
	@rsync -a scripts/binaries/kube-controller-manager dist/formulas/kube-controller-manager/files
	@rsync -a scripts/binaries/kube-scheduler dist/formulas/kube-scheduler/files
	@rsync -a scripts/binaries/kubectl dist/formulas/kubectl/files
	@rsync -a scripts/binaries/kube-proxy dist/formulas/kube-proxy/files
	@rsync -a scripts/binaries/kubelet dist/formulas/kubelet/files
	@rsync -a scripts/binaries/etcd-v$(ETCD_VERSION)-linux-amd64.tar.gz dist/formulas/etcd/files
	@rsync -a scripts/binaries/cni-plugins-linux-amd64-$(CNI_PLUGINS_VERSION).tgz dist/formulas/kube-cni/cni/files
	@rsync -a scripts/binaries/containerd-$(CONTAINERD_VERSION).linux-amd64.tar.gz dist/formulas/containerd/files
	@rsync -a scripts/binaries/crictl-$(CRICTL_VERSION)-linux-amd64.tar.gz dist/formulas/containerd/files
	@rsync -a scripts/binaries/runc.amd64 dist/formulas/containerd/files
	@echo $(GIT_SHA) > ./dist/SHA
	@find ./dist -type f | sort | xargs $(SHASUM) | sed "s;./dist;/srv;" > MANIFEST
	@$(SHASUM) MANIFEST | cut -d\  -f1 > MANIFEST.sha256
	@mv MANIFEST* ./dist/
	@echo "Salt $(env) env is ready in ./dist. Enjoy!"

localinstall:
	@rsync -a scripts/binaries/kube-apiserver dist/formulas/kube-apiserver/files
	@rsync -a scripts/binaries/kube-controller-manager dist/formulas/kube-controller-manager/files
	@rsync -a scripts/binaries/kube-scheduler dist/formulas/kube-scheduler/files
	@rsync -a scripts/binaries/kubectl dist/formulas/kubectl/files
	@rsync -a scripts/binaries/kube-proxy dist/formulas/kube-proxy/files
	@rsync -a scripts/binaries/kubelet dist/formulas/kubelet/files
	@rsync -a scripts/binaries/etcd-v$(ETCD_VERSION)-linux-amd64.tar.gz dist/formulas/etcd/files
	@rsync -a scripts/binaries/cni-plugins-linux-amd64-$(CNI_PLUGINS_VERSION).tgz dist/formulas/kube-cni/cni/files
lint:
	@tests/lint.sh

test: clean all lint
	@true

package: clean all
	@tar czf $(PACKAGE) ./dist/
	@mv -f $(PACKAGE) ./dist
	@echo "Package ./dist/$(PACKAGE) is ready."

clean:
	@echo -n "Removing vagrant VMs..."
	@vagrant destroy -f
	@echo "DONE"
	@echo -n "Removing ./dist directory..."
	@rm -rf dist
	@echo "DONE"

coverage:
	@tests/coverage.sh

download:
	@echo -n 'Download the binaries package to ./tests/binaries directory...'
	@scripts/download.sh

init: all
	vagrant up
	sleep 10
	vagrant ssh salt -c "sudo salt salt state.sls salt.master"
	sleep 20
	vagrant ssh salt -c "sudo salt \* state.sls salt.minion"
	sleep 10
	vagrant ssh salt -c "sudo salt-call state.sls packages"
	vagrant ssh minion01 -c "sudo salt-call state.sls packages"
	vagrant ssh minion02 -c "sudo salt-call state.sls packages"
	sleep 20
	vagrant ssh salt -c "sudo salt salt state.sls caserver.initca"
	sleep 15
	vagrant ssh salt -c "sudo salt \* saltutil.sync_all"
	sleep 15
	vagrant ssh salt -c "sudo salt salt state.sls caserver"
	sleep 15
	vagrant ssh salt -c "sudo salt \* mine.update"
	sleep 10
	vagrant ssh salt -c "sudo salt \* state.apply -l debug"