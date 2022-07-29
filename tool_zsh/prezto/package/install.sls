# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/prezto/map.jinja" import users %}

include:
  - {{ tplroot }}.package

{%- for user in users %}

Prezto is cloned for user '{{ user.name }}':
  # git.cloned: # does not support --recursive -.-
  cmd.run:
    - name: |
        git clone --recursive {% if user._zprezto.branch %}--branch {{ user._zprezto.branch }} {% endif %}{{ user._zprezto.repo }} {{ user._zprezto.datadir }}
    - runas: {{ user.name }}
    - unless:
      - test -s {{ user._zprezto.datadir }}/init.zsh
    - require:
      - Zsh setup is completed
{%- endfor %}
