# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/prezto/map.jinja" import users %}


{%- for user in users %}

Prezto zdotfiles/runcoms are (re)moved (to .saltbak) for user '{{ user.name }}':
  file.rename:
    - names:
{%-   for cf in [".zshrc", ".zshenv", ".zprofile", ".zlogin", ".zlogout", ".zpreztorc"] %}
      - {{ user._zsh.confdir | path_join(cf ~ ".saltbak") }}:
        - source: {{ user._zprezto.datadir | path_join("runcoms", cf[1:]) }}
{%-   endfor %}
    - force: true
{%- endfor %}
