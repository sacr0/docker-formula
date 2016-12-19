{% from "docker/map.jinja" import docker with context %}

# pre installation requirements
{% if grains["os_family"] == "Arch" %}
include:
  - .archlinux-requirements
{% endif %}

docker:
  pkg.installed:
    - name: {{ docker.package }}
  service.running:
    - name: {{ docker.service }}
    - enable: True
    - watch:
      - file: {{ docker.configlocation }}

docker-config:
  file.managed:
    - name: {{ docker.configlocation }}
    - source: salt://docker/files/config
    - template: jinja
    - mode: 644
    - user: root
    - require:
      - pkg: docker

