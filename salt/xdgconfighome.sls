include:
  - ..zsh

tool-zsh-uses-xdg-config-dir:
  file.blockreplace:
    - name: /etc/zsh/zshenv
    - makedirs: true
    - content: |
        if [[ -z "${XDG_CONFIG_HOME}" ]]
        then
                export XDG_CONFIG_HOME="${HOME}/.config"
        fi

        if [[ -d "${XDG_CONFIG_HOME}/zsh" ]]
        then
                export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"
        fi
    - require:
      - pkg: zsh
    - prereq_in:
      - tool-zsh-setup-completely-finished

{%- for username in salt['pillar.get']('tool:zsh', [{'username': 'user' }]) | rejectattr('xdgconfig', 'sameas', false) | map(attribute='username') %}
  {%- set confdir = salt['cmd.run']('if [ ! -z "$XDG_CONFIG_HOME" ]; then echo "${XDG_CONFIG_HOME}"; else echo "${HOME}/.config"; fi', runas=username) -%}
  {%- set home = salt['user.info'](username).home -%}

tool-zsh-existing-config-migrated-to-xdg-for-{{ username }}:
  file.rename:
    - names:
      - {{ confdir }}/zsh/.zshrc:
        - source: {{ home }}/.zshrc
        - onlyif:
          - test -e {{ home }}/.zshrc
      - {{ confdir }}/zsh/.zshenv:
        - source: {{ home }}/.zshenv
        - onlyif:
          - test -e {{ home }}/.zshenv
      - {{ confdir }}/zsh/.zprofile:
        - source: {{ home }}/.zprofile
        - onlyif:
          - test -e {{ home }}/.zprofile
      - {{ confdir }}/zsh/.zlogin:
        - source: {{ home }}/.zlogin
        - onlyif:
          - test -e {{ home }}/.zlogin
      - {{ confdir }}/zsh/.zlogout:
        - source: {{ home }}/.zlogout
        - onlyif:
          - test -e {{ home }}/.zlogout
    - makedirs: true
    - prereq_in:
      - tool-zsh-setup-completely-finished

tool-zsh-xdg-dir-exists-for-{{ username }}:
  file.directory:
    - name: {{ confdir }}/zsh
    - user: {{ username }}
    - group: {{ username }}
    - mode: '0700'
    - prereq_in:
      - tool-zsh-setup-completely-finished
{%- endfor %}
