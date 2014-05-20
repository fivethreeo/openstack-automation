
nova-compute-kvm:
  pkg:
    - installed

nova-compute:
  pkg:
     - installed
  service:
    - running
    - watch:
      - pkg: nova-compute
      - ini: nova-compute
      - ini: nova-conf-kvm
  file:
    - managed
    - name: /etc/nova/nova-compute.conf
    - user: nova
    - group: nova
    - mode: 644
    - require:
      - pkg: nova-compute
  ini:
    - options_present
    - name: /etc/nova/nova-compute.conf
    - sections:
        DEFAULT:
          {% if 'virt.is_hyper' in salt and salt['virt.is_hyper'] %}
          libvirt_type: kvm
          {% else %}
          libvirt_type: qemu
          {% endif %}
          compute_driver: libvirt.LibvirtDriver
          libvirt_use_virtio_for_bridges: "True"
          libvirt_vif_type: ethernet
          libvirt_ovs_bridge: br-int 
          libvirt_vif_driver: nova.virt.libvirt.vif.LibvirtGenericVIFDriver
    - require:
      - file: nova-compute

python-guestfs:
  pkg:
    - installed

nova-conf-kvm:
  file:
    - managed
    - name: /etc/nova/nova.conf
    - user: nova
    - password: nova
    - mode: 644
    - require:
      - pkg: nova-compute
  ini:
    - options_present
    - name: /etc/nova/nova.conf
    - sections:
        DEFAULT:
          region_list: "['RegionOne']"
  
          my_ip: {{ grains['id'] }}      
  
          volume_api_class: nova.volume.cinder.API
          rpc_backend: nova.rpc.impl_kombu
          firewall_driver: nova.virt.firewall.NoopFirewallDriver
          network_api_class: nova.network.neutronv2.api.API
  
          auth_strategy: keystone
          security_group_api: neutron
  
          rabbit_host: {{ salt['cluster_ops.get_candidate'](pillar['queue-engine']) }}
  
          neutron_auth_strategy: keystone
          neutron_admin_tenant_name: service
          neutron_admin_auth_url: http://{{ salt['cluster_ops.get_candidate']('keystone') }}:35357/v2.0
          neutron_url: http://{{ salt['cluster_ops.get_candidate']('neutron') }}:9696
          neutron_admin_username: neutron
          neutron_admin_password: {{ pillar['keystone']['tenants']['service']['users']['neutron']['password'] }}
          vncserver_listen: "0.0.0.0"
          vncserver_proxyclient_address: {{ grains['id'] }}
  
          vnc_enabled: "True"
          novncproxy_base_url: http://{{ salt['cluster_ops.get_candidate']('nova') }}:6080/vnc_auto.html
  
          glance_host: {{ salt['cluster_ops.get_candidate']('glance') }}

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
      - file: nova-conf-kvm

nova-api-paste-kvm:
  file:
    - managed
    - name: /etc/nova/api-paste.ini
    - user: nova
    - group: nova
    - mode: 644
    - require:
      - pkg: nova-compute
      
nova-api-paste-kvm-opt:
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
      - file: nova-api-paste-kvm

