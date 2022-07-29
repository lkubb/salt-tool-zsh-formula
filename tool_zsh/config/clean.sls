# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as zsh with context %}


{%- for user in zsh.users %}

Zsh config file is cleaned for user '{{ user.name }}':
  file.absent:
    - name: {{ user['_zsh'].conffile }}

{%-   if user.xdg %}

Zsh config dir is absent for user '{{ user.name }}':
  file.absent:
    - name: {{ user['_zsh'].confdir }}
{%-   endif %}
{%- endfor %}
