

glance:
  pkg:
    - installed
  service:
    - running               
    - names:
      - glance-registry
      - glance-api
    - watch:
      - pkg: glance
      - ini: glance-api-conf
      - ini: glance-registry-conf

glance-api-conf:
  file:
    - managed               
    - name: /etc/glance/glance-api.conf    
    - mode: 644    
    - user: glance    
    - group: glance    
    - require:                               
      - pkg: glance
  ini:
    - options_present
    - name: /etc/glance/glance-api.conf
    - sections:
        DEFAULT:
          rpc_backend: rabbit
          rabbit_host: {{ salt['cluster_ops.get_candidate'](pillar['queue-engine']) }}
        keystone_authtoken:
          auth_uri: http://{{ salt['cluster_ops.get_candidate']('keystone') }}:5000
          auth_host: {{ salt['cluster_ops.get_candidate']('keystone') }}
          auth_port: 35357
          auth_protocol: http
          admin_tenant_name: service
          admin_user: glance
          admin_password: {{ pillar['keystone']['tenants']['service']['users']['glance']['password'] }}
        paste_deploy:
          flavour: keystone
        database:
          connection: mysql://{{ pillar['mysql']['glance']['username'] }}:{{ pillar['mysql']['glance']['password'] }}@{{ salt['cluster_ops.get_candidate']('mysql') }}/glance
    - require:
      - file: glance-api-conf

glance-registry-conf:
  file:
    - managed               
    - name: /etc/glance/glance-registry.conf    
    - user: glance    
    - group: glance    
    - mode: 644    
    - require:                               
      - pkg: glance
  ini:
    - options_present
    - name: /etc/glance/glance-registry.conf
    - sections:
        keystone_authtoken:
          auth_uri: http://{{ salt['cluster_ops.get_candidate']('keystone') }}:5000
          auth_host: {{ salt['cluster_ops.get_candidate']('keystone') }}
          auth_port: 35357
          auth_protocol: http
          admin_tenant_name: service
          admin_user: glance
          admin_password: {{ pillar['keystone']['tenants']['service']['users']['glance']['password'] }}
        paste_deploy:
          flavour: keystone
        database:
          connection: mysql://{{ pillar['mysql']['glance']['username'] }}:{{ pillar['mysql']['glance']['password'] }}@{{ salt['cluster_ops.get_candidate']('mysql') }}/glance
    - require:
      - file: glance-registry-conf

glance_sync:
  cmd:
    - run
    - name: {{ pillar['mysql']['glance']['sync'] }}
    - require:
      - service: glance
      
glance_sqlite_delete:
  file:
    - absent               
    - name: /var/lib/glance/glance.sqlite
    - require:
      - pkg: glance