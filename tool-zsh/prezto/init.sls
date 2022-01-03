{%- from 'tool-zsh/prezto/map.jinja' import users %}
include:
  - .package
  - .config
{%- if users | selectattr('zsh.prezto.extplugins', 'defined') %}
  - .plugins
{%- endif %}
