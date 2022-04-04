# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as zsh with context %}

include:
  - {{ tplroot }}.package


{%- for user in zsh.users | selectattr('zsh.default_shell', 'defined') | selectattr('zsh.default_shell') %}

Zsh is default shell for user '{{ user.name }}':
  cmd.run: # there's user.present with shell option, but I don't want to create one here in case it does not exist
    - name: | # running this as root because chsh asks for the user's password interactively if he calls it himself
        ZSHPATH=$(sudo -u {{ user.name }} echo $((find /usr/local/bin /opt/homebrew/bin /usr/bin /bin -name zsh 2>/dev/null || which zsh) | head -n 1))
        [ -z "$ZSHPATH" ] && exit 1
        chsh -s "$ZSHPATH" "{{ user.name }}"
    - unless:
      - test "$(sudo -u {{ user.name }} echo $SHELL)" -eq \
        "$(sudo -u {{ user.name }} echo $((find /usr/local/bin /opt/homebrew/bin /usr/bin /bin -name zsh 2>/dev/null || which zsh) | head -n 1))"
    - require_in:
      - Zsh setup is completed
{%- endfor %}
