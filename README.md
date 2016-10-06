Emacs-mode for GDscript 

This mode is based on python-mode.el. 
I removed half of the code (execution, shell, pymacs, etc) and
add some minor syntax tweaks. It did not tested very thoroughly 
but I use it on day-to-day basis and it does editing/deleting/selecting well
Mode provides almost all python-mode functions related to simple text/selection 
manipulation.

Command names are the same as in python-mode but with "gd" prefix
Examples
* gd-mark-def - marks current func
* gd-mark-block - marks current block (if/func/class/etc)
* gd-delete-def - delete current func
* gd-boolswitch - switches between true and false at point

To use clone this repo and add to .emacs 
```elisp
(add-to-list 'load-path "PATH-TO-GDSCRIPT-MODE-FOLDER")
(require 'gdscript-mode)
```

