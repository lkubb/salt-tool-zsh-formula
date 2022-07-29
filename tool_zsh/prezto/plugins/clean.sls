# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/prezto/map.jinja" import users %}


{%- for user in users | selectattr('zsh.prezto.extplugins', 'defined') %}

{%-   if user.zsh.prezto.get('extplugins_sync_on_startup', false) %}

External Zsh plugins are not synced on Prezto init for user '{{ user.name }}':
  file.blockreplace:
    - name: {{ user._zsh.confdir | path_join('.zpreztorc') }}
    - content: ''
    - marker_start: '# ----- managed by salt tool-zsh.prezto.plugins -----'
    - marker_end:   '# ----- end managed by tool-zsh.prezto.plugins -----'

  {%- elif user.zsh.prezto.get('extplugins_as_submodule', false) %}

Git ignores contrib folder in zpreztodir for user '{{ user.name }}':
  file.append:
    - name: {{ user._zprezto.datadir | path_join('.gitignore') }}
    - text: contrib

    {%- for plugin in user.zsh.prezto.get('extplugins', []) %}
      {%- set plugin_name = plugin.split('/') | last %}

Zsh plugin '{{ plugin }}' is removed from Prezto as submodule for user '{{ user.name }}':
  cmd.run:
    - name: |
        cd {{ user._zprezto.datadir }} && git submodule deinit {{ 'contrib' | path_join(plugin_name) }} \
        && git rm -rf {{ 'contrib' | path_join(plugin_name) }}
    - runas: {{ user.name }}
    - onlyif:
      - test -f {{ user._zprezto.datadir | path_join('contrib', plugin_name, 'init.zsh') }}
      - test -f {{ user._zprezto.datadir | path_join('contrib', plugin_name, plugin_name ~ '.plugin.zsh') }}
    {%- endfor %}

  {%- else %}
    {%- for plugin in user.zsh.prezto.get('extplugins', []) %}
      {%- set plugin_name = plugin.split('/') | last %}

Zsh plugin '{{ plugin }}' is removed from zpreztodir for user '{{ user.name }}':
  # git.cloned: # does not support --recursive -.- prezto modules might have a submodule.
  file.absent:
    - name: {{ user._zprezto.datadir | path_join('contrib', plugin_name) }}
    {%- endfor %}
  {%- endif %}
{%- endfor %}
