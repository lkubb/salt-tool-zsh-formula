.. _readme:

Zsh Formula
===========

Manages Zsh and optionally Prezto framework in the user environment.

.. contents:: **Table of Contents**
   :depth: 1

Usage
-----
Applying ``tool_zsh`` will make sure ``zsh`` is configured as specified.

Configuration
-------------

This formula
~~~~~~~~~~~~
The general configuration structure is in line with all other formulae from the `tool` suite, for details see :ref:`toolsuite`. An example pillar is provided, see :ref:`pillar.example`. Note that you do not need to specify everything by pillar. Often, it's much easier and less resource-heavy to use the ``parameters/<grain>/<value>.yaml`` files for non-sensitive settings. The underlying logic is explained in :ref:`map.jinja`.

User-specific
^^^^^^^^^^^^^
The following shows an example of ``tool_zsh`` per-user configuration. If provided by pillar, namespace it to ``tool_global:users`` and/or ``tool_zsh:users``. For the ``parameters`` YAML file variant, it needs to be nested under a ``values`` parent key. The YAML files are expected to be found in

1. ``salt://tool_zsh/parameters/<grain>/<value>.yaml`` or
2. ``salt://tool_global/parameters/<grain>/<value>.yaml``.

.. code-block:: yaml

  user:

      # Force the usage of XDG directories for this user.
      # This sets up $ZDOTDIR in XDG_CONF_HOME. Mind that currently,
      # $ZDOTDIR will be set globally. Thus, excluded users will
      # have broken config.
    xdg: true

      # Sync this user's config from a dotfiles repo.
      # The available paths and their priority can be found in the
      # rendered `config/sync.sls` file (currently, @TODO docs).
      # Overview in descending priority:
      # salt://dotconfig/<minion_id>/<user>/zsh
      # salt://dotconfig/<minion_id>/zsh
      # salt://dotconfig/<os_family>/<user>/zsh
      # salt://dotconfig/<os_family>/zsh
      # salt://dotconfig/default/<user>/zsh
      # salt://dotconfig/default/zsh
    dotconfig:              # can be bool or mapping
      file_mode: '0600'     # default: keep destination or salt umask (new)
      dir_mode: '0700'      # default: 0700
      clean: false          # delete files in target. default: false

      # Persist environment variables used by this formula for this
      # user to this file (will be appended to a file relative to $HOME)
    persistenv: '.config/zsh/zshenv'

      # Add runcom hooks specific to this formula to this file
      # for this user (will be appended to a file relative to $HOME)
    rchook: '.config/zsh/zshrc'

      # This user's configuration for this formula. Will be overridden by
      # user-specific configuration in `tool_zsh:users`.
      # Set this to `false` to disable configuration for this user.
    zsh:
        # Set zsh as default shell for this user. Defaults to false.
      default_shell: true
        # Set up Prezto framework (if xdg is true, use XDG_DATA_HOME, else ZDOTDIR).
        # Defaults to false. Set to true or mapping to install.
      prezto:
          # List of zsh plugins **on Github** to clone into <extplugins_target>,
          # by default $ZPREZTODIR/contrib.
        extplugins:
          - gpanders/fzf-prezto
          - skywind3000/z.lua
          # If you want to add the extplugins as submodules to prezto instead of
          # cloned repos in <extplugins_target>.
        extplugins_as_submodule: false
          # If you want to manually edit zshrc and add plugins on init to test them
          # (will add stuff to zshrc).
        extplugins_sync_on_startup: false
          # By default, plugins are synced to $ZPREZTODIR/contrib.
          # You can override it here.
        extplugins_target: some/other/path
          # if you want to override the default repository with your own
        repo:
            # Git rev to checkout after cloning.
            # If you do not want to update in subsequent runs, pin this
            # to a specific commit hash.
          rev: master
            # URL to git repository of Prezto. If you want to work on the
            # default branch, just specify repo: <url>.
          url: https://github.com/sorin-ionescu/prezto
          # List of packages that are required by the modules specified in
          # ext_plugins (will be automatically installed by the package manager).
        required_packages:
          - fzf
          - lua
          # List of additional paths Prezto searches for plugins
          # besides $ZPREZTODIR/{contrib, modules}
        user_plugin_dirs:
          - ${XDG_DATA_HOME}/zprezto-contrib

Formula-specific
^^^^^^^^^^^^^^^^

.. code-block:: yaml

  tool_zsh:

      # Specify an explicit version (works on most Linux distributions) or
      # keep the packages updated to their latest version on subsequent runs
      # by leaving version empty or setting it to 'latest'
      # (again for Linux, brew does that anyways).
    version: latest

      # Default formula configuration for all users.
    defaults:
      default_shell: default value for all users

Dotfiles
~~~~~~~~
``tool_zsh.config.sync`` will recursively apply templates from

* ``salt://dotconfig/<minion_id>/<user>/zsh``
* ``salt://dotconfig/<minion_id>/zsh``
* ``salt://dotconfig/<os_family>/<user>/zsh``
* ``salt://dotconfig/<os_family>/zsh``
* ``salt://dotconfig/default/<user>/zsh``
* ``salt://dotconfig/default/zsh``

to the user's config dir for every user that has it enabled (see ``user.dotconfig``). The target folder will not be cleaned by default (ie files in the target that are absent from the user's dotconfig will stay).

The URL list above is in descending priority. This means user-specific configuration from wider scopes will be overridden by more system-specific general configuration.

Development
-----------

Contributing to this repo
~~~~~~~~~~~~~~~~~~~~~~~~~

Commit messages
^^^^^^^^^^^^^^^

Commit message formatting is significant.

Please see `How to contribute <https://github.com/saltstack-formulas/.github/blob/master/CONTRIBUTING.rst>`_ for more details.

pre-commit
^^^^^^^^^^

`pre-commit <https://pre-commit.com/>`_ is configured for this formula, which you may optionally use to ease the steps involved in submitting your changes.
First install  the ``pre-commit`` package manager using the appropriate `method <https://pre-commit.com/#installation>`_, then run ``bin/install-hooks`` and
now ``pre-commit`` will run automatically on each ``git commit``.

.. code-block:: console

  $ bin/install-hooks
  pre-commit installed at .git/hooks/pre-commit
  pre-commit installed at .git/hooks/commit-msg

State documentation
~~~~~~~~~~~~~~~~~~~
There is a script that semi-autodocuments available states: ``bin/slsdoc``.

If a ``.sls`` file begins with a Jinja comment, it will dump that into the docs. It can be configured differently depending on the formula. See the script source code for details currently.

This means if you feel a state should be documented, make sure to write a comment explaining it.

Testing
~~~~~~~

Linux testing is done with ``kitchen-salt``.

Requirements
^^^^^^^^^^^^

* Ruby
* Docker

.. code-block:: bash

  $ gem install bundler
  $ bundle install
  $ bin/kitchen test [platform]

Where ``[platform]`` is the platform name defined in ``kitchen.yml``,
e.g. ``debian-9-2019-2-py3``.

``bin/kitchen converge``
^^^^^^^^^^^^^^^^^^^^^^^^

Creates the docker instance and runs the ``tool_zsh`` main state, ready for testing.

``bin/kitchen verify``
^^^^^^^^^^^^^^^^^^^^^^

Runs the ``inspec`` tests on the actual instance.

``bin/kitchen destroy``
^^^^^^^^^^^^^^^^^^^^^^^

Removes the docker instance.

``bin/kitchen test``
^^^^^^^^^^^^^^^^^^^^

Runs all of the stages above in one go: i.e. ``destroy`` + ``converge`` + ``verify`` + ``destroy``.

``bin/kitchen login``
^^^^^^^^^^^^^^^^^^^^^

Gives you SSH access to the instance for manual testing.

General zsh notes
-----------------
Config files
~~~~~~~~~~~~
* ``$ZDOTDIR/.zshenv``
  - The .zshenv is used every time you start zsh. This is for your environment variables like $PATH, $EDITOR, $VISUAL, $PAGER, $LANG. <<<< and ZDOTDIR
* ``$ZDOTDIR/.zprofile``
  - The .zprofile is an alternative to .zlogin and these two are not intended to be used together.
* ``$ZDOTDIR/.zshrc``
  - The .zshrc is where we add our aliases, functions and other customizations.
* ``$ZDOTDIR/.zlogin``
  - The .zlogin is started when you log in your shell but after your .zshrc.
* ``$ZDOTDIR/.zlogout``
  - The .zlogout is used when you close your shell.

Todo
----
* integrate `zinit <https://github.com/zdharma-continuum/zinit>`_
* https://chr4.org/posts/2014-09-10-conf-dot-d-like-directories-for-zsh-slash-bash-dotfiles/

Reference
---------
* https://blog.devgenius.io/enhance-your-terminal-with-zsh-and-prezto-ab9abf9bc424
* https://redd.jean.casa/r/zsh/comments/ak0vgi/a_comparison_of_all_the_zsh_plugin_mangers_i_used/
* https://github.com/unixorn/awesome-zsh-plugins
