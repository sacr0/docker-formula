include:
  - docker

{%- for image_desc, image in salt['pillar.get']('docker:image', {}).iteritems() %}
docker_image_{{image_desc}}:
  docker_image.{{ image.get('state', "present") }}:
    - name: {{ image.get(name,"") }}
  {%- for variable, value in image.iteritems() %}
    {%- if image.variable is iterable %}
      - {{ variable }}:
      {%- for value2 in image.get(variable,[]) %}
          - {{ value2 }}
      {%- endfor %}
    {%- else %}
    - {{variable}}: {{value}}
    {%- endif %}
  {%- endfor %}
{% endfor %}
