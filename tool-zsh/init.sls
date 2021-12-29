{%- from 'tool-zsh/map.jinja' import zsh %}

include:
  - .package
{%- if zsh.users | rejectattr('xdg', 'sameas', False) %}
  - .xdg
{%- endif %}
{%- if zsh.users | selectattr('zsh.default') %}
  - .default
{%- endif %}
{%- if zsh.users | selectattr('dotconfig') %}
  - .configsync
{%- endif %}
{%- if zsh.users | selectattr('zsh.prezto') %}
  - .prezto
{%- endif %}
