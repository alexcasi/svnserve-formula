{% from 'svnserve/map.jinja' import svnserve with context %}

{% for pkg in svnserve.packages %}
{{ pkg }}:
  pkg.installed:
    - name: {{ pkg }}
{% endfor %}

svnserve_user:
  user.present:
    - name: {{ svnserve.user }}

svnserve_group:
  group.present:
    - name: {{ svnserve.group }}

svnserve_log_directory:
  file.directory:
    - name: {{ svnserve.log_directory }}
    - user: {{ svnserve.user }}
    - group: {{ svnserve.group }}
    - makedirs: true

svnserve_logrotate_config:
  file.managed:
    - name: /etc/logrotate.d/svnserve
    - source: salt://svnserve/files/svnserve.logrotate
    - template: jinja
    - mode: 644
    - user: {{ svnserve.user }}
    - group: {{ svnserve.group }}
    - defaults:
        directory: {{ svnserve.log_directory }}

{% if grains.os_family == 'Debian' %}
svnserve_systemd_service:
  file.managed:
    - name: /etc/systemd/system/svnserve.service
    - source: salt://svnserve/files/svnserve.service
    - mode: 644
    - user: root
    - group: root

svnserve_service_default:
  file.managed:
    - name: /etc/default/svnserve
    - source: salt://svnserve/files/svnserve.env
    - template: jinja
    - mode: 644
    - user: {{ svnserve.user }}
    - group: {{ svnserve.group }}
    - defaults:
        log_directory: {{ svnserve.log_directory }}
        root: {{ svnserve.root }}
    - watch_in:
      - service: svnserve_service

# TODO: *BSD support
svnserve_umask_wrapper:
  file.managed:
    - name: /usr/local/bin/svnserve
    - source: salt://svnserve/files/svnserve_umask_wrapper.sh
    - mode: 755
    - user: root
    - group: root
{% endif %}

svnserve_service:
  service.running:
    - name: svnserve
    - enable: True
