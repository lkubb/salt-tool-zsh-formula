{%- from 'tool-zsh/prezto/map.jinja' import zsh %}

{%- for user in zsh.users | selectattr('zsh.prezto') %}
Prezto is updated to latest commit for user '{{ user.name }}':
  cmd.run:
    - name: |
        cd {{ user._zprezto.datadir }} {% if user._zprezto.branch%}&& git switch {{ user._zprezto.branch }}{% endif %} \
        && git pull && git submodule update --init --recursive
    - runas: {{ user.name }}
    - onlyif:
      - test -s {{ user._zprezto.datadir }}/init.zsh
{%- endfor %}
