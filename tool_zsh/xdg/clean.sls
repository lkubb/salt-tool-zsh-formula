# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as zsh with context %}


{#- @FIXME if a user does not have xdg set, this will error #}
{%- if zsh.users | rejectattr('xdg', 'sameas', false) %}

Zsh is ignorant about XDG_CONFIG_HOME:
  file.blockreplace:
    - names:
      - /etc/zsh/zshenv:
        - onlyif:
          - test -d /etc/zsh
      - /etc/zshenv:
        - unless:
          - test -d /etc/zsh
    - content: ''
    - marker_start: '# ----- managed by salt tool_zsh.xdg -----'
    - marker_end:   '# ----- end managed by tool_zsh.xdg -----'

{%-   for user in zsh.users | rejectattr('xdg', 'sameas', False) %}
{%-     set user_xdg_confdir = user.xdg.config | path_join(zsh.lookup.paths.xdg_dirname) %}
{%-     set config_files = ['.zshrc', '.zshenv', '.zprofile', '.zlogin', '.zlogout', '.zpreztorc'] %}

Zsh configuration is cluttering $HOME for user '{{ user.name }}':
  file.rename:
    - names:
{%-     for cf in config_files %}
      - {{ user.home | path_join(cf) }}:
        - source: {{ user_xdg_confdir | path_join(cf) }}
{%-     endfor %}

Zsh does not have its config folder in XDG_CONFIG_HOME for user '{{ user.name }}':
  file.absent:
    - name: {{ user_xdg_confdir }}
    - require:
      - Zsh configuration is cluttering $HOME for user '{{ user.name }}'

{%-   endfor %}
{%- endif %}
