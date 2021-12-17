include:
  - .package

{%- for user in salt['pillar.get']('tool:zsh', []) | selectattr('prezto') %}
  {%- from 'tool/zsh/map.jinja' import user with context %}
  {%- from 'tool/zsh/prezto/map.jinja' import zdotdir, zpreztodir, extplugins_target with context %}
Prezto zdotfiles/runcoms are copied for user '{{ user.name }}' if he has no custom file:
  file.copy:
    - names:
      - {{ zdotdir }}/.zshenv:
        - source: {{ zpreztodir }}/runcoms/zshenv
      - {{ zdotdir }}/.zprofile:
        - source: {{ zpreztodir }}/runcoms/zprofile
      - {{ zdotdir }}/.zlogin:
        - source: {{ zpreztodir }}/runcoms/zlogin
      - {{ zdotdir }}/.zlogout:
        - source: {{ zpreztodir }}/runcoms/zlogout
      - {{ zdotdir }}/.zpreztorc:
        - source: {{ zpreztodir }}/runcoms/zpreztorc
    - user: {{ user.name }}
    - group: {{ user.group }}
    - mode: '0600'
    - require:
      - Prezto is cloned for user '{{ user.name }}'

Prezto zshrc is copied for user '{{ user.name }}' if he has no custom one (special cased because of salt requisite weirdness):
  file.copy:
    - name: {{ zdotdir }}/.zshrc
    - source: {{ zpreztodir }}/runcoms/zshrc
    - user: {{ user.name }}
    - group: {{ user.group }}
    - mode: '0600'
    - require:
      - Prezto is cloned for user '{{ user.name }}'

# this only works for default zpreztorc ofc
Prezto is sourced from the correct directory for user '{{ user.name }}':
  file.replace:
    - name: {{ zdotdir }}/.zshrc
    - pattern: '{{ "${ZDOTDIR:-$HOME}/.zprezto" | regex_escape }}'
    - repl: '{{ zpreztodir }}'
    - backup: False
    - onchanges:
      - Prezto zshrc is copied for user '{{ user.name }}' if he has no custom one (special cased because of salt requisite weirdness)

Prezto contrib folder exists for user '{{ user.name }}':
  file.directory:
    - name: {{ zpreztodir }}/contrib
    - user: {{ user.name }}
    - group: {{ user.group }}
    - require:
      - Prezto is cloned for user '{{ user.name }}'

  {%- if user.prezto.get('user_plugin_dirs', []) %}
# this only works for default zpreztorc ofc
Prezto looks for plugins in additional user-defined paths for user '{{ user.name }}:
  file.replace:
    - name: {{ zdotdir }}/.zpreztorc
    - pattern: >-
        {{ "# zstyle ':prezto:load' pmodule-dirs $HOME/.zprezto-contrib" | regex_escape }}
    - repl: "zstyle ':prezto:load' pmodule-dirs{% for d in user.prezto['user_plugin_dirs'] %} {{ d }}{% endfor %}"
  {%- endif %}
{%- endfor %}
