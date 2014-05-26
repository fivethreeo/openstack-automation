cluster_entities: 
  - compute
  - controller
  - network
compute: 
  - saturn
controller: 
  - mercury
network: 
  - mercury
cluster_name: openstack_cluster
keystone.auth_url: http://mercury:5000/v2.0/
keystone.endpoint: http://mercury:35357/v2.0
keystone.token: 24811ee3d9a09915bef0
keystone.user: admin
keystone.password: admin_pass
keystone.tenant: admin
cluster_type: openstack
pkg_proxy_url: http://salt:3142
queue-engine: queue.rabbit
install: 
  controller: 
    - inverse.generics.icehouse_cloud_repo
    - inverse.generics.apt-proxy
    - inverse.generics.headers
    - inverse.generics.host
    - inverse.mysql
    - inverse.mysql.client
    - inverse.queue.rabbit
    - inverse.keystone
    - inverse.glance
    - inverse.nova
    - inverse.horizon
  network: 
    - inverse.generics.icehouse_cloud_repo
    - inverse.generics.apt-proxy
    - inverse.generics.headers
    - inverse.generics.host
    - inverse.neutron
    - inverse.neutron.openvswitch
  compute: 
    - inverse.generics.icehouse_cloud_repo
    - inverse.generics.apt-proxy
    - inverse.generics.headers
    - inverse.generics.host
    - inverse.nova.compute_kvm
    - inverse.neutron.openvswitch
