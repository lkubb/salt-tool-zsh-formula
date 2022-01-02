{%- from 'tool-zsh/prezto/map.jinja' import users %}

include:
  - ..package

{%- for user in users %}
Prezto is cloned for user '{{ user.name }}':
  # git.cloned: # does not support --recursive -.-
  cmd.run:
    - name: |
        git clone --recursive {% if user._zprezto.branch %}--branch {{ user._zprezto.branch }} {% endif %}{{ user._zprezto.repo }} {{ user._zprezto.datadir }}
    - runas: {{ user.name }}
    - unless:
      - test -s {{ user._zprezto.datadir }}/init.zsh
    - require:
      - ZSH setup is completed
{%- endfor %}
