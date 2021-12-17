# `zsh` Formula
Sets up, configures and updates `zsh`, and optionally Prezto framework. It's possible to reference your own fork of Prezto.

## Usage
Applying `tool.zsh` will make sure zsh (and possibly Prezto) will work as specified. Existing configuration will not be replaced. If you want to make sure everything is up to date, run `tool.zsh.update`. This will pull the specified Prezto repo, possibly update its submodules to the specified commits, sync dotconfig and install the latest `zsh`.

## Configuration
### Pillar
This module is namespaced to `tool:zsh` and expects a list of user configurations. `name` is the only required parameter (this formula assumes salt is running as root).
```yaml
- name: user
  default: false      # set zsh as default shell for this user. defaults to false
  xdg: true           # set up ZDOTDIR in XDG_CONF_HOME. mind that currently, ZDOTDIR will be set globally,
                      # excluded users will have broken config.
  dotconfig: false    # if you want to sync this user's zsh config from a dotfiles repo available as salt://dotconfig/<user>/zsh or salt://dotconfig/zsh
  gitignore: false    # add non-config files in ZDOTDIR to a .gitignore file in that folder
  prezto:             # set up prezto framework (if xdg is true, use XDG_DATA_HOME, else ZDOTDIR). defaults to false. set to true or to mapping to install
    repo:             # if you want to override the default repository with your own
      url: <url>      # url to repo. if you want to work on main/master, just specify repo: <url>. @TODO with custom module/state: if the repo contains 'required_packages', they will be installed
      branch: my      # branch to checkout when cloning
    required_packages:# list of packages that are required by the modules specified in ext_plugins that will be automatically installed
      - fzf
      - lua
    extplugins:       # list of zsh plugins **on github** to clone into <extplugins_target>, by default ZPREZTODIR/contrib
      - gpanders/fzf-prezto
      - skywind3000/z.lua
    extplugins_target: /some/path     # by default, plugins are synced to $ZPREZTODIR/contrib. you can override it here
    extplugins_sync_on_startup: False # if you want to manually edit zshrc and add plugins on init to test them (will add stuff to zshrc)
    extplugins_as_submodule: False    # if you want to add the plugins as submodules to prezto instead of cloned repos in <extplugins_target>
    user_plugin_dirs: # list of additional paths prezto searches for plugins besides $ZPREZTODIR/{contrib, modules}
      - ${XDG_DATA_HOME}/zprezto-contrib
```
### Dotfiles
`tool.zsh.configsync` will recursively apply templates from `salt://dotconfig/<user>/zsh` or `salt://dotconfig/zsh` to `$ZDOTDIR` for every user that has it enabled (see `dotconfig`). The target folder will not be cleaned by default (ie files in `$ZDOTDIR` that are not in the user's dotconfig will stay).

## General ZSH Notes
### Config Files
* `$ZDOTDIR/.zshenv`
  - The .zshenv is used every time you start zsh. This is for your environment variables like $PATH, $EDITOR, $VISUAL, $PAGER, $LANG. <<<< and ZDOTDIR
* `$ZDOTDIR/.zprofile`
  - The .zprofile is an alternative to .zlogin and these two are not intended to be used together.
* `$ZDOTDIR/.zshrc`
  - The .zshrc is where we add our aliases, functions and other customizations.
* `$ZDOTDIR/.zlogin`
  - The .zlogin is started when you log in your shell but after your .zshrc.
* `$ZDOTDIR/.zlogout`
  - The .zlogout is used when you close your shell.

## Todo
* integrate [zinit](https://github.com/zdharma-continuum/zinit)

## Reference
* https://blog.devgenius.io/enhance-your-terminal-with-zsh-and-prezto-ab9abf9bc424
* https://redd.jean.casa/r/zsh/comments/ak0vgi/a_comparison_of_all_the_zsh_plugin_mangers_i_used/
* https://github.com/unixorn/awesome-zsh-plugins
