{% if 'salt' in salt['grains.get']('roles', []) %}
{% if salt['pillar.get']('cni:plugin', 'flannel').lower() == "cilium" %}

{% from '_macros/kubectl.jinja' import kubectl, kubectl_apply_dir_template with context %}

{{ kubectl("create-etcd-secrets",
           "create secret generic -n kube-system cilium-etcd-secrets --from-file=etcd-client-ca.crt=" +
           pillar['ssl']['ca_file'] +
           " --from-file=etcd-client.key=" +
           pillar['ssl']['key_file'] +
           " --from-file=etcd-client.crt=" +
           pillar['ssl']['crt_file'],
           unless="kubectl -n kube-system --kubeconfig=/var/lib/kubernetes/kubeconfig get secrets/cilium-etcd-secrets") }}

{{ kubectl_apply_dir_template("salt://kube-cni/cilium/files/cilium-1.7/",
                              "/etc/kubernetes/addons/cilium/") }}

/etc/kubernetes/policy:
  file.directory:
    - mode: 0755
    - makedirs: True

{% else %}

dns-dummy:
  cmd.run:
    - name: echo "Cilium addon not enabled in config"

{% endif %}
{% endif %}