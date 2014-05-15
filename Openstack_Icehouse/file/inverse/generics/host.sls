{% for server in pillar['hosts'] %}

{{ server }}:
  host:
    - absent
    - ip : {{ pillar['hosts'][server] }}

{% endfor %}
