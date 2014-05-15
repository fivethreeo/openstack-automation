mysql-client:
  pkg
    - purged¨

python-mysqldb:
  pkg:
    - purged
    - require
      - pkg: mysql-client