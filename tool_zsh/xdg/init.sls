# vim: ft=sls

{#-
    Ensures Zsh adheres to the XDG spec
    as best as possible for all managed users.
    Has a dependency on `tool_zsh.package`_.
#}

include:
  - .migrated
