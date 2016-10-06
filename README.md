Emacs-mode for GDscript 

This mode is based on python-mode.el. 
I removed half of the code (execution, shell, pymacs, etc) and
add some minor syntax tweaks. Mode is not tested very thoroughly 
but I use it on a day-to-day basis and it does editing/deleting/selecting well
Mode provides almost all python-mode functions related to simple text/selection 
manipulation.

Command names are the same as in python-mode but with "gd" prefix
Examples
* gd-mark-def - marks current func
* gd-mark-block - marks current block (if/func/class/etc)
* gd-delete-def-or-class - delete current func or class statement
* gd-boolswitch - switches between true and false at point
* gd-next-statement - moves to the next GDScript statement
* gd-backward-class - moves to previous class

If you find bug or some stuff related to Python in gdscript-mode please submit an issue

Usage
* clone repo
* add to .emacs 
```elisp
(add-to-list 'load-path "PATH-TO-GDSCRIPT-MODE-FOLDER")
(require 'gdscript-mode)
```

