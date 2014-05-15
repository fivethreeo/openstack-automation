
cinder: 
  pkg: 
    - installed
    - names: 
      - cinder-api
      - cinder-backup
      - cinder-common
      - cinder-volume
      - cinder-scheduler
      - python-cinder
      
cinder-service: 
  service: 
    - running
    - names: 
      - cinder-api
      - cinder-backup
      - cinder-volume
      - cinder-scheduler
    - watch: 
      - pkg: cinder
      - ini: cinder-conf
      - ini: cinder-api-ini
      
cinder-conf: 
  file: 
    - managed
    - name: /etc/cinder/cinder.conf
    - mode: 644
    - user: cinder
    - group: cinder
    - require: 
      - pkg: cinder
  ini: 
    - options_present
    - name: /etc/cinder/cinder.conf
    - sections: 
        DEFAULT: 
          rpc_backend: cinder.openstack.common.rpc.impl_kombu
          rabbit_host: {{ salt['cluster_ops.get_candidate'](pillar['queue-engine']) }}
        keystone_authtoken:
          auth_uri: http://{{ salt['cluster_ops.get_candidate']('keystone') }}:5000
          auth_host: {{ salt['cluster_ops.get_candidate']('keystone') }}
          auth_port: 35357
          auth_protocol: http
          admin_tenant_name: service
          admin_user: cinder
          admin_password: {{ pillar['keystone']['tenants']['service']['users']['cinder']['password'] }}
        database:
          connection: mysql://{{ pillar['mysql']['cinder']['username'] }}:{{ pillar['mysql']['cinder']['password'] }}@{{ salt['cluster_ops.get_candidate']('mysql') }}/cinder
    - require: 
      - file: cinder-conf
      
cinder-api-ini: 
  file: 
    - managed
    - name: /etc/cinder/api-paste.ini
    - mode: 644
    - user: cinder
    - group: cinder
    - require: 
      - pkg: cinder
  ini: 
    - options_present
    - name: /etc/cinder/api-paste.ini
    - sections: 
      filter:authtoken: 
        paste.filter_factory: keystoneclient.middleware.auth_token:filter_factory
        auth_uri: http://{{ salt['cluster_ops.get_candidate']('keystone') }}:5000
        auth_host: {{ salt['cluster_ops.get_candidate']('keystone') }}
        auth_port: 35357
        auth_protocol: http
        admin_tenant_name: service
        admin_user: cinder
        admin_password: {{ pillar['keystone']['tenants']['service']['users']['cinder']['password'] }}
    - require: 
      - file: cinder-api-ini
cinder_sync: 
  cmd: 
    - run
    - name: "{{ pillar['mysql']['cinder']['sync'] }}"
    - require: 
      - service: cinder-service