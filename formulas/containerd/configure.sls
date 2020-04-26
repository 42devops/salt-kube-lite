/etc/containerd/:
  file.directory:
    - mode: 0755
    - makedirs: True

configure-containerd:
  file.managed:
    - name: /etc/containerd/config.toml
    - source: salt://containerd/files/config.toml

configure-systemd-containerd-service:
  file.managed:
    - name: /etc/systemd/system/containerd.service
    - source: salt://containerd/files/containerd.service

containerd_running:
  service.running:
    - name: containerd
    - enable: True
    - reload: True
    - watch:
      - file: configure-containerd
      - file: configure-systemd-containerd-service
    - require:
      - file: configure-containerd
      - file: configure-systemd-containerd-service