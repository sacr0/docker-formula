# reeuirements that needs tobe configured before docker is installed

# load "loop" module, as suggested by ArchLinux
docker_modprobe:
  file.managed:
    - name: /etc/modules-load.d/loop.conf
    - makedirs: True
    - contents: "loop"
  kmod.present:
    - name: loop
    - require:
      - file: docker_modprobe
    - order: 1

# use the latest storage driver, as suggested by ArchLinux
docker_storagedriver:
  file.managed:
    - name: /etc/systemd/system/docker.service.d/override.conf
    - makedirs: True
    - contents: 
      - "[Service]"
      - "ExecStart="
      - "ExecStart=/usr/bin/dockerd -H fd:// -s overlay2"