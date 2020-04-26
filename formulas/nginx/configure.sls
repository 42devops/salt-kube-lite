---

config-nginx-enable-site:
  file.managed:
    - name: /etc/nginx/sites-available/kubernetes.default.svc.cluster.local
    - source: salt://nginx/files/kubernetes.default.svc.cluster.local.jinjia
    - template: jinja

/etc/nginx/sites-enabled/kubernetes.default.svc.cluster.local:
  file.symlink:
    - target: /etc/nginx/sites-available/kubernetes.default.svc.cluster.local

start-nginx:
  service.running:
    - name: nginx
    - enable: true
    - reload: true
    - watch:
      - file: config-nginx-enable-site