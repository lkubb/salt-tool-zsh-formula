# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as zsh with context %}

include:
  - {{ tplroot }}.package


{#- @FIXME if a user does not have xdg set, this will error #}
{%- if zsh.users | rejectattr('xdg', 'sameas', false) %}

Global zshenv exists:
  file.managed:
    - names:
      - /etc/zshenv:
        - unless:
          - test -d /etc/zsh
      - /etc/zsh/zshenv:
        - onlyif:
          - test -d /etc/zsh
    - replace: false
    - user: root
    - group: {{ zsh.lookup.rootgroup }}
    - mode: '0644'
    - require:
      - pkg: {{ zsh.lookup.pkg.name }}
    - require_in:
      - Zsh setup is completed

Zsh uses XDG_CONFIG_HOME:     # in case /etc/zsh dir does not exist, use /etc/zshenv. cannot do this in jinja because it is evaluated before states are run
  file.blockreplace:          # (including pkg.installed zsh)
    - names:                  # there is a workaround with reactor and event bus https://github.com/saltstack/salt/issues/44778#issuecomment-872077365
      - /etc/zsh/zshenv:      # but that's too complicated atm
        - onlyif:
          - test -d /etc/zsh
      - /etc/zshenv:
        - unless:
          - test -d /etc/zsh
    - content: |
        if [[ -z "${XDG_CONFIG_HOME}" ]]; then
                export XDG_CONFIG_HOME="${HOME}/.config"
        fi

        if [[ -d "${XDG_CONFIG_HOME}/zsh" ]]; then
                export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"
        fi
    - append_if_not_found: true
    - marker_start: '# ----- managed by salt tool_zsh.xdg -----'
    - marker_end:   '# ----- end managed by tool_zsh.xdg -----'
    - require:
      - pkg: {{ zsh.lookup.pkg.name }}
    - require_in:
      - Zsh setup is completed

{%-   for user in zsh.users | rejectattr('xdg', 'sameas', False) %}
{%-     set user_xdg_confdir = user.xdg.config | path_join(zsh.lookup.paths.xdg_dirname) %}
{%-     set config_files = ['.zshrc', '.zshenv', '.zprofile', '.zlogin', '.zlogout'] %}

Zsh has its config dir in XDG_CONFIG_HOME for user '{{ user.name }}':
  file.directory:
    - name: {{ user_xdg_confdir }}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - mode: '0700'
    - require_in:
      - Zsh setup is completed

Existing Zsh configuration is migrated for user '{{ user.name }}':
  file.rename:
    - names:
{%-     for cf in config_files %}
      - {{ user_xdg_confdir | path_join(cf) }}:
        - source: {{ user.home | path_join(cf) }}
{%-     endfor %}
    - require:
      - Zsh has its config dir in XDG_CONFIG_HOME for user '{{ user.name }}'
    - require_in:
      - Zsh setup is completed
{%-   endfor %}
{%- endif %}
