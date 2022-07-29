# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/prezto/map.jinja" import users %}

include:
  - {{ tplroot }}.package

{%- for user in users %}

Prezto is removed for user '{{ user.name }}':
  file.absent:
    - name: {{ user._zprezto.datadir }}
{%- endfor %}
