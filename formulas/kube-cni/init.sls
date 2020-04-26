
{% set plugin = salt['pillar.get']('cni:plugin', 'cilium').lower() %}

{% if plugin == "cilium" %}
include:
  - kube-cni/cni
  - kube-cni/cilium
{% endif %}