{%- for user in salt['pillar.get']('tool:zsh', salt['pillar.get']('tool:users', [])) | selectattr('dotconfig') %}
  {%- from 'tool-zsh/map.jinja' import user, zdotdir with context %}
zsh configuration is synced to ZDOTDIR for user '{{ user.name }}':
  file.recurse:
    - name: {{ zdotdir }}
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
