Available states
----------------

The following states are found in this formula:

.. contents::
   :local:


``tool_zsh``
~~~~~~~~~~~~
*Meta-state*.

Performs all operations described in this formula according to the specified configuration.


``tool_zsh.package``
~~~~~~~~~~~~~~~~~~~~
Installs the Zsh package only.


``tool_zsh.xdg``
~~~~~~~~~~~~~~~~
Ensures Zsh adheres to the XDG spec
as best as possible for all managed users.
Has a dependency on `tool_zsh.package`_.


``tool_zsh.default_shell``
~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_zsh.config``
~~~~~~~~~~~~~~~~~~~
Manages the Zsh package configuration by

* recursively syncing from a dotfiles repo

Has a dependency on `tool_zsh.package`_.


``tool_zsh.prezto``
~~~~~~~~~~~~~~~~~~~



``tool_zsh.prezto.config``
~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_zsh.prezto.package``
~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_zsh.prezto.plugins``
~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_zsh.clean``
~~~~~~~~~~~~~~~~~~
*Meta-state*.

Undoes everything performed in the ``tool_zsh`` meta-state
in reverse order.


``tool_zsh.package.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~
Removes the Zsh package.
Has a dependency on `tool_zsh.config.clean`_.


``tool_zsh.xdg.clean``
~~~~~~~~~~~~~~~~~~~~~~



``tool_zsh.config.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~
Removes the configuration of the Zsh package.


``tool_zsh.prezto.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_zsh.prezto.config.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_zsh.prezto.package.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_zsh.prezto.plugins.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



