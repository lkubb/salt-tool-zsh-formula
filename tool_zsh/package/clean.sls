# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as zsh with context %}

include:
  - {{ sls_config_clean }}


# this is a bad idea since this is not idempotent:
# eg on MacOS, there would be two zsh binaries
# this would need knowledge about where on the system zsh
# is installed (in zsh.lookup)
# Zsh is unregistered in /etc/shells:
#   file.replace:
#     - name: /etc/shells
#     - pattern: {{ salt['cmd.stdout']('which zsh') or '.*zsh.*' }}
#     - repl: ''

Zsh is removed:
  pkg.removed:
    - name: {{ zsh.lookup.pkg.name }}
    - require:
      - sls: {{ sls_config_clean }}
