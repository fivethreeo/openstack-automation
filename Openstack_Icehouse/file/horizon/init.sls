
memcached:
  pkg:
    - installed
  service:
    - running
    - watch:
      - pkg: memcached

apache2:
  pkg:
    - installed
  service:
    - running
    - watch:
      - pkg: libapache2-mod-wsgi
      - file: openstack-dashboard.conf
      - file: local_settings.py

openstack-dashboard.conf:
  file:
    - managed
    - name: /etc/apache2/sites-enabled/openstack-dashboard.conf
    - source: salt://horizon/openstack-dashboard.conf
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: apache2

libapache2-mod-wsgi:
  pkg:
    - installed

local_settings.py:
  file:
    - managed
    - name: /usr/share/openstack-dashboard/openstack_dashboard/local/local_settings.py
    - source: salt://horizon/local_settings.py
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: apache2
      
openstack-dashboard:
  pkg:
    - installed
