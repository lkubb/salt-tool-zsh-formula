{%- from 'tool-zsh/prezto/map.jinja' import users %}
include:
  - .package
{%- if users | selectattr('dotconfig', 'defined') | selectattr('dotconfig') %}
  - .configsync
{%- endif %}
  - .config
  - .plugins
