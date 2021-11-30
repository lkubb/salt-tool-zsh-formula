tool-zsh-required-packages-installed:
  pkg.installed:
    - name: zsh

tool-zsh-setup-completely-finished:
  test.nop:
    - name: zsh setup has finished, this state exists for technical reasons
    - require:
      - pkg: zsh
