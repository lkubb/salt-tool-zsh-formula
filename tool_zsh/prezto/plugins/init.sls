# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/prezto/map.jinja" import users %}

include:
  - {{ tplroot }}.prezto.package

{%- for user in users | selectattr('zsh.prezto.extplugins', 'defined') %}
{%-   if user.zsh.prezto.get('required_packages', false) %}

Packages required for prezto modules specified for user '{{ user.name }}' are installed:
  pkg.installed:
    - pkgs: {{ user.zsh.prezto.required_packages | json }}
{%-   endif %}

{%-   if user.zsh.prezto.get('extplugins_sync_on_startup', false) %}

External Zsh plugins are synced on Prezto init for user '{{ user.name }}':
  file.blockreplace:
    - name: {{ user._zsh.confdir | path_join('.zpreztorc') }}
    - source: salt://tool_zsh/prezto/files/external_plugins.zsh
    - template: jinja
    - context:
        extplugins: {{ user.zsh.prezto.extplugins }}
        extplugins_target: {{ user._zprezto.extplugins_target }}
    - marker_start: '# ----- managed by salt tool-zsh.prezto.plugins -----'
    - marker_end:   '# ----- end managed by tool-zsh.prezto.plugins -----'
    - prepend_if_not_found: true

  {%- elif user.zsh.prezto.get('extplugins_as_submodule', false) %}

Git does not ignore contrib folder in zpreztodir for user '{{ user.name }}':
  file.replace:
    - name: {{ user._zprezto.datadir | path_join('.gitignore') }}
    - pattern: '^contrib$'
    - repl: ''

    {%- for plugin in user.zsh.prezto.get('extplugins', []) %}
      {%- set plugin_name = plugin.split('/') | last %}

Zsh plugin '{{ plugin }}' is added to Prezto as submodule for user '{{ user.name }}':
  cmd.run:
    - name: |
        cd {{ user._zprezto.datadir }} && git submodule add https://github.com/{{ plugin }}.git {{ 'contrib' | path_join(plugin_name) }} \
        && git submodule update --init --recursive {{ 'contrib' | path_join(plugin_name) }}
    - runas: {{ user.name }}
    - unless:
      - test -f {{ user._zprezto.datadir | path_join('contrib', plugin_name, 'init.zsh') }}
      - test -f {{ user._zprezto.datadir | path_join('contrib', plugin_name, plugin_name ~ '.plugin.zsh') }}
    {%- endfor %}

  {%- else %}
    {%- for plugin in user.zsh.prezto.get('extplugins', []) %}
      {%- set plugin_name = plugin.split('/') | last %}

Zsh plugin '{{ plugin }}' is cloned to zpreztodir for user '{{ user.name }}':
  # git.cloned: # does not support --recursive -.- prezto modules might have a submodule.
  cmd.run:
    - name: |
        git clone --recursive https://github.com/{{ plugin }}.git {{ user._zprezto.datadir | path_join('contrib', plugin_name) }}
    - runas: {{ user.name }}
    - unless:
      - test -f {{ user._zprezto.datadir | path_join('contrib', plugin_name, 'init.zsh') }}
      - test -f {{ user._zprezto.datadir | path_join('contrib', plugin_name, plugin_name ~ '.plugin.zsh') }}
    {%- endfor %}
  {%- endif %}
{%- endfor %}
