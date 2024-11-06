# vim: ft=sls

{#-
    Manages the Zsh package configuration by

    * recursively syncing from a dotfiles repo

    Has a dependency on `tool_zsh.package`_.
#}

include:
  - .sync
