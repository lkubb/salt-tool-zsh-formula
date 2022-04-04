# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as zsh with context %}


{%- for user in zsh.users | selectattr('config', 'defined') | selectattr('config') %}

Zsh config file is cleaned for user '{{ user.name }}':
  file.absent:
    - name: {{ user['_zsh'].conffile }}
{%- endfor %}
