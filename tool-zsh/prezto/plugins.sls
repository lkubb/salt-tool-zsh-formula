include:
  - .package

{%- for user in salt['pillar.get']('tool:zsh', []) | selectattr('prezto') | selectattr('prezto.extplugins') %}
  {%- from 'tool-zsh/prezto/map.jinja' import zpreztodir, extplugins_target with context -%}

  {%- if user.prezto.get('required_packages', False) %}
Packages required for prezto modules specified for user '{{ user.name }}' are installed:
  pkg.installed:
    - pkgs: {{ user.prezto.get('required_packages')  }}
  {%- endif %}

  {%- if user.prezto.get('extplugins_sync_on_startup', False) %}
External zsh plugins are synced on Prezto init for user '{{ user.name }}':
  file.blockreplace:
    - name: {{ zdotdir }}/.zpreztorc
    - source: salt://tool-zsh/prezto/files/external_plugins.zsh
    - template: jinja
    - context:
        extplugins: {{ user.prezto['extplugins'] }}
        extplugins_target: {{ user.prezto.get('extplugins_target', '$ZPREZTODIR/contrib') }}
    - marker_start: '# ----- managed by salt tool.zsh.prezto.plugins -----'
    - marker_end:   '# ----- end managed by tool.zsh.prezto.plugins -----'
    - prepend_if_not_found: True

  {%- elif user.prezto.get('extplugins_as_submodule', False) %}
Git does not ignore contrib folder in zpreztodir for user '{{ user.name }}':
  file.replace:
    - name: {{ zpreztodir }}/.gitignore
    - pattern: '^contrib$'
    - repl: ''

    {%- for plugin in user.prezto.get('extplugins', []) %}
      {%- set plugin_name = plugin.split('/') | last %}
Zsh plugin '{{ plugin }}' is added to prezto as submodule for user '{{ user.name }}':
  cmd.run:
    - name: |
        cd {{ zpreztodir }} && git submodule add {{ https://github.com/{{ plugin }}.git }} contrib/{{ plugin_name }} \
        && git submodule update --init --recursive contrib/{{ plugin_name }}
    - runas: {{ user.name }}
    - unless:
      - test -f {{ zpreztodir }}/contrib/{{ plugin_name }}/init.zsh
      - test -f {{ zpreztodir }}/contrib/{{ plugin_name }}/{{ plugin_name }}.plugin.zsh
    {%- endfor %}

  {%- else %}
    {%- for plugin in user.prezto.get('extplugins', []) %}
      {%- set plugin_name = plugin.split('/') | last %}
Zsh plugin '{{ plugin }}' is cloned to zpreztodir for user '{{ user.name }}':
  # git.cloned: # does not support --recursive -.- prezto modules might have a submodule.
  cmd.run:
    - name: |
        git clone --recursive https://github.com/{{ plugin }}.git {{ zpreztodir }}/contrib/{{ plugin_name }}
    - runas: {{ user.name }}
    - unless:
      - test -f {{ zpreztodir }}/contrib/{{ plugin_name }}/init.zsh
      - test -f {{ zpreztodir }}/contrib/{{ plugin_name }}/{{ plugin_name }}.plugin.zsh
    {%- endfor %}
  {%- endif %}
{%- endfor %}
