include:
  - docker
  - docker.volumes
  - docker.images

# install pip and with pip docker-py as this is required for these modules to work
dockerng_pip:
  pkg.installed:
    - name: python-pip

dockerng_pip_docker:
  pip.installed:
    - name: docker
    - require:
      - pip: dockerng_pip_docker-py
    
dockerng_pip_docker-py:
  pip.removed:
    - name: docker-py
    - require:
      - pkg: dockerng_pip

{%- from "docker/map.jinja" import compose with context %}
{%- for name, container in compose.items() %}
  {%- set id = container.container_name|d(name) %}
  {%- set required_containers = [] %}
{{id}}_container:
  docker_container.running:
    - name: {{id}}
    - image: {{container.image}}
  {%- if 'privileged' in container %}
    - privileged: {{container.privileged}}
  {%- endif %}
  {%- if 'command' in container %}
    - command: {{container.command}}
  {%- endif %}
  {%- if 'entrypoint' in container and container.entrypoint is iterable %}
    - entrypoint:
    {%- for entrypoint in container.entrypoint %}
      - {{entrypoint}}
    {%- endfor %}
  {%- elif 'entrypoint' in container %}
    - entrypoint: {{container.entrypoint}}
  {%- endif %}
  {%- if 'environment' in container and container.environment is iterable %}
    - environment:
    {%- for variable, value in container.environment.items() %}
        - {{variable}}: '{{value}}'
    {%- endfor %}
  {%- endif %}
  {%- if 'ports' in container and container.ports is iterable %}
    - port_bindings:
    {%- for port_mapping in container.ports %}
      - '{{port_mapping}}'
    {%- endfor %}
  {%- endif %}
  {%- if 'volumes' in container %}
    - volumes:
    {%- for volume in container.volumes %}
      - '{{volume}}'
    {%- endfor %}
  {%- endif %}
  {%- if 'volumes_from' in container %}
    - volumes_from:
    {%- for volume in container.volumes_from %}
      {%- do required_containers.append(volume) %}
      - '{{volume}}'
    {%- endfor %}
  {%- endif %}
  {%- if 'binds' in container %}
    - binds:
    {%- for bind in container.binds %}
      - '{{bind}}'
    {%- endfor %}
  {%- endif %}
  {%- if 'links' in container %}
    - links:
    {%- for link in container.links %}
#      {%- set name, alias = link.split(':',1) %}
#      {%- do required_containers.append(name) %}
#        - '{{name}}:{{alias}}'
         - '{{link}}'
    {%- endfor %}
  {%- endif %}
  {%- if 'logdriver' in container %}
    - log_driver: '{{container.logdriver}}'
  {%- endif %}
  {%- if 'logopt' in container and container.logopt is iterable%}
    - log_opt:
    {%- for variable, value in container.logopt.items() %}
        - {{variable}}: '{{value}}'
    {%- endfor %}
  {%- elif 'logopt' in container%}
    - log_opt: '{{ container.logopt }}'
  {%- endif %}
  {%- if 'restart_policy' in container %}
    - restart_policy: '{{container.restart_policy}}'
  {%- endif %}
  {%- if 'auto_remove' in container %}
    - auto_remove: '{{container.auto_remove}}'
  {%- endif %}
  {%- if 'user' in container %}
    - user: '{{container.user}}'
  {%- endif %}
  {%- if 'extra_hosts' in container and container.extra_hosts is iterable %}
    - extra_hosts:
    {%- for extra_host in container.extra_hosts %}
      - '{{extra_host}}'
    {%- endfor %}
  {%- endif %}
  {%- if 'cap_add' in container %}
    - cap_add: '{{container.cap_add}}'
  {%- endif %}
  {%- if 'cap_drop' in container %}
    - cap_drop: '{{container.cap_drop}}'
  {%- endif %}
  {%- if 'dns' in container %}
  {%- if container.dns is iterable %}
    - dns:
    {%- for dns_record in container.dns %}
      - {{dns_record}}
    {%- endfor %}
  {%- else %}
    - dns: {{container.dns}}
  {%- endif %}
  {%- endif %}
    - require:
      - service: docker
  {%- if id in salt['pillar.get']('docker:image', {}) %}
      - docker_image: docker_image_{{ id }}
  {%- endif %}
  {%- if required_containers|length > 0 %}
    {%- for containerid in required_containers %}
      - docker_container: {{containerid}}
    {%- endfor %}
  {%- endif %}
{% endfor %}
