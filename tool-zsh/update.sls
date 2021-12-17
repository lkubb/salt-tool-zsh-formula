include:
  - .prezto.update
{%- if salt['pillar.get']('tool:zsh') | selectattr('dotconfig') %}
  - .configsync
{%- endif %}

ZSH is updated to latest package:
{%- if grains['kernel'] == 'Darwin' %}
  pkg.installed: # assumes homebrew as package manager. homebrew always installs the latest version, mac_brew_pkg does not support upgrading a single package
{%- else %}
  pkg.latest:
{%- endif %}
    - name: zsh
