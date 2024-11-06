# vim: ft=sls

{#-
    *Meta-state*.

    Undoes everything performed in the ``tool_zsh`` meta-state
    in reverse order.
#}

include:
  - .prezto.clean
  - .default_shell.clean
  - .config.clean
  - .package.clean
