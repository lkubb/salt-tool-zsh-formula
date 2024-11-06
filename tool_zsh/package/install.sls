# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as zsh with context %}


Zsh is installed:
  pkg.installed:
    - name: {{ zsh.lookup.pkg.name }}
    - version: {{ zsh.get("version") or "latest" }}
    {#- do not specify alternative return value to be able to unset default version #}

Zsh is registered in /etc/shells: # chsh does not allow a user (besides root) to change to non-standard shells
  cmd.run: # workaround for jinja being evaluated before salt states (zsh might not be available then)
    - name: |
        ZSHPATH="$((find /usr/local/bin /opt/homebrew/bin /usr/bin /bin -name zsh 2>/dev/null || which zsh) | head -n 1)"
        [ -z "$ZSHPATH" ] && exit 1
        [ $(grep "$ZSHPATH" /etc/shells) ] && exit 0
        echo "$ZSHPATH" >> /etc/shells
    - unless:
      # chaining is necessary apparently, exit 1 should not fail, so it's fine ;)
      - ZSHPATH="$((find /usr/local/bin /opt/homebrew/bin /usr/bin /bin -name zsh 2>/dev/null || which zsh) | head -n 1)" \
        [ -z "$ZSHPATH" ] && exit 1 \
        || grep "$ZSHPATH" /etc/shells
    - require:
      - pkg: {{ zsh.lookup.pkg.name }}

Zsh setup is completed:
  test.nop:
    - name: Hooray, Zsh setup has finished.
    - require:
      - pkg: {{ zsh.lookup.pkg.name }}
      - Zsh is registered in /etc/shells
