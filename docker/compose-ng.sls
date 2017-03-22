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
      {%- if port_mapping is string %}
        {%- set mapping = port_mapping.split(':',2) %}
        {%- if mapping|length < 2 %}
      - "{{mapping[0]}}"
        {%- else %}
      - "{{mapping[-1]}}/tcp":
            HostPort: "{{mapping[-2]}}"
            HostIp: "{{mapping[-3]|d('')}}"
        {%- endif %}
      {%- elif port_mapping is mapping %}
      - {{port_mapping}}
      {%- endif %}
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
    - restart_policy: {{container.restart}}
  {%- endif %}
    - require:
      - docker: {{id}} image
  {%- if required_containers is defined %}
    {%- for containerid in required_containers %}
      - docker: {{containerid}}
    {%- endfor %}
  {%- endif %}
{% endfor %}
