{%- from 'tool-zsh/prezto/map.jinja' import zsh %}

include:
  - .package

{%- for user in zsh.users | selectattr('zsh.prezto') %}
Prezto is cloned for user '{{ user.name }}':
  # git.cloned: # does not support --recursive -.-
  cmd.run:
    - name: |
        git clone --recursive {% if user._zprezto.branch %}--branch {{ user._zprezto.branch}} {% endif %}{{ user._zprezto.repo }} {{ user._zprezto.datadir }}
    - runas: {{ user.name }}
    - unless:
      - test -s {{ user._zprezto.datadir }}/init.zsh
    - require:
      - ZSH setup is completed
{%- endfor %}
