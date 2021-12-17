ZSH is installed:
  pkg.installed:
    - name: zsh

ZSH is registered in /etc/shells: # chsh does not allow a user (besides root) to change to non-standard shells
  cmd.run: # workaround for jinja being evaluated before salt states (zsh might not be available then)
    - name: |
        ZSHPATH=$((find /usr/local/bin /opt/homebrew/bin /usr/bin /bin -name zsh 2>/dev/null || which zsh) | head -n 1)
        [ -z "$ZSHPATH" ] && exit 1
        [ $(grep "$ZSHPATH" /etc/shells) ] && exit 0
        echo "$ZSHPATH" >> /etc/shells
    - require:
      - pkg: zsh

ZSH setup is completed:
  test.nop:
    - name: ZSH setup has finished, this state exists for technical reasons.
    - require:
      - pkg: zsh
      - ZSH is registered in /etc/shells
