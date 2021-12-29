{%- from 'tool-zsh/map.jinja' import zsh %}

include:
  - .package

{%- if zsh.users | rejectattr('xdg', 'sameas', False) %}
ZSH uses XDG_CONFIG_HOME:     # in case /etc/zsh dir does not exist, use /etc/zshenv. cannot do this in jinja because it is evaluated before states are run
  file.blockreplace:          # (including pkg.installed zsh)
    - names:                  # there is a workaround with reactor and event bus https://github.com/saltstack/salt/issues/44778#issuecomment-872077365
      - /etc/zsh/zshenv:      # but that's too complicated atm
        - onlyif:
          - test -d /etc/zsh
      - /etc/zshenv:
        - unless:
          - test -d /etc/zsh
    - content: |
        if [[ -z "${XDG_CONFIG_HOME}" ]]; then
                export XDG_CONFIG_HOME="${HOME}/.config"
        fi

        if [[ -d "${XDG_CONFIG_HOME}/zsh" ]]; then
                export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"
        fi
    - append_if_not_found: True
    - marker_start: '# ----- managed by salt tool-zsh.xdg -----'
    - marker_end:   '# ----- end managed by tool-zsh.xdg -----'
    - require:
      - pkg: zsh
    - prereq_in:
      - ZSH setup is completed

  {%- for user in zsh.users | rejectattr('xdg', 'sameas', False) %}
Existing ZSH configuration is migrated for user '{{ user.name }}':
  file.rename:
    - names:
      - {{ user.xdg.config }}/zsh/.zshrc:
        - source: {{ user.home }}/.zshrc
        - onlyif:
          - test -e {{ user.home }}/.zshrc
      - {{ user.xdg.config }}/zsh/.zshenv:
        - source: {{ user.home }}/.zshenv
        - onlyif:
          - test -e {{ user.home }}/.zshenv
      - {{ user.xdg.config }}/zsh/.zprofile:
        - source: {{ user.home }}/.zprofile
        - onlyif:
          - test -e {{ user.home }}/.zprofile
      - {{ user.xdg.config }}/zsh/.zlogin:
        - source: {{ user.home }}/.zlogin
        - onlyif:
          - test -e {{ user.home }}/.zlogin
      - {{ user.xdg.config }}/zsh/.zlogout:
        - source: {{ user.home }}/.zlogout
        - onlyif:
          - test -e {{ user.home }}/.zlogout
    - makedirs: true
    - prereq_in:
      - ZSH setup is completed

ZSH has its own directory in XDG_CONFIG_HOME for user '{{ user.name }}':
  file.directory:
    - name: {{ user.xdg.config }}/zsh
    - user: {{ user.name }}
    - group: {{ user.group }}
    - mode: '0700'
    - prereq_in:
      - ZSH setup is completed

    {%- if user.zsh.get('gitignore', False) %}
Git ignores unnecessary files in ZSH's XDG_CONFIG_HOME for user '{{ user.name }}':
  file.managed:
    - name: {{ user.xdg.config }}/zsh/.gitignore
    - contents: |
        .zsh_history
        .zsh_history_ext
        .zsh_sessions
    - mode: '0644'
    - user: {{ user.name }}
    {%- endif %}
  {%- endfor %}
{%- endif %}
