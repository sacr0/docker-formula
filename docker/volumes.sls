include:
  - docker

{%- for name, volume in salt['pillar.get']('docker:volumes', {}).items() %}
docker_volume_{{name}}:
  docker_volume.{{ volume.get('state', "present") }}:
    - name: {{ name }}
  {%- if 'driver' in volume %}
    - driver: {{ volume.get('driver', "local") }}
  {%- endif %}
  {%- if 'driver_opts' in volume and volume.driver_opts is iterable %}
    - driver_opts:
    {%- for variable, value in volume.driver_opts.items() %}
        - {{variable}}: {{value}}
    {%- endfor %}
  {%- endif %}
  {%- if 'force' in volume  %}
    - force: {{ volume.get('force', "False") }}
  {%- endif %}
{% endfor %}
