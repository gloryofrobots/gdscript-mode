##Emacs-mode for GDscript 

This mode is based on python-mode.el. 
The idea is to provide accustomed interface for users familiar with emacs python-mode.
Mode targets only basic editing areas such as editing/navigation/marking. 
Features not related to this simple tasks or to GDScript were removed (execution, shell, pymacs, plugins, etc).
GDscript mode also adds some minor syntax tweaks (different set of language keywords, priority of tabs over spaces, etc)

Command names are the same as in python-mode but with "gd" prefix

For example:

* gd-mark-def - marks current func
* gd-mark-block - marks current block (if/func/class/etc)
* gd-delete-def-or-class - delete current func or class statement
* gd-boolswitch - switches between true and false at point
* gd-next-statement - moves to the next GDScript statement
* gd-backward-class - moves to previous class

I did not replace 'def' with 'func' in function names for legacy reasons 

If you find bug or some Python related stuff in gdscript-mode please submit an issue

Usage
* clone repo
* add to .emacs 
```elisp
(add-to-list 'load-path "PATH-TO-GDSCRIPT-MODE-FOLDER")
(require 'gdscript-mode)
```

