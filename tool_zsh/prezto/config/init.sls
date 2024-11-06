# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/prezto/map.jinja" import users %}

include:
  - {{ tplroot }}.prezto.package

{%- for user in users %}

Prezto zdotfiles/runcoms are copied for user '{{ user.name }}' if he has no custom file:
  file.copy:
    - names:
{%-   for cf in [".zshenv", ".zprofile", ".zlogin", ".zlogout", ".zpreztorc"] %}
      - {{ user._zsh.confdir | path_join(cf) }}:
        - source: {{ user._zprezto.datadir | path_join("runcoms", cf[1:]) }}
{%-   endfor %}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - mode: '0600'
    - require:
      - Prezto is cloned for user '{{ user.name }}'

Prezto zshrc is copied for user '{{ user.name }}' if he has no custom one (special cased because of salt requisite weirdness):
  file.copy:
    - name: {{ user._zsh.confdir | path_join(".zshrc") }}
    - source: {{ user._zprezto.datadir | path_join("runcoms", "zshrc") }}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - mode: '0600'
    - require:
      - Prezto is cloned for user '{{ user.name }}'

# this only works for default zpreztorc ofc
Prezto is sourced from the correct directory for user '{{ user.name }}':
  file.replace:
    - name: {{ user._zsh.confdir | path_join(".zshrc") }}
    - pattern: '{{ "${ZDOTDIR:-$HOME}/.zprezto" | regex_escape }}'
    - repl: '{{ user._zprezto.datadir }}'
    - backup: false
    - onchanges:
      - Prezto zshrc is copied for user '{{ user.name }}' if he has no custom one (special cased because of salt requisite weirdness)

Prezto contrib folder exists for user '{{ user.name }}':
  file.directory:
    - name: {{ user._zprezto.datadir }}/contrib
    - user: {{ user.name }}
    - group: {{ user.group }}
    - mode: '0700'
    - require:
      - Prezto is cloned for user '{{ user.name }}'

{%-   if user.zsh.prezto.get("user_plugin_dirs", []) %}

# this only works for default zpreztorc ofc
Prezto looks for plugins in additional user-defined paths for user '{{ user.name }}:
  file.replace:
    - name: {{ user._zsh.confdir }}/.zpreztorc
    - pattern: >-
        {{ "# zstyle ':prezto:load' pmodule-dirs $HOME/.zprezto-contrib" | regex_escape }}
    - repl: "zstyle ':prezto:load' pmodule-dirs{% for d in user.prezto["user_plugin_dirs"] %} {{ d }}{% endfor %}"
{%-   endif %}
{%- endfor %}
