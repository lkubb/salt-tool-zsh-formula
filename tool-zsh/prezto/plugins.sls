{%- from 'tool-zsh/prezto/map.jinja' import zsh %}

include:
  - .package

{%- for user in zsh.users | selectattr('zsh.prezto', 'defined') | rejectattr('zsh.prezto', 'sameas', False) | selectattr('zsh.prezto.extplugins', 'defined') %}
  {%- if user.zsh.prezto.get('required_packages', False) %}
Packages required for prezto modules specified for user '{{ user.name }}' are installed:
  pkg.installed:
    - pkgs: {{ user.zsh.prezto.get('required_packages') | json  }}
  {%- endif %}

  {%- if user.zsh.prezto.get('extplugins_sync_on_startup', False) %}
External zsh plugins are synced on Prezto init for user '{{ user.name }}':
  file.blockreplace:
    - name: {{ user._zsh.confdir }}/.zpreztorc
    - source: salt://tool-zsh/prezto/files/external_plugins.zsh
    - template: jinja
    - context:
        extplugins: {{ user.zsh.prezto.extplugins }}
        extplugins_target: {{ user._zprezto.extplugins_target }}
    - marker_start: '# ----- managed by salt tool-zsh.prezto.plugins -----'
    - marker_end:   '# ----- end managed by tool-zsh.prezto.plugins -----'
    - prepend_if_not_found: True

  {%- elif user.zsh.prezto.get('extplugins_as_submodule', False) %}
Git does not ignore contrib folder in zpreztodir for user '{{ user.name }}':
  file.replace:
    - name: {{ user._zprezto.datadir }}/.gitignore
    - pattern: '^contrib$'
    - repl: ''

    {%- for plugin in user.zsh.prezto.get('extplugins', []) %}
      {%- set plugin_name = plugin.split('/') | last %}
Zsh plugin '{{ plugin }}' is added to prezto as submodule for user '{{ user.name }}':
  cmd.run:
    - name: |
        cd {{ user._zprezto.datadir }} && git submodule add {{ https://github.com/{{ plugin }}.git }} contrib/{{ plugin_name }} \
        && git submodule update --init --recursive contrib/{{ plugin_name }}
    - runas: {{ user.name }}
    - unless:
      - test -f {{ user._zprezto.datadir }}/contrib/{{ plugin_name }}/init.zsh
      - test -f {{ user._zprezto.datadir }}/contrib/{{ plugin_name }}/{{ plugin_name }}.plugin.zsh
    {%- endfor %}

  {%- else %}
    {%- for plugin in user.zsh.prezto.get('extplugins', []) %}
      {%- set plugin_name = plugin.split('/') | last %}
Zsh plugin '{{ plugin }}' is cloned to zpreztodir for user '{{ user.name }}':
  # git.cloned: # does not support --recursive -.- prezto modules might have a submodule.
  cmd.run:
    - name: |
        git clone --recursive https://github.com/{{ plugin }}.git {{ user._zprezto.datadir }}/contrib/{{ plugin_name }}
    - runas: {{ user.name }}
    - unless:
      - test -f {{ user._zprezto.datadir }}/contrib/{{ plugin_name }}/init.zsh
      - test -f {{ user._zprezto.datadir }}/contrib/{{ plugin_name }}/{{ plugin_name }}.plugin.zsh
    {%- endfor %}
  {%- endif %}
{%- endfor %}
