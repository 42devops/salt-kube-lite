{% set containerd_version = salt.caasp_pillar.get('containerd:version') %}
{% set containerd_package_hash = salt.caasp_pillar.get('containerd:hash') %}
{% set crictl_version = salt.caasp_pillar.get('critools:version') %}
{% set crictl_package_hash = salt.caasp_pillar.get('critools:hash') %}
{% set runc_package_hash = salt.caasp_pillar.get('runc:hash') %}
upload_containerd_package:
  file.managed:
    - name: /tmp/containerd-{{ containerd_version }}.linux-amd64.tar.gz
    - source: salt://containerd/files/containerd-{{ containerd_version }}.linux-amd64.tar.gz
    - source_hash: sha256={{ containerd_package_hash }}
    - unless: test -f /usr/local/bin/containerd


uarchive_containerd_package:
  cmd.wait:
    - name: tar xzf /tmp/containerd-{{ containerd_version }}.linux-amd64.tar.gz -C /tmp
    - unless: test -f /usr/local/bin/containerd
    - watch:
      - file: upload_containerd_package
    - require:
      - file: upload_containerd_package

containerd_install:
  cmd.wait:
    - name: cp -r /tmp/bin/* /usr/local/bin/
    - unless: test -f /usr/local/bin/containerd
    - watch:
      - cmd: uarchive_containerd_package
    - require:
      - cmd: uarchive_containerd_package

upload_critools_package:
  file.managed:
    - name: /tmp/crictl-{{ crictl_version }}-linux-amd64.tar.gz
    - source: salt://containerd/files/crictl-{{ crictl_version }}-linux-amd64.tar.gz
    - source_hash: sha256={{ crictl_package_hash }}
    - unless: test -f /usr/local/bin/crictl

uarchive_critools_package:
  cmd.wait:
    - name: tar xzf /tmp/crictl-{{ crictl_version }}-linux-amd64.tar.gz -C /tmp
    - unless: test -f /usr/local/bin/crictl
    - watch:
      - file: upload_critools_package
    - require:
      - file: upload_critools_package

critools_install:
  cmd.wait:
    - name: cp -r /tmp/crictl /usr/local/bin/
    - unless: test -f /usr/local/bin/crictl
    - watch:
      - cmd: uarchive_critools_package
    - require:
      - cmd: uarchive_critools_package

runc-package-install:
  file.managed:
    - name: /usr/local/bin/runc
    - source: salt://containerd/files/runc.amd64
    - source_hash: sha256={{ runc_package_hash }}
    - mode: 711
    - unless: test -f /usr/local/bin/runc