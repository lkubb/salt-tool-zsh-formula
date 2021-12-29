{%- from 'tool-zsh/prezto/map.jinja' import zsh %}

include:
  - .package

{%- for user in zsh.users | selectattr('zsh.prezto') %}
Prezto zdotfiles/runcoms are copied for user '{{ user.name }}' if he has no custom file:
  file.copy:
    - names:
      - {{ user._zsh.confdir }}/.zshenv:
        - source: {{ user._zprezto.datadir }}/runcoms/zshenv
      - {{ user._zsh.confdir }}/.zprofile:
        - source: {{ user._zprezto.datadir }}/runcoms/zprofile
      - {{ user._zsh.confdir }}/.zlogin:
        - source: {{ user._zprezto.datadir }}/runcoms/zlogin
      - {{ user._zsh.confdir }}/.zlogout:
        - source: {{ user._zprezto.datadir }}/runcoms/zlogout
      - {{ user._zsh.confdir }}/.zpreztorc:
        - source: {{ user._zprezto.datadir }}/runcoms/zpreztorc
    - user: {{ user.name }}
    - group: {{ user.group }}
    - mode: '0600'
    - require:
      - Prezto is cloned for user '{{ user.name }}'

Prezto zshrc is copied for user '{{ user.name }}' if he has no custom one (special cased because of salt requisite weirdness):
  file.copy:
    - name: {{ user._zsh.confdir }}/.zshrc
    - source: {{ user._zprezto.datadir }}/runcoms/zshrc
    - user: {{ user.name }}
    - group: {{ user.group }}
    - mode: '0600'
    - require:
      - Prezto is cloned for user '{{ user.name }}'

# this only works for default zpreztorc ofc
Prezto is sourced from the correct directory for user '{{ user.name }}':
  file.replace:
    - name: {{ user._zsh.confdir }}/.zshrc
    - pattern: '{{ "${ZDOTDIR:-$HOME}/.zprezto" | regex_escape }}'
    - repl: '{{ user._zprezto.datadir }}'
    - backup: False
    - onchanges:
      - Prezto zshrc is copied for user '{{ user.name }}' if he has no custom one (special cased because of salt requisite weirdness)

Prezto contrib folder exists for user '{{ user.name }}':
  file.directory:
    - name: {{ user._zprezto.datadir }}/contrib
    - user: {{ user.name }}
    - group: {{ user.group }}
    - require:
      - Prezto is cloned for user '{{ user.name }}'

  {%- if user.prezto.get('user_plugin_dirs', []) %}
# this only works for default zpreztorc ofc
Prezto looks for plugins in additional user-defined paths for user '{{ user.name }}:
  file.replace:
    - name: {{ user._zsh.confdir }}/.zpreztorc
    - pattern: >-
        {{ "# zstyle ':prezto:load' pmodule-dirs $HOME/.zprezto-contrib" | regex_escape }}
    - repl: "zstyle ':prezto:load' pmodule-dirs{% for d in user.prezto['user_plugin_dirs'] %} {{ d }}{% endfor %}"
  {%- endif %}
{%- endfor %}
