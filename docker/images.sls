include:
  - docker

{%- for image_desc, image in salt['pillar.get']('docker:image', {}).items() %}
docker_image_{{image_desc}}:
  docker_image.{{ image.get('state', "present") }}:
#    - name: '{{ image.get('name', "") }}' # make sure the name is specified in the pillar
  {%- for variable, value in image.items() %}
  {%- if image.get('sls', "") and image.get(variable, "") is iterable %}
    - {{ variable }}:
    {%- for value2 in image.get(variable,[]) %}
      - '{{ value2 }}'
    {%- endfor %}
  {%- else %}
    - {{variable}}: '{{value}}'
  {%- endif %}
  {%- endfor %}
{% endfor %}
