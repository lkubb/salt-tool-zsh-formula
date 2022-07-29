# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/prezto/map.jinja" import users %}


{%- for user in users %}

Prezto is updated to latest commit for user '{{ user.name }}':
  cmd.run:
    - name: |
        cd {{ user._zprezto.datadir }} {% if user._zprezto.branch %}&& git switch {{ user._zprezto.branch }}{% endif %} \
        && git pull --rebase && git submodule update --init --recursive
    - runas: {{ user.name }}
    - onlyif:
      - test -s {{ user._zprezto.datadir | path_join('init.zsh') }}
{%- endfor %}
