include:
  - .package
{%- if salt['pillar.get']('tool:zsh') | rejectattr('xdg', 'sameas', False) %}
  - .xdg
{%- endif %}
{%- if salt['pillar.get']('tool:zsh') | selectattr('default') %}
  - .default
{%- endif %}
{%- if salt['pillar.get']('tool:zsh') | selectattr('dotconfig') %}
  - .configsync
{%- endif %}
{%- if salt['pillar.get']('tool:zsh') | selectattr('prezto') %}
  - .prezto
{%- endif %}
