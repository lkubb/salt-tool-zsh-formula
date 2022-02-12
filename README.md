# `zsh` Formula
Sets up, configures and updates `zsh`, and optionally Prezto framework. It's possible to reference your own fork of Prezto.

## Usage
Applying `tool-zsh` will make sure zsh (and possibly Prezto) will work as specified. Existing configuration will not be replaced. If you want to make sure everything is up to date, run `tool-zsh.update`. This will pull the specified Prezto repo, possibly update its submodules to the specified commits, sync dotconfig and install the latest `zsh`.

## Configuration
### Pillar
#### General `tool` architecture
Since installing user environments is not the primary use case for saltstack, the architecture is currently a bit awkward. All `tool` formulas assume running as root. There are three scopes of configuration:
1. per-user `tool`-specific
  > e.g. generally force usage of XDG dirs in `tool` formulas for this user
2. per-user formula-specific
  > e.g. setup this tool with the following configuration values for this user
3. global formula-specific (All formulas will accept `defaults` for `users:username:formula` default values in this scope as well.)
  > e.g. setup system-wide configuration files like this

**3** goes into `tool:formula` (e.g. `tool:git`). Both user scopes (**1**+**2**) are mixed per user in `users`. `users` can be defined in `tool:users` and/or `tool:formula:users`, the latter taking precedence. (**1**) is namespaced directly under `username`, (**2**) is namespaced under `username: {formula: {}}`.

```yaml
tool:
######### user-scope 1+2 #########
  users:                         #
    username:                    #
      xdg: true                  #
      dotconfig: true            #
      formula:                   #
        config: value            #
####### user-scope 1+2 end #######
  formula:
    formulaspecificstuff:
      conf: val
    defaults:
      yetanotherconfig: somevalue
######### user-scope 1+2 #########
    users:                       #
      username:                  #
        xdg: false               #
        formula:                 #
          otherconfig: otherval  #
####### user-scope 1+2 end #######
```


#### User-specific
The following shows an example of `tool-zsh` pillar configuration. Namespace it to `tool:users` and/or `tool:zsh:users`.
```yaml
username:
  # Set up $ZDOTDIR in XDG_CONF_HOME. Mind that currently,
  # $ZDOTDIR will be set globally. Thus, excluded users will
  # have broken config. @TODO possible workaround by creating
  # the option to only leave .zshenv in $HOME or
  # specifically checking [[ "$(whoami)" == 'user' ]] in /etc/zshenv
  xdg: true
  # sync this user's config from a dotfiles repo available as
  # salt://dotconfig/<user>/zsh or salt://dotconfig/zsh
  dotconfig:              # can be bool or mapping
    file_mode: '0600'     # default: keep destination or salt umask (new)
    dir_mode: '0700'      # default: 0700
    clean: false          # delete files in target. default: false
  zsh:
    default: false                      # set zsh as default shell for this user. defaults to false
    gitignore: false                    # add non-config files to gitignore in ZDOTDIR
    prezto:                             # set up prezto framework (if xdg is true, use XDG_DATA_HOME, else ZDOTDIR). defaults to false.
                                        # set to true or to mapping to install
      repo:                             # if you want to override the default repository with your own
        url: <url>                      # url to repo. if you want to work on main/master, just specify repo: <url>.
                                        # @TODO with custom module/state: if the repo contains 'required_packages', they will be installed
        branch: my                      # branch to checkout when cloning
      required_packages:                # list of packages that are required by the modules specified in ext_plugins that will be automatically installed
        - fzf
        - lua
      extplugins:                       # list of zsh plugins **on github** to clone into <extplugins_target>, by default ZPREZTODIR/contrib
        - gpanders/fzf-prezto
        - skywind3000/z.lua
      extplugins_target: /some/path     # by default, plugins are synced to $ZPREZTODIR/contrib. you can override it here
      extplugins_sync_on_startup: False # if you want to manually edit zshrc and add plugins on init to test them (will add stuff to zshrc)
      extplugins_as_submodule: False    # if you want to add the plugins as submodules to prezto instead of cloned repos in <extplugins_target>
      user_plugin_dirs:                 # list of additional paths prezto searches for plugins besides $ZPREZTODIR/{contrib, modules}
        - ${XDG_DATA_HOME}/zprezto-contrib
```


#### Formula-specific
```yaml
tool:
  zsh:
    defaults:
      prezto: true
```

### Dotfiles
`tool-zsh.configsync` will recursively apply templates from 

- `salt://dotconfig/<user>/zsh` or
- `salt://dotconfig/zsh`

to the user's `$ZDOTDIR` for every user that has it enabled (see `user.dotconfig`). The target folder will not be cleaned by default (ie files in the target that are absent from the user's dotconfig will stay).

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
* https://chr4.org/posts/2014-09-10-conf-dot-d-like-directories-for-zsh-slash-bash-dotfiles/

## Reference
* https://blog.devgenius.io/enhance-your-terminal-with-zsh-and-prezto-ab9abf9bc424
* https://redd.jean.casa/r/zsh/comments/ak0vgi/a_comparison_of_all_the_zsh_plugin_mangers_i_used/
* https://github.com/unixorn/awesome-zsh-plugins
