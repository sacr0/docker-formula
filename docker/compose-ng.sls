include:
  - docker
  - docker.volumes
  
{%- from "docker/map.jinja" import compose with context %}
{%- for name, container in compose.items() %}
  {%- set id = container.container_name|d(name) %}
  {%- set required_containers = [] %}
{{id}}_container:
  docker.running:
    - name: {{id}}
    - image: {{container.image}}
  {%- if 'command' in container %}
    - command: {{container.command}}
  {%- endif %}
  {%- if 'environment' in container and container.environment is iterable %}
    - environment:
    {%- for variable, value in container.environment.iteritems() %}
        - {{variable}}: {{value}}
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
      - {{volume}}
    {%- endfor %}
  {%- endif %}
  {%- if 'volumes_from' in container %}
    - volumes_from:
    {%- for volume in container.volumes_from %}
      {%- do required_containers.append(volume) %}
      - {{volume}}
    {%- endfor %}
  {%- endif %}
  {%- if 'links' in container %}
    - links:
    {%- for link in container.links %}
      {%- set name, alias = link.split(':',1) %}
      {%- do required_containers.append(name) %}
        {{name}}: {{alias}}
    {%- endfor %}
  {%- endif %}
  {%- if 'restart' in container %}
    - restart_policy: '{{container.restart}}'
  {%- endif %}
  {%- if 'user' in container %}
    - user: '{{container.user}}'
  {%- endif %}
    - require:
      - service: docker
  {%- if required_containers|length > 0 %}
    {%- for containerid in required_containers %}
      - docker: {{containerid}}
    {%- endfor %}
  {%- endif %}
{% endfor %}
