{%- for user in salt['pillar.get']('tool:zsh', []) | selectattr('prezto') %}
  {%- from 'tool-zsh/prezto/map.jinja' import zpreztodir, prezto_branch with context %}
Prezto is updated to latest commit for user '{{ user.name }}':
  cmd.run:
    - name: |
        cd {{ zpreztodir }} {% if prezto_branch%}&& git switch {{ prezto_branch }}{% endif %} \
        && git pull && git submodule update --init --recursive
    - runas: {{ user.name }}
    - onlyif:
      - test -s {{ zpreztodir }}/init.zsh
{%- endfor %}
