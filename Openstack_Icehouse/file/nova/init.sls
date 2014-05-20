
nova: 
  group: 
    - present
    - system: true
  user: 
    - present
    - home: /var/lib/nova
    - createhome: false
    - system: true
    
nova-services: 
  pkg:
    - installed
    - names:
      - nova-api
      - nova-conductor
      - nova-scheduler
      - nova-cert
      - nova-consoleauth
      - nova-doc
      - python-novaclient
      - nova-ajax-console-proxy
      - novnc
      - nova-novncproxy
  service: 
    - running
    - names:
      - nova-api
      - nova-conductor
      - nova-scheduler
      - nova-cert
      - nova-consoleauth
    - watch: 
      - ini: nova-conf
      - file: nova-api-paste
      - ini: nova-api-paste-opt
      
nova_sync: 
  cmd: 
    - run
    - name: {{ pillar['mysql']['nova']['sync'] }}
    - require: 
      - service: nova-services
      
nova_sqlite_delete: 
  file: 
    - absent
    - name: /var/lib/nova/nova.sqlite
    - require: 
      - pkg: nova-services

nova-conf: 
  file: 
    - managed
    - name: /etc/nova/nova.conf
    - user: nova
    - password: nova
    - mode: 644
    - require: 
      - pkg: nova-services
  ini: 
    - options_present
    - name: /etc/nova/nova.conf
    - sections: 
        DEFAULT:           
          region_list: "['RegionOne']"
  
          my_ip: {{ grains['id'] }}      
    
          #volume_api_class: nova.volume.cinder.API
          rpc_backend: nova.rpc.impl_kombu
          firewall_driver: nova.virt.firewall.NoopFirewallDriver
          network_api_class: nova.network.neutronv2.api.API
  
          auth_strategy: keystone
          security_group_api: neutron
                    
          rabbit_host: {{ salt['cluster_ops.get_candidate'](pillar['queue-engine']) }}
          
          lockout_attempts: 5
          lockout_window: 15
          lockout_minutes: 15

          service_neutron_metadata_proxy: "True"
          neutron_auth_strategy: keystone
          neutron_admin_tenant_name: service
          neutron_admin_auth_url: http://{{ salt['cluster_ops.get_candidate']('keystone') }}:35357/v2.0
          neutron_url: http://{{ salt['cluster_ops.get_candidate']('neutron') }}:9696
          neutron_admin_username: neutron
          neutron_admin_password: {{ pillar['keystone']['tenants']['service']['users']['neutron']['password'] }}
          neutron_metadata_proxy_shared_secret: {{ pillar['neutron']['metadata_secret'] }}
  
          vncserver_listen: {{ salt['cluster_ops.get_candidate']('nova') }}
          vncserver_proxyclient_address: {{ salt['cluster_ops.get_candidate']('nova') }}

          ec2_dmz_host: {{ salt['cluster_ops.get_candidate']('nova') }}
          ec2_port: 8773
          ec2_strict_validation: "True"
          ec2_listen_port: 8773
          ec2_listen: "0.0.0.0"
          ec2_sheme: http
          ec2_host: {{ salt['cluster_ops.get_candidate']('nova') }}
          ec2_path: /services/Cloud
          ec2_timestamp_expiry: 300
          keystone_ec2_url: http://{{ salt['cluster_ops.get_candidate']('nova') }}:5000/v2.0/ec2tokens
          
        keystone_authtoken:
          auth_protocol: http
          admin_user: nova 
          admin_password: {{ pillar['keystone']['tenants']['service']['users']['nova']['password'] }}
          auth_host: {{ salt['cluster_ops.get_candidate']('keystone') }}
          admin_tenant_name: service
          auth_port: 35357
          
        database: 
          connection: mysql://{{ pillar['mysql']['nova']['username'] }}:{{ pillar['mysql']['nova']['password'] }}@{{ salt['cluster_ops.get_candidate']('mysql') }}/nova
    - require: 
        - file: nova-conf
        
nova-api-paste: 
  file: 
    - managed
    - name: /etc/nova/api-paste.ini
    - user: nova
    - group: nova
    - mode: 644
    - require: 
      - pkg: nova-services
      
nova-api-paste-opt:
  ini: 
    - options_present
    - name: /etc/nova/api-paste.ini
    - sections: 
        composite:ec2: 
          /services/Admin: ec2cloud
        filter:authtoken:
          auth_protocol: http
          admin_user: nova 
          admin_password: {{ pillar['keystone']['tenants']['service']['users']['nova']['password'] }}
          auth_host: {{ salt['cluster_ops.get_candidate']('keystone') }}
          admin_tenant_name: service
    - require: 
      - file: nova-api-paste

