# vim: ft=sls

{#-
    *Meta-state*.

    Performs all operations described in this formula according to the specified configuration.
#}

include:
  - .package
  - .xdg
  - .default_shell
  - .config
  - .prezto
