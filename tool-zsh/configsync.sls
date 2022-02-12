{%- from 'tool-zsh/map.jinja' import zsh %}

{%- for user in zsh.users | selectattr('dotconfig', 'defined') | selectattr('dotconfig') %}
  {%- set dotconfig = user.dotconfig if dotconfig is mapping else {} %}

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
  {%- if dotconfig.get('file_mode') %}
    - file_mode: '{{ dotconfig.file_mode }}'
  {%- endif %}
    - dir_mode: '{{ dotconfig.get('dir_mode', '0700') }}'
    - clean: {{ dotconfig.get('clean', False) | to_bool }}
    - makedirs: True
{%- endfor %}
