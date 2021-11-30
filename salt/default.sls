include:
  - ..zsh

{%- for username in salt['pillar.get']('tool:zsh', [{'username': 'user', 'default': True }]) | selectattr('default') | map(attribute='username') %}
zsh-is-default-shell:
  cmd.run: # there's user.present with shell option, but I don't want to create one here in case it does not exist
    - name: chsh -s /bin/zsh
    - runas: {{ username }}
    - prereq_in:
      - tool-zsh-setup-completely-finished
{%- endfor %}
