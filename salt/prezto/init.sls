include:
  - ..zsh

{%- for user in salt['pillar.get']('tool:zsh', [{'username': user, 'prezto': True}]) | rejectattr('prezto', 'equalto', False) -%}
{# @TODO not sure if this will run the first time or fail (likely) since zsh was just installed, probably only after jinja evaluation #}
  {%- set zdotdir = salt['cmd.run']('echo ${ZDOTDIR:-$HOME}', runas=user.username, shell='/bin/zsh') -%}
tool-zsh-prezto-cloned-for-{{ user.username }}:
  git.cloned:
    - name: https://github.com/sorin-ionescu/prezto.git
    - user: {{ user.username }}
    - target: {{ zdotdir }}/.zprezto
    - require:
      - sls: ..zsh

tool-zsh-prezto-zdotfiles-linked-for-{{ user.username }}:
  file.symlink:
    - names:
      - {{ zdotdir }}/.zshrc:
        - target: {{ zdotdir }}/.zprezto/.zshrc
      - {{ zdotdir }}/.zshenv:
        - target: {{ zdotdir }}/.zprezto/.zshenv
      - {{ zdotdir }}/.zprofile:
        - target: {{ zdotdir }}/.zprezto/.zprofile
      - {{ zdotdir }}/.zlogin:
        - target: {{ zdotdir }}/.zprezto/.zlogin
      - {{ zdotdir }}/.zlogout:
        - target: {{ zdotdir }}/.zprezto/.zlogout
      - {{ zdotdir }}/.zpreztorc:
        - target: {{ zdotdir }}/.zprezto/.zpreztorc
    - user: {{ user.username }}
    - group: {{ user.username }}
    - require:
      - tool-zsh-prezto-cloned
{%- endfor %}
