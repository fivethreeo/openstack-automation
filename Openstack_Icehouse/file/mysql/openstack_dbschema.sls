mysql-refresh-repo:
  module:
    - run
    - name: saltutil.sync_all
    - require:
      - pkg: python-mysqldb

{% for database_name in pillar['mysql'] %}
 
{{ database_name }}-db:
  mysql_database:
    - present
    - name: {{ database_name }}
    - character_set: utf8
    - collate: utf8_general_ci
    - require:
      - service: mysql-server
      - module: mysql-refresh-repo

            
    {% for server in salt['cluster_ops.list_hosts']() %}
{{ server }}-{{ database_name }}-accounts:
  mysql_user:
    - present
    - name: {{ pillar['mysql'][database_name]['username'] }}
    - password: {{ pillar['mysql'][database_name]['password'] }}
    - host: "%"
    - require:
      - mysql_database: {{ database_name }}-db
  mysql_grants:
    - present
    - grant: all
    - database: {{ database_name }}.*
    - user: {{ pillar['mysql'][database_name]['username'] }}
    - host: "%"
    - password: {{ pillar['mysql'][database_name]['password'] }}
    - require:
      - mysql_user: {{ server }}-{{ database_name }}-accounts
  {% endfor %}

{% endfor %}

