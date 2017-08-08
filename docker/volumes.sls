include:
  - docker

{%- for name, volume in salt['pillar.get']('docker:volumes', {}).iteritems() %}
docker_volume_{{name}}:
  dockerng.{{ volume.get('state', "volume_present") }}:
    - name: {{ name }}
  {%- if 'driver' in volume %}
    - driver: {{ volume.get('driver', "local") }}
  {%- endif %}
  {%- if 'driver_opts' in volume and volume.driver_opts is iterable %}
    - driver_opts:
    {%- for variable, value in volume.driver_opts.iteritems() %}
        - {{variable}}: {{value}}
    {%- endfor %}
  {%- endif %}
  {%- if 'force' in volume  %}
    - force: {{ volume.get('driver', "False") }}
  {%- endif %}
{% endfor %}
