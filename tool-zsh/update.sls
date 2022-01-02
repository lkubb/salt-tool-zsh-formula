{%- from 'tool-zsh/map.jinja' import zsh -%}

{%- set dotconfig = zsh.users | selectattr('dotconfig', 'defined') | selectattr('dotconfig') -%}
{%- set prezto = zsh.users | selectattr('zsh.prezto', 'defined') | rejectattr('zsh.prezto', 'sameas', False) -%}

{%- if dotconfig or prezto %}
include:
  {%- if dotconfig %}
  - .prezto.update
  {%- endif %}
  {%- if dotconfig %}
  - .configsync
  {%- endif %}
{%- endif %}

ZSH is updated to latest package:
{%- if grains['kernel'] == 'Darwin' %}
  pkg.installed: # assumes homebrew as package manager. homebrew always installs the latest version, mac_brew_pkg does not support upgrading a single package
{%- else %}
  pkg.latest:
{%- endif %}
    - name: zsh
