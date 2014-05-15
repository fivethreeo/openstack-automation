nova-pkg:
  pkg:
    - purged
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

nova_sqlite:
  file:
    - absent
    - name: /var/lib/nova/nova.sqlite