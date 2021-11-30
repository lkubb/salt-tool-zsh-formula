# `zsh` salt formula
## Notes
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
* look over https://github.com/unixorn/awesome-zsh-plugins

## Reference
* https://blog.devgenius.io/enhance-your-terminal-with-zsh-and-prezto-ab9abf9bc424
* https://redd.jean.casa/r/zsh/comments/ak0vgi/a_comparison_of_all_the_zsh_plugin_mangers_i_used/
