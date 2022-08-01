# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/prezto/map.jinja" import users %}

include:
  - {{ tplroot }}.package

{%- for user in users %}

Prezto is cloned for user '{{ user.name }}':
  git.latest:
    - name: {{ user._zprezto.repo }}
    - target: {{ user._zprezto.datadir }}
    - rev: {{ user._zprezto.rev or "null" }}
    - submodules: true
    - force_fetch: true
    - force_reset: remote-changes
    - user: {{ user.name }}
    - require:
      - Zsh setup is completed
{%- endfor %}
