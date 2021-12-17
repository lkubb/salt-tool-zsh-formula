include:
  - ..package

{%- for user in salt['pillar.get']('tool:zsh', []) | selectattr('prezto') %}
  {%- from 'tool-zsh/prezto/map.jinja' import zpreztodir, prezto_repo, prezto_branch with context %}
Prezto is cloned for user '{{ user.name }}':
  # git.cloned: # does not support --recursive -.-
  cmd.run:
    - name: |
        git clone --recursive {% if prezto_branch %}--branch {{ prezto_branch}} {% endif %}{{ prezto_repo }} {{ zpreztodir }}
    - runas: {{ user.name }}
    - unless:
      - test -s {{ zpreztodir }}/init.zsh
    - require:
      - ZSH setup is completed
{%- endfor %}
