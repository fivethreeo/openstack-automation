
cluster_entities: 
  - compute
  - controller
  - network
compute: 
  - saltvikprime
controller: 
  - saltvikprime
network: 
  - saltvikprime
cluster_name: openstack_cluster
keystone.auth_url: http://saltvikprime:5000/v2.0
keystone.endpoint: http://saltvikprime:35357/v2.0
keystone.token: 24811ee3d9a09915bef0
keystone.user: admin
keystone.password: admin_pass
keystone.tenant: admin
cluster_type: openstack
queue-engine: queue.rabbit
cloud_repos: 
  - 
    reponame: havana-cloud-bin
    name: deb http://ubuntu-cloud.archive.canonical.com/ubuntu cloud-archive/icehouse main
    file: /etc/apt/sources.list.d/cloudarchive-icehouse.list
  - 
    reponame: havana-cloud-src
    name: deb-src http://ubuntu-cloud.archive.canonical.com/ubuntu cloud-archive/icehouse main
    file: /etc/apt/sources.list.d/cloudarchive-icehouse-src.list
mysql: 
  nova: 
    username: nova
    password: nova_pass
    sync: nova-manage db sync
    service: nova-api
  dash: 
    username: dash
    password: dash_pass
  keystone: 
    username: keystone
    password: keystone_pass
    sync: keystone-manage db_sync
    service: keystone
  cinder: 
    username: cinder
    password: cinder_pass
    sync: cinder-manage db sync
  glance: 
    username: glance
    password: glance_pass
    sync: glance-manage db_sync
    service: glance
  neutron: 
    username: neutron
    password: neutron_pass
keystone: 
  endpoint: http://saltvikprime:35357/v2.0
  token: 24811ee3d9a09915bef0
  roles: 
    - admin
    - Member
  services: 
    glance: 
      service_type: image
      endpoint: 
        adminurl: http://{{ grains['id'] }}:9292/v1
        internalurl: http://{{ grains['id'] }}:9292/v1
        publicurl: http://{{ grains['id'] }}:9292/v1
      description: glance image service
    cinder: 
      service_type: volume
      endpoint: 
        adminurl: http://{{ grains['id'] }}:8776/v1/%(tenant_id)s
        internalurl: http://{{ grains['id'] }}:8776/v1/%(tenant_id)s
        publicurl: http://{{ grains['id'] }}:8776/v1/%(tenant_id)s
      description: cinder volume service
    keystone: 
      service_type: identity
      endpoint: 
        adminurl: http://{{ grains['id'] }}:35357/v2.0
        internalurl: http://{{ grains['id'] }}:5000/v2.0
        publicurl: http://{{ grains['id'] }}:5000/v2.0
      description: keystone identity service
    neutron: 
      service_type: network
      endpoint: 
        adminurl: http://{{ grains['id'] }}:9696
        internalurl: http://{{ grains['id'] }}:9696
        publicurl: http://{{ grains['id'] }}:9696
      description: Openstack network service
    nova: 
      service_type: compute
      endpoint: 
        adminurl: http://{{ grains['id'] }}:8774/v2/%(tenant_id)s
        internalurl: http://{{ grains['id'] }}:8774/v2/%(tenant_id)s
        publicurl: http://{{ grains['id'] }}:8774/v2/%(tenant_id)s
      description: nova compute service
  tenants: 
    admin: 
      users: 
        admin: 
          password: admin_pass
          role: admin
          email: salt@csscorp.com
    service: 
      users: 
        glance: 
          password: glance_pass
          role: admin
          email: salt@csscorp.com
        neutron: 
          password: neutron_pass
          role: admin
          email: salt@csscorp.com
        nova: 
          password: nova_pass
          role: admin
          email: salt@csscorp.com
        cinder: 
          password: cinder_pass
          role: admin
          email: salt@csscorp.com
  dbname: keystone
neutron: 
  metadata_secret: 414c66b22b1e7a20cc35
  intergration_bridge: br-int
  network_mode: vlan
  saltvikprime: 
    Intnet1: 
      start_vlan: 100
      end_vlan: 200
      bridge: br-eth1
      interface: eth1
install: 
  controller: 
    - generics.icehouse_cloud_repo
    - generics.apt-proxy
    - generics.headers
    - generics.host
    - mysql
    - mysql.client
    - mysql.openstack_dbschema
    - queue.rabbit
    - keystone
    - keystone.openstack_tenants
    - keystone.openstack_users
    - keystone.openstack_services
    - glance
    - cinder
    - nova
    - horizon
  network: 
    - generics.icehouse_cloud_repo
    - generics.apt-proxy
    - generics.headers
    - generics.host
    - neutron
    - neutron.openvswitch
  compute: 
    - generics.icehouse_cloud_repo
    - generics.apt-proxy
    - generics.headers
    - generics.host
    - nova.compute_kvm
    - neutron.openvswitch
hosts: 
  salt: 192.168.0.7
