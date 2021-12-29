{%- from 'tool-zsh/map.jinja' import zsh %}

{%- for user in zsh.users | selectattr('dotconfig') %}
zsh configuration is synced to ZDOTDIR for user '{{ user.name }}':
  file.recurse:
    - name: {{ user._zsh.confdir }}
    - source:
      - salt://dotconfig/{{ user.name }}/zsh
      - salt://dotconfig/zsh
    - context:
        user: {{ user }}
    - template: jinja
    - user: {{ user.name }}
    - group: {{ user.group }}
    - file_mode: keep
    - dir_mode: '0700'
{%- endfor %}
