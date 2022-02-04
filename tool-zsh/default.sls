{%- from 'tool-zsh/map.jinja' import zsh %}

include:
  - .package

{%- for username in zsh.users | selectattr('zsh.default', 'defined') | selectattr('zsh.default') | map(attribute='name') %}
ZSH is default shell for user '{{ username }}':
  cmd.run: # there's user.present with shell option, but I don't want to create one here in case it does not exist
    - name: | # running this as root because chsh asks for the user's password interactively if he calls it himself
        ZSHPATH=$(sudo -u {{ username }} echo $((find /usr/local/bin /opt/homebrew/bin /usr/bin /bin -name zsh 2>/dev/null || which zsh) | head -n 1))
        [ -z "$ZSHPATH" ] && exit 1
        chsh -s "$ZSHPATH" "{{ username }}"
    - require_in:
      - ZSH setup is completed
{%- endfor %}
