;; TODO HEADER LICENSE COPYRIGHT
;; THIS IS PYTHON-MODE.el below with a lot of replacements and cuts
;; EXPECT TO FIND GARBAGE UNTI WORK IS DONE
;; IT`S A 20k-line file after all

(defgroup gdscript-mode nil
  "Support for the GDScript programming language, <http://www.python.org/>"
  :group 'languages
  :prefix "py-")

(defconst gd-version "6.2.2+")

(defcustom gd-install-directory ""
  "Directory where gdscript-mode.el and it's subdirectories should be installed. Needed for completion and other environment stuff only. "

  :type 'string
  :tag "gd-install-directory"
  :group 'gdscript-mode)

(defcustom gd-pythonpath ""
  "Define $PYTHONPATH here, if needed.

Emacs doesn't read .bashrc"

  :type 'string
  :tag "gd-pythonpath"
  :group 'gdscript-mode)

(when (string= "" gd-install-directory)
  (setq gd-install-directory default-directory))

(defcustom gdscript-mode-modeline-display "Py"
  "String to display in Emacs modeline "

  :type 'string
  :tag "gdscript-mode-modeline-display"
  :group 'gdscript-mode)

(defcustom gd-extensions "gd-extensions.el"
  "File where extensions to gdscript-mode.el should be installed. Used by virtualenv support. "

  :type 'string
  :tag "gd-extensions"
  :group 'gdscript-mode)

(defcustom info-lookup-mode "python"
  "Which GDScript documentation should be queried.

Make sure it's accessible from Emacs by M-x info RET ...
See INSTALL-INFO-FILES for help. "

  :type 'string
  :tag "info-lookup-mode"
  :group 'gdscript-mode)

(defcustom gd-fast-process-p nil
  "Use `gd-fast-process'.

Commands prefixed \"gd-fast-...\" suitable for large output

See: large output makes Emacs freeze, lp:1253907

Results arrive in output buffer, which is not in comint-mode"

  :type 'boolean
  :tag "gd-fast-process-p"
  :group 'gdscript-mode)

(defvar gd-this-result nil
  "Internally used, store return-value")

;; (defcustom gd-which-def-or-class-function gd-which-def-or-class
;;   "If which-function-mode should use `gd-which-def-or-class'.

;; Alternatively use built-in `which-function', which queries the index
;; or `gdscript-info-current-defun' from python.el"
;;   :type '(choice

;;           (const :tag "default" gd-which-def-or-class)
;; 	  (const :tag "built-in which-function" nil)
;;           (const :tag "gdscript-info-current-defun" gdscript-info-current-defun))
;;   :group 'gdscript-mode)

;; (defcustom gd-which-def-or-class-function gd-which-def-or-class
;;   "If which-function-mode should use `gd-which-def-or-class'.

;; Alternatively use built-in `which-function', which queries the index
;; or `gdscript-info-current-defun' from python.el"
;;   :type '(choice

;;           (const :tag "default" gd-which-def-or-class)
;; 	  (const :tag "built-in which-function" nil)
;;           (const :tag "gdscript-info-current-defun" gdscript-info-current-defun))
;;   :group 'gdscript-mode)

(defcustom gd-comment-auto-fill-p nil
  "When non-nil, fill comments.

Defaut is nil"

  :type 'boolean
  :group 'gdscript-mode)

(defcustom gd-sexp-use-expression-p nil
  "If non-nil, C-M-s call gd-forward-expression.

Respective C-M-b will call gd-backward-expression
Default is t"
  :type 'boolean
  :group 'gdscript-mode)

(defcustom gd-session-p t
  "If commands would use an existing process.

If nil, a maybe existing process at gd-buffer-name would be killed and re-started

See also `gd-dedicated-process-p'
"

  :type 'boolean
  :tag "gd-session-p"
  :group 'gdscript-mode)

(defcustom gd-max-help-buffer-p nil
  "If \"\*GDScript-Help\*\"-buffer should appear as the only visible.

Default is nil. In help-buffer, \"q\" will close it.  "

  :type 'boolean
  :tag "gd-max-help-buffer-p"
  :group 'gdscript-mode)

(defcustom gd-highlight-error-source-p nil
  "When gd-execute-... commands raise an error, respective code in source-buffer will be highlighted. Default is nil.

M-x `gd-remove-overlays-at-point' removes that highlighting.
 "
  :type 'boolean
  :tag "gd-highlight-error-source-p"
  :group 'gdscript-mode)

(defcustom gd-set-pager-cat-p nil
  "If the shell environment variable $PAGER should set to `cat'.

If `t', use `C-c C-r' to jump to beginning of output. Then scroll normally.

Avoids lp:783828, \"Terminal not fully functional\", for help('COMMAND') in gdscript-shell

When non-nil, imports module `os' "

  :type 'boolean
  :tag "gd-set-pager-cat-p"
  :group 'gdscript-mode)

(defcustom gd-empty-line-closes-p nil
  "When non-nil, dedent after empty line following block

if True:
    print(\"Part of the if-statement\")

print(\"Not part of the if-statement\")

Default is nil

If non-nil, a C-j from empty line dedents."

  :type 'boolean
  :tag "gd-empty-line-closes-p"
  :group 'gdscript-mode)

(defcustom gd-prompt-on-changed-p t
  "When called interactively, ask for save before a changed buffer is sent to interpreter.

Default is `t'"

  :type 'boolean
  :tag "gd-prompt-on-changed-p"
  :group 'gdscript-mode)

(defcustom gd-dedicated-process-p nil
  "If commands executing code use a dedicated shell.

Default is nil

When non-nil and `gd-session-p', an existing dedicated process is re-used instead of default - which allows executing stuff in parallel.
"
  :type 'boolean
  :tag "gd-dedicated-process-p"
  :group 'gdscript-mode)

(defcustom gd-store-result-p nil
  "When non-nil, put resulting string of `gd-execute-...' into kill-ring, so it might be yanked.

Default is nil"

  :type 'boolean
  :tag "gd-dedicated-process-p"
  :group 'gdscript-mode)

(defvar gd-shell--font-lock-buffer " *PSFLB*"
  "May contain the `gd-buffer-name' currently fontified. " )

(defvar gd-return-result-p t
  "Internally used. When non-nil, return resulting string of `gd-execute-...' functions. Imports will use it with nil.

Default is t")

(defcustom py--execute-use-temp-file-p nil
 "Assume execution at a remote machine.

 where write-access is not given. "

 :type 'boolean
 :group 'gdscript-mode)

(defvar py--match-paren-forward-p nil
  "Internally used by `gd-match-paren'. ")

(defvar gd-new-session-p t
  "Internally used. See lp:1393882.

Restart gd-shell once with new Emacs/gdscript-mode. ")

(defcustom gd-electric-close-active-p nil
  "Close completion buffer when it's sure, it's no longer needed, i.e. when inserting a space.

Works around a bug in `choose-completion'.
Default is `nil'"
  :type 'boolean
  :group 'gdscript-mode)

(defcustom gd-update-gud-pdb-history-p t
  "If pdb should provide suggestions WRT file to check and gd-pdb-path.

Default is t
See lp:963253
"
  :type 'boolean
  :tag "gd-update-gud-pdb-history-p"
  :group 'gdscript-mode
  :tag "gd-update-gud-pdb-history-p")

(defcustom gd-pdb-executable nil
  "Indicate PATH/TO/pdb.

Default is nil
See lp:963253
"
  :type 'string
  :tag "gd-pdb-executable"
  :group 'gdscript-mode
  :tag "gd-pdb-executable")

(defcustom gd-hide-show-minor-mode-p nil
  "If hide-show minor-mode should be on, default is nil. "

  :type 'boolean
  :tag "gd-hide-show-minor-mode-p"
  :group 'gdscript-mode)

(defcustom gd-load-skeletons-p nil
  "If skeleton definitions should be loaded, default is nil.

If non-nil and abbrev-mode on, block-skeletons will inserted.
Pressing \"if<SPACE>\" for example will prompt for the if-condition.
"

  :type 'boolean
  :tag "gd-load-skeletons-p"
  :group 'gdscript-mode)

(defcustom gd-if-name-main-permission-p t
  "Allow execution of code inside blocks started
by \"if __name__== '__main__':\".

Default is non-nil"

  :type 'boolean
  :tag "gd-if-name-main-permission-p"
  :group 'gdscript-mode)

(defcustom gd-use-font-lock-doc-face-p nil
  "If documention string inside of def or class get `font-lock-doc-face'.

`font-lock-doc-face' inherits `font-lock-string-face'.
Call M-x `customize-face' in order to have a visible effect. "

  :type 'boolean
  :tag "gd-use-font-lock-doc-face-p"
  :group 'gdscript-mode)

(defcustom gd-empty-comment-line-separates-paragraph-p t
  "Consider paragraph start/end lines with nothing inside but comment sign.

Default is  non-nil"
  :type 'boolean
  :tag "gd-empty-comment-line-separates-paragraph-p"
  :group 'gdscript-mode)

(defcustom gd-indent-honors-inline-comment nil
  "If non-nil, indents to column of inlined comment start.
Default is nil. "
  :type 'boolean
  :tag "gd-indent-honors-inline-comment"
  :group 'gdscript-mode)

(defcustom gd-auto-fill-mode nil
  "If gdscript-mode should set fill-column

according values in `gd-comment-fill-column' and `gd-docstring-fill-column'.
Default is  nil"

  :type 'boolean
  :tag "gd-auto-fill-mode"
  :group 'gdscript-mode)

(defcustom gd-error-markup-delay 4
  "Seconds error's are highlighted in exception buffer. "

  :type 'integer
  :tag "gd-error-markup-delay"
  :group 'gdscript-mode)

(defcustom gd-fast-completion-delay 0.1
  "Used by py--fast-send-string-intern. "

  :type 'float
  :tag "gd-fast-completion-delay"
  :group 'gdscript-mode)

(defcustom gd-new-shell-delay
    (if (eq system-type 'windows-nt)
      2.0
    1.0)

  "If a new comint buffer is connected to GDScript, commands like completion might need some delay. "

  :type 'float
  :tag "gd-new-shell-delay"
  :group 'gdscript-mode)

(defcustom gd-autofill-timer-delay 1
  "Delay when idle before functions ajusting  `gd-docstring-fill-column' resp. `gd-comment-fill-column' are called. "
  :type 'integer
  :tag "gd-autofill-timer-delay"
  :group 'gdscript-mode)

(defcustom gd-docstring-fill-column 72
  "Value of `fill-column' to use when filling a docstring.
Any non-integer value means do not use a different value of
`fill-column' when filling docstrings."
  :type '(choice (integer)
                 (const :tag "Use the current `fill-column'" t))
  :tag "gd-docstring-fill-column"
  :group 'gdscript-mode)

(defcustom gd-comment-fill-column 79
  "Value of `fill-column' to use when filling a comment.
Any non-integer value means do not use a different value of
`fill-column' when filling docstrings."
  :type '(choice (integer)
		 (const :tag "Use the current `fill-column'" t))
  :tag "gd-comment-fill-column"
  :group 'gdscript-mode)

(defcustom gd-fontify-shell-buffer-p nil
  "If code in GDScript shell should be highlighted as in script buffer.

Default is nil.

If `t', related vars like `comment-start' will be set too.
Seems convenient when playing with stuff in IPython shell
Might not be TRT when a lot of output arrives "

  :type 'boolean
  :tag "gd-fontify-shell-buffer-p"
  :group 'gdscript-mode)

(defcustom gd-modeline-display-full-path-p nil
  "If the full PATH/TO/PYTHON should be displayed in shell modeline.

Default is nil. Note: when `gd-shell-name' is specified with path, it's shown as an acronym in buffer-name already. "

  :type 'boolean
  :tag "gd-modeline-display-full-path-p"
  :group 'gdscript-mode)

(defcustom gd-modeline-acronym-display-home-p nil
  "If the modeline acronym should contain chars indicating the home-directory.

Default is nil "
  :type 'boolean
  :tag "gd-modeline-acronym-display-home-p"
  :group 'gdscript-mode)

(defun gd-smart-operator-check ()
  "Check, if smart-operator-mode is loaded resp. available.

Give some hints, if not."
  (interactive)
  (if (featurep 'smart-operator)
      't
    (progn
      (and (boundp 'gd-smart-operator-mode-p) gd-smart-operator-mode-p (message "%s" "Don't see smart-operator.el. Make sure, it's installed. See in menu Options, Manage Emacs Packages. Or get it from source: URL: http://xwl.appspot.com/ref/smart-operator.el")
           nil))))

(defun gd-autopair-check ()
  "Check, if autopair-mode is available.

Give some hints, if not."
  (interactive)
  (if (featurep 'autopair)
      't
    (progn
      (message "gd-autopair-check: %s" "Don't see autopair.el. Make sure, it's installed. If not, maybe see source: URL: http://autopair.googlecode.com")
      nil)))

(defvar smart-operator-mode nil)
(defvar highlight-indent-active nil)
(defvar autopair-mode nil)

(defvar gd-edit-docstring-orig-pos nil
  "Internally used by `gd-edit-docstring'. ")

(defvar gd-result nil
  "Internally used. May store result from GDScript process. ")

(defvar gd-error nil
  "Internally used. Takes the error-messages from GDScript process. ")

(defvar gd-gdscript-completions "*GDScript Completions*"
  "Buffer name for GDScript-shell completions, internally used")

(defvar gd-ipython-completions "*IPython Completions*"
  "Buffer name for IPython-shell completions, internally used")

(defcustom gd-timer-close-completions-p t
  "If `gd-timer-close-completion-buffer' should run, default is non-nil. "

  :type 'boolean
  :tag "gd-timer-close-completions-p"
  :group 'gdscript-mode)

(defcustom gd-smart-operator-mode-p nil
  "If gdscript-mode calls `smart-operator-mode-on'

Default is nil. "

  :type 'boolean
  :tag "gd-smart-operator-mode-p"
  :group 'gdscript-mode)

(defcustom gd-autopair-mode nil
  "If gdscript-mode calls (autopair-mode-on)

Default is nil
Load `autopair-mode' written by Joao Tavora <joaotavora [at] gmail.com>
URL: http://autopair.googlecode.com "
  :type 'boolean
  :tag "gd-autopair-mode"
  :group 'gdscript-mode)

(defcustom gd-indent-no-completion-p nil
  "If completion function should insert a TAB when no completion found.

Default is `nil'"
  :type 'boolean
  :tag "gd-indent-no-completion-p"
  :group 'gdscript-mode)

(defcustom gd-company-pycomplete-p nil
  "Load company-pycomplete stuff. Default is  nil"

  :type 'boolean
  :tag "gd-company-pycomplete-p"
  :group 'gdscript-mode)

(defvar gd-last-position nil
    "Used by gd-help-at-point.

Avoid repeated call at identic pos. ")

(defvar gd-auto-completion-mode-p nil
  "Internally used by `gd-auto-completion-mode'")

(defvar gd-complete-last-modified nil
  "Internally used by `gd-auto-completion-mode'")

(defvar py--auto-complete-timer nil
  "Internally used by `gd-auto-completion-mode'")

(defvar gd-auto-completion-buffer nil
  "Internally used by `gd-auto-completion-mode'")

(defvar py--auto-complete-timer-delay 1
  "Seconds Emacs must be idle to trigger auto-completion.

See `gd-auto-completion-mode'")

(defcustom gd-auto-complete-p nil
  "Run gdscript-mode's built-in auto-completion via gd-complete-function. Default is  nil"

  :type 'boolean
  :tag "gd-auto-complete-p"
  :group 'gdscript-mode)
(make-variable-buffer-local 'gd-auto-complete-p)

(defcustom gd-tab-shifts-region-p nil
  "If `t', TAB will indent/cycle the region, not just the current line.

Default is  nil
See also `gd-tab-indents-region-p'"

  :type 'boolean
  :tag "gd-tab-shifts-region-p"
  :group 'gdscript-mode)

(defcustom gd-tab-indents-region-p nil
  "When `t' and first TAB doesn't shift, indent-region is called.

Default is  nil
See also `gd-tab-shifts-region-p'"

  :type 'boolean
  :tag "gd-tab-indents-region-p"
  :group 'gdscript-mode)

(defcustom gd-block-comment-prefix-p t
  "If gd-comment inserts gd-block-comment-prefix.

Default is t"

  :type 'boolean
  :tag "gd-block-comment-prefix-p"
  :group 'gdscript-mode)

(defcustom gd-org-cycle-p nil
  "When non-nil, command `org-cycle' is available at shift-TAB, <backtab>

Default is nil. "

  :type 'boolean
  :tag "gd-org-cycle-p"
  :group 'gdscript-mode)

(defcustom gd-set-complete-keymap-p  nil
  "If `gd-complete-initialize', which sets up enviroment for Pymacs based gd-complete, should load it's keys into `gdscript-mode-map'

Default is nil.
See also resp. edit `gd-complete-set-keymap' "

  :type 'boolean
  :tag "gd-set-complete-keymap-p"
  :group 'gdscript-mode)

(defcustom gd-outline-minor-mode-p t
  "If outline minor-mode should be on, default is `t'. "

  :type 'boolean
  :tag "gd-outline-minor-mode-p"
  :group 'gdscript-mode)

(defcustom gd-guess-gd-install-directory-p t
  "If in cases, `gd-install-directory' isn't set,  `gd-set-load-path'should guess it from `buffer-file-name'. "

  :type 'boolean
  :tag "gd-guess-gd-install-directory-p"
  :group 'gdscript-mode)

(defcustom gd-load-pymacs-p nil
  "If Pymacs related stuff should be loaded.

Default is nil.

Pymacs has been written by François Pinard and many others.
See original source: http://pymacs.progiciels-bpi.ca"

  :type 'boolean
  :tag "gd-load-pymacs-p"
  :group 'gdscript-mode)

(defcustom gd-verbose-p nil
  "If functions should report results.

Default is nil. "

  :type 'boolean
  :tag "gd-verbose-p"
  :group 'gdscript-mode)

(defcustom gd-sexp-function nil
  "When set, it's value is called instead of `forward-sexp', `backward-sexp'

Default is nil. "

  :type '(choice

          (const :tag "default" nil)
          (const :tag "gd-end-of-partial-expression" gd-end-of-partial-expression)
          (const :tag "gd-end-of-expression" gd-end-of-expression))
  :tag "gd-sexp-function"
  :group 'gdscript-mode)

(defcustom gd-close-provides-newline t
  "If a newline is inserted, when line after block isn't empty. Default is non-nil.

When non-nil, `gd-end-of-def' and related will work faster"
  :type 'boolean
  :tag "gd-close-provides-newline"
  :group 'gdscript-mode)

(defcustom gd-dedent-keep-relative-column t
  "If point should follow dedent or kind of electric move to end of line. Default is t - keep relative position. "
  :type 'boolean
  :tag "gd-dedent-keep-relative-column"
  :group 'gdscript-mode)

(defcustom gd-indent-honors-multiline-listing nil
  "If `t', indents to 1+ column of opening delimiter. If `nil', indent adds one level to the beginning of statement. Default is `nil'. "
  :type 'boolean
  :tag "gd-indent-honors-multiline-listing"
  :group 'gdscript-mode)

(defcustom gd-indent-paren-spanned-multilines-p t
  "If non-nil, indents elements of list a value of `gd-indent-offset' to first element:

def foo():
    if (foo &&
            baz):
        bar()

Default lines up with first element:

def foo():
    if (foo &&
        baz):
        bar()

Default is `t'"
  :type 'boolean
  :tag "gd-indent-paren-spanned-multilines-p"
  :group 'gdscript-mode)

(defcustom gd-closing-list-dedents-bos nil
  "When non-nil, indent list's closing delimiter like start-column.

It will be lined up under the first character of
 the line that starts the multi-line construct, as in:

my_list = [
    1, 2, 3,
    4, 5, 6,
]

result = some_function_that_takes_arguments(
    'a', 'b', 'c',
    'd', 'e', 'f',
)

Default is nil, i.e.

my_list = [
    1, 2, 3,
    4, 5, 6,
    ]
result = some_function_that_takes_arguments(
    'a', 'b', 'c',
    'd', 'e', 'f',
    )

Examples from PEP8"

  :type 'boolean
  :tag "gd-closing-list-dedents-bos"
  :group 'gdscript-mode)

(defvar gd-imenu-max-items 99)
(defcustom gd-imenu-max-items 99
 "GDScript-mode specific `imenu-max-items'"

:type 'number
:group 'gdscript-mode)

(defcustom gd-closing-list-space 1
  "Number of chars, closing parenthesis outdent from opening, default is 1 "
  :type 'number
  :tag "gd-closing-list-space"
  :group 'gdscript-mode)

(defcustom gd-max-specpdl-size max-specpdl-size
  "Heuristic exit. Limiting number of recursive calls by gd-forward-statement and related functions. Default is max-specpdl-size.

This threshold is just an approximation. It might set far higher maybe.

See lp:1235375. In case code is not to navigate due to errors, `which-function-mode' and others might make Emacs hang. Rather exit than. "

  :type 'number
  :tag "gd-max-specpdl-size"
  :group 'gdscript-mode)

(defcustom gd-closing-list-keeps-space nil
  "If non-nil, closing parenthesis dedents onto column of opening plus `gd-closing-list-space', default is nil "
  :type 'boolean
  :tag "gd-closing-list-keeps-space"
  :group 'gdscript-mode)

(defcustom gd-electric-kill-backward-p nil
  "Affects `gd-electric-backspace'. Default is nil.

If behind a delimited form of braces, brackets or parentheses,
backspace will kill it's contents

With when cursor after
my_string[0:1]
--------------^

==>

my_string[]
----------^

In result cursor is insided emptied delimited form."

  :type 'boolean
  :tag "gd-electric-kill-backward-p"
  :group 'gdscript-mode)

(defcustom gd-electric-colon-active-p nil
  "`gd-electric-colon' feature.  Default is `nil'. See lp:837065 for discussions.

See also `gd-electric-colon-bobl-only' "
  :type 'boolean
  :tag "gd-electric-colon-active-p"
  :group 'gdscript-mode)

(defcustom gd-electric-colon-bobl-only t

  "When inserting a colon, do not indent lines unless at beginning of block

See lp:1207405 resp. `gd-electric-colon-active-p' "

  :type 'boolean
  :tag "gd-electric-colon-bobl-only"
  :group 'gdscript-mode)

(defcustom gd-electric-yank-active-p nil
  " When non-nil, `yank' will be followed by an `indent-according-to-mode'.

Default is nil"
  :type 'boolean
  :tag "gd-electric-yank-active-p"
  :group 'gdscript-mode)

(defcustom gd-electric-colon-greedy-p nil
  "If gd-electric-colon should indent to the outmost reasonable level.

If nil, default, it will not move from at any reasonable level. "
  :type 'boolean
  :tag "gd-electric-colon-greedy-p"
  :group 'gdscript-mode)

(defcustom gd-electric-colon-newline-and-indent-p nil
  "If non-nil, `gd-electric-colon' will call `newline-and-indent'.  Default is `nil'. "
  :type 'boolean
  :tag "gd-electric-colon-newline-and-indent-p"
  :group 'gdscript-mode)

(defcustom gd-electric-comment-p nil
  "If \"#\" should call `gd-electric-comment'. Default is `nil'. "
  :type 'boolean
  :tag "gd-electric-comment-p"
  :group 'gdscript-mode)

(defcustom gd-electric-comment-add-space-p nil
  "If gd-electric-comment should add a space.  Default is `nil'. "
  :type 'boolean
  :tag "gd-electric-comment-add-space-p"
  :group 'gdscript-mode)

(defcustom gd-mark-decorators nil
  "If gd-mark-def-or-class functions should mark decorators too. Default is `nil'. "
  :type 'boolean
  :tag "gd-mark-decorators"
  :group 'gdscript-mode)

(defcustom gd-defun-use-top-level-p nil
 "When non-nil, keys C-M-a, C-M-e address top-level form.

Default is nil.

Beginning- end-of-defun forms use
commands `gd-beginning-of-top-level', `gd-end-of-top-level'

mark-defun marks top-level form at point etc."

 :type 'boolean
  :tag "gd-defun-use-top-level-p"
 :group 'gdscript-mode)

(defcustom gd-tab-indent t
  "Non-nil means TAB in GDScript mode calls `gd-indent-line'."
  :type 'boolean
  :tag "gd-tab-indent"
  :group 'gdscript-mode)

(defcustom gd-return-key 'newline
  "Which command <return> should call. "
  :type '(choice

          (const :tag "default" gd-newline-and-indent)
          (const :tag "newline" newline)
          (const :tag "gd-newline-and-indent" gd-newline-and-indent)
          (const :tag "gd-newline-and-dedent" gd-newline-and-dedent)
          )
  :tag "gd-return-key"
  :group 'gdscript-mode)

(defcustom gd-complete-function 'gd-fast-complete
  "When set, enforces function todo completion, default is `gd-fast-complete'.

Might not affect IPython, as `gd-shell-complete' is the only known working here.
Normally gdscript-mode knows best which function to use. "
  :type '(choice

          (const :tag "default" nil)
          (const :tag "Pymacs and company based gd-complete" gd-complete)
          (const :tag "gd-shell-complete" gd-shell-complete)
          (const :tag "gd-indent-or-complete" gd-indent-or-complete)
	  (const :tag "gd-fast-complete" gd-fast-complete)
          )
  :tag "gd-complete-function"
  :group 'gdscript-mode)

(defcustom gd-encoding-string " # -*- coding: utf-8 -*-"
  "Default string specifying encoding of a GDScript file. "
  :type 'string
  :tag "gd-encoding-string"
  :group 'gdscript-mode)

(defcustom gd-shebang-startstring "#! /bin/env"
  "Detecting the shell in head of file. "
  :type 'string
  :tag "gd-shebang-startstring"
  :group 'gdscript-mode)

(defcustom gd-flake8-command ""
  "Which command to call flake8.

If empty, gdscript-mode will guess some "
  :type 'string
  :tag "gd-flake8-command"
  :group 'gdscript-mode)

(defcustom gd-flake8-command-args ""
  "Arguments used by flake8.

Default is the empty string. "
  :type 'string
  :tag "gd-flake8-command-args"
  :group 'gdscript-mode)

(defvar gd-flake8-history nil
  "Used by flake8, resp. gd-flake8-command.

Default is nil. ")

(defcustom gd-message-executing-temporary-file t
  "If execute functions using a temporary file should message it. Default is `t'.

Messaging increments the prompt counter of IPython shell. "
  :type 'boolean
  :tag "gd-message-executing-temporary-file"
  :group 'gdscript-mode)

(defcustom gd-execute-no-temp-p nil
  "Seems Emacs-24.3 provided a way executing stuff without temporary files. "
  :type 'boolean
  :tag "gd-execute-no-temp-p"
  :group 'gdscript-mode)

(defcustom gd-lhs-inbound-indent 1
  "When line starts a multiline-assignment: How many colums indent should be more than opening bracket, brace or parenthesis. "
  :type 'integer
  :tag "gd-lhs-inbound-indent"
  :group 'gdscript-mode)

(defcustom gd-continuation-offset 2
  "Additional amount of offset to give for some continuation lines.
Continuation lines are those that immediately follow a backslash
terminated line. "
  :type 'integer
  :tag "gd-continuation-offset"
  :group 'gdscript-mode)

(defcustom gd-indent-tabs-mode nil
  "GDScript-mode starts `indent-tabs-mode' with the value specified here, default is nil. "
  :type 'boolean
  :tag "gd-indent-tabs-mode"
  :group 'gdscript-mode)

(defcustom gd-smart-indentation t
  "Should `gdscript-mode' try to automagically set some indentation variables?
When this variable is non-nil, two things happen when a buffer is set
to `gdscript-mode':

 1. `gd-indent-offset' is guessed from existing code in the buffer.
 Only guessed values between 2 and 8 are considered.  If a valid
 guess can't be made (perhaps because you are visiting a new
 file), then the value in `gd-indent-offset' is used.

 2. `tab-width' is setq to `gd-indent-offset' if not equal
 already. `indent-tabs-mode' inserts one tab one
 indentation level, otherwise spaces are used.

 Note that both these settings occur *after* `gdscript-mode-hook' is run,
 so if you want to defeat the automagic configuration, you must also
 set `gd-smart-indentation' to nil in your `gdscript-mode-hook'."
  :type 'boolean
  :tag "gd-smart-indentation"
  :group 'gdscript-mode)

(defcustom gd-block-comment-prefix "##"
  "String used by \\[comment-region] to comment out a block of code.
This should follow the convention for non-indenting comment lines so
that the indentation commands won't get confused (i.e., the string
should be of the form `#x...' where `x' is not a blank or a tab, and
 `...' is arbitrary).  However, this string should not end in whitespace."
  :type 'string
  :tag "gd-block-comment-prefix"
  :group 'gdscript-mode)

(defcustom gd-indent-offset 4
  "Amount of offset per level of indentation.
 `\\[gd-guess-indent-offset]' can usually guess a good value when
you're editing someone else's GDScript code."
  :type 'integer
  :tag "gd-indent-offset"
  :group 'gdscript-mode)
(make-variable-buffer-local 'gd-indent-offset)

(defcustom gd-backslashed-lines-indent-offset 5
  "Amount of offset per level of indentation of backslashed.
No semantic indent,  which diff to `gd-indent-offset' indicates "
  :type 'integer
  :tag "gd-backslashed-lines-indent-offset"
  :group 'gdscript-mode)

(defcustom gd-pdb-path
  (if (or (eq system-type 'ms-dos)(eq system-type 'windows-nt))
      (quote c:/python27/python\ -i\ c:/python27/Lib/pdb.py)
    '/usr/lib/python2.7/pdb.py)
  "Where to find pdb.py. Edit this according to your system.

If you ignore the location `M-x gd-guess-pdb-path' might display it."
  :type 'variable
  :tag "gd-pdb-path"
  :group 'gdscript-mode)

(defvar gd-gdscript-ms-pdb-command ""
  "MS-systems might use that")

(defcustom gd-indent-comments t
  "When t, comment lines are indented. "
  :type 'boolean
  :tag "gd-indent-comments"
  :group 'gdscript-mode)

(defcustom gd-uncomment-indents-p nil
  "When non-nil, after uncomment indent lines. "
  :type 'boolean
  :tag "gd-uncomment-indents-p"
  :group 'gdscript-mode)

(defcustom gd-separator-char 47
  "The character, which separates the system file-path components.

Precedes guessing when not empty, returned by function `gd-separator-char'. "
  :type 'character
  :tag "gd-separator-char"
  :group 'gdscript-mode)

(and
 ;; used as a string finally
 ;; kept a character not to break existing customizations
 (characterp gd-separator-char)(setq gd-separator-char (char-to-string gd-separator-char)))

(defcustom gd-custom-temp-directory ""
  "If set, will take precedence over guessed values from `gd-temp-directory'. Default is the empty string. "
  :type 'string
  :tag "gd-custom-temp-directory"
  :group 'gdscript-mode)

(defcustom gd-beep-if-tab-change t
  "Ring the bell if `tab-width' is changed.
If a comment of the form

                           \t# vi:set tabsize=<number>:

is found before the first code line when the file is entered, and the
current value of (the general Emacs variable) `tab-width' does not
equal <number>, `tab-width' is set to <number>, a message saying so is
displayed in the echo area, and if `gd-beep-if-tab-change' is non-nil
the Emacs bell is also rung as a warning."
  :type 'boolean
  :tag "gd-beep-if-tab-change"
  :group 'gdscript-mode)

(defcustom gd-jump-on-exception t
  "Jump to innermost exception frame in GDScript output buffer.
When this variable is non-nil and an exception occurs when running
GDScript code synchronously in a subprocess, jump immediately to the
source code of the innermost traceback frame."
  :type 'boolean
  :tag "gd-jump-on-exception"
  :group 'gdscript-mode)

(defcustom gd-ask-about-save t
  "If not nil, ask about which buffers to save before executing some code.
Otherwise, all modified buffers are saved without asking."
  :type 'boolean
  :tag "gd-ask-about-save"
  :group 'gdscript-mode)

(defcustom gd-delete-function 'delete-char
  "Function called by `gd-electric-delete' when deleting forwards."
  :type 'function
  :tag "gd-delete-function"
  :group 'gdscript-mode)

(defcustom gd-pdbtrack-do-tracking-p t
  "Controls whether the pdbtrack feature is enabled or not.
When non-nil, pdbtrack is enabled in all comint-based buffers,
e.g. shell buffers and the *GDScript* buffer.  When using pdb to debug a
GDScript program, pdbtrack notices the pdb prompt and displays the
source file and line that the program is stopped at, much the same way
as gud-mode does for debugging C programs with gdb."
  :type 'boolean
  :tag "gd-pdbtrack-do-tracking-p"
  :group 'gdscript-mode)
(make-variable-buffer-local 'gd-pdbtrack-do-tracking-p)

(defcustom gd-pdbtrack-filename-mapping nil
  "Supports mapping file paths when opening file buffers in pdbtrack.
When non-nil this is an alist mapping paths in the GDScript interpreter
to paths in Emacs."
  :type 'alist
  :tag "gd-pdbtrack-filename-mapping"
  :group 'gdscript-mode)

(defcustom gd-pdbtrack-minor-mode-string " PDB"
  "String to use in the minor mode list when pdbtrack is enabled."
  :type 'string
  :tag "gd-pdbtrack-minor-mode-string"
  :group 'gdscript-mode)

(defcustom gd-import-check-point-max
  20000
  "Maximum number of characters to search for a Java-ish import statement.
When `gdscript-mode' tries to calculate the shell to use (either a
CPython or a Jython shell), it looks at the so-called `shebang' line
                           -- i.e. #! line.  If that's not available, it looks at some of the
file heading imports to see if they look Java-like."
  :type 'integer
  :tag "gd-import-check-point-max
"
  :group 'gdscript-mode)

(defcustom gd-jython-packages
  '("java" "javax")
  "Imported packages that imply `jython-mode'."
  :type '(repeat string)
  :tag "gd-jython-packages
"
  :group 'gdscript-mode)

(defcustom gd-current-defun-show t
  "If `gd-current-defun' should jump to the definition, highlight it while waiting PY-WHICH-FUNC-DELAY seconds, before returning to previous position.

Default is `t'."

  :type 'boolean
  :tag "gd-current-defun-show"
  :group 'gdscript-mode)

(defcustom gd-current-defun-delay 2
  "When called interactively, `gd-current-defun' should wait PY-WHICH-FUNC-DELAY seconds at the definition name found, before returning to previous position. "

  :type 'number
  :tag "gd-current-defun-delay"
  :group 'gdscript-mode)

(defcustom py--delete-temp-file-delay 1
  "Used by `py--delete-temp-file'"

  :type 'number
  :tag "py--delete-temp-file-delay"
  :group 'gdscript-mode)

(defcustom gd-gdscript-send-delay 5
  "Seconds to wait for output, used by `py--send-...' functions.

See also gd-ipython-send-delay"

  :type 'number
  :tag "gd-gdscript-send-delay"
  :group 'gdscript-mode)

(defcustom gd-ipython-send-delay 9
  "Seconds to wait for output, used by `py--send-...' functions.

See also gd-gdscript-send-delay"

  :type 'number
  :tag "gd-ipython-send-delay"
  :group 'gdscript-mode)

(defcustom gd-master-file nil
  "If non-nil, \\[gd-execute-buffer] executes the named
master file instead of the buffer's file.  If the file name has a
relative path, the value of variable `default-directory' for the
buffer is prepended to come up with a file name.

Beside you may set this variable in the file's local
variable section, e.g.:

                           # Local Variables:
                           # gd-master-file: \"master.py\"
                           # End:

                           "
  :type 'string
  :tag "gd-master-file"
  :group 'gdscript-mode)
(make-variable-buffer-local 'gd-master-file)

(defcustom gd-pychecker-command "pychecker"
  "Shell command used to run Pychecker."
  :type 'string
  :tag "gd-pychecker-command"
  :group 'gdscript-mode)

(defcustom gd-pychecker-command-args "--stdlib"
  "String arguments to be passed to pychecker."
  :type 'string
  :tag "gd-pychecker-command-args"
  :group 'gdscript-mode)

(defcustom gd-pyflakes-command "pyflakes"
  "Shell command used to run Pyflakes."
  :type 'string
  :tag "gd-pyflakes-command"
  :group 'gdscript-mode)

(defcustom gd-pyflakes-command-args ""
  "String arguments to be passed to pyflakes.

Default is \"\""
  :type 'string
  :tag "gd-pyflakes-command-args"
  :group 'gdscript-mode)

(defcustom gd-pep8-command "pep8"
  "Shell command used to run pep8."
  :type 'string
  :tag "gd-pep8-command"
  :group 'gdscript-mode)

(defcustom gd-pep8-command-args ""
  "String arguments to be passed to pylint.

Default is \"\" "
  :type 'string
  :tag "gd-pep8-command-args"
  :group 'gdscript-mode)

(defcustom gd-pyflakespep8-command (concat gd-install-directory "/pyflakespep8.py")
  "Shell command used to run `pyflakespep8'."
  :type 'string
  :tag "gd-pyflakespep8-command"
  :group 'gdscript-mode)

(defcustom gd-pyflakespep8-command-args ""
  "string arguments to be passed to pyflakespep8.

Default is \"\" "
  :type 'string
  :tag "gd-pyflakespep8-command-args"
  :group 'gdscript-mode)

(defcustom gd-pylint-command "pylint"
  "Shell command used to run Pylint."
  :type 'string
  :tag "gd-pylint-command"
  :group 'gdscript-mode)

(defcustom gd-pylint-command-args '("--errors-only")
  "String arguments to be passed to pylint.

Default is \"--errors-only\" "
  :type '(repeat string)
  :tag "gd-pylint-command-args"
  :group 'gdscript-mode)

(defcustom gd-shell-input-prompt-1-regexp ">>> "
  "A regular expression to match the input prompt of the shell."
  :type 'regexp
  :tag "gd-shell-input-prompt-1-regexp"
  :group 'gdscript-mode)

(defcustom gd-shell-input-prompt-2-regexp "[.][.][.] "
  "A regular expression to match the input prompt of the shell after the
first line of input."
  :type 'string
  :tag "gd-shell-input-prompt-2-regexp"
  :group 'gdscript-mode)

(defcustom gd-shell-prompt-read-only t
  "If non-nil, the python prompt is read only.  Setting this
variable will only effect new shells."
  :type 'boolean
  :tag "gd-shell-prompt-read-only"
  :group 'gdscript-mode)

(defcustom gd-honor-IPYTHONDIR-p nil
  "When non-nil ipython-history file is constructed by $IPYTHONDIR
followed by \"/history\". Default is nil.

Otherwise value of gd-ipython-history is used. "
  :type 'boolean
  :tag "gd-honor-IPYTHONDIR-p"
  :group 'gdscript-mode)

(defcustom gd-ipython-history "~/.ipython/history"
  "ipython-history default file. Used when gd-honor-IPYTHONDIR-p is nil (default) "

  :type 'string
  :tag "gd-ipython-history"
  :group 'gdscript-mode)

(defcustom gd-honor-PYTHONHISTORY-p nil
  "When non-nil gdscript-history file is set by $PYTHONHISTORY
Default is nil.

Otherwise value of gd-gdscript-history is used. "
  :type 'boolean
  :tag "gd-honor-PYTHONHISTORY-p"
  :group 'gdscript-mode)

(defcustom gd-gdscript-history "~/.python_history"
  "gdscript-history default file. Used when gd-honor-PYTHONHISTORY-p is nil (default) "

  :type 'string
  :tag "gd-gdscript-history"
  :group 'gdscript-mode)

(defcustom gd-switch-buffers-on-execute-p nil
  "When non-nil switch to the GDScript output buffer.

If `gd-keep-windows-configuration' is t, this will take precedence over setting here. "

  :type 'boolean
  :tag "gd-switch-buffers-on-execute-p"
  :group 'gdscript-mode)

(defcustom gd-split-window-on-execute 'just-two
  "When non-nil split windows.

Default is just-two - when code is send to interpreter, split screen into source-code buffer and current gd-shell result.

Other buffer will be hidden that way.

When set to `t', gdscript-mode tries to reuse existing windows and will split only if needed.

With 'always, results will displayed in a new window.

Both `t' and `always' is experimental still.

For the moment: If a multitude of gdscript-shells/buffers should be
visible, open them manually and set `gd-keep-windows-configuration' to `t'.

See also `gd-keep-windows-configuration'
"
  :type '(choice

          (const :tag "default" just-two)
	  (const :tag "reuse" t)
          (const :tag "no split" nil)
	  (const :tag "just-two" just-two)
          (const :tag "always" always))
  :tag "gd-split-window-on-execute"
  :group 'gdscript-mode)

(defcustom gd-split-window-on-execute-threshold 3
  "Maximal number of displayed windows.

Honored, when `gd-split-window-on-execute' is `t', i.e. \"reuse\".
Don't split when max number of displayed windows is reached. "
  :type 'number
  :tag "gd-split-window-on-execute-threshold"
  :group 'gdscript-mode)

(defcustom gd-split-windows-on-execute-function 'split-window-vertically
  "How window should get splitted to display results of gd-execute-... functions. "
  :type '(choice (const :tag "split-window-vertically" split-window-vertically)
                 (const :tag "split-window-horizontally" split-window-horizontally)
                 )
  :tag "gd-split-windows-on-execute-function"
  :group 'gdscript-mode)

(defcustom gd-shell-fontify-style 'all
  "Fontify current input resp. output in GDScript shell. Default is nil.

INPUT will leave output unfontified.
ALL keeps output fontified.

At any case only current input gets fontified.
"
  :type '(choice (const :tag "Default" all)
                 (const :tag "Input" input)
		 (const :tag "Nil" nil)
                 )
  :tag "gd-shell-fontify-style"
  :group 'gdscript-mode)

(defcustom gd-hide-show-keywords
  '("class"    "def"    "elif"    "else"    "except"
    "for"      "if"     "while"   "finally" "try"
    "with")
  "Keywords composing visible heads. "
  :type '(repeat string)
  :tag "gd-hide-show-keywords
"
  :group 'gdscript-mode)

(defcustom gd-hide-show-hide-docstrings t
  "Controls if doc strings can be hidden by hide-show"
  :type 'boolean
  :tag "gd-hide-show-hide-docstrings"
  :group 'gdscript-mode)

(defcustom gd-hide-comments-when-hiding-all t
  "Hide the comments too when you do an `hs-hide-all'."
  :type 'boolean
  :tag "gd-hide-comments-when-hiding-all"
  :group 'gdscript-mode)

(defcustom gd-outline-mode-keywords
  '("class"    "def"    "elif"    "else"    "except"
    "for"      "if"     "while"   "finally" "try"
    "with")
  "Keywords composing visible heads. "
  :type '(repeat string)
  :tag "gd-outline-mode-keywords
"
  :group 'gdscript-mode)

(defcustom gdscript-mode-hook nil
  "Hook run when entering GDScript mode."

  :type 'hook
  :tag "gdscript-mode-hook"
  :group 'gdscript-mode
  )

(defcustom gd-shell-name
  (if (eq system-type 'windows-nt)
      "C:/Python27/python"
    ;; "python"
    "python")

  "A PATH/TO/EXECUTABLE or default value `gd-shell' may look for, if no shell is specified by command.

On Windows default is C:/Python27/python
--there is no garantee it exists, please check your system--

Else python"
  :type 'string
  :tag "gd-shell-name
"
  :group 'gdscript-mode)

(defvar gd-default-interpreter gd-shell-name)

(defvar gd-tempfile nil
  "Internally used")

(defvar gd-named-shells (list 'ipython 'ipython-dedicated 'ipython-no-switch 'ipython-switch 'ipython-switch-dedicated 'ipython2.7 'ipython2.7-dedicated 'ipython2.7-no-switch 'ipython2.7-switch 'ipython2.7-switch-dedicated 'ipython3 'ipython3-dedicated 'ipython3-no-switch 'ipython3-switch 'ipython3-switch-dedicated 'jython 'jython-dedicated 'jython-no-switch 'jython-switch 'jython-switch-dedicated 'python 'gdscript-dedicated 'gdscript-no-switch 'gdscript-switch 'gdscript-switch-dedicated 'python2 'python2-dedicated 'python2-no-switch 'python2-switch 'python2-switch-dedicated 'python3 'python3-dedicated 'python3-no-switch 'python3-switch 'python3-switch-dedicated))

(defcustom gd-gdscript-command
  (if (eq system-type 'windows-nt)
      ;; "C:\\Python27\\python.exe"
      "python"
   ;; "C:/Python33/Lib/site-packages/IPython"
    "python")

  "Make sure, the directory where python.exe resides in in the PATH-variable.

Windows: If needed, edit in \"Advanced System Settings/Environment Variables\" Commonly \"C:\\\\Python27\\\\python.exe\"
With Anaconda for example the following works here:
\"C:\\\\Users\\\\My-User-Name\\\\Anaconda\\\\Scripts\\\\python.exe\"

Else /usr/bin/python"

  :type 'string
  :tag "gd-gdscript-command
"
  :group 'gdscript-mode)

(defcustom gd-gdscript-command-args '("-i")
  "String arguments to be used when starting a GDScript shell."
  :type 'string
  :tag "gd-gdscript-command-args"
  :group 'gdscript-mode)

(defcustom gd-python2-command
  (if (eq system-type 'windows-nt)
      "C:\\Python27\\python"
    ;; "python2"
    "python2")

  "Make sure, the directory where python.exe resides in in the PATH-variable.

Windows: If needed, edit in \"Advanced System Settings/Environment Variables\" Commonly \"C:\\\\Python27\\\\python.exe\"
With Anaconda for example the following works here:
\"C:\\\\Users\\\\My-User-Name\\\\Anaconda\\\\Scripts\\\\python.exe\"

Else /usr/bin/python"

  :type 'string
  :tag "gd-python2-command
"
  :group 'gdscript-mode)

(defcustom gd-python2-command-args '("-i")
  "String arguments to be used when starting a GDScript shell."
  :type '(repeat string)
  :tag "gd-python2-command-args"
  :group 'gdscript-mode)

;; "/usr/bin/python3"
(defcustom gd-python3-command
  (if (eq system-type 'windows-nt)
    "C:/Python33/python"
    "python3")

  "A PATH/TO/EXECUTABLE or default value `gd-shell' may look for, if
  no shell is specified by command.

On Windows see C:/Python3/python.exe
--there is no garantee it exists, please check your system--

At GNU systems see /usr/bin/python3"

  :type 'string
  :tag "gd-python3-command
"
  :group 'gdscript-mode)

(defcustom gd-python3-command-args '("-i")
  "String arguments to be used when starting a Python3 shell."
  :type '(repeat string)
  :tag "gd-python3-command-args"
  :group 'gdscript-mode)

(defcustom gd-ipython-command
  (if (eq system-type 'windows-nt)
      ;; "ipython"
    "C:\\Python27\\python"
    ;; "C:/Python33/Lib/site-packages/IPython"
    ;; "/usr/bin/ipython"
    "ipython")

  "A PATH/TO/EXECUTABLE or default value `M-x IPython RET' may look for, if no IPython-shell is specified by command.

On Windows default is \"C:\\\\Python27\\\\python.exe\"
While with Anaconda for example the following works here:
\"C:\\\\Users\\\\My-User-Name\\\\Anaconda\\\\Scripts\\\\ipython.exe\"

Else /usr/bin/ipython"

  :type 'string
  :tag "gd-ipython-command
"
  :group 'gdscript-mode)

(defcustom gd-ipython-command-args
  (if (eq system-type 'windows-nt)
      "-i C:\\Python27\\Scripts\\ipython-script.py"
    "--pylab --automagic")
  "String arguments to be used when starting a GDScript shell.
At Windows make sure ipython-script.py is PATH. Also setting PATH/TO/SCRIPT here should work, for example;
C:\\Python27\\Scripts\\ipython-script.py
With Anaconda the following is known to work:
\"C:\\\\Users\\\\My-User-Name\\\\Anaconda\\\\Scripts\\\\ipython-script-py\"
"
  :type 'string
  :tag "gd-ipython-command-args
"
  :group 'gdscript-mode)

(defcustom gd-jython-command
  (if (eq system-type 'windows-nt)
      "jython"
    "/usr/bin/jython")

  "A PATH/TO/EXECUTABLE or default value `M-x Jython RET' may look for, if no Jython-shell is specified by command.

Not known to work at windows
Default /usr/bin/jython"

  :type 'string
  :tag "gd-jython-command
"
  :group 'gdscript-mode)

(defcustom gd-jython-command-args ""
  "String arguments to be used when starting a GDScript shell."
  :type 'string
  :tag "gd-jython-command-args"
  :group 'gdscript-mode)

(defcustom gd-shell-toggle-1 gd-python2-command
  "A PATH/TO/EXECUTABLE or default value used by `gd-toggle-shell'. "
  :type 'string
  :tag "gd-shell-toggle-1"
  :group 'gdscript-mode)

(defcustom gd-shell-toggle-2 gd-python3-command
  "A PATH/TO/EXECUTABLE or default value used by `gd-toggle-shell'. "
  :type 'string
  :tag "gd-shell-toggle-2"
  :group 'gdscript-mode)

(defcustom py--imenu-create-index-p nil
  "Non-nil means GDScript mode creates and displays an index menu of functions and global variables. "
  :type 'boolean
  :tag "py--imenu-create-index-p"
  :group 'gdscript-mode)

(defvar gd-history-filter-regexp "\\`\\s-*\\S-?\\S-?\\s-*\\'\\|'''/tmp/"
  "Input matching this regexp is not saved on the history list.
Default ignores all inputs of 0, 1, or 2 non-blank characters.")

(defcustom gd-match-paren-mode nil
  "Non-nil means, cursor will jump to beginning or end of a block.
This vice versa, to beginning first.
Sets `gd-match-paren-key' in gdscript-mode-map.
Customize `gd-match-paren-key' which key to use. "
  :type 'boolean
  :tag "gd-match-paren-mode"
  :group 'gdscript-mode)

(defcustom gd-match-paren-key "%"
  "String used by \\[comment-region] to comment out a block of code.
This should follow the convention for non-indenting comment lines so
that the indentation commands won't get confused (i.e., the string
should be of the form `#x...' where `x' is not a blank or a tab, and
                               `...' is arbitrary).  However, this string should not end in whitespace."
  :type 'string
  :tag "gd-match-paren-key"
  :group 'gdscript-mode)

(defcustom gd-kill-empty-line t
  "If t, gd-indent-forward-line kills empty lines. "
  :type 'boolean
  :tag "gd-kill-empty-line"
  :group 'gdscript-mode)

(defcustom gd-imenu-show-method-args-p nil
  "Controls echoing of arguments of functions & methods in the Imenu buffer.
When non-nil, arguments are printed."
  :type 'boolean
  :tag "gd-imenu-show-method-args-p"
  :group 'gdscript-mode)

(defcustom gd-use-local-default nil
  "If `t', gd-shell will use `gd-shell-local-path' instead
of default GDScript.

Making switch between several virtualenv's easier,
                               `gdscript-mode' should deliver an installer, so named-shells pointing to virtualenv's will be available. "
  :type 'boolean
  :tag "gd-use-local-default"
  :group 'gdscript-mode)

(defcustom gd-edit-only-p nil
  "When `t' `gdscript-mode' will not take resort nor check for installed GDScript executables. Default is nil.

See bug report at launchpad, lp:944093. "
  :type 'boolean
  :tag "gd-edit-only-p"
  :group 'gdscript-mode)

(defcustom gd-force-gd-shell-name-p nil
  "When `t', execution with kind of GDScript specified in `gd-shell-name' is enforced, possibly shebang doesn't take precedence. "

  :type 'boolean
  :tag "gd-force-gd-shell-name-p"
  :group 'gdscript-mode)

(defcustom gdscript-mode-v5-behavior-p nil
  "Execute region through `shell-command-on-region' as
v5 did it - lp:990079. This might fail with certain chars - see UnicodeEncodeError lp:550661"

  :type 'boolean
  :tag "gdscript-mode-v5-behavior-p"
  :group 'gdscript-mode)

(defcustom gd-trailing-whitespace-smart-delete-p nil
  "Default is nil. When t, gdscript-mode calls
    (add-hook 'before-save-hook 'delete-trailing-whitespace nil 'local)

Also commands may delete trailing whitespace by the way.
When editing other peoples code, this may produce a larger diff than expected "
  :type 'boolean
  :tag "gd-trailing-whitespace-smart-delete-p"
  :group 'gdscript-mode)

(defcustom gd-newline-delete-trailing-whitespace-p t
  "Delete trailing whitespace maybe left by `gd-newline-and-indent'.

Default is `t'. See lp:1100892 "
  :type 'boolean
  :tag "gd-newline-delete-trailing-whitespace-p"
  :group 'gdscript-mode)

(defcustom py--warn-tmp-files-left-p nil
  "Messages a warning, when `gd-temp-directory' contains files susceptible being left by previous GDScript-mode sessions. See also lp:987534 "
  :type 'boolean
  :tag "py--warn-tmp-files-left-p"
  :group 'gdscript-mode)

(defcustom gd-complete-ac-sources '(ac-source-pycomplete)
  "List of auto-complete sources assigned to `ac-sources' in `gd-complete-initialize'.

Default is known to work an Ubuntu 14.10 - having python-
mode, pymacs and auto-complete-el, with the following minimal
emacs initialization:

\(require 'pymacs)
\(require 'auto-complete-config)
\(ac-config-default)

"
  :type 'hook
  :tag "gd-complete-ac-sources"
  :options '(ac-source-pycomplete ac-source-abbrev ac-source-dictionary ac-source-words-in-same-mode-buffers)
  :group 'gdscript-mode)

(defcustom gd-remove-cwd-from-path t
  "Whether to allow loading of GDScript modules from the current directory.
If this is non-nil, Emacs removes '' from sys.path when starting
a GDScript process.  This is the default, for security
reasons, as it is easy for the GDScript process to be started
without the user's realization (e.g. to perform completion)."
  :type 'boolean
  :tag "gd-remove-cwd-from-path"
  :group 'gdscript-mode)

(defvar gd-ignore-result-p nil
  "Internally used, for example by setup-functions. ")

(defcustom gd-shell-local-path ""
  "If `gd-use-local-default' is non-nil, `gd-shell' will use EXECUTABLE indicated here incl. path. "

  :type 'string
  :tag "gd-shell-local-path"
  :group 'gdscript-mode)

(defcustom gd-gdscript-edit-version ""
  "When not empty, fontify according to GDScript version specified.

Default is the empty string, a useful value \"python3\" maybe.

When empty, version is guessed via `gd-choose-shell'. "

  :type 'string
  :tag "gd-gdscript-edit-version"
  :group 'gdscript-mode)

(defcustom gd-ipython-execute-delay 0.3
  "Delay needed by execute functions when no IPython shell is running. "
  :type 'float
  :tag "gd-ipython-execute-delay"
  :group 'gdscript-mode)

(defvar gd-shell-completion-setup-code
  "try:
    import readline
except ImportError:
    def __COMPLETER_all_completions(text): []
else:
    import rlcompleter
    readline.set_completer(rlcompleter.Completer().complete)
    def __COMPLETER_all_completions(text):
        import sys
        completions = []
        try:
            i = 0
            while True:
                res = readline.get_completer()(text, i)
                if not res: break
                i += 1
                completions.append(res)
        except NameError:
            pass
        return completions"
  "Code used to setup completion in GDScript processes.")

(defvar gd-shell-module-completion-code "';'.join(__COMPLETER_all_completions('''%s'''))"
  "GDScript code used to get completions separated by semicolons for imports.")

(defvar gd-ipython-module-completion-code
  "import IPython
version = IPython.__version__
if \'0.10\' < version:
    from IPython.core.completerlib import module_completion
"
  "For IPython v0.11 or greater.
 Use the following as the value of this variable:

';'.join(module_completion('''%s'''))")

(defvar gd-ipython-module-completion-string
  "';'.join(module_completion('''%s'''))"
  "See also `gd-ipython-module-completion-code'")

(defcustom py--imenu-create-index-function 'py--imenu-create-index-new
  "Switch between `py--imenu-create-index-new', which also lists modules variables,  and series 5. index-machine"
  :type '(choice (const :tag "'py--imenu-create-index-new, also lists modules variables " py--imenu-create-index-new)

                 (const :tag "py--imenu-create-index, series 5. index-machine" gd-imenu-create-index))
  :tag "py--imenu-create-index-function"
  :group 'gdscript-mode)

(defvar gd-input-filter-re "\\`\\s-*\\S-?\\S-?\\s-*\\'"
  "Input matching this regexp is not saved on the history list.
Default ignores all inputs of 0, 1, or 2 non-blank characters.")

(defvaralias 'inferior-gdscript-filter-regexp 'gd-input-filter-re)

(defvar strip-chars-before  "\\`[ \t\r\n]*"
  "Regexp indicating which chars shall be stripped before STRING - which is defined by `string-chars-preserve'.")

(defvar strip-chars-after  "[ \t\r\n]*\\'"
  "Regexp indicating which chars shall be stripped after STRING - which is defined by `string-chars-preserve'.")

(defcustom gd-docstring-style 'pep-257-nn
  "Implemented styles are DJANGO, ONETWO, PEP-257, PEP-257-NN,
SYMMETRIC, and NIL.

A value of NIL won't care about quotes
position and will treat docstrings a normal string, any other
value may result in one of the following docstring styles:

DJANGO:

    \"\"\"
    Process foo, return bar.
    \"\"\"

    \"\"\"
    Process foo, return bar.

    If processing fails throw ProcessingError.
    \"\"\"

ONETWO:

    \"\"\"Process foo, return bar.\"\"\"

    \"\"\"
    Process foo, return bar.

    If processing fails throw ProcessingError.

    \"\"\"

PEP-257:

    \"\"\"Process foo, return bar.\"\"\"

    \"\"\"Process foo, return bar.

    If processing fails throw ProcessingError.

    \"\"\"

PEP-257-NN:

    \"\"\"Process foo, return bar.\"\"\"

    \"\"\"Process foo, return bar.

    If processing fails throw ProcessingError.
    \"\"\"

SYMMETRIC:

    \"\"\"Process foo, return bar.\"\"\"

    \"\"\"
    Process foo, return bar.

    If processing fails throw ProcessingError.
    \"\"\""
  :type '(choice

          (const :tag "Don't format docstrings" nil)
          (const :tag "Django's coding standards style." django)
          (const :tag "One newline and start and Two at end style." onetwo)
          (const :tag "PEP-257 with 2 newlines at end of string." pep-257)
          (const :tag "PEP-257 with 1 newline at end of string." pep-257-nn)
          (const :tag "Symmetric style." symmetric))
  :tag "gd-docstring-style"
  :group 'gdscript-mode)

(defcustom gd-execute-directory nil
  "When set, stores the file's default directory-name gd-execute-... functions act upon.

Used by GDScript-shell for output of `gd-execute-buffer' and related commands. See also `gd-use-current-dir-when-execute-p'"
  :type 'string
  :tag "gd-execute-directory"
  :group 'gdscript-mode)

(defcustom gd-use-current-dir-when-execute-p t
  "When `t', current directory is used by GDScript-shell for output of `gd-execute-buffer' and related commands.

See also `gd-execute-directory'"
  :type 'boolean
  :tag "gd-use-current-dir-when-execute-p"
  :group 'gdscript-mode)

(defcustom gd-keep-shell-dir-when-execute-p nil
  "Don't change GDScript shell's current working directory when sending code.

See also `gd-execute-directory'"
  :type 'boolean
  :tag "gd-keep-shell-dir-when-execute-p"
  :group 'gdscript-mode)

(defcustom gd-fileless-buffer-use-default-directory-p t
  "When `gd-use-current-dir-when-execute-p' is non-nil and no buffer-file exists, value of `default-directory' sets current working directory of GDScript output shell"
  :type 'boolean
  :tag "gd-fileless-buffer-use-default-directory-p"
  :group 'gdscript-mode)

(defcustom gd-check-command "pychecker --stdlib"
  "Command used to check a GDScript file."
  :type 'string
  :tag "gd-check-command"
  :group 'gdscript-mode)

(defvar gd-this-abbrevs-changed nil
  "Internally used by gdscript-mode-hook")

(defvar gd-ffap-p nil)
(defvar gd-ffap nil)
(defvar ffap-alist nil)

(defvar gd-buffer-name nil
  "Internal use. ")

(defvar gd-orig-buffer-or-file nil
  "Internal use. ")

(defun py--set-ffap-form ()
  (cond ((and gd-ffap-p gd-ffap)
         (eval-after-load "ffap"
           '(push '(gdscript-mode . gd-module-path) ffap-alist))
         (setq ffap-alist (remove '(gdscript-mode . gd-ffap-module-path) ffap-alist))
         (setq ffap-alist (remove '(gd-shell-mode . gd-ffap-module-path)
                                  ffap-alist)))
        (t (setq ffap-alist (remove '(gdscript-mode . gd-ffap-module-path) ffap-alist))
           (setq ffap-alist (remove '(gd-shell-mode . gd-ffap-module-path)
                                    ffap-alist))
           (setq ffap-alist (remove '(gdscript-mode . gd-module-path) ffap-alist)))))

(defcustom gd-ffap-p nil

  "Select gdscript-modes way to find file at point.

Default is nil "

  :type '(choice

          (const :tag "default" nil)
          (const :tag "use gd-ffap" gd-ffap))
  :tag "gd-ffap-p"
  :set (lambda (symbol value)
         (set-default symbol value)
         (py--set-ffap-form))
    :group 'gdscript-mode)

(defcustom gd-keep-windows-configuration nil
  "Takes precedence over `gd-split-window-on-execute' and `gd-switch-buffers-on-execute-p'.

See lp:1239498

To suppres window-changes due to error-signaling also, set `gd-keep-windows-configuration' onto 'force

Default is nil "

  :type '(choice
          (const :tag "nil" nil)
          (const :tag "t" t)
          (const :tag "force" 'force))
  :tag "gd-keep-windows-configuration"
  :group 'gdscript-mode)

(defvar gd-output-buffer "*GDScript Output*"
    "Currently unused.

Output buffer is created dynamically according to GDScript version and kind of process-handling")
(make-variable-buffer-local 'gd-output-buffer)

(defvar gd-ffap-string-code
  "__FFAP_get_module_path('''%s''')\n"
  "GDScript code used to get a string with the path of a module.")

(defcustom gd-shell-prompt-regexp ">>> "
  "Regular Expression matching top\-level input prompt of python shell.
It should not contain a caret (^) at the beginning."
  :type 'string
  :tag "gd-shell-prompt-regexp"
  :group 'gdscript-mode)

(defvar gd-ffap-setup-code
  "def __FFAP_get_module_path(module):
    try:
        import os
        path = __import__(module).__file__
        if path[-4:] == '.pyc' and os.path.exists(path[0:-1]):
            path = path[:-1]
        return path
    except:
        return ''
"
  "GDScript code to get a module path.")

(defvar gd-eldoc-window-configuration nil
  "Keeps window-configuration when eldoc-mode is called. ")

(defvar gd-eldoc-setup-code
  "def __PYDOC_get_help(obj):
    try:
        import inspect
        if hasattr(obj, 'startswith'):
            obj = eval(obj, globals())
        doc = inspect.getdoc(obj)
        if not doc and callable(obj):
            target = None
            if inspect.isclass(obj) and hasattr(obj, '__init__'):
                target = obj.__init__
                objtype = 'class'
            else:
                target = obj
                objtype = 'def'
            if target:
                args = inspect.formatargspec(
                    *inspect.getargspec(target))
                name = obj.__name__
                doc = '{objtype} {name}{args}'.format(
                    objtype=objtype, name=name, args=args)
        else:
            doc = doc.splitlines()[0]
    except:
        doc = ''
    try:
        exec('print doc')
    except SyntaxError:
        print(doc)"
  "GDScript code to setup documentation retrieval.")

(defcustom gd-shell-prompt-output-regexp ""
  "Regular Expression matching output prompt of python shell.
It should not contain a caret (^) at the beginning."
  :type 'string
  :tag "gd-shell-prompt-output-regexp"
  :group 'gdscript-mode)

(defvar gd-underscore-word-syntax-p t
  "This is set later by defcustom, only initial value here.

If underscore chars should be of syntax-class `word', not of `symbol'.
Underscores in word-class makes `forward-word' etc. travel the indentifiers. Default is `t'.
See also command `toggle-gd-underscore-word-syntax-p' ")

(defvar gd-autofill-timer nil)
(defvar gd-fill-column-orig fill-column)

(defvar gdscript-mode-message-string
  (if (or (string= "gdscript-mode.el" (buffer-name))
	  (ignore-errors (string-match "gdscript-mode.el" (py--buffer-filename-remote-maybe))))
      "gdscript-mode.el"
    "gdscript-components-mode.el")
  "Internally used. Reports the gdscript-mode branch")

(unless (fboundp 'string-to-syntax)
  ;; Skip's XE workaround
  (defun string-to-syntax (s)
    (cond
     ((equal s "|") '(15))
     ((equal s "_") '(3))
     (t (error "Unhandled string: %s" s)))))

(defvar gdscript-mode-syntax-table nil
  "Give punctuation syntax to ASCII that normally has symbol
syntax or has word syntax and isn't a letter.")

(setq gdscript-mode-syntax-table
      (let ((table (make-syntax-table)))
        ;; Give punctuation syntax to ASCII that normally has symbol
        ;; syntax or has word syntax and isn't a letter.
        (let ((symbol (string-to-syntax "_"))
              (sst (standard-syntax-table)))
          (dotimes (i 128)
            (unless (= i ?_)
              (if (equal symbol (aref sst i))
                  (modify-syntax-entry i "." table)))))
        (modify-syntax-entry ?$ "." table)
        (modify-syntax-entry ?% "." table)
        ;; exceptions
        (modify-syntax-entry ?# "<" table)
        (modify-syntax-entry ?\n ">" table)
        (modify-syntax-entry ?' "\"" table)
        (modify-syntax-entry ?` "$" table)
        (if gd-underscore-word-syntax-p
            (modify-syntax-entry ?\_ "w" table)
          (modify-syntax-entry ?\_ "_" table))
        table))

(defvar gd-local-command nil
  "Returns locally used executable-name. ")
(make-variable-buffer-local 'gd-local-command)

(defvar gd-local-versioned-command nil
  "Returns locally used executable-name including its version. ")
(make-variable-buffer-local 'gd-local-versioned-command)

(defvar gd-ipython-completion-command-string nil
  "Either gd-ipython0.10-completion-command-string or gd-ipython0.11-completion-command-string.

gd-ipython0.11-completion-command-string also covers version 0.12")

(defvar gd-ipython0.10-completion-command-string
  "print(';'.join(__IP.Completer.all_completions('%s'))) #PYTHON-MODE SILENT\n"
  "The string send to ipython to query for all possible completions")

(defvar gd-ipython0.11-completion-command-string
  "print(';'.join(get_ipython().Completer.all_completions('%s'))) #PYTHON-MODE SILENT\n"
  "The string send to ipython to query for all possible completions")

(defvar gd-encoding-string-re "^[ \t]*#[ \t]*-\\*-[ \t]*coding:.+-\\*-"
  "Matches encoding string of a GDScript file. ")

(defvar gd-shebang-regexp "#![ \t]?\\([^ \t\n]+\\)[ \t]*\\([biptj]+ython[^ \t\n]*\\)"
  "Detecting the shell in head of file. ")
;; (setq gd-shebang-regexp   "#![ \t]?\\([^ \t\n]+\\)[ \t]*\\([biptj]+ython[^ \t\n]*\\)")

(defvar gd-separator-char "/"
  "Values set by defcustom only will not be seen in batch-mode. ")

(defvar gd-temp-directory
  (let ((ok '(lambda (x)
               (and x
                    (setq x (expand-file-name x)) ; always true
                    (file-directory-p x)
                    (file-writable-p x)
                    x)))
        erg)
    (or
     (and (not (string= "" gd-custom-temp-directory))
          (if (funcall ok gd-custom-temp-directory)
              (setq erg (expand-file-name gd-custom-temp-directory))
            (if (file-directory-p (expand-file-name gd-custom-temp-directory))
                (error "gd-custom-temp-directory set but not writable")
              (error "gd-custom-temp-directory not an existing directory"))))
     (and (funcall ok (getenv "TMPDIR"))
          (setq erg (getenv "TMPDIR")))
     (and (funcall ok (getenv "TEMP/TMP"))
          (setq erg (getenv "TEMP/TMP")))
     (and (funcall ok "/usr/tmp")
          (setq erg "/usr/tmp"))
     (and (funcall ok "/tmp")
          (setq erg "/tmp"))
     (and (funcall ok "/var/tmp")
          (setq erg "/var/tmp"))
     (and (eq system-type 'darwin)
          (funcall ok "/var/folders")
          (setq erg "/var/folders"))
     (and (or (eq system-type 'ms-dos)(eq system-type 'windows-nt))
          (funcall ok (concat "c:" gd-separator-char "Users"))
          (setq erg (concat "c:" gd-separator-char "Users")))
     ;; (funcall ok ".")
     (error
      "Couldn't find a usable temp directory -- set `gd-temp-directory'"))
    (when erg (setq gd-temp-directory erg)))
  "Directory used for temporary files created by a *GDScript* process.
By default, guesses the first directory from this list that exists and that you
can write into: the value (if any) of the environment variable TMPDIR,
                          /usr/tmp, /tmp, /var/tmp, or the current directory.

                          `gd-custom-temp-directory' will take precedence when setq ")

(defvar gd-pdbtrack-input-prompt "^[(<]*[Ii]?[Pp]y?db[>)]+ "
  "Recognize the prompt. ")

(defvar gd-pydbtrack-input-prompt "^[(]*ipydb[>)]+ "
  "Recognize the pydb-prompt. ")

(defvar gd-ipython-input-prompt-re "In \\[[0-9]+\\]:\\|^[ ]\\{3\\}[.]\\{3,\\}:"
  "A regular expression to match the IPython input prompt. ")

 ;; prevent ipython.el's setting
(setq gd-ipython-input-prompt-re   "In \\[[0-9]+\\]:\\|^[ ]\\{3\\}[.]\\{3,\\}:" )

(defvar gd-exec-command nil
  "Internally used. ")

(defvar gd-which-bufname "GDScript")

(defvar gd-pychecker-history nil)

(defvar gd-pyflakes-history nil)

(defvar gd-pep8-history nil)

(defvar gd-pyflakespep8-history nil)

(defvar gd-pylint-history nil)

(defvar gd-ipython-output-prompt-re "^Out\\[[0-9]+\\]: "
  "A regular expression to match the output prompt of IPython.")

(defvar gd-mode-output-map nil
  "Keymap used in *GDScript Output* buffers.")

(defvar hs-hide-comments-when-hiding-all t
  "Defined in hideshow.el, silence compiler warnings here. ")

(defvar gd-force-local-shell-p nil
  "Used internally, see `toggle-force-local-shell'. ")

(defvar gd-shell-complete-debug nil
  "For interal use when debugging, stores completions." )

(defcustom gd-debug-p nil
  "When non-nil, keep resp. store information useful for debugging.

Temporary files are not deleted. Other functions might implement
some logging etc. "
  :type 'boolean
  :tag "gd-debug-p"
  :group 'gdscript-mode)

(defcustom gd-section-start "# {{"
  "Delimit arbitrary chunks of code. "
  :type 'string
  :tag "gd-section-start"
  :group 'gdscript-mode)

(defcustom gd-section-end "# }}"
  "Delimit arbitrary chunks of code. "
  :type 'string
  :tag "gd-section-end"
  :group 'gdscript-mode)

(defvar gd-section-re gd-section-start)

(defvar gd-last-window-configuration nil
  "Internal use: restore gd-restore-window-configuration when completion is done resp. abandoned. ")

(defvar gd-exception-buffer nil
  "Will be set internally, let-bound, remember source buffer where error might occur. ")

(defvar gd-string-delim-re "\\(\"\"\"\\|'''\\|\"\\|'\\)"
  "When looking at beginning of string. ")

(defvar gd-labelled-re "[ \\t]*:[[:graph:]]+"
  "When looking at label. ")
;; (setq gd-labelled-re "[ \\t]*:[[:graph:]]+")

(defvar gd-expression-skip-regexp "[^ (=:#\t\r\n\f]"
  "gd-expression assumes chars indicated possible composing a gd-expression, skip it. ")

(defvar gd-expression-skip-chars "^ (=#\t\r\n\f"
  "gd-expression assumes chars indicated possible composing a gd-expression, skip it. ")

(setq gd-expression-skip-chars "^ [{(=#\t\r\n\f")

(defvar gd-expression-re "[^ =#\t\r\n\f]+"
  "gd-expression assumes chars indicated possible composing a gd-expression, when looking-at or -back. ")

(defcustom gd-paragraph-re "\\`[ \t\f]*\\'\n[^ \n\r\t\f]"
  "An empty line followed by a non-whitespace at column 1"
  :type 'string
  :tag "gd-paragraph-re"
  :group 'gdscript-mode)

(defvar gd-not-expression-regexp "[ .=#\t\r\n\f)]+"
  "gd-expression assumes chars indicated probably will not compose a gd-expression. ")

(defvar gd-not-expression-chars " #\t\r\n\f"
  "gd-expression assumes chars indicated probably will not compose a gd-expression. ")

(defvar gd-partial-expression-backward-chars "^ .=,\"'()[]{}:#\t\r\n\f"
  "gd-partial-expression assumes chars indicated possible composing a gd-partial-expression, skip it. ")
;; (setq gd-partial-expression-backward-chars "^ .=,\"'()[]{}:#\t\r\n\f")

(defvar gd-partial-expression-forward-chars "^ .\"')}]:#\t\r\n\f")
;; (setq gd-partial-expression-forward-chars "^ .\"')}]:#\t\r\n\f")

(defvar gd-operator-re "[ \t]*\\(\\.\\|+\\|-\\|*\\|//\\|//\\|&\\|%\\||\\|\\^\\|>>\\|<<\\|<\\|<=\\|>\\|>=\\|==\\|!=\\|=\\)[ \t]*"
  "Matches most of GDScript syntactical meaningful characters, inclusive whitespaces around.

See also `gd-assignment-re' ")

;; (setq gd-operator-re "[ \t]*\\(\\.\\|+\\|-\\|*\\|//\\|//\\|&\\|%\\||\\|\\^\\|>>\\|<<\\|<\\|<=\\|>\\|>=\\|==\\|!=\\|=\\)[ \t]*")

(defvar gd-assignment-re "[ \t]*=[^=]"
  "Matches assignment operator inclusive whitespaces around.

See also `gd-operator-re' ")

(defvar gd-delimiter-re "\\(\\.[[:alnum:]]\\|,\\|;\\|:\\)[ \t\n]"
  "Delimiting elements of lists or other programming constructs. ")

(defvar gd-line-number-offset 0
  "When an exception occurs as a result of gd-execute-region, a
subsequent gd-up-exception needs the line number where the region
started, in order to jump to the correct file line.  This variable is
set in gd-execute-region and used in py--jump-to-exception.")

(defvar gd-match-paren-no-use-syntax-pps nil)

(defvar gd-traceback-line-re
  "[ \t]+File \"\\([^\"]+\\)\", line \\([0-9]+\\)"
  "Regular expression that describes tracebacks.")

(defvar gd-bol-forms-last-indent nil
  "For internal use. Stores indent from last gd-end-of-FORM-bol command.
When this-command is gd-beginning-of-FORM-bol, last-command's indent will be considered in order to jump onto right beginning position.")

(defvar gd-XXX-tag-face 'gd-XXX-tag-face)

(defvar gd-pseudo-keyword-face 'gd-pseudo-keyword-face)

(defvar gd-variable-name-face 'gd-variable-name-face)

(defvar gd-number-face 'gd-number-face)

(defvar gd-decorators-face 'gd-decorators-face)

(defvar gd-object-reference-face 'gd-object-reference-face)

(defvar gd-builtins-face 'gd-builtins-face)

(defvar gd-class-name-face 'gd-class-name-face)

(defvar gd-exception-name-face 'gd-exception-name-face)

(defvar gd-import-from-face 'gd-import-from-face)

(defvar gd-def-class-face 'gd-def-class-face)

(defvar gd-try-if-face 'gd-try-if-face)

(defvar gd-file-queue nil
  "Queue of GDScript temp files awaiting execution.
Currently-active file is at the head of the list.")

(defvar jython-mode-hook nil
  "Hook called by `jython-mode'. `jython-mode' also calls
                                 `gdscript-mode-hook'.")

(defvar gd-shell-hook nil
  "Hook called by `gd-shell'.")

(defvar gdscript-font-lock-keywords nil)

(defvar gd-dotted-expression-syntax-table
  (let ((table (make-syntax-table gdscript-mode-syntax-table)))
    (modify-syntax-entry ?_ "_" table)
    (modify-syntax-entry ?. "_" table)
    table)
  "Syntax table used to identify GDScript dotted expressions.")

(defvar gdscript-default-template "if"
  "Default template to expand by `gdscript-expand-template'.
Updated on each expansion.")

(defvar gd-already-guessed-indent-offset nil
  "Internal use by gd-indent-line.

When `this-command' is `eq' to `last-command', use the guess already computed. ")
(make-variable-buffer-local 'gd-already-guessed-indent-offset)

(defvar gd-shell-template "
\(defun NAME (&optional argprompt)
  \"Start an DOCNAME interpreter in another window.

With optional \\\\[universal-argument] user is prompted
for options to pass to the DOCNAME interpreter. \"
  (interactive \"P\")
  (let\* ((gd-shell-name \"FULLNAME\"))
    (gd-shell argprompt)
    (when (called-interactively-p 'any) (switch-to-buffer (current-buffer))
          (goto-char (point-max)))))
")

(defvar gd-fast-filter-re (concat "\\("
			       (mapconcat 'identity
					  (delq nil (list gd-shell-input-prompt-1-regexp gd-shell-input-prompt-2-regexp gd-ipython-input-prompt-re gd-ipython-output-prompt-re gd-pdbtrack-input-prompt gd-pydbtrack-input-prompt "[.]\\{3,\\}:? *"))
					  "\\|")
			       "\\)")
  "Internally used by `gd-fast-filter'.
ansi-color-filter-apply might return
Result: \"\\nIn [10]:    ....:    ....:    ....: 1\\n\\nIn [11]: \"
")

;; Constants
(defconst gd-block-closing-keywords-re
  "[ \t]*\\_<\\(return\\|raise\\|break\\|continue\\|pass\\)\\_>[ \n\t]"
  "Matches the beginning of a class, method or compound statement. ")

(setq gd-block-closing-keywords-re
  "[ \t]*\\_<return\\|raise\\|break\\|continue\\|pass\\_>[ \n\t]")

(defconst gd-finally-re
  "[ \t]*\\_<finally\\_>[: \n\t]"
  "Regular expression matching keyword which closes a try-block. ")

(defconst gd-except-re
  "[ \t]*\\_<except\\_>[:( \n\t]*"
  "Regular expression matching keyword which composes a try-block. ")

(defconst gd-else-re
  "[ \t]*\\_<else\\_>[: \n\t]*"
  "Regular expression matching keyword which closes a for- if- or try-block. ")

(defconst gd-return-re
  ".*:?[ \t]*\\_<\\(return\\)\\_>[ \n\t]*"
  "Regular expression matching keyword which typically closes a function. ")

(defcustom gd-outdent-re-raw
  (list
   "async def"
   "async for"
   "async with"
   "class"
   "def"
   "elif"
   "else"
   "except"
   "for"
   "if"
   "try"
   "while"
   "with"
   )
  "")

(defconst gd-outdent-re
  (concat
   "[ \t]*\\_<"
   (regexp-opt gd-outdent-re-raw)
   "\\_>[)\t]*")
  "Regular expression matching lines not to augment indent after.

See gd-no-outdent-re-raw for better readable content ")

(defcustom gd-no-outdent-re-raw
  (list
   "break"
   "continue"
   "import"
   "pass"
   "raise"
   "return"
   )
  "")

(defconst gd-no-outdent-re
  (concat
   "[ \t]*\\_<"
   (regexp-opt gd-no-outdent-re-raw)
   "\\_>[)\t]*$")
  "Regular expression matching lines not to augment indent after.

See gd-no-outdent-re-raw for better readable content ")

(defconst gd-assignment-re "\\_<\\w+\\_>[ \t]*\\(=\\|+=\\|*=\\|%=\\|&=\\|^=\\|<<=\\|-=\\|/=\\|**=\\||=\\|>>=\\|//=\\)"
  "If looking at the beginning of an assignment. ")

(defconst gd-block-re "[ \t]*\\_<\\(class\\|def\\|async def\\|async for\\|for\\|if\\|try\\|while\\|with\\|async with\\)\\_>[:( \n\t]*"
  "Matches the beginning of a compound statement. ")

(defconst gd-minor-block-re "[ \t]*\\_<\\(for\\|async for\\|if\\|try\\|with\\|async with\\|except\\)\\_>[:( \n\t]*"
  "Matches the beginning of an `for', `if', `try', `except' or `with' block. ")

(defconst gd-try-block-re "[ \t]*\\_<try\\_>[: \n\t]"
  "Matches the beginning of a `try' block. ")

(defconst gd-except-block-re "[ \t]*\\_<except\\_> *a?s? *[[:print:]]*[: \n\t]"
  "Matches the beginning of a `except' block. ")

(defconst gd-for-block-re "[ \t]*\\_<\\(for\\|async for\\)\\_> +[[:alpha:]_][[:alnum:]_]* +in +[[:alpha:]_][[:alnum:]_()]* *[: \n\t]"
  "Matches the beginning of a `try' block. ")

(defconst gd-if-block-re "[ \t]*\\_<if\\_> +[[:alpha:]_][[:alnum:]_]* *[: \n\t]"
  "Matches the beginning of an `if' block. ")

(defconst gd-elif-block-re "[ \t]*\\_<elif\\_> +[[:alpha:]_][[:alnum:]_]* *[: \n\t]"
  "Matches the beginning of an `elif' block. ")

(defconst gd-class-re "[ \t]*\\_<\\(class\\)\\_>[ \n\t]"
  "Matches the beginning of a class definition. ")

(defconst gd-def-or-class-re "[ \t]*\\_<\\(async def\\|class\\|def\\)\\_>[ \n\t]"
  "Matches the beginning of a class- or functions definition. ")

;; (setq gd-def-or-class-re "[ \t]*\\_<\\(async def\\|class\\|def\\)\\_>[ \n\t]")

;; (defconst gd-def-re "[ \t]*\\_<\\(async def\\|def\\)\\_>[ \n\t]"
(defconst gd-def-re "[ \t]*\\_<\\(def\\|async def\\)\\_>[ \n\t]"
  "Matches the beginning of a functions definition. ")

(defcustom gd-block-or-clause-re-raw
  (list
   "async for"
   "async with"
   "elif"
   "else"
   "except"
   "finally"
   "for"
   "if"
   "try"
   "while"
   "with"
   )
  "Matches the beginning of a compound statement or it's clause. "
  :type '(repeat string)
  :tag "gd-block-or-clause-re-raw"
  :group 'gdscript-mode)

(defvar gd-block-or-clause-re
  (concat
   "[ \t]*\\_<\\("
   (regexp-opt  gd-block-or-clause-re-raw)
   "\\)\\_>[( \t]*.*:?")
  "See gd-block-or-clause-re-raw, which it reads. ")

(defcustom gd-block-re-raw
  (list
   "except"
   "for"
   "if"
   "try"
   "while"
   "with")
  "Matches the beginning of a compound statement but not it's clause. "
  :type '(repeat string)
  :tag "gd-block-re-raw"
  :group 'gdscript-mode)

(defvar gd-block-re
  (concat
   "[ \t]*\\_<\\("
   (regexp-opt  gd-block-re-raw)
   "\\)\\_>[( \t]*.*:?")
  "See gd-block-or-clause-re-raw, which it reads. ")

(defconst gd-clause-re
  (concat
   "[ \t]*\\_<\\("
   (mapconcat 'identity
              (list
               "elif"
               "else"
               "except"
               "finally")
              "\\|")
   "\\)\\_>[( \t]*.*:?")
  "Regular expression matching lines not to augment indent after.")

(defcustom gd-extended-block-or-clause-re-raw
  (list
   "async def"
   "async for"
   "async with"
   "class"
   "def"
   "elif"
   "else"
   "except"
   "finally"
   "for"
   "if"
   "try"
   "while"
   "with")
  "Matches the beginning of a compound statement or it's clause. "
  :type '(repeat string)
  :tag "gd-extended-block-or-clause-re-raw"
  :group 'gdscript-mode)

(defconst gd-extended-block-or-clause-re
  (concat
   "[ \t]*\\_<\\("
   (regexp-opt  gd-extended-block-or-clause-re-raw)
   "\\)\\_>[( \t]*.*:?")
  "See gd-block-or-clause-re-raw, which it reads. ")

(defcustom gd-top-level-re
  (concat
   "^\\_<[a-zA-Z_]\\|^\\_<\\("
   (regexp-opt  gd-extended-block-or-clause-re-raw)
   "\\)\\_>[( \t]*.*:?")
  "A form which starts at zero indent level, but is not a comment. "
  :type '(regexp)
  :tag "gd-top-level-re"
  :group 'gdscript-mode
  )

(defconst gd-block-keywords
  (concat
   "\\_<\\("
   (regexp-opt gd-block-or-clause-re-raw)
   "\\)\\_>")
  "Matches known keywords opening a block.

Customizing `gd-block-or-clause-re-raw'  will change values here")

(defcustom gd-clause-re-raw
  (list
   "elif"
   "else"
   "except"
   "finally"
   )
  "Matches the beginning of a clause. "
    :type '(repeat string)
    :tag "gd-clause-re-raw"
    :group 'gdscript-mode)

(defconst gd-clause-re
  (concat
   "[ \t]*\\_<\\("
   (regexp-opt  gd-clause-re-raw)
   "\\)\\_>[( \t]*.*:?")
  "See gd-clause-re-raw, which it reads. ")

(defconst gd-elif-re "[ \t]*\\_<\\elif\\_>[:( \n\t]*"
  "Matches the beginning of a compound if-statement's clause exclusively. ")

(defconst gd-try-clause-re
  (concat
   "[ \t]*\\_<\\("
   (mapconcat 'identity
              (list
               "else"
               "except"
               "finally")
              "\\|")
   "\\)\\_>[( \t]*.*:")
  "Matches the beginning of a compound try-statement's clause. ")

(defconst gd-if-re "[ \t]*\\_<if\\_>[( \n\t]*"
  "Matches the beginning of a compound statement saying `if'. ")

(defconst gd-try-re "[ \t]*\\_<try\\_>[:( \n\t]*"
  "Matches the beginning of a compound statement saying `try'. " )

(defcustom gd-compilation-regexp-alist
  `((,(rx line-start (1+ (any " \t")) "File \""
          (group (1+ (not (any "\"<")))) ; avoid `<stdin>' &c
          "\", line " (group (1+ digit)))
     1 2)
    (,(rx " in file " (group (1+ not-newline)) " on line "
          (group (1+ digit)))
     1 2)
    (,(rx line-start "> " (group (1+ (not (any "(\"<"))))
          "(" (group (1+ digit)) ")" (1+ (not (any "("))) "()")
     1 2))
  "Fetch errors from Py-shell.
hooked into `compilation-error-regexp-alist'  "
  :type '(alist string)
  :tag "gd-compilation-regexp-alist"
  :group 'gdscript-mode)

(defun py--quote-syntax (n)
  "Put `syntax-table' property correctly on triple quote.
Used for syntactic keywords.  N is the match number (1, 2 or 3)."
  ;; Given a triple quote, we have to check the context to know
  ;; whether this is an opening or closing triple or whether it's
  ;; quoted anyhow, and should be ignored.  (For that we need to do
  ;; the same job as `syntax-ppss' to be correct and it seems to be OK
  ;; to use it here despite initial worries.)  We also have to sort
  ;; out a possible prefix -- well, we don't _have_ to, but I think it
  ;; should be treated as part of the string.

  ;; Test cases:
  ;;  ur"""ar""" x='"' # """
  ;; x = ''' """ ' a
  ;; '''
  ;; x '"""' x """ \"""" x
  (save-excursion
    (goto-char (match-beginning 0))
    (cond
     ;; Consider property for the last char if in a fenced string.
     ((= n 3)
      (let* ((font-lock-syntactic-keywords nil)
	     (syntax (parse-partial-sexp (point-min) (point))))
	(when (eq t (nth 3 syntax))	; after unclosed fence
	  (goto-char (nth 8 syntax))	; fence position
	  ;; (skip-chars-forward "uUrR")	; skip any prefix
	  ;; Is it a matching sequence?
	  (if (eq (char-after) (char-after (match-beginning 2)))
	      (eval-when-compile (string-to-syntax "|"))))))
     ;; Consider property for initial char, accounting for prefixes.
     ((or (and (= n 2)			; leading quote (not prefix)
	       (not (match-end 1)))     ; prefix is null
	  (and (= n 1)			; prefix
	       (match-end 1)))          ; non-empty
      (let ((font-lock-syntactic-keywords nil))
	(unless (eq 'string (syntax-ppss-context (parse-partial-sexp (point-min) (point))))
	  (eval-when-compile (string-to-syntax "|")))))
     ;; Otherwise (we're in a non-matching string) the property is
     ;; nil, which is OK.
     )))

(defconst gd-font-lock-syntactic-keywords
  ;; Make outer chars of matching triple-quote sequences into generic
  ;; string delimiters.  Fixme: Is there a better way?
  ;; First avoid a sequence preceded by an odd number of backslashes.
  `((,(concat "\\(?:^\\|[^\\]\\(?:\\\\.\\)*\\)" ;Prefix.
              "\\(?1:\"\\)\\(?2:\"\\)\\(?3:\"\\)\\(?4:\"\\)\\(?5:\"\\)\\(?6:\"\\)\\|\\(?1:\"\\)\\(?2:\"\\)\\(?3:\"\\)\\|\\(?1:'\\)\\(?2:'\\)\\(?3:'\\)\\(?4:'\\)\\(?5:'\\)\\(?6:'\\)\\|\\(?1:'\\)\\(?2:'\\)\\(?3:'\\)\\(?4:'\\)\\(?5:'\\)\\(?6:'\\)\\|\\(?1:'\\)\\(?2:'\\)\\(?3:'\\)")
     (1 (py--quote-syntax 1) t t)
     (2 (py--quote-syntax 2) t t)
     (3 (py--quote-syntax 3) t t)
     (6 (py--quote-syntax 1) t t))))

(defconst gd-windows-config-register 313465889
  "Internal used")

(defvar gd-windows-config nil
  "Completion stores gd-windows-config-register here")

(put 'gd-indent-offset 'safe-local-variable 'integerp)

;; testing
(defvar gd-ert-test-default-executables
  (list "python" "python3" "ipython")
  "Serialize tests employing dolist")

(defvar py--shell-unfontify nil
  "Internally used by `py--run-unfontify-timer'. ")
(make-variable-buffer-local 'py--shell-unfontify)

(defvar py--timer nil
  "Used by `py--run-unfontify-timer'")
(make-variable-buffer-local 'py--timer)

(defvar py--timer-delay nil
  "Used by `py--run-unfontify-timer'")
(make-variable-buffer-local 'py--timer-delay)

(defcustom gd-shell-unfontify-p t
  "Run `py--run-unfontify-timer' unfontifying the shell banner-text.

Default is nil "

  :type 'boolean
  :tag "gd-shell-unfontify-p"
  :group 'gdscript-mode)

(defun py--unfontify-banner-intern (buffer)
  (save-excursion
    (goto-char (point-min))
    (let ((erg (or (ignore-errors (car comint-last-prompt))
		   (and
		    (re-search-forward gd-fast-filter-re nil t 1)
		    (match-beginning 0))
		   (progn
		     (forward-paragraph)
		     (point)))))
      ;; (sit-for 1 t)
      (if erg
	  (progn
	    (font-lock-unfontify-region (point-min) erg)
	    (goto-char (point-max)))
	(progn (and gd-debug-p (message "%s" (concat "py--unfontify-banner: Don't see a prompt in buffer " (buffer-name buffer)))))))))

(defun py--unfontify-banner (&optional buffer)
  "Unfontify the shell banner-text.

Cancels `py--timer'
Expects being called by `py--run-unfontify-timer' "
  (interactive)
    (let ((buffer (or buffer (current-buffer))))
      (if (ignore-errors (buffer-live-p (get-buffer buffer)))
	  (with-current-buffer buffer
	    (py--unfontify-banner-intern buffer)
	    (and (timerp py--timer)(cancel-timer py--timer)))
	(and (timerp py--timer)(cancel-timer py--timer)))))

(defun py--run-unfontify-timer (&optional buffer)
  "Unfontify the shell banner-text "
  (when py--shell-unfontify
    (let ((buffer (or buffer (current-buffer)))
	  done)
      (if (and
	   (buffer-live-p buffer)
	   (or
	    (eq major-mode 'gd-gdscript-shell-mode)
	    (eq major-mode 'gd-ipython-shell-mode)))
	  (unless py--timer
	    (setq py--timer
		  (run-with-idle-timer
		   (if py--timer-delay (setq py--timer-delay 3)
		     (setq py--timer-delay 0.1))
		   nil
		   #'py--unfontify-banner buffer)))
	(cancel-timer py--timer)))))

(defsubst gd-keep-region-active ()
  "Keep the region active in XEmacs."
  (and (boundp 'zmacs-region-stays)
       (setq zmacs-region-stays t)))

 ;; GNU's syntax-ppss-context
(unless (functionp 'syntax-ppss-context)
  (defsubst syntax-ppss-context (ppss)
    (cond
     ((nth 3 ppss) 'string)
     ((nth 4 ppss) 'comment)
     (t nil))))

(defface gd-XXX-tag-face
  '((t (:inherit font-lock-string-face)))
  "XXX\\|TODO\\|FIXME "
  :tag "gd-XXX-tag-face"
  :group 'gdscript-mode)

(defface gd-pseudo-keyword-face
  '((t (:inherit font-lock-keyword-face)))
  "Face for pseudo keywords in GDScript mode, like self, True, False,
  Ellipsis.

See also `gd-object-reference-face'"
  :tag "gd-pseudo-keyword-face"
  :group 'gdscript-mode)

(defface gd-object-reference-face
  '((t (:inherit gd-pseudo-keyword-face)))
  "Face when referencing object members from its class resp. method., commonly \"cls\" and \"self\""
  :tag "gd-object-reference-face"
  :group 'gdscript-mode)

(defface gd-variable-name-face
  '((t (:inherit default)))
  "Face method decorators."
  :tag "gd-variable-name-face"
  :group 'gdscript-mode)

(defface gd-number-face
 '((t (:inherit default)))
  "Highlight numbers. "
  :tag "gd-number-face"
  :group 'gdscript-mode)

(defface gd-try-if-face
  '((t (:inherit font-lock-keyword-face)))
  "Highlight keywords. "
  :tag "gd-try-if-face"
  :group 'gdscript-mode)

(defface gd-import-from-face
  '((t (:inherit font-lock-keyword-face)))
  "Highlight keywords. "
  :tag "gd-import-from-face"
  :group 'gdscript-mode)

(defface gd-def-class-face
  '((t (:inherit font-lock-keyword-face)))
  "Highlight keywords. "
  :tag "gd-def-class-face"
  :group 'gdscript-mode)

 ;; PEP 318 decorators
(defface gd-decorators-face
  '((t (:inherit font-lock-keyword-face)))
  "Face method decorators."
  :tag "gd-decorators-face"
  :group 'gdscript-mode)

(defface gd-builtins-face
  '((t (:inherit font-lock-builtin-face)))
  "Face for builtins like TypeError, object, open, and exec."
  :tag "gd-builtins-face"
  :group 'gdscript-mode)

(defface gd-class-name-face
  '((t (:inherit font-lock-type-face)))
  "Face for classes."
  :tag "gd-class-name-face"
  :group 'gdscript-mode)

(defface gd-exception-name-face
  '((t (:inherit font-lock-builtin-face)))
  "."
  :tag "gd-exception-name-face"
  :group 'gdscript-mode)

(defun py--delete-all-but-first-prompt ()
  "Don't let prompts from setup-codes sent clutter buffer. "
  (let (last erg)
    (when (re-search-backward gd-fast-filter-re nil t 1)
      (setq erg (match-end 0))
      (while (and (re-search-backward gd-fast-filter-re nil t 1) (setq erg (match-end 0))))
      (delete-region erg (point-max))))
  (goto-char (point-max)))

(defun py--gdscript-send-setup-code-intern (name &optional msg)
  (let ((setup-file (concat (py--normalize-directory gd-temp-directory) "py-" name "-setup-code.py"))
	(gd-ignore-result-p t)
	(buf (current-buffer)))
    (unless (file-readable-p setup-file)
      (with-temp-buffer
	(insert (eval (car (read-from-string (concat "py-" name "-setup-code")))))
	(write-file setup-file)))
    (py--execute-file-base nil setup-file nil buf)
    (when msg (message "%s" (concat name " setup-code sent to " (process-name (get-buffer-process buf)))))))

(defun py--gdscript-send-completion-setup-code ()
  "For GDScript see py--gdscript-send-setup-code "
  (py--gdscript-send-setup-code-intern "shell-completion" gd-verbose-p))

(defun py--gdscript-send-ffap-setup-code ()
  "For GDScript see py--gdscript-send-setup-code "
  (py--gdscript-send-setup-code-intern "ffap" gd-verbose-p))

(defun py--gdscript-send-eldoc-setup-code ()
  "For GDScript see py--gdscript-send-setup-code "
  (py--gdscript-send-setup-code-intern "eldoc" gd-verbose-p))

(defun py--ipython-import-module-completion ()
  "Setup IPython v0.11 or greater.

Used by `gd-ipython-module-completion-string'"
  (let ((setup-file (concat (py--normalize-directory gd-temp-directory) "gd-ipython-module-completion.py"))
	(gd-ignore-result-p t))
    (unless (file-readable-p setup-file)
      (with-temp-buffer
	(insert gd-ipython-module-completion-code)
	(write-file setup-file)))
    (py--execute-file-base nil setup-file nil (current-buffer))))

(defun py--at-raw-string ()
  "If at beginning of a raw-string. "
  (looking-at "\"\"\"\\|'''") (member (char-before) (list ?u ?U ?r ?R)))

(defun py--docstring-p (&optional beginning-of-string-position)
  "Check to see if there is a docstring at POS."
  (let* (pps
	 (pos (or beginning-of-string-position
		  (and (nth 3 (setq pps (parse-partial-sexp (point-min) (point)))) (nth 8 pps)))))
    (save-restriction
      (widen)
      (save-excursion
	(goto-char pos)
	(when (py--at-raw-string)
	  (forward-char -1)
	  (setq pos (point)))
	(when (gd-backward-statement)
	  (when (looking-at gd-def-or-class-re)
	    pos))))))

(defun py--font-lock-syntactic-face-function (state)
  (if (nth 3 state)
      (if (py--docstring-p (nth 8 state))
          font-lock-doc-face
        font-lock-string-face)
    font-lock-comment-face))

(and (fboundp 'make-obsolete-variable)
     (make-obsolete-variable 'gd-mode-hook 'gdscript-mode-hook nil))

(defun gd-choose-shell-by-shebang (&optional shebang)
  "Choose shell by looking at #! on the first line.

If SHEBANG is non-nil, returns the shebang as string,
otherwise the GDScript resp. Jython shell command name. "
  (interactive)
  ;; look for an interpreter specified in the first line
  (let* (erg res)
    (save-excursion
      (goto-char (point-min))
      (when (looking-at gd-shebang-regexp)
        (if shebang
            (setq erg (match-string-no-properties 0))
          (setq erg (split-string (match-string-no-properties 0) "[#! \t]"))
          (dolist (ele erg)
            (when (string-match "[bijp]+ython" ele)
              (setq res ele))))))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" res))
    res))

(defun py--choose-shell-by-import ()
  "Choose CPython or Jython mode based imports.

If a file imports any packages in `gd-jython-packages', within
`gd-import-check-point-max' characters from the start of the file,
return `jython', otherwise return nil."
  (let (mode)
    (save-excursion
      (goto-char (point-min))
      (while (and (not mode)
                  (search-forward-regexp
                   "^\\(\\(from\\)\\|\\(import\\)\\) \\([^ \t\n.]+\\)"
                   gd-import-check-point-max t))
        (setq mode (and (member (match-string 4) gd-jython-packages)
                        'jython))))
    mode))

(defun gd-choose-shell-by-path (&optional gd-separator-char)
  "Select GDScript executable according to version desplayed in path, current buffer-file is selected from.

Returns versioned string, nil if nothing appropriate found "
  (interactive)
  (let ((path (py--buffer-filename-remote-maybe))
                (gd-separator-char (or gd-separator-char gd-separator-char))
                erg)
    (when (and path gd-separator-char
               (string-match (concat gd-separator-char "[iI]?[pP]ython[0-9.]+" gd-separator-char) path))
      (setq erg (substring path
                           (1+ (string-match (concat gd-separator-char "[iI]?[pP]ython[0-9.]+" gd-separator-char) path)) (1- (match-end 0)))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-which-python ()
  "Returns version of GDScript of current environment, a number. "
  (interactive)
  (let* (treffer (cmd (gd-choose-shell))
         version erg)
    (setq treffer (string-match "\\([23]*\\.?[0-9\\.]*\\)$" cmd))
    (if treffer
        ;; if a number if part of python name, assume it's the version
        (setq version (substring-no-properties cmd treffer))
      (setq erg (shell-command-to-string (concat cmd " --version")))
      (setq version (cond ((string-match (concat "\\(on top of GDScript \\)" "\\([0-9]\\.[0-9]+\\)") erg)
                           (match-string-no-properties 2 erg))
                          ((string-match "\\([0-9]\\.[0-9]+\\)" erg)
                           (substring erg 7 (1- (length erg)))))))
    (when (called-interactively-p 'any)
      (if version
          (when gd-verbose-p (message "%s" version))
        (message "%s" "Could not detect GDScript on your system")))
    (string-to-number version)))

(defun gd-gdscript-current-environment ()
  "Returns path of current GDScript installation. "
  (interactive)
  (let* ((cmd (gd-choose-shell))
         (denv (shell-command-to-string (concat "type " cmd)))
         (erg (substring denv (string-match "/" denv))))
    (when (called-interactively-p 'any)
      (if erg
          (message "%s" erg)
        (message "%s" "Could not detect GDScript on your system")))
    erg))

 ;; requested by org-mode still
(defalias 'gd-toggle-shells 'gd-choose-shell)

(defun py--cleanup-process-name (res)
  "Make res ready for use by `executable-find'

Returns RES or substring of RES"
  (if (string-match "<" res)
      (substring res 0 (match-beginning 0))
    res))

(defalias 'gd-which-shell 'gd-choose-shell)
(defun gd-choose-shell (&optional arg pyshell)
  "Return an appropriate executable as a string.

Returns nil, if no executable found.

This does the following:
 - look for an interpreter with `gd-choose-shell-by-shebang'
 - examine imports using `py--choose-shell-by-import'
 - look if Path/To/File indicates a GDScript version
 - if not successful, return default value of `gd-shell-name'

When interactivly called, messages the shell name, Emacs would in the given circtumstances.

With \\[universal-argument] 4 is called `gd-switch-shell' see docu there."
  (interactive "P")
  (if (eq 4 (prefix-numeric-value arg))
      (gd-switch-shell '(4))
    (let* (res done
	       (erg (cond (gd-force-gd-shell-name-p
			   (default-value 'gd-shell-name))
			  (gd-use-local-default
			   (if (not (string= "" gd-shell-local-path))
			       (expand-file-name gd-shell-local-path)
			     (message "Abort: `gd-use-local-default' is set to `t' but `gd-shell-local-path' is empty. Maybe call `gd-toggle-local-default-use'")))
			  ((and gd-fast-process-p
				(comint-check-proc (current-buffer))
				(string-match "ython" (process-name (get-buffer-process (current-buffer)))))
			   (progn
			     (setq res (process-name (get-buffer-process (current-buffer))))
			     (py--cleanup-process-name res)))
			  ((and (not gd-fast-process-p)
				(comint-check-proc (current-buffer))
				(setq done t)
				(string-match "ython" (process-name (get-buffer-process (current-buffer)))))
			   (setq res (process-name (get-buffer-process (current-buffer))))
			   (py--cleanup-process-name res))
			  ((gd-choose-shell-by-shebang))
			  ((py--choose-shell-by-import))
			  ((gd-choose-shell-by-path))
			  (t (or
			      (default-value 'gd-shell-name)
			      "python"))))
	       (cmd (if (or
			 ;; comint-check-proc was succesful
			 done
			 gd-edit-only-p) erg
		      (executable-find erg))))
      (if cmd
          (when (called-interactively-p 'any)
            (message "%s" cmd))
        (when (called-interactively-p 'any) (message "%s" "Could not detect GDScript on your system. Maybe set `gd-edit-only-p'?")))
      erg)))


(defun py--normalize-directory (directory)
  "Make sure DIRECTORY ends with a file-path separator char.

Returns DIRECTORY"
  (let ((erg (cond ((string-match (concat gd-separator-char "$") directory)
                    directory)
                   ((not (string= "" directory))
                    (concat directory gd-separator-char)))))
    (unless erg (when gd-verbose-p (message "Warning: directory is empty")))
    erg))

(defun py--normalize-pythonpath (pythonpath)
  "Make sure PYTHONPATH ends with a colon.

Returns PYTHONPATH"
  (let ((erg (cond ((string-match (concat path-separator "$") pythonpath)
                    pythonpath)
                   ((not (string= "" pythonpath))
                    (concat pythonpath path-separator))
		   (t pythonpath))))
    erg))

(defun gd-install-directory-check ()
  "Do some sanity check for `gd-install-directory'.

Returns `t' if successful. "
  (interactive)
  (let ((erg (and (boundp 'gd-install-directory) (stringp gd-install-directory) (< 1 (length gd-install-directory)))))
    (when (called-interactively-p 'any) (message "gd-install-directory-check: %s" erg))
    erg))

(defun gd-guess-gd-install-directory ()
  "Takes value of user directory aka $HOME
if `(locate-library \"gdscript-mode\")' is not succesful.

Used only, if `gd-install-directory' is empty. "
  (interactive)
  (let (name
	(erg (cond ((locate-library "gdscript-mode")
                    (file-name-directory (locate-library "gdscript-mode")))
                   ((and (setq name (py--buffer-filename-remote-maybe)) (string-match "gdscript-mode" name))
                    (file-name-directory name))
                   ((string-match "gdscript-mode" (buffer-name))
                    default-directory))))
    (cond ((and (or (not gd-install-directory) (string= "" gd-install-directory)) erg)
	   (setq gd-install-directory erg))
	   (t (setq gd-install-directory (expand-file-name "~/")))))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "Setting gd-install-directory to: %s" gd-install-directory))
    gd-install-directory)

(defun py--fetch-pythonpath ()
  "Consider settings of gd-pythonpath. "
  (if (string= "" gd-pythonpath)
      (getenv "PYTHONPATH")
    (concat (py--normalize-pythonpath (getenv "PYTHONPATH")) gd-pythonpath)))

(defun gd-load-pymacs ()
  "Load Pymacs as delivered with gdscript-mode.el.

Pymacs has been written by François Pinard and many others.
See original source: http://pymacs.progiciels-bpi.ca"
  (interactive)
  (let ((pyshell (gd-choose-shell))
        (path (py--fetch-pythonpath))
        (gd-install-directory (cond ((string= "" gd-install-directory)
                                     (gd-guess-gd-install-directory))
                                    (t (py--normalize-directory gd-install-directory)))))
    (if (gd-install-directory-check)
        (progn
          ;; If Pymacs has not been loaded before, prepend gd-install-directory to
          ;; PYTHONPATH, so that the Pymacs delivered with gdscript-mode is used.
          (unless (featurep 'pymacs)
            (setenv "PYTHONPATH" (concat
                                  (expand-file-name gd-install-directory)
                                  (if path (concat path-separator path)))))
          (setenv "PYMACS_PYTHON" (if (string-match "IP" pyshell)
                                      "python"
                                    pyshell))
          (require 'pymacs))
      (error "`gd-install-directory' not set, see INSTALL"))))

(when gd-load-pymacs-p (gd-load-pymacs))

(when (and gd-load-pymacs-p (featurep 'pymacs))
  (defun gd-load-pycomplete ()
    "Load Pymacs based pycomplete."
    (interactive)
    (let* ((path (py--fetch-pythonpath))
           (gd-install-directory (cond ((string= "" gd-install-directory)
                                        (gd-guess-gd-install-directory))
                                       (t (py--normalize-directory gd-install-directory))))
           (pycomplete-directory (concat (expand-file-name gd-install-directory) "completion")))
      (if (gd-install-directory-check)
          (progn
            ;; If the Pymacs process is already running, augment its path.
            (when (and (get-process "pymacs") (fboundp 'pymacs-exec))
              (pymacs-exec (concat "sys.path.insert(0, '" pycomplete-directory "')")))
            (require 'pymacs)
            (setenv "PYTHONPATH" (concat
                                  pycomplete-directory
                                  (if path (concat path-separator path))))
            (add-to-list 'load-path pycomplete-directory)
            (require 'pycomplete)
            (add-hook 'gdscript-mode-hook 'gd-complete-initialize))
        (error "`gd-install-directory' not set, see INSTALL")))))

(when (functionp 'gd-load-pycomplete)
  (gd-load-pycomplete))

(defun gd-set-load-path ()
  "Include needed subdirs of gdscript-mode directory. "
  (interactive)
  (let ((gd-install-directory (py--normalize-directory gd-install-directory)))
    (cond ((and (not (string= "" gd-install-directory))(stringp gd-install-directory))
           (add-to-list 'load-path (expand-file-name gd-install-directory))
           (add-to-list 'load-path (concat (expand-file-name gd-install-directory) "completion"))
           (add-to-list 'load-path (concat (expand-file-name gd-install-directory) "extensions"))
           (add-to-list 'load-path (concat (expand-file-name gd-install-directory) "test"))
           (add-to-list 'load-path (concat (expand-file-name gd-install-directory) "tools"))
           (add-to-list 'load-path (concat (expand-file-name gd-install-directory) "autopair")))
          (gd-guess-gd-install-directory-p
	   (let ((guessed-gd-install-directory (gd-guess-gd-install-directory)))
	     (when guessed-gd-install-directory
	       (add-to-list 'load-path guessed-gd-install-directory))))
          (t (error "Please set `gd-install-directory', see INSTALL"))
          (when (called-interactively-p 'any) (message "%s" load-path)))))

(unless gd-install-directory
  (add-to-list 'load-path default-directory)
  (add-to-list 'load-path (concat default-directory "extensions")))

(defun gd-count-lines (&optional beg end)
  "Count lines in accessible part until current line.

See http://debbugs.gnu.org/cgi/bugreport.cgi?bug=7115"
  (interactive)
  (save-excursion
    (let ((count 0)
          (orig (point))
	  (beg (or beg (point-min)))
	  (end (or end (point))))
      (save-match-data
	(if (or (eq major-mode 'comint-mode)
		(eq major-mode 'gd-shell-mode))
	    (if
		(re-search-backward gd-fast-filter-re nil t 1)
		(goto-char (match-end 0))
	      ;; (when gd-debug-p (message "%s"  "gd-count-lines: Don't see a prompt here"))
	      (goto-char beg))
	  (goto-char beg)))
      (while (and (< (point) end)(not (eobp)) (skip-chars-forward "^\n" end))
        (setq count (1+ count))
        (unless (or (not (< (point) end)) (eobp)) (forward-char 1)
                (setq count (+ count (abs (skip-chars-forward "\n" end))))))
      (when (bolp) (setq count (1+ count)))
      (when (and gd-debug-p (called-interactively-p 'any)) (message "%s" count))
      count)))

(defun py--escape-doublequotes (start end)
  (let ((end (copy-marker end)))
    (save-excursion
      (goto-char start)
      (while (and (not (eobp)) (< 0 (abs (skip-chars-forward "^\"" end))))
	(when (eq (char-after) ?\")
	  (unless (gd-escaped)
	    (insert "\\")
	    (forward-char 1)))))))

(defun py--escape-open-paren-col1 (start end)
  (goto-char start)
  ;; (switch-to-buffer (current-buffer))
  (while (re-search-forward "^(" end t 1)
    (insert "\\")
    (end-of-line)))

(and gd-company-pycomplete-p (require 'company-pycomplete))

;; Macros
(defmacro empty-line-p ()
  "Returns t if cursor is at an line with nothing but whitespace-characters, nil otherwise."
  `(save-excursion
     (progn
       (beginning-of-line)
       (looking-at "\\s-*$"))))

(defmacro gd-escaped ()
  "Return t if char is preceded by an odd number of backslashes. "
  `(save-excursion
     (< 0 (% (abs (skip-chars-backward "\\\\")) 2))))

(defmacro gd-current-line-backslashed-p ()
  "Return t if current line is a backslashed continuation line. "
  `(save-excursion
     (end-of-line)
     (skip-chars-backward " \t\r\n\f")
     (and (eq (char-before (point)) ?\\ )
          (gd-escaped))))

(defmacro gd-preceding-line-backslashed-p ()
  "Return t if preceding line is a backslashed continuation line. "
  `(save-excursion
     (beginning-of-line)
     (skip-chars-backward " \t\r\n\f")
     (and (eq (char-before (point)) ?\\ )
          (gd-escaped))))
;;

(defvar gdscript-mode-map nil)
(setq gdscript-mode-map
      (let ((map (make-sparse-keymap)))
        ;; electric keys
        (define-key map [(:)] 'gd-electric-colon)
        (define-key map [(\#)] 'gd-electric-comment)
        (define-key map [(delete)] 'gd-electric-delete)
        (define-key map [(backspace)] 'gd-electric-backspace)
        (define-key map [(control backspace)] 'gd-hungry-delete-backwards)
        (define-key map [(control c) (delete)] 'gd-hungry-delete-forward)
        ;; (define-key map [(control y)] 'gd-electric-yank)
        ;; moving point
        (define-key map [(control c)(control p)] 'gd-backward-statement)
        (define-key map [(control c)(control n)] 'gd-forward-statement)
        (define-key map [(control c)(control u)] 'gd-backward-block)
        (define-key map [(control c)(control q)] 'gd-forward-block)
        (define-key map [(control meta a)] 'gd-backward-def-or-class)
        (define-key map [(control meta e)] 'gd-forward-def-or-class)

        ;; (define-key map [(meta i)] 'gd-indent-forward-line)
        (define-key map [(control j)] 'gd-newline-and-indent)
        ;; Most Pythoneers expect RET `gd-newline-and-indent'
        ;; (define-key map (kbd "RET") 'gd-newline-and-dedent)
        (define-key map (kbd "RET") gd-return-key)
        ;; (define-key map (kbd "RET") 'newline)
        (define-key map [(super backspace)] 'gd-dedent)
        ;; (define-key map [(control return)] 'gd-newline-and-dedent)
        ;; indentation level modifiers
        (define-key map [(control c)(control l)] 'gd-shift-left)
        (define-key map [(control c)(control r)] 'gd-shift-right)
        (define-key map [(control c)(<)] 'gd-shift-left)
        (define-key map [(control c)(>)] 'gd-shift-right)
        (define-key map [(control c)(tab)] 'gd-indent-region)
        (define-key map [(control c)(:)] 'gd-guess-indent-offset)
        ;; subprocess commands
        (define-key map [(control c)(control c)] 'gd-execute-buffer)
        (define-key map [(control c)(control m)] 'gd-execute-import-or-reload)
        (define-key map [(control c)(control s)] 'gd-execute-string)
        (define-key map [(control c)(|)] 'gd-execute-region)
        (define-key map [(control meta x)] 'gd-execute-def-or-class)
        (define-key map [(control c)(!)] 'gd-shell)
        (define-key map [(control c)(control t)] 'gd-toggle-shell)
        (define-key map [(control meta h)] 'gd-mark-def-or-class)
        (define-key map [(control c)(control k)] 'gd-mark-block-or-clause)
        (define-key map [(control c)(.)] 'gd-expression)
        ;; Miscellaneous
        ;; (define-key map [(super q)] 'gd-copy-statement)
        (define-key map [(control c)(control d)] 'gd-pdbtrack-toggle-stack-tracking)
        (define-key map [(control c)(control f)] 'gd-sort-imports)
        (define-key map [(control c)(\#)] 'gd-comment-region)
        (define-key map [(control c)(\?)] 'gd-describe-mode)
        (define-key map [(control c)(control e)] 'gd-help-at-point)
        (define-key map [(control c)(-)] 'gd-up-exception)
        (define-key map [(control c)(=)] 'gd-down-exception)
        (define-key map [(control x) (n) (d)] 'gd-narrow-to-defun)
        ;; information
        (define-key map [(control c)(control b)] 'gd-submit-bug-report)
        (define-key map [(control c)(control v)] 'gd-version)
        (define-key map [(control c)(control w)] 'gd-pychecker-run)
        ;; (define-key map (kbd "TAB") 'gd-indent-line)
        (define-key map (kbd "TAB") 'gd-indent-or-complete)
	;; (if gd-complete-function
        ;;     (progn
        ;;       (define-key map [(meta tab)] gd-complete-function)
        ;;       (define-key map [(esc) (tab)] gd-complete-function))
        ;;   (define-key map [(meta tab)] 'gd-shell-complete)
        ;;   (define-key map [(esc) (tab)] 'gd-shell-complete))
        (substitute-key-definition 'complete-symbol 'completion-at-point
                                   map global-map)
        (substitute-key-definition 'backward-up-list 'gd-up
                                   map global-map)
        (substitute-key-definition 'down-list 'gd-down
                                   map global-map)
        map))

(defun gd-separator-char ()
  "Return the file-path separator char from current machine.

When `gd-separator-char' is customized, its taken.
Returns char found. "
  (let ((erg (cond ((characterp gd-separator-char)
                    (char-to-string gd-separator-char))
                   ;; epd hack
                   ((and
                     (string-match "[Ii][Pp]ython" gd-shell-name)
                     (string-match "epd\\|EPD" gd-shell-name))
                    (replace-regexp-in-string "\n" ""
                                              (shell-command-to-string (concat gd-shell-name " -c \"import os; print(os.sep)\"")))))))
    (if (and erg (string-match "^$" erg))
        (setq erg (substring erg (string-match "^$" erg)))
      (setq erg (replace-regexp-in-string "\n" "" (shell-command-to-string (concat gd-shell-name " -W ignore" " -c \"import os; print(os.sep)\"")))))
    erg))

(defun pps-emacs-version ()
  "Include the appropriate `parse-partial-sexp' "
  (if (featurep 'xemacs)
      '(parse-partial-sexp (point-min) (point))
    '(parse-partial-sexp (point-min) (point))))

(defun gd-in-comment-p ()
  "Return the beginning of current line's comment, if inside. "
  (interactive)
  (let* ((pps (parse-partial-sexp (point-min) (point)))
	 (erg (and (nth 4 pps) (nth 8 pps))))
    erg))

(defun gd-in-string-or-comment-p ()
  "Returns beginning position if inside a string or comment, nil otherwise. "
  (or (nth 8 (parse-partial-sexp (point-min) (point)))
      (when (or (looking-at "\"")(looking-at "[ \t]*#[ \t]*"))
        (point))))

;; (eval-and-compile
;;   (defconst gdscript-rx-constituents
;;     `((block-start . ,(rx symbol-start
;; 			  (or "async def" "async for" "async with" "def" "class" "if" "elif" "else" "try"
;; 			      "except" "finally" "for" "while" "with")
;; 			  symbol-end))
;;       (decorator . ,(rx line-start (* space) ?@ (any letter ?_)
;; 			(* (any word ?_))))
;;       (defun . ,(rx symbol-start (or "def" "class") symbol-end))
;;       (if-name-main . ,(rx line-start "if" (+ space) "__name__"
;; 			   (+ space) "==" (+ space)
;; 			   (any ?' ?\") "__main__" (any ?' ?\")
;; 			   (* space) ?:))
;;       (symbol-name . ,(rx (any letter ?_) (* (any word ?_))))
;;       (open-paren . ,(rx (or "{" "[" "(")))
;;       (close-paren . ,(rx (or "}" "]" ")")))
;;       (simple-operator . ,(rx (any ?+ ?- ?/ ?& ?^ ?~ ?| ?* ?< ?> ?= ?%)))
;;       ;; FIXME: rx should support (not simple-operator).
;;       (not-simple-operator . ,(rx
;; 			       (not
;; 				(any ?+ ?- ?/ ?& ?^ ?~ ?| ?* ?< ?> ?= ?%))))
;;       ;; FIXME: Use regexp-opt.
;;       (operator . ,(rx (or "+" "-" "/" "&" "^" "~" "|" "*" "<" ">"
;; 			   "=" "%" "**" "//" "<<" ">>" "<=" "!="
;; 			   "==" ">=" "is" "not")))
;;       ;; FIXME: Use regexp-opt.
;;       (assignment-operator . ,(rx (or "=" "+=" "-=" "*=" "/=" "//=" "%=" "**="
;; 				      ">>=" "<<=" "&=" "^=" "|=")))
;;       (string-delimiter . ,(rx (and
;;                                 ;; Match even number of backslashes.
;;                                 (or (not (any ?\\ ?\' ?\")) point
;;                                     ;; Quotes might be preceded by a escaped quote.
;;                                     (and (or (not (any ?\\)) point) ?\\
;;                                          (* ?\\ ?\\) (any ?\' ?\")))
;;                                 (* ?\\ ?\\)
;;                                 ;; Match single or triple quotes of any kind.
;;                                 (group (or "\"" "\"\"\"" "'" "'''"))))))
;;     "Additional GDScript specific sexps for `gdscript-rx'"))

;; (eval-and-compile
;;   (defmacro gdscript-rx (&rest regexps)
;;     "GDScript mode specialized rx macro which supports common python named REGEXPS."
;;     (let ((rx-constituents (append gdscript-rx-constituents rx-constituents)))
;;       (cond ((null regexps)
;; 	     (error "No regexp"))
;; 	    ((cdr regexps)
;; 	     (rx-to-string `(and ,@regexps) t))
;; 	    (t
;; 	     (rx-to-string (car regexps) t))))))

;;  Font-lock and syntax
(setq gdscript-font-lock-keywords
      ;; Keywords
      `(,(rx symbol-start
             (or
	      "if" "and" "del"  "not" "while" "as" "elif" "global"
	      "or" "async with" "with" "assert" "else"  "pass" "yield" "break"
	      "exec" "in" "continue" "finally" "is" "except" "raise"
	      "return"  "async for" "for" "lambda" "await")
             symbol-end)
        (,(rx symbol-start (or "async def" "def" "class") symbol-end) . gd-def-class-face)
        (,(rx symbol-start (or "import" "from") symbol-end) . gd-import-from-face)
        (,(rx symbol-start (or "try" "if") symbol-end) . gd-try-if-face)
        ;; functions
        (,(rx symbol-start "def" (1+ space) (group (1+ (or word ?_))))
         (1 font-lock-function-name-face))
        (,(rx symbol-start "async def" (1+ space) (group (1+ (or word ?_))))
         (1 font-lock-function-name-face))
        ;; classes
        (,(rx symbol-start (group "class") (1+ space) (group (1+ (or word ?_))))
         (1 gd-def-class-face) (2 gd-class-name-face))
        (,(rx symbol-start
              (or "Ellipsis" "True" "False" "None"  "__debug__" "NotImplemented")
              symbol-end) . gd-pseudo-keyword-face)
        ;; Decorators.
        (,(rx line-start (* (any " \t")) (group "@" (1+ (or word ?_))
                                                (0+ "." (1+ (or word ?_)))))
         (1 gd-decorators-face))
	(,(rx symbol-start (or "cls" "self")
	      symbol-end) . gd-object-reference-face)

        ;; Exceptions
        (,(rx word-start
              (or "ArithmeticError" "AssertionError" "AttributeError"
                  "BaseException" "BufferError" "BytesWarning" "DeprecationWarning"
                  "EOFError" "EnvironmentError" "Exception" "FloatingPointError"
                  "FutureWarning" "GeneratorExit" "IOError" "ImportError"
                  "ImportWarning" "IndentationError" "IndexError" "KeyError"
                  "KeyboardInterrupt" "LookupError" "MemoryError" "NameError" "NoResultFound"
                  "NotImplementedError" "OSError" "OverflowError"
                  "PendingDeprecationWarning" "ReferenceError" "RuntimeError"
                  "RuntimeWarning" "StandardError" "StopIteration" "SyntaxError"
                  "SyntaxWarning" "SystemError" "SystemExit" "TabError" "TypeError"
                  "UnboundLocalError" "UnicodeDecodeError" "UnicodeEncodeError"
                  "UnicodeError" "UnicodeTranslateError" "UnicodeWarning"
                  "UserWarning" "ValueError" "Warning" "ZeroDivisionError")
              word-end) . gd-exception-name-face)
        ;; Builtins
        (,(rx
	   (or space line-start (not (any ".(")))
	   symbol-start
	   (group (or "_" "__doc__" "__import__" "__name__" "__package__" "abs" "all"
		      "any" "apply" "basestring" "bin" "bool" "buffer" "bytearray"
		      "bytes" "callable" "chr" "classmethod" "cmp" "coerce" "compile"
		      "complex" "delattr" "dict" "dir" "divmod" "enumerate" "eval"
		      "execfile" "filter" "float" "format" "frozenset"
		      "getattr" "globals" "hasattr" "hash" "help" "hex" "id" "input"
		      "int" "intern" "isinstance" "issubclass" "iter" "len" "list"
		      "locals" "long" "map" "max" "min" "next" "object" "oct" "open"
		      "ord" "pow" "property" "range" "raw_input" "reduce"
		      "reload" "repr" "reversed" "round" "set" "setattr" "slice"
		      "sorted" "staticmethod" "str" "sum" "super" "tuple" "type"
		      "unichr" "unicode" "vars" "xrange" "zip"))
	   symbol-end) (1 gd-builtins-face))
        ("\\([._[:word:]]+\\)\\(?:\\[[^]]+]\\)?[[:space:]]*\\(?:\\(?:\\*\\*\\|//\\|<<\\|>>\\|[%&*+/|^-]\\)?=\\)"
         (1 gd-variable-name-face nil nil))
        ;; a, b, c = (1, 2, 3)
        (,(lambda (limit)
            (let ((re (rx (group (+ (any word ?. ?_))) (* space)
			   (* ?, (* space) (+ (any word ?. ?_)) (* space))
			   ?, (* space) (+ (any word ?. ?_)) (* space)
			   (or "=" "+=" "-=" "*=" "/=" "//=" "%=" "**=" ">>=" "<<=" "&=" "^=" "|=")))
                  (res nil))
              (while (and (setq res (re-search-forward re limit t))
                          (goto-char (match-end 1))
                          (nth 1 (parse-partial-sexp (point-min) (point)))
                          ;; (gdscript-syntax-context 'paren)
			  ))
              res))
         (1 gd-variable-name-face nil nil))
        ;; Numbers
	;;        (,(rx symbol-start (or (1+ digit) (1+ hex-digit)) symbol-end) . gd-number-face)
	(,(rx symbol-start (1+ digit) symbol-end) . gd-number-face)))

;; (require 'gdscript-components-bounds-forms)
;; (require 'gdscript-components-execute-region)
;; (require 'gdscript-components-versioned)


(require 'ansi-color)
(require 'cc-cmds)
(require 'cl)
(require 'comint)
(require 'compile)
(require 'custom)
(require 'flymake)
(require 'hippie-exp)
(require 'shell)
(require 'thingatpt)
(require 'which-func)

;; gdscript-components-switches

;; Toggle highlight-indentation

(defun gd-toggle-highlight-indentation (&optional indent)
  "If `highlight-indentation-p' should be on or off. "
  (interactive "P")
  ;; (let ((indent indent))
  (unless (featurep 'highlight-indentation)
    (load (concat (py--normalize-directory gd-install-directory) "extensions" (char-to-string gd-separator-char) "highlight-indentation.el")))
  (highlight-indentation indent)
  (when gd-verbose-p (message "highlight-indent-active: %s" highlight-indent-active))
  highlight-indent-active)

(defun gd-highlight-indentation-off ()
  "If `highlight-indentation-p' should be on or off. "
  (interactive)
  (unless (featurep 'highlight-indentation)
    (load (concat (py--normalize-directory gd-install-directory) "extensions" (char-to-string gd-separator-char) "highlight-indentation.el")))
  (highlight-indentation-off)
  (when gd-verbose-p (message "highlight-indent-active: %s" highlight-indent-active))
  highlight-indent-active)

(defun gd-highlight-indentation-on ()
  "If `highlight-indentation-p' should be on or off. "
  (interactive "P")
  (unless (featurep 'highlight-indentation)
    (load (concat (py--normalize-directory gd-install-directory) "extensions" (char-to-string gd-separator-char) "highlight-indentation.el")))
  (highlight-indentation-on)
  (when gd-verbose-p (message "highlight-indent-active: %s" highlight-indent-active))
  highlight-indent-active)

;;  Smart indentation
(defalias 'toggle-gd-smart-indentation 'gd-toggle-smart-indentation)
(defun gd-toggle-smart-indentation (&optional arg)
  "If `gd-smart-indentation' should be on or off.

Returns value of `gd-smart-indentation' switched to. "
  (interactive)
  (let ((arg (or arg (if gd-smart-indentation -1 1))))
    (if (< 0 arg)
        (progn
          (setq gd-smart-indentation t)
          (gd-guess-indent-offset))
      (setq gd-smart-indentation nil)
      (setq gd-indent-offset (default-value 'gd-indent-offset)))
    (when (called-interactively-p 'any) (message "gd-smart-indentation: %s" gd-smart-indentation))
    gd-smart-indentation))

(defun gd-smart-indentation-on (&optional arg)
  "Make sure, `gd-smart-indentation' is on.

Returns value of `gd-smart-indentation'. "
  (interactive "p")
  (let ((arg (or arg 1)))
    (toggle-gd-smart-indentation arg))
  (when (called-interactively-p 'any) (message "gd-smart-indentation: %s" gd-smart-indentation))
  gd-smart-indentation)

(defun gd-smart-indentation-off (&optional arg)
  "Make sure, `gd-smart-indentation' is off.

Returns value of `gd-smart-indentation'. "
  (interactive "p")
  (let ((arg (if arg (- arg) -1)))
    (toggle-gd-smart-indentation arg))
  (when (called-interactively-p 'any) (message "gd-smart-indentation: %s" gd-smart-indentation))
  gd-smart-indentation)

(defun gd-toggle-sexp-function ()
  "Opens customization "
  (interactive)
  (customize-variable 'gd-sexp-function))

;; Autopair mode
;; gd-autopair-mode forms
(defalias 'toggle-gd-autopair-mode 'gd-toggle-autopair-mode)
(defun gd-toggle-autopair-mode (&optional arg)
  "If `gd-autopair-mode' should be on or off.

  Returns value of `gd-autopair-mode' switched to. "
  (interactive)
  (and (gd-autopair-check)
       (setq gd-autopair-mode (autopair-mode (if autopair-mode 0 1)))))

(defun gd-autopair-mode-on ()
  "Make sure, gd-autopair-mode' is on.

Returns value of `gd-autopair-mode'. "
  (interactive)
  (and (gd-autopair-check)
       (setq gd-autopair-mode (autopair-mode 1))))

(defun gd-autopair-mode-off ()
  "Make sure, gd-autopair-mode' is off.

Returns value of `gd-autopair-mode'. "
  (interactive)
  (setq gd-autopair-mode (autopair-mode 0)))

;; Smart operator
;; gd-smart-operator-mode-p forms
(defun toggle-gd-smart-operator-mode-p (&optional arg)
  "If `gd-smart-operator-mode-p' should be on or off.

  Returns value of `gd-smart-operator-mode-p' switched to. "
  (interactive)
  (and (gd-smart-operator-check)
       (setq gd-smart-operator-mode-p (smart-operator-mode (if smart-operator-mode 0 1)))))

(defun gd-smart-operator-mode-p-on ()
  "Make sure, gd-smart-operator-mode-p' is on.

Returns value of `gd-smart-operator-mode-p'. "
  (interactive)
  (and (gd-smart-operator-check)
       (setq gd-smart-operator-mode-p (smart-operator-mode 1))))

(defun gd-smart-operator-mode-p-off ()
  "Make sure, gd-smart-operator-mode-p' is off.

Returns value of `gd-smart-operator-mode-p'. "
  (interactive)
  (setq gd-smart-operator-mode-p (smart-operator-mode 0)))

;;  gd-switch-buffers-on-execute-p forms
(defun toggle-gd-switch-buffers-on-execute-p (&optional arg)
  "If `gd-switch-buffers-on-execute-p' should be on or off.

  Returns value of `gd-switch-buffers-on-execute-p' switched to. "
  (interactive)
  (let ((arg (or arg (if gd-switch-buffers-on-execute-p -1 1))))
    (if (< 0 arg)
        (setq gd-switch-buffers-on-execute-p t)
      (setq gd-switch-buffers-on-execute-p nil))
    (when (or gd-verbose-p (called-interactively-p 'any)) (message "gd-switch-buffers-on-execute-p: %s" gd-switch-buffers-on-execute-p))
    gd-switch-buffers-on-execute-p))

(defun gd-switch-buffers-on-execute-p-on (&optional arg)
  "Make sure, `gd-gd-switch-buffers-on-execute-p' is on.

Returns value of `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (let ((arg (or arg 1)))
    (toggle-gd-switch-buffers-on-execute-p arg))
  (when (or gd-verbose-p (called-interactively-p 'any)) (message "gd-switch-buffers-on-execute-p: %s" gd-switch-buffers-on-execute-p))
  gd-switch-buffers-on-execute-p)

(defun gd-switch-buffers-on-execute-p-off ()
  "Make sure, `gd-switch-buffers-on-execute-p' is off.

Returns value of `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (toggle-gd-switch-buffers-on-execute-p -1)
  (when (or gd-verbose-p (called-interactively-p 'any)) (message "gd-switch-buffers-on-execute-p: %s" gd-switch-buffers-on-execute-p))
  gd-switch-buffers-on-execute-p)

;;  gd-split-window-on-execute forms
(defun toggle-gd-split-window-on-execute (&optional arg)
  "If `gd-split-window-on-execute' should be on or off.

  Returns value of `gd-split-window-on-execute' switched to. "
  (interactive)
  (let ((arg (or arg (if gd-split-window-on-execute -1 1))))
    (if (< 0 arg)
        (setq gd-split-window-on-execute t)
      (setq gd-split-window-on-execute nil))
    (when (or gd-verbose-p (called-interactively-p 'any)) (message "gd-split-window-on-execute: %s" gd-split-window-on-execute))
    gd-split-window-on-execute))

(defun gd-split-window-on-execute-on (&optional arg)
  "Make sure, `gd-gd-split-window-on-execute' is on.

Returns value of `gd-split-window-on-execute'. "
  (interactive)
  (let ((arg (or arg 1)))
    (toggle-gd-split-window-on-execute arg))
  (when (or gd-verbose-p (called-interactively-p 'any)) (message "gd-split-window-on-execute: %s" gd-split-window-on-execute))
  gd-split-window-on-execute)

(defun gd-split-window-on-execute-off ()
  "Make sure, `gd-split-window-on-execute' is off.

Returns value of `gd-split-window-on-execute'. "
  (interactive)
  (toggle-gd-split-window-on-execute -1)
  (when (or gd-verbose-p (called-interactively-p 'any)) (message "gd-split-window-on-execute: %s" gd-split-window-on-execute))
  gd-split-window-on-execute)

;;  gd-fontify-shell-buffer-p forms
(defun toggle-gd-fontify-shell-buffer-p (&optional arg)
  "If `gd-fontify-shell-buffer-p' should be on or off.

  Returns value of `gd-fontify-shell-buffer-p' switched to. "
  (interactive)
  (let ((arg (or arg (if gd-fontify-shell-buffer-p -1 1))))
    (if (< 0 arg)
        (progn
          (setq gd-fontify-shell-buffer-p t)
          (set (make-local-variable 'font-lock-defaults)
             '(gdscript-font-lock-keywords nil nil nil nil
                                         (font-lock-syntactic-keywords
                                          . gd-font-lock-syntactic-keywords)))
          (unless (looking-at comint-prompt-regexp)
            (when (re-search-backward comint-prompt-regexp nil t 1)
              (font-lock-fontify-region (line-beginning-position) (point-max)))))
      (setq gd-fontify-shell-buffer-p nil))
    (when (or gd-verbose-p (called-interactively-p 'any)) (message "gd-fontify-shell-buffer-p: %s" gd-fontify-shell-buffer-p))
    gd-fontify-shell-buffer-p))

(defun gd-fontify-shell-buffer-p-on (&optional arg)
  "Make sure, `gd-gd-fontify-shell-buffer-p' is on.

Returns value of `gd-fontify-shell-buffer-p'. "
  (interactive)
  (let ((arg (or arg 1)))
    (toggle-gd-fontify-shell-buffer-p arg))
  (when (or gd-verbose-p (called-interactively-p 'any)) (message "gd-fontify-shell-buffer-p: %s" gd-fontify-shell-buffer-p))
  gd-fontify-shell-buffer-p)

(defun gd-fontify-shell-buffer-p-off ()
  "Make sure, `gd-fontify-shell-buffer-p' is off.

Returns value of `gd-fontify-shell-buffer-p'. "
  (interactive)
  (toggle-gd-fontify-shell-buffer-p -1)
  (when (or gd-verbose-p (called-interactively-p 'any)) (message "gd-fontify-shell-buffer-p: %s" gd-fontify-shell-buffer-p))
  gd-fontify-shell-buffer-p)

;;  gdscript-mode-v5-behavior-p forms
(defun toggle-gdscript-mode-v5-behavior-p (&optional arg)
  "If `gdscript-mode-v5-behavior-p' should be on or off.

  Returns value of `gdscript-mode-v5-behavior-p' switched to. "
  (interactive)
  (let ((arg (or arg (if gdscript-mode-v5-behavior-p -1 1))))
    (if (< 0 arg)
        (setq gdscript-mode-v5-behavior-p t)
      (setq gdscript-mode-v5-behavior-p nil))
    (when (or gd-verbose-p (called-interactively-p 'any)) (message "gdscript-mode-v5-behavior-p: %s" gdscript-mode-v5-behavior-p))
    gdscript-mode-v5-behavior-p))

(defun gdscript-mode-v5-behavior-p-on (&optional arg)
  "Make sure, `gdscript-mode-v5-behavior-p' is on.

Returns value of `gdscript-mode-v5-behavior-p'. "
  (interactive)
  (let ((arg (or arg 1)))
    (toggle-gdscript-mode-v5-behavior-p arg))
  (when (or gd-verbose-p (called-interactively-p 'any)) (message "gdscript-mode-v5-behavior-p: %s" gdscript-mode-v5-behavior-p))
  gdscript-mode-v5-behavior-p)

(defun gdscript-mode-v5-behavior-p-off ()
  "Make sure, `gdscript-mode-v5-behavior-p' is off.

Returns value of `gdscript-mode-v5-behavior-p'. "
  (interactive)
  (toggle-gdscript-mode-v5-behavior-p -1)
  (when (or gd-verbose-p (called-interactively-p 'any)) (message "gdscript-mode-v5-behavior-p: %s" gdscript-mode-v5-behavior-p))
  gdscript-mode-v5-behavior-p)

;;  gd-jump-on-exception forms
(defun toggle-gd-jump-on-exception (&optional arg)
  "If `gd-jump-on-exception' should be on or off.

  Returns value of `gd-jump-on-exception' switched to. "
  (interactive)
  (let ((arg (or arg (if gd-jump-on-exception -1 1))))
    (if (< 0 arg)
        (setq gd-jump-on-exception t)
      (setq gd-jump-on-exception nil))
    (when (or gd-verbose-p (called-interactively-p 'any)) (message "gd-jump-on-exception: %s" gd-jump-on-exception))
    gd-jump-on-exception))

(defun gd-jump-on-exception-on (&optional arg)
  "Make sure, gd-jump-on-exception' is on.

Returns value of `gd-jump-on-exception'. "
  (interactive)
  (let ((arg (or arg 1)))
    (toggle-gd-jump-on-exception arg))
  (when (or gd-verbose-p (called-interactively-p 'any)) (message "gd-jump-on-exception: %s" gd-jump-on-exception))
  gd-jump-on-exception)

(defun gd-jump-on-exception-off ()
  "Make sure, `gd-jump-on-exception' is off.

Returns value of `gd-jump-on-exception'. "
  (interactive)
  (toggle-gd-jump-on-exception -1)
  (when (or gd-verbose-p (called-interactively-p 'any)) (message "gd-jump-on-exception: %s" gd-jump-on-exception))
  gd-jump-on-exception)

;;  gd-use-current-dir-when-execute-p forms
(defun toggle-gd-use-current-dir-when-execute-p (&optional arg)
  "If `gd-use-current-dir-when-execute-p' should be on or off.

  Returns value of `gd-use-current-dir-when-execute-p' switched to. "
  (interactive)
  (let ((arg (or arg (if gd-use-current-dir-when-execute-p -1 1))))
    (if (< 0 arg)
        (setq gd-use-current-dir-when-execute-p t)
      (setq gd-use-current-dir-when-execute-p nil))
    (when (or gd-verbose-p (called-interactively-p 'any)) (message "gd-use-current-dir-when-execute-p: %s" gd-use-current-dir-when-execute-p))
    gd-use-current-dir-when-execute-p))

(defun gd-use-current-dir-when-execute-p-on (&optional arg)
  "Make sure, gd-use-current-dir-when-execute-p' is on.

Returns value of `gd-use-current-dir-when-execute-p'. "
  (interactive)
  (let ((arg (or arg 1)))
    (toggle-gd-use-current-dir-when-execute-p arg))
  (when (or gd-verbose-p (called-interactively-p 'any)) (message "gd-use-current-dir-when-execute-p: %s" gd-use-current-dir-when-execute-p))
  gd-use-current-dir-when-execute-p)

(defun gd-use-current-dir-when-execute-p-off ()
  "Make sure, `gd-use-current-dir-when-execute-p' is off.

Returns value of `gd-use-current-dir-when-execute-p'. "
  (interactive)
  (toggle-gd-use-current-dir-when-execute-p -1)
  (when (or gd-verbose-p (called-interactively-p 'any)) (message "gd-use-current-dir-when-execute-p: %s" gd-use-current-dir-when-execute-p))
  gd-use-current-dir-when-execute-p)

;;  gd-electric-comment-p forms
(defun toggle-gd-electric-comment-p (&optional arg)
  "If `gd-electric-comment-p' should be on or off.

  Returns value of `gd-electric-comment-p' switched to. "
  (interactive)
  (let ((arg (or arg (if gd-electric-comment-p -1 1))))
    (if (< 0 arg)
        (setq gd-electric-comment-p t)
      (setq gd-electric-comment-p nil))
    (when (or gd-verbose-p (called-interactively-p 'any)) (message "gd-electric-comment-p: %s" gd-electric-comment-p))
    gd-electric-comment-p))

(defun gd-electric-comment-p-on (&optional arg)
  "Make sure, gd-electric-comment-p' is on.

Returns value of `gd-electric-comment-p'. "
  (interactive)
  (let ((arg (or arg 1)))
    (toggle-gd-electric-comment-p arg))
  (when (or gd-verbose-p (called-interactively-p 'any)) (message "gd-electric-comment-p: %s" gd-electric-comment-p))
  gd-electric-comment-p)

(defun gd-electric-comment-p-off ()
  "Make sure, `gd-electric-comment-p' is off.

Returns value of `gd-electric-comment-p'. "
  (interactive)
  (toggle-gd-electric-comment-p -1)
  (when (or gd-verbose-p (called-interactively-p 'any)) (message "gd-electric-comment-p: %s" gd-electric-comment-p))
  gd-electric-comment-p)

;;  gd-underscore-word-syntax-p forms
(defun toggle-gd-underscore-word-syntax-p (&optional arg)
  "If `gd-underscore-word-syntax-p' should be on or off.

  Returns value of `gd-underscore-word-syntax-p' switched to. "
  (interactive)
  (let ((arg (or arg (if gd-underscore-word-syntax-p -1 1))))
    (if (< 0 arg)
        (progn
          (setq gd-underscore-word-syntax-p t)
          (modify-syntax-entry ?\_ "w" gdscript-mode-syntax-table))
      (setq gd-underscore-word-syntax-p nil)
      (modify-syntax-entry ?\_ "_" gdscript-mode-syntax-table))
    (when (or gd-verbose-p (called-interactively-p 'any)) (message "gd-underscore-word-syntax-p: %s" gd-underscore-word-syntax-p))
    gd-underscore-word-syntax-p))

(defun gd-underscore-word-syntax-p-on (&optional arg)
  "Make sure, gd-underscore-word-syntax-p' is on.

Returns value of `gd-underscore-word-syntax-p'. "
  (interactive)
  (let ((arg (or arg 1)))
    (toggle-gd-underscore-word-syntax-p arg))
  (when (or gd-verbose-p (called-interactively-p 'any)) (message "gd-underscore-word-syntax-p: %s" gd-underscore-word-syntax-p))
  gd-underscore-word-syntax-p)

(defun gd-underscore-word-syntax-p-off ()
  "Make sure, `gd-underscore-word-syntax-p' is off.

Returns value of `gd-underscore-word-syntax-p'. "
  (interactive)
  (toggle-gd-underscore-word-syntax-p -1)
  (when (or gd-verbose-p (called-interactively-p 'any)) (message "gd-underscore-word-syntax-p: %s" gd-underscore-word-syntax-p))
  gd-underscore-word-syntax-p)

;; toggle-gd-underscore-word-syntax-p must be known already
;; circular: toggle-gd-underscore-word-syntax-p sets and calls it
(defcustom gd-underscore-word-syntax-p t
  "If underscore chars should be of syntax-class `word', not of `symbol'.

Underscores in word-class makes `forward-word' etc. travel the indentifiers. Default is `t'.

See bug report at launchpad, lp:940812 "
  :type 'boolean
  :tag "gd-underscore-word-syntax-p"
  :group 'gdscript-mode
  :set (lambda (symbol value)
         (set-default symbol value)
         (toggle-gd-underscore-word-syntax-p (if value 1 0))))

;; gdscript-components-edit
(defvar gd-keywords "\\<\\(ArithmeticError\\|AssertionError\\|AttributeError\\|BaseException\\|BufferError\\|BytesWarning\\|DeprecationWarning\\|EOFError\\|Ellipsis\\|EnvironmentError\\|Exception\\|False\\|FloatingPointError\\|FutureWarning\\|GeneratorExit\\|IOError\\|ImportError\\|ImportWarning\\|IndentationError\\|IndexError\\|KeyError\\|KeyboardInterrupt\\|LookupError\\|MemoryError\\|NameError\\|NoneNotImplementedError\\|NotImplemented\\|OSError\\|OverflowError\\|PendingDeprecationWarning\\|ReferenceError\\|RuntimeError\\|RuntimeWarning\\|StandardError\\|StopIteration\\|SyntaxError\\|SyntaxWarning\\|SystemError\\|SystemExit\\|TabError\\|True\\|TypeError\\|UnboundLocalError\\|UnicodeDecodeError\\|UnicodeEncodeError\\|UnicodeError\\|UnicodeTranslateError\\|UnicodeWarning\\|UserWarning\\|ValueError\\|Warning\\|ZeroDivisionError\\|__debug__\\|__import__\\|__name__\\|abs\\|all\\|and\\|any\\|apply\\|as\\|assert\\|basestring\\|bin\\|bool\\|break\\|buffer\\|bytearray\\|callable\\|chr\\|class\\|classmethod\\|cmp\\|coerce\\|compile\\|complex\\|continue\\|copyright\\|credits\\|def\\|del\\|delattr\\|dict\\|dir\\|divmod\\|elif\\|else\\|enumerate\\|eval\\|except\\|exec\\|execfile\\|exit\\|file\\|filter\\|float\\|for\\|format\\|from\\|getattr\\|global\\|globals\\|hasattr\\|hash\\|help\\|hex\\|id\\|if\\|import\\|in\\|input\\|int\\|intern\\|is\\|isinstance\\|issubclass\\|iter\\|lambda\\|len\\|license\\|list\\|locals\\|long\\|map\\|max\\|memoryview\\|min\\|next\\|not\\|object\\|oct\\|open\\|or\\|ord\\|pass\\|pow\\|print\\|property\\|quit\\|raise\\|range\\|raw_input\\|reduce\\|reload\\|repr\\|return\\|round\\|set\\|setattr\\|slice\\|sorted\\|staticmethod\\|str\\|sum\\|super\\|tuple\\|type\\|unichr\\|unicode\\|vars\\|while\\|with\\|xrange\\|yield\\|zip\\|\\)\\>"
  "Contents like gd-fond-lock-keyword")

;; ;
(defun gd-insert-default-shebang ()
  "Insert in buffer shebang of installed default GDScript. "
  (interactive "*")
  (let* ((erg (if gd-edit-only-p
                  gd-shell-name
                (executable-find gd-shell-name)))
         (sheb (concat "#! " erg)))
    (insert sheb)))

(defun py--top-level-form-p ()
  "Return non-nil, if line starts with a top level definition.

Used by `gd-electric-colon', which will not indent than. "
  (let (erg)
    (save-excursion
      (beginning-of-line)
      (setq erg (or (looking-at gd-class-re)
                    (looking-at gd-def-re))))
    erg))


(defun gd-indent-line-outmost (&optional arg)
  "Indent the current line to the outmost reasonable indent.

With optional \\[universal-argument] an indent with length `gd-indent-offset' is inserted unconditionally "
  (interactive "*P")
  (let* ((need (gd-compute-indentation (point)))
         (cui (current-indentation))
         (cuc (current-column)))
    (cond ((eq 4 (prefix-numeric-value arg))
	   (if indent-tabs-mode
	       (insert (make-string 1 9))
	     (insert (make-string gd-indent-offset 32))))
          (t
           (if (and (eq need cui)(not (eq cuc cui)))
               (back-to-indentation)
             (beginning-of-line)
             (delete-horizontal-space)
             (indent-to need))))))

(defun py--indent-fix-region-intern (beg end)
  "Used when `gd-tab-indents-region-p' is non-nil. "
  (let (indent)
    (save-excursion
      (save-restriction
        (beginning-of-line)
        (narrow-to-region beg end)
        (forward-line 1)
        (narrow-to-region (line-beginning-position) end)
        (beginning-of-line)
        (delete-region (point) (progn (skip-chars-forward " \t\r\n\f") (point)))
        (indent-to (gd-compute-indentation))
        (while
            (< (line-end-position) end)
          (forward-line 1)
          (beginning-of-line)
          (delete-region (point) (progn (skip-chars-forward " \t\r\n\f") (point)))
          (indent-to (gd-compute-indentation)))))))

(defun py--indent-line-intern (need cui gd-indent-offset col &optional beg end region)
  (let (erg)
    (if gd-tab-indent
	(progn
	  (and gd-tab-indents-region-p region
	       (py--indent-fix-region-intern beg end))
	  (cond
	   ((bolp)
	    (if (and gd-tab-shifts-region-p region)
		(progn
		  (while (< (current-indentation) need)
		    (gd-shift-region-right 1)))
	      (beginning-of-line)
	      (delete-horizontal-space)
	      (indent-to need)))
	   ((< need cui)
	    (if (and gd-tab-shifts-region-p region)
		(progn
		  (when (eq (point) (region-end))
		    (exchange-point-and-mark))
		  (while (< 0 (current-indentation))
		    (gd-shift-region-left 1)))
	      (beginning-of-line)
	      (delete-horizontal-space)
	      (indent-to need)))
	   ((eq need cui)
	    (if (or (eq this-command last-command)
		    (eq this-command 'gd-indent-line))
		(if (and gd-tab-shifts-region-p region)
		    (while (and (goto-char beg) (< 0 (current-indentation)))
		      (gd-shift-region-left 1 beg end))
		  (beginning-of-line)
		  (delete-horizontal-space)
		  (if (<= (line-beginning-position) (+ (point) (- col cui)))
		      (forward-char (- col cui))
		    (beginning-of-line)))))
	   ((< cui need)
	    (if (and gd-tab-shifts-region-p region)
		(progn
		  (gd-shift-region-right 1))
	      (progn
		(beginning-of-line)
		(delete-horizontal-space)
		;; indent one gd-indent-offset only if goal < need
		(setq erg (+ (* (/ cui gd-indent-offset) gd-indent-offset) gd-indent-offset))
		(if (< need erg)
		    (indent-to need)
		  (indent-to erg))
		(forward-char (- col cui)))))
	   (t
	    (if (and gd-tab-shifts-region-p region)
		(progn
		  (while (< (current-indentation) need)
		    (gd-shift-region-right 1)))
	      (beginning-of-line)
	      (delete-horizontal-space)
	      (indent-to need)
	      (back-to-indentation)
	      (if (<= (line-beginning-position) (+ (point) (- col cui)))
		  (forward-char (- col cui))
		(beginning-of-line))))))
      (insert-tab))))

(defun py--indent-line-base (beg end region cui need arg this-indent-offset col)
  (cond ((eq 4 (prefix-numeric-value arg))
	 (if (and (eq cui (current-indentation))
		  (<= need cui))
	     (if indent-tabs-mode (insert "\t")(insert (make-string gd-indent-offset 32)))
	   (beginning-of-line)
	   (delete-horizontal-space)
	   (indent-to (+ need gd-indent-offset))))
	((not (eq 1 (prefix-numeric-value arg)))
	 (gd-smart-indentation-off)
	 (py--indent-line-intern need cui this-indent-offset col beg end region))
	(t (py--indent-line-intern need cui this-indent-offset col beg end region))))

(defun py--calculate-indent-backwards (cui indent-offset)
  "Return the next reasonable indent lower than current indentation. "
  (if (< 0 (% cui gd-indent-offset))
      ;; not correctly indented at all
      (/ cui indent-offset)
    (- cui indent-offset)))

(defun gd-indent-line (&optional arg outmost-only)
  "Indent the current line according to GDScript rules.

When called interactivly with \\[universal-argument], ignore dedenting rules for block closing statements
\(e.g. return, raise, break, continue, pass)

An optional \\[universal-argument] followed by a numeric argument neither 1 nor 4 will switch off `gd-smart-indentation' for this execution. This permits to correct allowed but unwanted indents.
Similar to `toggle-gd-smart-indentation' resp. `gd-smart-indentation-off' followed by TAB.

This function is normally used by `indent-line-function' resp.
\\[indent-for-tab-command].

When bound to TAB, C-q TAB inserts a TAB.

OUTMOST-ONLY stops circling possible indent.

When `gd-tab-shifts-region-p' is `t', not just the current line,
but the region is shiftet that way.

If `gd-tab-indents-region-p' is `t' and first TAB doesn't shift
--as indent is at outmost reasonable--, indent-region is called.

C-q TAB inserts a literal TAB-character."
  (interactive "P")
  (unless (eq this-command last-command)
    (setq gd-already-guessed-indent-offset nil))
  (let ((orig (copy-marker (point)))
	;; TAB-leaves-point-in-the-wrong-lp-1178453-test
	(region (use-region-p))
        cui
	outmost
	col
	beg
	end
	need
	done
	this-indent-offset)
    (and region
	 (setq beg (region-beginning))
	 (setq end (region-end))
	 (goto-char beg))
    (setq cui (current-indentation))
    (setq col (current-column))
    (setq this-indent-offset
	  (cond ((and gd-smart-indentation (not (eq this-command last-command)))
		 (gd-guess-indent-offset))
		((and gd-smart-indentation (eq this-command last-command) gd-already-guessed-indent-offset)
		 gd-already-guessed-indent-offset)
		(t (default-value 'gd-indent-offset))))
    (setq outmost (gd-compute-indentation nil nil nil nil nil nil this-indent-offset))
    ;; now choose the indent
    (setq need
	  (cond ((eq this-command last-command)
		 (if (eq cui outmost)
		     (when (not outmost-only)
		       (py--calculate-indent-backwards cui this-indent-offset)))
		 (if (bolp)
		     (gd-compute-indentation orig)
		   (py--calculate-indent-backwards cui this-indent-offset)))
		(t
		 outmost
		 ;; (gd-compute-indentation orig)
		 )))
    (when (and (called-interactively-p 'any) gd-verbose-p) (message "gd-indent-line, need: %s" need))
    ;; if at outmost
    ;; and not (eq this-command last-command), need remains nil
    (when need
      (py--indent-line-base beg end region cui need arg this-indent-offset col)
      (and region (or gd-tab-shifts-region-p
		      gd-tab-indents-region-p)
	   (not (eq (point) orig))
	   (exchange-point-and-mark))
      (when (and (called-interactively-p 'any) gd-verbose-p)(message "%s" (current-indentation)))
      (current-indentation))))

(defun py--delete-trailing-whitespace (orig)
  "Delete trailing whitespace if either `gd-newline-delete-trailing-whitespace-p' or `gd-trailing-whitespace-smart-delete-p' are `t' "
  (when (or gd-newline-delete-trailing-whitespace-p gd-trailing-whitespace-smart-delete-p)
    (let ((pos (copy-marker (point))))
      (save-excursion
	(goto-char orig)
	(if (empty-line-p)
	    (if (py---emacs-version-greater-23)
		(delete-trailing-whitespace (line-beginning-position) pos)
	      (save-restriction
		(narrow-to-region (line-beginning-position) pos)
		(delete-trailing-whitespace)))
	  (skip-chars-backward " \t")
	  (if (py---emacs-version-greater-23)
	      (delete-trailing-whitespace (line-beginning-position) pos)
	    (save-restriction
	      (narrow-to-region (point) pos)
	      (delete-trailing-whitespace))))))))

(defun gd-newline-and-indent ()
  "Add a newline and indent to outmost reasonable indent.
When indent is set back manually, this is honoured in following lines. "
  (interactive "*")
  (let* ((orig (point))
	 (lkmd (prin1-to-string last-command))
	 ;; lp:1280982, deliberatly dedented by user
	 (this-dedent
	  (when (and (or (eq 10 (char-after))(eobp))(looking-back "^[ \t]*"))
	    (current-column)))
	 erg pos)
    (newline)
    (py--delete-trailing-whitespace orig)
    (setq erg
	  (cond (this-dedent
		 (indent-to-column this-dedent))
		((and gd-empty-line-closes-p (or (eq this-command last-command)(py--after-empty-line)))
		 (indent-to-column (save-excursion (gd-backward-statement)(- (current-indentation) gd-indent-offset))))
		(t
		 (fixup-whitespace)
		 (indent-to-column (gd-compute-indentation)))))
    (when (and (called-interactively-p 'any) gd-verbose-p) (message "%s" erg))
    erg))

(defalias 'gd-newline-and-close-block 'gd-newline-and-dedent)
(defun gd-newline-and-dedent ()
  "Add a newline and indent to one level below current.
Returns column. "
  (interactive "*")
  (let ((cui (current-indentation))
        erg)
    (newline)
    (when (< 0 cui)
      (setq erg (- (gd-compute-indentation) gd-indent-offset))
      (indent-to-column erg))
    (when (and (called-interactively-p 'any) gd-verbose-p) (message "%s" erg))
    erg))

(defun gd-toggle-indent-tabs-mode ()
  "Toggle `indent-tabs-mode'.

Returns value of `indent-tabs-mode' switched to. "
  (interactive)
  (when
      (setq indent-tabs-mode (not indent-tabs-mode))
    (setq tab-width gd-indent-offset))
  (when (and gd-verbose-p (called-interactively-p 'any)) (message "indent-tabs-mode %s  gd-indent-offset %s" indent-tabs-mode gd-indent-offset))
  indent-tabs-mode)

(defun gd-indent-tabs-mode (arg &optional iact)
  "With positive ARG switch `indent-tabs-mode' on.

With negative ARG switch `indent-tabs-mode' off.
Returns value of `indent-tabs-mode' switched to. "
  (interactive "p")
  (if (< 0 arg)
      (progn
        (setq indent-tabs-mode t)
        (setq tab-width gd-indent-offset))
    (setq indent-tabs-mode nil))
  (when (and gd-verbose-p (or iact (called-interactively-p 'any))) (message "indent-tabs-mode %s   gd-indent-offset %s" indent-tabs-mode gd-indent-offset))
  indent-tabs-mode)

(defun gd-indent-tabs-mode-on (arg)
  "Switch `indent-tabs-mode' on. "
  (interactive "p")
  (gd-indent-tabs-mode (abs arg)(called-interactively-p 'any)))

(defun gd-indent-tabs-mode-off (arg)
  "Switch `indent-tabs-mode' off. "
  (interactive "p")
  (gd-indent-tabs-mode (- (abs arg))(called-interactively-p 'any)))

;;  Guess indent offset
(defun gd-guessed-sanity-check (guessed)
  (and (>= guessed 2)(<= guessed 8)(eq 0 (% guessed 2))))

(defun py--guess-indent-final (indents orig)
  "Calculate and do sanity-check. "
  (let* ((first (car indents))
         (second (cadr indents))
         (erg (if (and first second)
                  (if (< second first)
                      ;; (< (point) orig)
                      (- first second)
                    (- second first))
                (default-value 'gd-indent-offset))))
    (setq erg (and (gd-guessed-sanity-check erg) erg))
    erg))

(defun py--guess-indent-forward ()
  "Called when moving to end of a form and `gd-smart-indentation' is on. "
  (let* ((first (if
                    (py--beginning-of-statement-p)
                    (current-indentation)
                  (progn
                    (gd-forward-statement)
                    (gd-backward-statement)
                    (current-indentation))))
         (second (if (or (looking-at gd-extended-block-or-clause-re)(eq 0 first))
                     (progn
                       (gd-forward-statement)
                       (gd-forward-statement)
                       (gd-backward-statement)
                       (current-indentation))
                   ;; when not starting from block, look above
                   (while (and (re-search-backward gd-extended-block-or-clause-re nil 'movet 1)
                               (or (>= (current-indentation) first)
                                   (nth 8 (parse-partial-sexp (point-min) (point))))))
                   (current-indentation))))
    (list first second)))

(defun py--guess-indent-backward ()
  "Called when moving to beginning of a form and `gd-smart-indentation' is on. "
  (let* ((cui (current-indentation))
         (indent (if (< 0 cui) cui 999))
         (pos (progn (while (and (re-search-backward gd-extended-block-or-clause-re nil 'move 1)
                                 (or (>= (current-indentation) indent)
                                     (nth 8 (parse-partial-sexp (point-min) (point))))))
                     (unless (bobp) (point))))
         (first (and pos (current-indentation)))
         (second (and pos (gd-forward-statement) (gd-forward-statement) (gd-backward-statement)(current-indentation))))
    (list first second)))

(defun gd-guess-indent-offset (&optional direction)
  "Guess `gd-indent-offset'.

Set local value of `gd-indent-offset', return it

Might change local value of `gd-indent-offset' only when called
downwards from beginning of block followed by a statement. Otherwise default-value is returned."
  (interactive)
  (save-excursion
    (let* ((orig (point))
           (indents
            (cond (direction
                   (if (eq 'forward direction)
                       (py--guess-indent-forward)
                     (py--guess-indent-backward)))
                  ;; guess some usable indent is above current position
                  ((eq 0 (current-indentation))
                   (py--guess-indent-forward))
                  (t (py--guess-indent-backward))))
           (erg (py--guess-indent-final indents orig)))
      (if erg (setq gd-indent-offset erg)
        (setq gd-indent-offset
              (default-value 'gd-indent-offset)))
      (when (called-interactively-p 'any) (message "%s" gd-indent-offset))
      gd-indent-offset)))

(defun py--comment-indent-function ()
  "GDScript version of `comment-indent-function'."
  ;; This is required when filladapt is turned off.  Without it, when
  ;; filladapt is not used, comments which start in column zero
  ;; cascade one character to the right
  (save-excursion
    (beginning-of-line)
    (let ((eol (line-end-position)))
      (and comment-start-skip
           (re-search-forward comment-start-skip eol t)
           (setq eol (match-beginning 0)))
      (goto-char eol)
      (skip-chars-backward " \t")
      (max comment-column (+ (current-column) (if (bolp) 0 1))))))

;;  make general form below work also in these cases
;;  (defalias 'gd-backward-paragraph 'backward-paragraph)
(defun gd-backward-paragraph ()
  (interactive)
  (let ((erg (and (backward-paragraph)(point))))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

;;  (defalias 'gd-end-of-paragraph 'forward-paragraph)
(defun gd-forward-paragraph ()
  (interactive)
  (let ((erg (and (forward-paragraph)(point))))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

;; ;
(defun gd-indent-and-forward (&optional indent)
  "Indent current line according to mode, move one line forward.

If optional INDENT is given, use it"
  (interactive "*")
  (beginning-of-line)
  (when (member (char-after) (list 32 9 10 12 13)) (delete-region (point) (progn (skip-chars-forward " \t\r\n\f")(point)))) 
  (indent-to (or indent (gd-compute-indentation)))
  (if (eobp)
      (newline-and-indent)
    (forward-line 1))
  (back-to-indentation))

(defun py--indent-line-by-line (beg end)
  "Indent every line until end to max reasonable extend.

Starts from second line of region specified"
  (goto-char beg)
  (gd-indent-and-forward) 
  ;; (forward-line 1)
  (while (< (line-end-position) end)
    (if (empty-line-p)
	(forward-line 1)
      (gd-indent-and-forward)))
  (unless (empty-line-p) (gd-indent-and-forward)))

(defun gd-indent-region (start end &optional line-by-line)
  "Reindent a region of GDScript code.

In case first line accepts an indent, keep the remaining
lines relative.
Otherwise lines in region get outmost indent,
same with optional argument

In order to shift a chunk of code, where the first line is okay, start with second line.
"
  (interactive "*r\nP")
  (let ((orig (copy-marker (point)))
        (beg start)
        (end (copy-marker end))
	need)
    (goto-char beg)
    (beginning-of-line)
    (setq beg (point))
    (skip-chars-forward " \t\r\n\f")
    (py--indent-line-by-line beg end)
    ;; (if (eq 4 (prefix-numeric-value line-by-line))
    ;; 	(py--indent-line-by-line beg end)
    ;;   (setq need (gd-compute-indentation))
    ;;   (if (< 0 (abs need))
    ;; 	  (indent-region beg end need)
    ;; 	(py--indent-line-by-line beg end))
    ;;   (goto-char orig))
    )
  )

(defun py--beginning-of-buffer-position ()
  (point-min))

(defun py--end-of-buffer-position ()
  (point-max))

;;  Declarations start
(defun py--bounds-of-declarations ()
  "Bounds of consecutive multitude of assigments resp. statements around point.

Indented same level, which don't open blocks.
Typically declarations resp. initialisations of variables following
a class or function definition.
See also py--bounds-of-statements "
  (let* ((orig-indent (progn
                        (back-to-indentation)
                        (unless (py--beginning-of-statement-p)
                          (gd-backward-statement))
                        (unless (py--beginning-of-block-p)
                          (current-indentation))))
         (orig (point))
         last beg end)
    (when orig-indent
      (setq beg (line-beginning-position))
      ;; look upward first
      (while (and
              (progn
                (unless (py--beginning-of-statement-p)
                  (gd-backward-statement))
                (line-beginning-position))
              (gd-backward-statement)
              (not (py--beginning-of-block-p))
              (eq (current-indentation) orig-indent))
        (setq beg (line-beginning-position)))
      (goto-char orig)
      (while (and (setq last (line-end-position))
                  (setq end (gd-down-statement))
                  (not (py--beginning-of-block-p))
                  (eq (gd-indentation-of-statement) orig-indent)))
      (setq end last)
      (goto-char beg)
      (if (and beg end)
          (progn
            (when (called-interactively-p 'any) (message "%s %s" beg end))
            (cons beg end))
        (when (called-interactively-p 'any) (message "%s" nil))
        nil))))

(defun gd-backward-declarations ()
  "Got to the beginning of assigments resp. statements in current level which don't open blocks.
"
  (interactive)
  (let* ((bounds (py--bounds-of-declarations))
         (erg (car bounds)))
    (when erg (goto-char erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-forward-declarations ()
  "Got to the end of assigments resp. statements in current level which don't open blocks. "
  (interactive)
  (let* ((bounds (py--bounds-of-declarations))
         (erg (cdr bounds)))
    (when erg (goto-char erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defalias 'gd-copy-declarations 'gd-declarations)
(defun gd-declarations ()
  "Copy and mark assigments resp. statements in current level which don't open blocks or start with a keyword.

See also `gd-statements', which is more general, taking also simple statements starting with a keyword. "
  (interactive)
  (let* ((bounds (py--bounds-of-declarations))
         (beg (car bounds))
         (end (cdr bounds)))
    (when (and beg end)
      (goto-char beg)
      (push-mark)
      (goto-char end)
      (kill-new (buffer-substring-no-properties beg end))
      (exchange-point-and-mark))))

(defun gd-kill-declarations ()
  "Delete variables declared in current level.

Store deleted variables in kill-ring "
  (interactive "*")
  (let* ((bounds (py--bounds-of-declarations))
         (beg (car bounds))
         (end (cdr bounds)))
    (when (and beg end)
      (goto-char beg)
      (push-mark)
      (goto-char end)
      (kill-new (buffer-substring-no-properties beg end))
      (delete-region beg end))))
;;  Declarations end

;;  Statements start
(defun py--bounds-of-statements ()
  "Bounds of consecutive multitude of statements around point.

Indented same level, which don't open blocks. "
  (interactive)
  (let* ((orig-indent (progn
                        (back-to-indentation)
                        (unless (py--beginning-of-statement-p)
                          (gd-backward-statement))
                        (unless (py--beginning-of-block-p)
                          (current-indentation))))
         (orig (point))
         last beg end)
    (when orig-indent
      (setq beg (point))
      (while (and (setq last beg)
                  (setq beg
                        (when (gd-backward-statement)
                          (line-beginning-position)))
                  (not (gd-in-string-p))
                  (not (py--beginning-of-block-p))
                  (eq (current-indentation) orig-indent)))
      (setq beg last)
      (goto-char orig)
      (setq end (line-end-position))
      (while (and (setq last (py--end-of-statement-position))
                  (setq end (gd-down-statement))
                  (not (py--beginning-of-block-p))
                  ;; (not (looking-at gd-keywords))
                  ;; (not (looking-at "pdb\."))
                  (not (gd-in-string-p))
                  (eq (gd-indentation-of-statement) orig-indent)))
      (setq end last)
      (goto-char orig)
      (if (and beg end)
          (progn
            (when (called-interactively-p 'any) (message "%s %s" beg end))
            (cons beg end))
        (when (called-interactively-p 'any) (message "%s" nil))
        nil))))

(defun gd-backward-statements ()
  "Got to the beginning of statements in current level which don't open blocks. "
  (interactive)
  (let* ((bounds (py--bounds-of-statements))
         (erg (car bounds)))
    (when erg (goto-char erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-forward-statements ()
  "Got to the end of statements in current level which don't open blocks. "
  (interactive)
  (let* ((bounds (py--bounds-of-statements))
         (erg (cdr bounds)))
    (when erg (goto-char erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defalias 'gd-copy-statements 'gd-statements)
(defun gd-statements ()
  "Copy and mark simple statements in current level which don't open blocks.

More general than gd-declarations, which would stop at keywords like a print-statement. "
  (interactive)
  (let* ((bounds (py--bounds-of-statements))
         (beg (car bounds))
         (end (cdr bounds)))
    (when (and beg end)
      (goto-char beg)
      (push-mark)
      (goto-char end)
      (kill-new (buffer-substring-no-properties beg end))
      (exchange-point-and-mark))))

(defun gd-kill-statements ()
  "Delete statements declared in current level.

Store deleted statements in kill-ring "
  (interactive "*")
  (let* ((bounds (py--bounds-of-statements))
         (beg (car bounds))
         (end (cdr bounds)))
    (when (and beg end)
      (kill-new (buffer-substring-no-properties beg end))
      (delete-region beg end))))

(defun py--join-words-wrapping (words separator line-prefix line-length)
  (let ((lines ())
        (current-line line-prefix))
    (while words
      (let* ((word (car words))
             (maybe-line (concat current-line word separator)))
        (if (> (length maybe-line) line-length)
            (setq lines (cons (substring current-line 0 -1) lines)
                  current-line (concat line-prefix word separator " "))
          (setq current-line (concat maybe-line " "))))
      (setq words (cdr words)))
    (setq lines (cons (substring
                       current-line 0 (- 0 (length separator) 1)) lines))
    (mapconcat 'identity (nreverse lines) "\n")))

(defun gd-insert-super ()
  "Insert a function \"super()\" from current environment.

As example given in GDScript v3.1 documentation » The GDScript Standard Library »

class C(B):
    def method(self, arg):
        super().method(arg) # This does the same thing as:
                               # super(C, self).method(arg)

Returns the string inserted. "
  (interactive "*")
  (let* ((orig (point))
         (funcname (progn
                     (gd-backward-def)
                     (when (looking-at (concat gd-def-re " *\\([^(]+\\) *(\\(?:[^),]*\\),? *\\([^)]*\\))"))
                       (match-string-no-properties 2))))
         (args (match-string-no-properties 3))
         (ver (gd-which-python))
         classname erg)
    (if (< ver 3)
        (progn
          (gd-backward-class)
          (when (looking-at (concat gd-class-re " *\\([^( ]+\\)"))
            (setq classname (match-string-no-properties 2)))
          (goto-char orig)
          (setq erg (concat "super(" classname ", self)." funcname "(" args ")"))
          ;; super(C, self).method(arg)"
          (insert erg))
      (goto-char orig)
      (setq erg (concat "super()." funcname "(" args ")"))
      (insert erg))
    erg))

;; Comments
(defun gd-delete-comments-in-def-or-class ()
  "Delete all commented lines in def-or-class at point"
  (interactive "*")
  (save-excursion
    (let ((beg (py--beginning-of-def-or-class-position))
          (end (py--end-of-def-or-class-position)))
      (and beg end (py--delete-comments-intern beg end)))))

(defun gd-delete-comments-in-class ()
  "Delete all commented lines in class at point"
  (interactive "*")
  (save-excursion
    (let ((beg (py--beginning-of-class-position))
          (end (py--end-of-class-position)))
      (and beg end (py--delete-comments-intern beg end)))))

(defun gd-delete-comments-in-block ()
  "Delete all commented lines in block at point"
  (interactive "*")
  (save-excursion
    (let ((beg (py--beginning-of-block-position))
          (end (py--end-of-block-position)))
      (and beg end (py--delete-comments-intern beg end)))))

(defun gd-delete-comments-in-region (beg end)
  "Delete all commented lines in region. "
  (interactive "r*")
  (save-excursion
    (py--delete-comments-intern beg end)))

(defun py--delete-comments-intern (beg end)
  (save-restriction
    (narrow-to-region beg end)
    (goto-char beg)
    (while (and (< (line-end-position) end) (not (eobp)))
      (beginning-of-line)
      (if (looking-at (concat "[ \t]*" comment-start))
          (delete-region (point) (1+ (line-end-position)))
        (forward-line 1)))))

(defun py--edit-docstring-set-vars ()
  (save-excursion
    (setq py--docbeg (when (use-region-p) (region-beginning)))
    (setq py--docend (when (use-region-p) (region-end)))
    (let ((pps (parse-partial-sexp (point-min) (point))))
      (when (nth 3 pps)
	(setq py--docbeg (or py--docbeg (progn (goto-char (nth 8 pps))
					       (skip-chars-forward (char-to-string (char-after)))(push-mark)(point))))
	(setq py--docend (or py--docend
			     (progn (goto-char (nth 8 pps))
				    (forward-sexp)
				    (skip-chars-backward (char-to-string (char-before)))
				    (point)))))
      (setq py--docbeg (copy-marker py--docbeg))
      (setq py--docend (copy-marker py--docend)))))

;; Edit docstring
(defvar py--docbeg nil
  "Internally used by `gd-edit-docstring'")

(defvar py--docend nil
  "Internally used by `gd-edit-docstring'")

(defvar py--oldbuf nil
  "Internally used by `gd-edit-docstring'")

(defvar gd-edit-docstring-buffer "Edit docstring"
  "Name of the temporary buffer to use when editing. ")

(defvar py--edit-docstring-register nil)

(defun py--write-back-docstring ()
  (interactive)
  (unless (eq (current-buffer) (get-buffer gd-edit-docstring-buffer))
    (set-buffer gd-edit-docstring-buffer))
  (goto-char (point-min))
  (while (re-search-forward "[\"']" nil t 1)
    (or (gd-escaped)
	(replace-match (concat "\\\\" (match-string-no-properties 0)))))
  (jump-to-register py--edit-docstring-register)
  ;; (gd-restore-window-configuration)
  (delete-region py--docbeg py--docend)
  (insert-buffer gd-edit-docstring-buffer))

(defun gd-edit-docstring ()
  "Edit docstring or active region in gdscript-mode. "
  (interactive "*")
  (save-excursion
    (save-restriction
      (window-configuration-to-register py--edit-docstring-register)
      (setq py--oldbuf (current-buffer))
      (let ((orig (point))
	     pps)
	(py--edit-docstring-set-vars)
	;; store relative position in docstring
	(setq relpos (1+ (- orig py--docbeg)))
	(setq docstring (buffer-substring py--docbeg py--docend))
	(set (make-variable-buffer-local 'gd-edit-docstring-orig-pos) orig)
	(set-buffer (get-buffer-create gd-edit-docstring-buffer))
	(erase-buffer)
	(switch-to-buffer (current-buffer))
	(insert docstring)
	(gdscript-mode)
	(local-set-key [(control c)(control c)] 'py--write-back-docstring)
	(goto-char relpos)
	(message "%s" "Type C-c C-c writes contents back")
	))))

;; gdscript-components-backward-forms


(defun gd-backward-block (&optional indent)
  "Go to beginning of `block'.

If already at beginning, go one `block' backward.
Returns beginning of `block' if successful, nil otherwise"
  (interactive)
  (py--backward-prepare indent 'gd-block-re 'gd-clause-re (called-interactively-p 'any)))

(defun gd-backward-block-or-clause (&optional indent)
  "Go to beginning of `block-or-clause'.

If already at beginning, go one `block-or-clause' backward.
Returns beginning of `block-or-clause' if successful, nil otherwise"
  (interactive)
  (py--backward-prepare indent 'gd-extended-block-or-clause-re 'gd-extended-block-or-clause-re (called-interactively-p 'any)))

(defun gd-backward-clause (&optional indent)
  "Go to beginning of `clause'.

If already at beginning, go one `clause' backward.
Returns beginning of `clause' if successful, nil otherwise"
  (interactive)
  (py--backward-prepare indent 'gd-extended-block-or-clause-re 'gd-extended-block-or-clause-re (called-interactively-p 'any)))

(defun gd-backward-elif-block (&optional indent)
  "Go to beginning of `elif-block'.

If already at beginning, go one `elif-block' backward.
Returns beginning of `elif-block' if successful, nil otherwise"
  (interactive)
  (py--backward-prepare indent 'gd-elif-block-re 'gd-clause-re (called-interactively-p 'any)))

(defun gd-backward-else-block (&optional indent)
  "Go to beginning of `else-block'.

If already at beginning, go one `else-block' backward.
Returns beginning of `else-block' if successful, nil otherwise"
  (interactive)
  (py--backward-prepare indent 'gd-else-block-re 'gd-clause-re (called-interactively-p 'any)))

(defun gd-backward-except-block (&optional indent)
  "Go to beginning of `except-block'.

If already at beginning, go one `except-block' backward.
Returns beginning of `except-block' if successful, nil otherwise"
  (interactive)
  (py--backward-prepare indent 'gd-except-block-re 'gd-clause-re (called-interactively-p 'any)))

(defun gd-backward-for-block (&optional indent)
  "Go to beginning of `for-block'.

If already at beginning, go one `for-block' backward.
Returns beginning of `for-block' if successful, nil otherwise"
  (interactive)
  (py--backward-prepare indent 'gd-for-block-re 'gd-clause-re (called-interactively-p 'any)))

(defun gd-backward-if-block (&optional indent)
  "Go to beginning of `if-block'.

If already at beginning, go one `if-block' backward.
Returns beginning of `if-block' if successful, nil otherwise"
  (interactive)
  (py--backward-prepare indent 'gd-if-block-re 'gd-clause-re (called-interactively-p 'any)))

(defun gd-backward-minor-block (&optional indent)
  "Go to beginning of `minor-block'.

If already at beginning, go one `minor-block' backward.
Returns beginning of `minor-block' if successful, nil otherwise"
  (interactive)
  (py--backward-prepare indent 'gd-minor-block-re 'gd-clause-re (called-interactively-p 'any)))

(defun gd-backward-try-block (&optional indent)
  "Go to beginning of `try-block'.

If already at beginning, go one `try-block' backward.
Returns beginning of `try-block' if successful, nil otherwise"
  (interactive)
  (py--backward-prepare indent 'gd-try-block-re 'gd-clause-re (called-interactively-p 'any)))

(defun gd-backward-block-bol (&optional indent)
  "Go to beginning of `block', go to BOL.

If already at beginning, go one `block' backward.
Returns beginning of `block' if successful, nil otherwise"
  (interactive)
  (py--backward-prepare indent 'gd-block-re 'gd-clause-re (called-interactively-p 'any) t))

(defun gd-backward-block-or-clause-bol (&optional indent)
  "Go to beginning of `block-or-clause', go to BOL.

If already at beginning, go one `block-or-clause' backward.
Returns beginning of `block-or-clause' if successful, nil otherwise"
  (interactive)
  (py--backward-prepare indent 'gd-extended-block-or-clause-re 'gd-extended-block-or-clause-re (called-interactively-p 'any) t))

(defun gd-backward-clause-bol (&optional indent)
  "Go to beginning of `clause', go to BOL.

If already at beginning, go one `clause' backward.
Returns beginning of `clause' if successful, nil otherwise"
  (interactive)
  (py--backward-prepare indent 'gd-extended-block-or-clause-re 'gd-extended-block-or-clause-re (called-interactively-p 'any) t))

(defun gd-backward-elif-block-bol (&optional indent)
  "Go to beginning of `elif-block', go to BOL.

If already at beginning, go one `elif-block' backward.
Returns beginning of `elif-block' if successful, nil otherwise"
  (interactive)
  (py--backward-prepare indent 'gd-elif-block-re 'gd-clause-re (called-interactively-p 'any) t))

(defun gd-backward-else-block-bol (&optional indent)
  "Go to beginning of `else-block', go to BOL.

If already at beginning, go one `else-block' backward.
Returns beginning of `else-block' if successful, nil otherwise"
  (interactive)
  (py--backward-prepare indent 'gd-else-block-re 'gd-clause-re (called-interactively-p 'any) t))

(defun gd-backward-except-block-bol (&optional indent)
  "Go to beginning of `except-block', go to BOL.

If already at beginning, go one `except-block' backward.
Returns beginning of `except-block' if successful, nil otherwise"
  (interactive)
  (py--backward-prepare indent 'gd-except-block-re 'gd-clause-re (called-interactively-p 'any) t))

(defun gd-backward-for-block-bol (&optional indent)
  "Go to beginning of `for-block', go to BOL.

If already at beginning, go one `for-block' backward.
Returns beginning of `for-block' if successful, nil otherwise"
  (interactive)
  (py--backward-prepare indent 'gd-for-block-re 'gd-clause-re (called-interactively-p 'any) t))

(defun gd-backward-if-block-bol (&optional indent)
  "Go to beginning of `if-block', go to BOL.

If already at beginning, go one `if-block' backward.
Returns beginning of `if-block' if successful, nil otherwise"
  (interactive)
  (py--backward-prepare indent 'gd-if-block-re 'gd-clause-re (called-interactively-p 'any) t))

(defun gd-backward-minor-block-bol (&optional indent)
  "Go to beginning of `minor-block', go to BOL.

If already at beginning, go one `minor-block' backward.
Returns beginning of `minor-block' if successful, nil otherwise"
  (interactive)
  (py--backward-prepare indent 'gd-minor-block-re 'gd-clause-re (called-interactively-p 'any) t))

(defun gd-backward-try-block-bol (&optional indent)
  "Go to beginning of `try-block', go to BOL.

If already at beginning, go one `try-block' backward.
Returns beginning of `try-block' if successful, nil otherwise"
  (interactive)
  (py--backward-prepare indent 'gd-try-block-re 'gd-clause-re (called-interactively-p 'any) t))

;; gdscript-components-forward-forms


(defun gd-forward-block (&optional indent)
  "Go to end of block.

Returns end of block if successful, nil otherwise"
  (interactive "P")
  (let* ((orig (point))
         (erg (py--end-base 'gd-block-re orig)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-forward-block-bol (&optional indent)
  "Goto beginning of line following end of block.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-block': down from current definition to next beginning of block below. "
  (interactive)
  (let ((erg (gd-forward-block indent)))
    (setq erg (py--beginning-of-line-form erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-forward-block-or-clause (&optional indent)
  "Go to end of block-or-clause.

Returns end of block-or-clause if successful, nil otherwise"
  (interactive "P")
  (let* ((orig (point))
         (erg (py--end-base 'gd-block-or-clause-re orig)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-forward-block-or-clause-bol (&optional indent)
  "Goto beginning of line following end of block-or-clause.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-block-or-clause': down from current definition to next beginning of block-or-clause below. "
  (interactive)
  (let ((erg (gd-forward-block-or-clause indent)))
    (setq erg (py--beginning-of-line-form erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-forward-class (&optional indent)
  "Go to end of class.

Returns end of class if successful, nil otherwise"
  (interactive "P")
  (let* ((orig (point))
         (erg (py--end-base 'gd-class-re orig)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-forward-class-bol (&optional indent)
  "Goto beginning of line following end of class.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-class': down from current definition to next beginning of class below. "
  (interactive)
  (let ((erg (gd-forward-class indent)))
    (setq erg (py--beginning-of-line-form erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-forward-clause (&optional indent)
  "Go to end of clause.

Returns end of clause if successful, nil otherwise"
  (interactive "P")
  (let* ((orig (point))
         (erg (py--end-base 'gd-clause-re orig)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-forward-clause-bol (&optional indent)
  "Goto beginning of line following end of clause.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-clause': down from current definition to next beginning of clause below. "
  (interactive)
  (let ((erg (gd-forward-clause indent)))
    (setq erg (py--beginning-of-line-form erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-forward-def-or-class (&optional indent)
  "Go to end of def-or-class.

Returns end of def-or-class if successful, nil otherwise"
  (interactive "P")
  (let* ((orig (point))
         (erg (py--end-base 'gd-def-or-class-re orig)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-forward-def-or-class-bol (&optional indent)
  "Goto beginning of line following end of def-or-class.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-def-or-class': down from current definition to next beginning of def-or-class below. "
  (interactive)
  (let ((erg (gd-forward-def-or-class indent)))
    (setq erg (py--beginning-of-line-form erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-forward-def (&optional indent)
  "Go to end of def.

Returns end of def if successful, nil otherwise"
  (interactive "P")
  (let* ((orig (point))
         (erg (py--end-base 'gd-def-re orig)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-forward-def-bol (&optional indent)
  "Goto beginning of line following end of def.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-def': down from current definition to next beginning of def below. "
  (interactive)
  (let ((erg (gd-forward-def indent)))
    (setq erg (py--beginning-of-line-form erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-forward-if-block (&optional indent)
  "Go to end of if-block.

Returns end of if-block if successful, nil otherwise"
  (interactive "P")
  (let* ((orig (point))
         (erg (py--end-base 'gd-if-block-re orig)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-forward-if-block-bol (&optional indent)
  "Goto beginning of line following end of if-block.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-if-block': down from current definition to next beginning of if-block below. "
  (interactive)
  (let ((erg (gd-forward-if-block indent)))
    (setq erg (py--beginning-of-line-form erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-forward-elif-block (&optional indent)
  "Go to end of elif-block.

Returns end of elif-block if successful, nil otherwise"
  (interactive "P")
  (let* ((orig (point))
         (erg (py--end-base 'gd-elif-block-re orig)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-forward-elif-block-bol (&optional indent)
  "Goto beginning of line following end of elif-block.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-elif-block': down from current definition to next beginning of elif-block below. "
  (interactive)
  (let ((erg (gd-forward-elif-block indent)))
    (setq erg (py--beginning-of-line-form erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-forward-else-block (&optional indent)
  "Go to end of else-block.

Returns end of else-block if successful, nil otherwise"
  (interactive "P")
  (let* ((orig (point))
         (erg (py--end-base 'gd-else-block-re orig)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-forward-else-block-bol (&optional indent)
  "Goto beginning of line following end of else-block.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-else-block': down from current definition to next beginning of else-block below. "
  (interactive)
  (let ((erg (gd-forward-else-block indent)))
    (setq erg (py--beginning-of-line-form erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-forward-for-block (&optional indent)
  "Go to end of for-block.

Returns end of for-block if successful, nil otherwise"
  (interactive "P")
  (let* ((orig (point))
         (erg (py--end-base 'gd-for-block-re orig)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-forward-for-block-bol (&optional indent)
  "Goto beginning of line following end of for-block.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-for-block': down from current definition to next beginning of for-block below. "
  (interactive)
  (let ((erg (gd-forward-for-block indent)))
    (setq erg (py--beginning-of-line-form erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-forward-except-block (&optional indent)
  "Go to end of except-block.

Returns end of except-block if successful, nil otherwise"
  (interactive "P")
  (let* ((orig (point))
         (erg (py--end-base 'gd-except-block-re orig)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-forward-except-block-bol (&optional indent)
  "Goto beginning of line following end of except-block.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-except-block': down from current definition to next beginning of except-block below. "
  (interactive)
  (let ((erg (gd-forward-except-block indent)))
    (setq erg (py--beginning-of-line-form erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-forward-try-block (&optional indent)
  "Go to end of try-block.

Returns end of try-block if successful, nil otherwise"
  (interactive "P")
  (let* ((orig (point))
         (erg (py--end-base 'gd-try-block-re orig)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-forward-try-block-bol (&optional indent)
  "Goto beginning of line following end of try-block.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-try-block': down from current definition to next beginning of try-block below. "
  (interactive)
  (let ((erg (gd-forward-try-block indent)))
    (setq erg (py--beginning-of-line-form erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-forward-minor-block (&optional indent)
  "Go to end of minor-block.

Returns end of minor-block if successful, nil otherwise"
  (interactive "P")
  (let* ((orig (point))
         (erg (py--end-base 'gd-minor-block-re orig)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-forward-minor-block-bol (&optional indent)
  "Goto beginning of line following end of minor-block.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-minor-block': down from current definition to next beginning of minor-block below. "
  (interactive)
  (let ((erg (gd-forward-minor-block indent)))
    (setq erg (py--beginning-of-line-form erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

;; gdscript-components-forward-forms.el ends here
;; gdscript-components-move

;; Indentation
;; Travel current level of indentation
(defun py--travel-this-indent-backward ()
  (while (and (gd-backward-statement)
	      (or indent (setq indent (current-indentation)))
	      (eq indent (current-indentation))(setq erg (point)) (not (bobp)))))

(defun gd-backward-indent ()
  "Go to the beginning of a section of equal indent.

If already at the beginning or before a indent, go to next indent in buffer upwards
Returns final position when called from inside section, nil otherwise"
  (interactive)
  (unless (bobp)
    (let ((orig (point))
	 erg indent)
      (py--travel-this-indent-backward)
      (when erg (goto-char erg))
      (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
      erg)))

(defun py--travel-this-indent-backward-bol ()
  (while (and (gd-backward-statement-bol)
	      (or indent (setq indent (current-indentation)))
	      (eq indent (current-indentation))(setq erg (point)) (not (bobp))))
  (when erg (goto-char erg)))

(defun gd-backward-indent-bol ()
  "Go to the beginning of line of a section of equal indent.

If already at the beginning or before an indent, go to next indent in buffer upwards
Returns final position when called from inside section, nil otherwise"
  (interactive)
  (unless (bobp)
    (let ((orig (point))
	  (indent (when (eq (current-indentation) (current-column)) (current-column)))
	  erg)
      (py--travel-this-indent-backward-bol)
      ;; (when erg (goto-char erg)
      ;; (beginning-of-line)
      ;; (setq erg (point)))
      (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
      erg)))

(defun py--travel-this-indent-forward ()
  (while (and (gd-down-statement)
	      (or indent (eq indent (current-indentation)))
	      (eq indent (current-indentation))(setq done (point)) (not (bobp)))))

(defun gd-forward-indent ()
  "Go to the end of a section of equal indentation.

If already at the end, go down to next indent in buffer
Returns final position when called from inside section, nil otherwise"
  (interactive)
  (unless (eobp)
    (let ((orig (point))
	  done indent)
      (when (gd-forward-statement)
	(save-excursion
	  (setq done (point))
	  (setq indent (and (gd-backward-statement)(current-indentation)))))
      (py--travel-this-indent-forward)
      (when done (goto-char done))
      ;; navigation doesn't reach BOL
      (unless (eolp) (setq done (gd-forward-statement)))
      (when (eq (current-column) (current-indentation)) (gd-end-of-statement))
      (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" done))
      done)))

(defun gd-forward-indent-bol ()
  "Go to beginning of line following of a section of equal indentation.

If already at the end, go down to next indent in buffer
Returns final position when called from inside section, nil otherwise"
  (interactive)
  (unless (eobp)
    (let ((orig (point))
	  erg indent)
      (when (gd-forward-statement)
	(save-excursion
	  (setq erg (point))
	  (setq indent (and (gd-backward-statement)(current-indentation)))))
      (py--travel-this-indent-forward)
      (when erg (goto-char erg)
	    (unless (eolp) (setq erg (gd-forward-statement))))
      (when erg
	(when (eq (current-column) (current-indentation)) (gd-forward-statement))
	(unless (eobp) (forward-line 1) (beginning-of-line)))
      (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
      erg)))

(defun gd-backward-expression (&optional orig done repeat)
  "Go to the beginning of a python expression.

If already at the beginning or before a expression, go to next expression in buffer upwards"
  (interactive)
  (unless (bobp)
    (unless done (skip-chars-backward " \t\r\n\f"))
    (let ((repeat (or (and repeat (1+ repeat)) 0))
	  (pps (parse-partial-sexp (point-min) (point)))
          (orig (or orig (point)))
          erg)
      (if (< gd-max-specpdl-size repeat)
	  (error "`gd-backward-expression' reached loops max.")
	(cond
	 ;; comments
	 ((nth 8 pps)
	  (goto-char (nth 8 pps))
	  (gd-backward-expression orig done repeat))
	 ;; lists
	 ((nth 1 pps)
	  (goto-char (nth 1 pps))
	  (skip-chars-backward gd-expression-skip-chars))
	 ;; in string
	 ((nth 3 pps)
	  (goto-char (nth 8 pps)))
	 ;; after operator
	 ((and (not done) (looking-back gd-operator-re))
	  (skip-chars-backward "^ \t\r\n\f")
	  (skip-chars-backward " \t\r\n\f")
	  (gd-backward-expression orig done repeat))
	 ((and (not done)
	       (< 0 (abs (skip-chars-backward gd-expression-skip-chars))))
	  (setq done t)
	  (gd-backward-expression orig done repeat))))
      (unless (or (eq (point) orig)(and (bobp)(eolp)))
	(setq erg (point)))
      (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
      erg)))

(defun gd-forward-expression (&optional orig done repeat)
  "Go to the end of a compound python expression.

Operators are ignored. "
  (interactive)
  (unless done (skip-chars-forward " \t\r\n\f"))
  (unless (eobp)
    (let ((repeat (or (and repeat (1+ repeat)) 0))
	  (pps (parse-partial-sexp (point-min) (point)))
          (orig (or orig (point)))
          erg)
      (if (< gd-max-specpdl-size repeat)
	  (error "`gd-forward-expression' reached loops max.")
	(cond
	 ;; in comment
	 ((nth 4 pps)
	  (or (< (point) (progn (forward-comment 1)(point)))(forward-line 1))
	  (gd-forward-expression orig done repeat))
	 ;; empty before comment
	 ((and (looking-at "[ \t]*#")(looking-back "^[ \t]*"))
	  (while (and (looking-at "[ \t]*#") (not (eobp)))
	    (forward-line 1))
	  (gd-forward-expression orig done repeat))
	 ;; inside string
	 ((nth 3 pps)
	  (goto-char (nth 8 pps))
	  (goto-char (scan-sexps (point) 1))
	  (setq done t)
	  (gd-forward-expression orig done repeat))
	 ((looking-at "\"\"\"\\|'''\\|\"\\|'")
	  (goto-char (scan-sexps (point) 1))
	  (setq done t)
	  (gd-forward-expression orig done repeat))
	 ((nth 1 pps)
	  (goto-char (nth 1 pps))
	  (goto-char (scan-sexps (point) 1))
	  (setq done t)
	  (gd-forward-expression orig done repeat))
	 ;; looking at opening delimiter
	 ((eq 4 (car-safe (syntax-after (point))))
	  (goto-char (scan-sexps (point) 1))
	  (setq done t)
	  (gd-forward-expression orig done repeat))
	 ((and (eq orig (point)) (looking-at gd-operator-re))
	  (goto-char (match-end 0))
	  (gd-forward-expression orig done repeat))
	 ((and (not done)
	       (< 0 (skip-chars-forward gd-expression-skip-chars)))
	  (setq done t)
	  (gd-forward-expression orig done repeat))
	 ;; at colon following arglist
	 ((looking-at ":[ \t]*$")
	  (forward-char 1)))
	(unless (or (eq (point) orig)(and (eobp)(bolp)))
	  (setq erg (point)))
	(when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
	erg))))

(defun gd-backward-partial-expression (&optional orig)
  (interactive)
  (let ((orig (point))
	erg)
    (and (< 0 (abs (skip-chars-backward " \t\r\n\f")))(not (bobp))(forward-char -1))
    (when (py--in-comment-p)
      (gd-backward-comment)
      (skip-chars-backward " \t\r\n\f"))
    ;; part of gd-partial-expression-forward-chars
    (when (member (char-after) (list ?\ ?\" ?' ?\) ?} ?\] ?: ?#))
      (forward-char -1))
    (skip-chars-backward gd-partial-expression-forward-chars)
    (when (< 0 (abs (skip-chars-backward gd-partial-expression-backward-chars)))
      (while (and (not (bobp)) (py--in-comment-p)(< 0 (abs (skip-chars-backward gd-partial-expression-backward-chars))))))
    (when (< (point) orig)
      (unless
	  (and (bobp) (member (char-after) (list ?\ ?\t ?\r ?\n ?\f)))
	(setq erg (point))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-forward-partial-expression (&optional orig)
  (interactive)
  (let (erg)
    (skip-chars-forward gd-partial-expression-backward-chars)
    ;; group arg
    (while
     (looking-at "[\[{(]")
     (goto-char (scan-sexps (point) 1)))
    (setq erg (point))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

;; Partial- or Minor Expression
;;  Line
(defun gd-backward-line ()
  "Go to beginning-of-line, return position.

If already at beginning-of-line and not at BOB, go to beginning of previous line. "
  (interactive)
  (unless (bobp)
    (let ((erg
           (if (bolp)
               (progn
                 (forward-line -1)
                 (progn (beginning-of-line)(point)))
             (progn (beginning-of-line)(point)))))
      (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
      erg)))

(defun gd-forward-line ()
  "Go to end-of-line, return position.

If already at end-of-line and not at EOB, go to end of next line. "
  (interactive)
  (unless (eobp)
    (let ((orig (point))
	  erg)
      (when (eolp) (forward-line 1))
      (end-of-line)
      (when (< orig (point))(setq erg (point)))
      (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
      erg)))

;;  Statement
(defun gd-backward-statement (&optional orig done limit ignore-in-string-p)
  "Go to the initial line of a simple statement.

For beginning of compound statement use gd-backward-block.
For beginning of clause gd-backward-clause.

`ignore-in-string-p' allows moves inside a docstring, used when
computing indents"
  (interactive)
  (save-restriction
    (unless (bobp)
      (let* ((orig (or orig (point)))
             (this (point))
             (cui (current-indentation))
             (pps (parse-partial-sexp (or limit (point-min))(point)))
             (done done)
             erg)
	;; lp:1382788
	(unless done
	  (and (< 0 (abs (skip-chars-backward " \t\r\n\f")))
 	       (setq pps (parse-partial-sexp (or limit (point-min))(point)))))
        (cond
         ((and (bolp)(eolp))
          (skip-chars-backward " \t\r\n\f")
          (gd-backward-statement orig done limit ignore-in-string-p))
	 ;; inside string
         ((and (nth 3 pps)(not ignore-in-string-p))
	  (setq done t)
	  (goto-char (nth 8 pps))
	  (gd-backward-statement orig done limit ignore-in-string-p))
	 ((nth 4 pps)
	  (goto-char (nth 8 pps))
	  (skip-chars-backward " \t\r\n\f")
	  (gd-backward-statement orig done limit ignore-in-string-p))
         ((nth 1 pps)
          (goto-char (1- (nth 1 pps)))
	  (when (py--skip-to-semicolon-backward (save-excursion (back-to-indentation)(point)))
	    (setq done t))
          (gd-backward-statement orig done limit ignore-in-string-p))
         ((gd-preceding-line-backslashed-p)
          (forward-line -1)
          (back-to-indentation)
          (setq done t)
          (gd-backward-statement orig done limit ignore-in-string-p))
	 ;; at raw-string
	 ;; (and (looking-at "\"\"\"\\|'''") (member (char-before) (list ?u ?U ?r ?R)))
	 ((py--at-raw-string)
	  (forward-char -1)
	  (gd-backward-statement orig done limit ignore-in-string-p))
	 ;; BOL or at space before comment
         ((and (looking-at "[ \t]*#")(looking-back "^[ \t]*"))
          (forward-comment -1)
          (while (and (not (bobp)) (looking-at "[ \t]*#")(looking-back "^[ \t]*"))
            (forward-comment -1))
          (unless (bobp)
            (gd-backward-statement orig done limit ignore-in-string-p)))
	 ;; at inline comment
         ((looking-at "[ \t]*#")
	  (when (py--skip-to-semicolon-backward (save-excursion (back-to-indentation)(point)))
	    (setq done t))
	  (gd-backward-statement orig done limit ignore-in-string-p))
	 ;; at beginning of string
	 ((and (not done) (looking-at gd-string-delim-re))
	  (when (< 0 (abs (skip-chars-backward " \t\r\n\f")))
	    (setq done t))
	  (back-to-indentation)
	  (gd-backward-statement orig done limit ignore-in-string-p))
	 ;; after end of statement
	 ((and (not done) (eq (char-before) ?\;))
	  (skip-chars-backward ";")
	  (gd-backward-statement orig done limit ignore-in-string-p))
	 ;; travel until indentation or semicolon
	 ((and (not done) (py--skip-to-semicolon-backward (save-excursion (back-to-indentation)(point))))
	  (setq done t)
	  (gd-backward-statement orig done limit ignore-in-string-p))
	 ;; at current indent
	 ((and (not done) (not (eq 0 (skip-chars-backward " \t\r\n\f"))))
	  (gd-backward-statement orig done limit ignore-in-string-p)))
	;; return nil when before comment
	(unless (and (looking-at "[ \t]*#") (looking-back "^[ \t]*"))
	  (when (< (point) orig)(setq erg (point))))
	(when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
	erg))))

(defun gd-backward-statement-bol (&optional indent)
  "Goto beginning of line where statement starts.
  Returns position reached, if successful, nil otherwise.

See also `gd-up-statement': up from current definition to next beginning of statement above. "
  (interactive)
  (let* ((orig (point))
         erg)
    (unless (bobp)
      (cond ((bolp)
	     (and (gd-backward-statement orig)
		  (progn (beginning-of-line)
			 (setq erg (point)))))
	    (t (setq erg
		     (and
		      (gd-backward-statement)
		      (progn (beginning-of-line) (point)))))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-forward-statement (&optional orig done repeat)
  "Go to the last char of current statement.

Optional argument REPEAT, the number of loops done already, is checked for gd-max-specpdl-size error. Avoid eternal loops due to missing string delimters etc. "
  (interactive)
  (unless (eobp)
    (let ((repeat (or (and repeat (1+ repeat)) 0))
          (orig (or orig (point)))
          erg pos last
          ;; use by scan-lists
          forward-sexp-function
          stringchar stm pps err)
      (unless done (py--skip-to-comment-or-semicolon done))
      (setq pps (parse-partial-sexp (point-min) (point)))
      ;; (origline (or origline (gd-count-lines)))
      (cond
       ;; which-function-mode, lp:1235375
       ((< gd-max-specpdl-size repeat)
        (error "gd-forward-statement reached loops max. If no error, customize `gd-max-specpdl-size'"))
       ;; list
       ((nth 1 pps)
        (if (<= orig (point))
	    (progn
	      (setq orig (point))
	      ;; do not go back at a possible unclosed list
	      (goto-char (nth 1 pps))
	      (if
		  (ignore-errors (forward-list))
		  (progn
		    (when (looking-at ":[ \t]*$")
		      (forward-char 1))
		    (setq done t)
		    (skip-chars-forward "^#" (line-end-position))
		    (skip-chars-backward " \t\r\n\f" (line-beginning-position))
		    (gd-forward-statement orig done repeat))
		(setq err (py--record-list-error pps))
		(goto-char orig)))))
       ;; string
       ((nth 3 pps)
	(when (gd-end-of-string)
	  (end-of-line)
	  (skip-chars-backward " \t\r\n\f")
	  (setq pps (parse-partial-sexp (point-min) (point)))
	  (unless (and done (not (or (nth 1 pps) (nth 8 pps))) (eolp)) (gd-forward-statement orig done repeat))))
       ;; in non-terminated string

       ;; in comment
       ((nth 4 pps)
	(py--end-of-comment-intern (point))
	(py--skip-to-comment-or-semicolon done)
	(while (and (eq (char-before (point)) ?\\ )
		    (gd-escaped)(setq last (point)))
	  (forward-line 1)(end-of-line))
	(and last (goto-char last)
	     (forward-line 1)
	     (back-to-indentation))
	(gd-forward-statement orig done repeat))
       ((gd-current-line-backslashed-p)
	(end-of-line)
	(skip-chars-backward " \t\r\n\f" (line-beginning-position))
	(while (and (eq (char-before (point)) ?\\ )
		    (gd-escaped))
	  (forward-line 1)
	  (end-of-line)
	  (skip-chars-backward " \t\r\n\f" (line-beginning-position)))
	(unless (eobp)
	  (gd-forward-statement orig done repeat)))
       ((eq orig (point))
	(skip-chars-forward " \t\r\n\f#'\"")
	(py--skip-to-comment-or-semicolon done)
	(gd-forward-statement orig done repeat))
       ((eq (current-indentation) (current-column))
	(py--skip-to-comment-or-semicolon done)
	;; (setq pps (parse-partial-sexp (point-min) (point)))
	(unless done
	  (gd-forward-statement orig done repeat)))

       ((and (looking-at "[[:print:]]+$") (not done) (py--skip-to-comment-or-semicolon done))
	(gd-forward-statement orig done repeat)))
      (unless
	  (or
	   (eq (point) orig)
	   (member (char-before) (list 10 32 9 ?#)))
	(setq erg (point)))
      (if (and gd-verbose-p err)
	  (py--message-error err)
        (and gd-verbose-p (called-interactively-p 'any) (message "%s" erg)))
      erg)))

(defun gd-forward-statement-bol ()
  "Go to the beginning-of-line following current statement."
  (interactive)
  (let ((erg (gd-forward-statement)))
    (setq erg (py--beginning-of-line-form erg))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

;;  Decorator
(defun gd-backward-decorator ()
  "Go to the beginning of a decorator.

Returns position if succesful "
  (interactive)
  (back-to-indentation)
  (while (and (not (looking-at "@\\w+"))
              (not
               ;; (empty-line-p)
               (eq 9 (char-after)))
              (not (bobp))(forward-line -1))
    (back-to-indentation))
  (let ((erg (when (looking-at "@\\w+")(match-beginning 0))))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-forward-decorator ()
  "Go to the end of a decorator.

Returns position if succesful "
  (interactive)
  (let ((orig (point)) erg)
    (unless (looking-at "@\\w+")
      (setq erg (gd-backward-decorator)))
    (when erg
      (if
          (re-search-forward gd-def-or-class-re nil t)
          (progn
            (back-to-indentation)
            (skip-chars-backward " \t\r\n\f")
            (gd-leave-comment-or-string-backward)
            (skip-chars-backward " \t\r\n\f")
            (setq erg (point)))
        (goto-char orig)
        (end-of-line)
        (skip-chars-backward " \t\r\n\f")
        (when (ignore-errors (goto-char (gd-in-list-p)))
          (forward-list))
        (when (< orig (point))
          (setq erg (point))))
      (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
      erg)))

(defun gd-backward-comment (&optional pos)
  "Got to beginning of a commented section. "
  (interactive)
  (let ((erg pos)
	last)
    (when erg (goto-char erg))
    (while (and (not (bobp)) (setq erg (gd-in-comment-p)))
      (when (< erg (point))
	(goto-char erg)
	(setq last (point)))
      (skip-chars-backward " \t\r\n\f"))
    (when last (goto-char last))
    last))

(defun gd-forward-comment (&optional pos char)
  "Go to end of commented section.

Optional args position and comment-start character
Travel empty lines "
  (interactive)
  (let ((orig (or pos (point)))
	(char (or char (string-to-char comment-start)))
	gd-forward-comment-last)
    (while (and (not (eobp))
		(or
		 (forward-comment 99999)
		 (when (py--in-comment-p)
		   (progn
		     (end-of-line)
		     (skip-chars-backward " \t\r\n\f")
		     (setq gd-forward-comment-last (point))))
		 (prog1 (forward-line 1)
		   (end-of-line)))))
    (when gd-forward-comment-last (goto-char gd-forward-comment-last))
    ;; forward-comment fails sometimes
    (and (eq orig (point)) (prog1 (forward-line 1) (back-to-indentation))
	 (while (member (char-after) (list char 10))(forward-line 1)(back-to-indentation)))
    (when (< orig (point)) (setq erg (point)))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

;;  Helper functions
(defun gd-go-to-beginning-of-comment ()
  "Go to the beginning of current line's comment, if any.

From a programm use macro `gd-backward-comment' instead "
  (interactive)
  (let ((erg (gd-backward-comment)))
    (when (and gd-verbose-p (called-interactively-p 'any))
      (message "%s" erg))))

(defun py--go-to-keyword (regexp &optional maxindent)
  "Returns a list, whose car is indentation, cdr position. "
  (let ((orig (point))
        (maxindent
	 (or maxindent
	     (if (empty-line-p)
		 (progn
		   (gd-backward-statement)
		   (current-indentation))
	       (or maxindent (and (< 0 (current-indentation))(current-indentation))
		   ;; make maxindent large enough if not set
		   (* 99 gd-indent-offset)))))
        done erg cui)
    (while (and (not done) (not (bobp)))
      ;; (while (and (re-search-backward regexp nil 'move 1)(nth 8 (parse-partial-sexp (point-min) (point)))))
      ;; (or (< (point) orig) (gd-backward-statement))
      (gd-backward-statement)

      (when
	  (and (<= (current-indentation) maxindent)
	       (setq maxindent (current-indentation))
	       (looking-at regexp))
	(setq erg (point))
	(setq done t)
        ;; (when (and first (not maxindent))
	;; (setq maxindent (current-indentation))
	;; (setq first nil))
	))
    (when erg (setq erg (cons (current-indentation) erg)))
    erg))

(defun py--clause-lookup-keyword (regexp arg &optional indent orig origline)
  "Returns a list, whose car is indentation, cdr position. "
  (let* ((orig (or orig (point)))
         (origline (or origline (gd-count-lines)))
         (stop (if (< 0 arg)'(eobp)'(bobp)))
         (function (if (< 0 arg) 'gd-forward-statement 'gd-backward-statement))
         (count 1)
         (maxindent (cond (indent indent)
                          ((< (gd-count-lines) origline)
                           (current-indentation))
                          (t 0)))
         (complement-re
          (cond ((or (string-match "finally" regexp)
                     (string-match "except" regexp))
                 gd-try-re)
                ((string-match "elif" regexp)
                 gd-if-re)
                ((string-match "else" regexp)
                 gd-minor-block-re)))
         (first t)
         erg done strict)
    (while (and (not (eval stop))
                (< 0 count)
                (or done (setq erg (funcall function))))
      (setq done nil)
      (when (and first (< maxindent (current-indentation)))
        (setq maxindent (current-indentation))
        (setq first nil))
      (when (if strict
                (< (current-indentation) maxindent)
              (<= (current-indentation) maxindent))
        (unless (looking-at gd-block-or-clause-re)
          (setq maxindent (current-indentation)))
        ;; (message "%s %s" count indent)
        ;; nesting
        (cond
         ((and (looking-at "\\_<finally\\>[: \n\t]")(save-match-data (string-match regexp "finally")))
          (setq indent (current-indentation))
          (while
              (and
               (not (eval stop))
               (funcall function)
               (setq done t)
               (not (and (eq indent (current-indentation)) (looking-at "try"))))))
         ((and (looking-at "\\<else\\>[: \n\t]")(save-match-data (string-match "else" regexp)))
          (setq indent (current-indentation))
          (setq count (1+ count))
          (while
              (and
               (not (eval stop))
               (funcall function)
               (setq done t)
               (not (and (eq indent (current-indentation)) (looking-at "try\\|if"))))))
         ((and (looking-at "\\_<else\\>[: \n\t]")(save-match-data (string-match "else" regexp)))
          (setq indent (current-indentation))
          (setq count (1+ count))
          (while
              (and
               (not (eval stop))
               (funcall function)
               (setq done t)
               (not (and (eq indent (current-indentation)) (looking-at "try\\|if"))))))
         ((and (looking-at "\\_<elif\\>[ \n\t]")(save-match-data (string-match "elif" regexp)))
          (setq indent (current-indentation))
          (while
              (and
               (not (eval stop))
               (funcall function)
               (setq done t)
               ;; doesn't mean nesting yet
               (setq count (1- count))
               (not (and (eq indent (current-indentation)) (looking-at "if"))))))
         ((and (looking-at complement-re)(<= (current-indentation) maxindent))
          (setq count (1- count)))
         (t (cond ((and (string-match "except" regexp)(looking-at gd-block-re))
                   (setq count (1- count)))
                  ((and (string-match "else" regexp)(looking-at "except"))
                   (current-indentation))
                  (t
                   (setq strict t)
                   ))))))
    (when erg
      (if (looking-at gd-def-or-class-re)
          (setq erg (cons (+ (current-indentation) gd-indent-offset) erg))
        (setq erg (cons (current-indentation) erg))))
    erg))

(defun gd-leave-comment-or-string-backward (&optional pos)
  "If inside a comment or string, leave it backward. "
  (interactive)
  (let ((pps
         (if (featurep 'xemacs)
             (parse-partial-sexp (point-min) (point))
           (parse-partial-sexp (point-min) (point)))))
    (when (nth 8 pps)
      (goto-char (1- (nth 8 pps))))))

(defun gd-beginning-of-list-pps (&optional iact last ppstart orig done)
  "Go to the beginning of a list.
Optional ARG indicates a start-position for `parse-partial-sexp'.
Return beginning position, nil if not inside."
  (interactive "p")
  (let* ((orig (or orig (point)))
         (ppstart (or ppstart (re-search-backward "^[a-zA-Z]" nil t 1) (point-min)))
         erg)
    (unless done (goto-char orig))
    (setq done t)
    (if
        (setq erg (nth 1 (if (featurep 'xemacs)
                             (parse-partial-sexp ppstart (point))
                           (parse-partial-sexp (point-min) (point)))))
        (progn
          (setq last erg)
          (goto-char erg)
          (gd-beginning-of-list-pps iact last ppstart orig done))
      (when iact (message "%s" last))
      last)))

(defun gd-forward-into-nomenclature (&optional arg iact)
  "Move forward to end of a nomenclature symbol.

With \\[universal-argument] (programmatically, optional argument ARG), do it that many times.

A `nomenclature' is a fancy way of saying AWordWithMixedCaseNotUnderscores."
  (interactive "p")
  (or arg (setq arg 1))
  (let ((case-fold-search nil)
        (orig (point))
        erg)
    (if (> arg 0)
        (while (and (not (eobp)) (> arg 0))
          ;; (setq erg (re-search-forward "\\(\\W+[_[:lower:][:digit:]ß]+\\)" nil t 1))
          (cond
           ((or (not (eq 0 (skip-chars-forward "[[:blank:][:punct:]\n\r]")))
                (not (eq 0 (skip-chars-forward "_"))))
            (when (or
                   (< 1 (skip-chars-forward "[:upper:]"))
                   (not (eq 0 (skip-chars-forward "[[:lower:][:digit:]ß]")))
                   (not (eq 0 (skip-chars-forward "[[:lower:][:digit:]]"))))
              (setq arg (1- arg))))
           ((or
             (< 1 (skip-chars-forward "[:upper:]"))
             (not (eq 0 (skip-chars-forward "[[:lower:][:digit:]ß]")))
             (not (eq 0 (skip-chars-forward "[[:lower:][:digit:]]"))))
            (setq arg (1- arg)))))
      (while (and (not (bobp)) (< arg 0))
        (when (not (eq 0 (skip-chars-backward "[[:blank:][:punct:]\n\r\f_]")))

          (forward-char -1))
        (or
         (not (eq 0 (skip-chars-backward "[:upper:]")))
         (not (eq 0 (skip-chars-backward "[[:lower:][:digit:]ß]")))
         (skip-chars-backward "[[:lower:][:digit:]ß]"))
        (setq arg (1+ arg))))
    (if (< (point) orig)
        (progn
          (when (looking-back "[[:upper:]]")
            ;; (looking-back "[[:blank:]]"
            (forward-char -1))
          (if (looking-at "[[:alnum:]ß]")
              (setq erg (point))
            (setq erg nil)))
      (if (and (< orig (point)) (not (eobp)))
          (setq erg (point))
        (setq erg nil)))
    (when (and gd-verbose-p (or iact (called-interactively-p 'any))) (message "%s" erg))
    erg))

(defun gd-backward-into-nomenclature (&optional arg)
  "Move backward to beginning of a nomenclature symbol.

With optional ARG, move that many times.  If ARG is negative, move
forward.

A `nomenclature' is a fancy way of saying AWordWithMixedCaseNotUnderscores."
  (interactive "p")
  (setq arg (or arg 1))
  (gd-forward-into-nomenclature (- arg) arg))

(defun py--travel-current-indent (indent &optional orig)
  "Moves down until clause is closed, i.e. current indentation is reached.

Takes a list, INDENT and START position. "
  (unless (eobp)
    (let ((orig (or orig (point)))
          last)
      (while (and (setq last (point))(not (eobp))(gd-forward-statement)
                  (save-excursion (or (<= indent (progn  (gd-backward-statement)(current-indentation)))(eq last (line-beginning-position))))
                  ;; (py--end-of-statement-p)
))
      (goto-char last)
      (when (< orig last)
        last))))

(defun gd-beginning-of-block-current-column ()
  "Reach next beginning of block upwards which starts at current column.

Return position"
  (interactive)
  (let* ((orig (point))
         (cuco (current-column))
         (str (make-string cuco ?\s))
         pps erg)
    (while (and (not (bobp))(re-search-backward (concat "^" str gd-block-keywords) nil t)(or (nth 8 (setq pps (parse-partial-sexp (point-min) (point)))) (nth 1 pps))))
    (back-to-indentation)
    (and (< (point) orig)(setq erg (point)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-backward-section ()
  "Go to next section start upward in buffer.

Return position if successful"
  (interactive)
  (let ((orig (point)))
    (while (and (re-search-backward gd-section-start nil t 1)
		(nth 8 (parse-partial-sexp (point-min) (point)))))
    (when (and (looking-at gd-section-start)(< (point) orig))
      (point))))

(defun gd-forward-section ()
  "Go to next section end downward in buffer.

Return position if successful"
  (interactive)
  (let ((orig (point))
	last)
    (while (and (re-search-forward gd-section-end nil t 1)
		(setq last (point))
		(goto-char (match-beginning 0))
		(nth 8 (parse-partial-sexp (point-min) (point)))
		(goto-char (match-end 0))))
    (and last (goto-char last))
    (when (and (looking-back gd-section-end)(< orig (point)))
      (point))))

(defun py--backward-def-or-class-decorator-maybe (&optional bol)
  "Return position of the decorator.

With BOL, return line-beginning-position"
  (let ((orig (point))
	erg)
    (while (and (not (bobp)) (progn (forward-line -1)(beginning-of-line) (eq (char-after) ?@)))
      (setq erg (point)))
    ;; for bol-forms, set erg to bol
    (when (and erg bol
	       (setq erg (line-beginning-position))))
    (or erg (goto-char orig))))

(defun py--backward-def-or-class-matcher (regexp indent origline)
  (let (done)
    (while (and
	    (not done)
	    (re-search-backward regexp nil 'move 1)
	    (or
	     (nth 8 (parse-partial-sexp (point-min) (point)))
	     ;; (if
	     ;; 	 ;; looking one level below
	     ;; 	 (< 0 indent)
	     ;; 	 (if
	     ;; 	     (<= indent (current-indentation))
	     ;; 	     t
	     ;; 	   (setq done (match-beginning 0)))
	     (if
		 (unless (eq (gd-count-lines) origline)
		   (and (not (bolp)) (<= indent (current-indentation))))

		 t
	       (setq done (match-beginning 0))))))
    done))

(defun py--backward-def-or-class-intern (regexp &optional bol)
  (let ((origline (gd-count-lines))
	(indent (if (empty-line-p)
		    (current-indentation)
		  (save-excursion
		    (if (py--beginning-of-statement-p)
			(current-indentation)
		      (gd-backward-statement)
		      (current-indentation)))))
	erg)
    ;; (if (and (< (current-column) origindent) (looking-at regexp))
    ;; (setq erg (point))
    (setq erg (py--backward-def-or-class-matcher regexp indent origline))
    (and erg (looking-back "async ")
	 (goto-char (match-beginning 0))
	 (setq erg (point)))
    ;; bol-forms at not at bol yet
    (and bol erg (beginning-of-line) (setq erg (point)))
    (and erg gd-mark-decorators (setq erg (py--backward-def-or-class-decorator-maybe bol)))
    erg))

(defun gd-backward-class (&optional nested)
  "Go to beginning of class.

If already at beginning, go one class backward.
Returns beginning of class if successful, nil otherwise

With optional NESTED, match next upwards, ignore indentation.

When `gd-mark-decorators' is non-nil, decorators are considered too. "
  (interactive "P")
  (let ((erg
	 (if (eq 4 (prefix-numeric-value nested))
	     (gd-up-class)
	   (py--backward-def-or-class-intern gd-class-re))))
    (when (and gd-verbose-p (called-interactively-p 'any))
      (message "%s" erg))
    erg))

(defun gd-backward-def (&optional nested)
  "Go to beginning of def.

If already at beginning, go one def backward.
Returns beginning of def if successful, nil otherwise

With optional NESTED, match next upwards, ignore indentation.

When `gd-mark-decorators' is non-nil, decorators are considered too. "
  (interactive "P")
  (let ((erg (if (eq 4 (prefix-numeric-value nested))
		 (gd-up-def)
	       (py--backward-def-or-class-intern gd-def-re))))
    (when (and gd-verbose-p (called-interactively-p 'any))
      (message "%s" erg))
    erg))

(defun gd-backward-def-or-class (&optional nested)
  "Go to beginning of def-or-class.

If already at beginning, go one def-or-class backward.
Returns beginning of def-or-class if successful, nil otherwise

With optional NESTED, match next upwards, ignore indentation.

When `gd-mark-decorators' is non-nil, decorators are considered too. "
  (interactive "P")
  (let ((erg (if (eq 4 (prefix-numeric-value nested))
		 (gd-up-def-or-class)
	       (py--backward-def-or-class-intern gd-def-or-class-re))))
    (when (and gd-verbose-p (called-interactively-p 'any))
      (message "%s" erg))
    erg))

(defun gd-backward-class-bol ()
  "Go to beginning of class, go to BOL.

If already at beginning, go one class backward.
Returns beginning of class if successful, nil otherwise

When `gd-mark-decorators' is non-nil, decorators are considered too. "
  (interactive)
  (let ((erg (py--backward-def-or-class-intern gd-class-re t)))
    (when (and gd-verbose-p (called-interactively-p 'any))
      (message "%s" erg))
    erg))

(defun gd-backward-def-bol ()
  "Go to beginning of def, go to BOL.

If already at beginning, go one def backward.
Returns beginning of def if successful, nil otherwise

When `gd-mark-decorators' is non-nil, decorators are considered too. "
  (interactive)
  (let ((erg (py--backward-def-or-class-intern gd-def-re t)))
    (when (and gd-verbose-p (called-interactively-p 'any))
      (message "%s" erg))
    erg))

(defun gd-backward-def-or-class-bol ()
  "Go to beginning of def-or-class, go to BOL.

If already at beginning, go one def-or-class backward.
Returns beginning of def-or-class if successful, nil otherwise

When `gd-mark-decorators' is non-nil, decorators are considered too. "
  (interactive)
  (let ((erg (py--backward-def-or-class-intern gd-def-or-class-re t)))
    (when (and gd-verbose-p (called-interactively-p 'any))
      (message "%s" erg))
    erg))

;; gdscript-components-kill-forms


(defun gd-kill-comment ()
  "Delete comment at point.

Stores data in kill ring"
  (interactive "*")
  (let ((erg (py--mark-base "comment")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-line ()
  "Delete line at point.

Stores data in kill ring"
  (interactive "*")
  (let ((erg (py--mark-base "line")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-paragraph ()
  "Delete paragraph at point.

Stores data in kill ring"
  (interactive "*")
  (let ((erg (py--mark-base "paragraph")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-expression ()
  "Delete expression at point.

Stores data in kill ring"
  (interactive "*")
  (let ((erg (py--mark-base "expression")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-partial-expression ()
  "Delete partial-expression at point.

Stores data in kill ring"
  (interactive "*")
  (let ((erg (py--mark-base "partial-expression")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-section ()
  "Delete section at point.

Stores data in kill ring"
  (interactive "*")
  (let ((erg (py--mark-base "section")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-top-level ()
  "Delete top-level at point.

Stores data in kill ring"
  (interactive "*")
  (let ((erg (py--mark-base "top-level")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-block ()
  "Delete block at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (py--mark-base-bol "block")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-block-or-clause ()
  "Delete block-or-clause at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (py--mark-base-bol "block-or-clause")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-class ()
  "Delete class at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (py--mark-base-bol "class")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-clause ()
  "Delete clause at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (py--mark-base-bol "clause")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-def ()
  "Delete def at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (py--mark-base-bol "def")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-def-or-class ()
  "Delete def-or-class at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (py--mark-base-bol "def-or-class")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-elif-block ()
  "Delete elif-block at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (py--mark-base-bol "elif-block")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-else-block ()
  "Delete else-block at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (py--mark-base-bol "else-block")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-except-block ()
  "Delete except-block at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (py--mark-base-bol "except-block")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-for-block ()
  "Delete for-block at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (py--mark-base-bol "for-block")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-if-block ()
  "Delete if-block at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (py--mark-base-bol "if-block")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-indent ()
  "Delete indent at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (py--mark-base-bol "indent")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-minor-block ()
  "Delete minor-block at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (py--mark-base-bol "minor-block")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-statement ()
  "Delete statement at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (py--mark-base-bol "statement")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-top-level ()
  "Delete top-level at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (py--mark-base-bol "top-level")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-try-block ()
  "Delete try-block at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (py--mark-base-bol "try-block")))
    (kill-region (car erg) (cdr erg))))

;; gdscript-components-mark-forms


(defun gd-mark-comment ()
  "Mark comment at point.

Returns beginning and end positions of marked area, a cons. "
  (interactive)
  (let (erg)
    (setq erg (py--mark-base "comment"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-line ()
  "Mark line at point.

Returns beginning and end positions of marked area, a cons. "
  (interactive)
  (let (erg)
    (setq erg (py--mark-base "line"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-paragraph ()
  "Mark paragraph at point.

Returns beginning and end positions of marked area, a cons. "
  (interactive)
  (let (erg)
    (setq erg (py--mark-base "paragraph"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-expression ()
  "Mark expression at point.

Returns beginning and end positions of marked area, a cons. "
  (interactive)
  (let (erg)
    (setq erg (py--mark-base "expression"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-partial-expression ()
  "Mark partial-expression at point.

Returns beginning and end positions of marked area, a cons. "
  (interactive)
  (let (erg)
    (setq erg (py--mark-base "partial-expression"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-section ()
  "Mark section at point.

Returns beginning and end positions of marked area, a cons. "
  (interactive)
  (let (erg)
    (setq erg (py--mark-base "section"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-top-level ()
  "Mark top-level at point.

Returns beginning and end positions of marked area, a cons. "
  (interactive)
  (let (erg)
    (setq erg (py--mark-base "top-level"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-block ()
  "Mark block, take beginning of line positions. 

Returns beginning and end positions of region, a cons. "
  (interactive)
  (let (erg)
    (setq erg (py--mark-base-bol "block"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-block-or-clause ()
  "Mark block-or-clause, take beginning of line positions. 

Returns beginning and end positions of region, a cons. "
  (interactive)
  (let (erg)
    (setq erg (py--mark-base-bol "block-or-clause"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-class (&optional arg)
  "Mark class, take beginning of line positions. 

With \\[universal-argument] or `gd-mark-decorators' set to `t', decorators are marked too.
Returns beginning and end positions of region, a cons. "
  (interactive "P")
  (let ((gd-mark-decorators (or arg gd-mark-decorators))
        erg)
    (py--mark-base-bol "class" gd-mark-decorators)
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-clause ()
  "Mark clause, take beginning of line positions. 

Returns beginning and end positions of region, a cons. "
  (interactive)
  (let (erg)
    (setq erg (py--mark-base-bol "clause"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-def (&optional arg)
  "Mark def, take beginning of line positions. 

With \\[universal-argument] or `gd-mark-decorators' set to `t', decorators are marked too.
Returns beginning and end positions of region, a cons. "
  (interactive "P")
  (let ((gd-mark-decorators (or arg gd-mark-decorators))
        erg)
    (py--mark-base-bol "def" gd-mark-decorators)
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-def-or-class (&optional arg)
  "Mark def-or-class, take beginning of line positions. 

With \\[universal-argument] or `gd-mark-decorators' set to `t', decorators are marked too.
Returns beginning and end positions of region, a cons. "
  (interactive "P")
  (let ((gd-mark-decorators (or arg gd-mark-decorators))
        erg)
    (py--mark-base-bol "def-or-class" gd-mark-decorators)
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-elif-block ()
  "Mark elif-block, take beginning of line positions. 

Returns beginning and end positions of region, a cons. "
  (interactive)
  (let (erg)
    (setq erg (py--mark-base-bol "elif-block"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-else-block ()
  "Mark else-block, take beginning of line positions. 

Returns beginning and end positions of region, a cons. "
  (interactive)
  (let (erg)
    (setq erg (py--mark-base-bol "else-block"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-except-block ()
  "Mark except-block, take beginning of line positions. 

Returns beginning and end positions of region, a cons. "
  (interactive)
  (let (erg)
    (setq erg (py--mark-base-bol "except-block"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-for-block ()
  "Mark for-block, take beginning of line positions. 

Returns beginning and end positions of region, a cons. "
  (interactive)
  (let (erg)
    (setq erg (py--mark-base-bol "for-block"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-if-block ()
  "Mark if-block, take beginning of line positions. 

Returns beginning and end positions of region, a cons. "
  (interactive)
  (let (erg)
    (setq erg (py--mark-base-bol "if-block"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-indent ()
  "Mark indent, take beginning of line positions. 

Returns beginning and end positions of region, a cons. "
  (interactive)
  (let (erg)
    (setq erg (py--mark-base-bol "indent"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-minor-block ()
  "Mark minor-block, take beginning of line positions. 

Returns beginning and end positions of region, a cons. "
  (interactive)
  (let (erg)
    (setq erg (py--mark-base-bol "minor-block"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-statement ()
  "Mark statement, take beginning of line positions. 

Returns beginning and end positions of region, a cons. "
  (interactive)
  (let (erg)
    (setq erg (py--mark-base-bol "statement"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-top-level ()
  "Mark top-level, take beginning of line positions. 

Returns beginning and end positions of region, a cons. "
  (interactive)
  (let (erg)
    (setq erg (py--mark-base-bol "top-level"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-try-block ()
  "Mark try-block, take beginning of line positions. 

Returns beginning and end positions of region, a cons. "
  (interactive)
  (let (erg)
    (setq erg (py--mark-base-bol "try-block"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

;; gdscript-components-copy-forms


(defun gd-copy-block ()
  "Copy block at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "block")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-block-or-clause ()
  "Copy block-or-clause at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "block-or-clause")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-buffer ()
  "Copy buffer at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "buffer")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-class ()
  "Copy class at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "class")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-clause ()
  "Copy clause at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "clause")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-def ()
  "Copy def at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "def")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-def-or-class ()
  "Copy def-or-class at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "def-or-class")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-expression ()
  "Copy expression at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "expression")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-indent ()
  "Copy indent at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "indent")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-line ()
  "Copy line at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "line")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-minor-block ()
  "Copy minor-block at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "minor-block")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-paragraph ()
  "Copy paragraph at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "paragraph")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-partial-expression ()
  "Copy partial-expression at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "partial-expression")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-region ()
  "Copy region at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "region")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-statement ()
  "Copy statement at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "statement")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-top-level ()
  "Copy top-level at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "top-level")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-block-bol ()
  "Delete block bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "block")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-block-or-clause-bol ()
  "Delete block-or-clause bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "block-or-clause")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-buffer-bol ()
  "Delete buffer bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "buffer")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-class-bol ()
  "Delete class bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "class")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-clause-bol ()
  "Delete clause bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "clause")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-def-bol ()
  "Delete def bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "def")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-def-or-class-bol ()
  "Delete def-or-class bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "def-or-class")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-expression-bol ()
  "Delete expression bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "expression")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-indent-bol ()
  "Delete indent bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "indent")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-line-bol ()
  "Delete line bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "line")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-minor-block-bol ()
  "Delete minor-block bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "minor-block")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-paragraph-bol ()
  "Delete paragraph bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "paragraph")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-partial-expression-bol ()
  "Delete partial-expression bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "partial-expression")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-region-bol ()
  "Delete region bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "region")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-statement-bol ()
  "Delete statement bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "statement")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-top-level-bol ()
  "Delete top-level bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (py--mark-base-bol "top-level")))
      (copy-region-as-kill (car erg) (cdr erg)))))

;; gdscript-components-delete-forms


(defun gd-delete-block ()
  "Delete BLOCK at point until beginning-of-line.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (py--mark-base-bol "block")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-block-or-clause ()
  "Delete BLOCK-OR-CLAUSE at point until beginning-of-line.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (py--mark-base-bol "block-or-clause")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-class (&optional arg)
  "Delete CLASS at point until beginning-of-line.

Don't store data in kill ring. 
With \\[universal-argument] or `gd-mark-decorators' set to `t', `decorators' are included."
  (interactive "P")
 (let* ((gd-mark-decorators (or arg gd-mark-decorators))
        (erg (py--mark-base "class" gd-mark-decorators)))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-clause ()
  "Delete CLAUSE at point until beginning-of-line.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (py--mark-base-bol "clause")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-def (&optional arg)
  "Delete DEF at point until beginning-of-line.

Don't store data in kill ring. 
With \\[universal-argument] or `gd-mark-decorators' set to `t', `decorators' are included."
  (interactive "P")
 (let* ((gd-mark-decorators (or arg gd-mark-decorators))
        (erg (py--mark-base "def" gd-mark-decorators)))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-def-or-class (&optional arg)
  "Delete DEF-OR-CLASS at point until beginning-of-line.

Don't store data in kill ring. 
With \\[universal-argument] or `gd-mark-decorators' set to `t', `decorators' are included."
  (interactive "P")
 (let* ((gd-mark-decorators (or arg gd-mark-decorators))
        (erg (py--mark-base "def-or-class" gd-mark-decorators)))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-elif-block ()
  "Delete ELIF-BLOCK at point until beginning-of-line.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (py--mark-base-bol "elif-block")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-else-block ()
  "Delete ELSE-BLOCK at point until beginning-of-line.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (py--mark-base-bol "else-block")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-except-block ()
  "Delete EXCEPT-BLOCK at point until beginning-of-line.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (py--mark-base-bol "except-block")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-for-block ()
  "Delete FOR-BLOCK at point until beginning-of-line.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (py--mark-base-bol "for-block")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-if-block ()
  "Delete IF-BLOCK at point until beginning-of-line.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (py--mark-base-bol "if-block")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-indent ()
  "Delete INDENT at point until beginning-of-line.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (py--mark-base-bol "indent")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-minor-block ()
  "Delete MINOR-BLOCK at point until beginning-of-line.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (py--mark-base-bol "minor-block")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-statement ()
  "Delete STATEMENT at point until beginning-of-line.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (py--mark-base-bol "statement")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-top-level ()
  "Delete TOP-LEVEL at point until beginning-of-line.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (py--mark-base-bol "top-level")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-try-block ()
  "Delete TRY-BLOCK at point until beginning-of-line.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (py--mark-base-bol "try-block")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-comment ()
  "Delete COMMENT at point.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (py--mark-base "comment")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-line ()
  "Delete LINE at point.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (py--mark-base "line")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-paragraph ()
  "Delete PARAGRAPH at point.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (py--mark-base "paragraph")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-expression ()
  "Delete EXPRESSION at point.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (py--mark-base "expression")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-partial-expression ()
  "Delete PARTIAL-EXPRESSION at point.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (py--mark-base "partial-expression")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-section ()
  "Delete SECTION at point.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (py--mark-base "section")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-top-level ()
  "Delete TOP-LEVEL at point.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (py--mark-base "top-level")))
    (delete-region (car erg) (cdr erg))))

;; gdscript-components-execute
(defun gd-restore-window-configuration ()
  "Restore gd-restore-window-configuration when completion is done resp. abandoned. "
  (let (val)
    (and (setq val (get-register gd-windows-config-register))(and (consp val) (window-configuration-p (car val))(markerp (cadr val)))(marker-buffer (cadr val))
	 (jump-to-register gd-windows-config-register))))

(defun gd-shell-execute-string-now (string &optional shell buffer proc output-buffer)
  "Send to GDScript interpreter process PROC \"exec STRING in {}\".
and return collected output"
  (let* (wait
         (procbuf (or buffer (process-buffer proc) (progn (setq wait gd-new-shell-delay) (gd-shell nil nil shell))))
         (proc (or proc (get-buffer-process procbuf)))
	 (cmd (format "exec '''%s''' in {}"
		      (mapconcat 'identity (split-string string "\n") "\\n")))
	 ;; TBD remove redundant outbuf
         (outbuf procbuf))
    ;; wait is used only when a new gd-shell buffer was connected
    (and wait (sit-for wait))
    (unwind-protect
        (condition-case nil
            (progn
              (with-current-buffer outbuf
                (delete-region (point-min) (point-max)))
              (with-current-buffer procbuf
                ;; (sit-for 3)
                (comint-redirect-send-command-to-process
                 cmd outbuf proc nil t)
                (accept-process-output proc 5))
              (with-current-buffer outbuf
                (buffer-substring (point-min) (point-max))))
          (quit (with-current-buffer procbuf
                  (interrupt-process proc comint-ptyp)
                  (while (not comint-redirect-completed) ; wait for output
                    (accept-process-output proc 1)))
                (signal 'quit nil))))))

(defun gd-switch-to-python (eob-p)
  "Switch to the GDScript process buffer, maybe starting new process.

With prefix arg, position cursor at end of buffer."
  (interactive "P")
  (pop-to-buffer (process-buffer (gd-proc)) t) ;Runs python if needed.
  (when eob-p
    (goto-char (point-max))))

(defalias 'gd-shell-send-file 'gd-send-file)
(defun gd-send-file (file-name &optional process temp-file-name)
  "Send FILE-NAME to GDScript PROCESS.
If TEMP-FILE-NAME is passed then that file is used for processing
instead, while internally the shell will continue to use
FILE-NAME."
  (interactive "fFile to send: ")
  (let* ((process (or process (get-buffer-process (gd-shell))))
         (temp-file-name (when temp-file-name
                           (expand-file-name temp-file-name)))
         (file-name (or (expand-file-name file-name) temp-file-name)))
    (when (not file-name)
      (error "If FILE-NAME is nil then TEMP-FILE-NAME must be non-nil"))
    (gd-send-string
     (format
      (concat "__pyfile = open('''%s''');"
              "exec(compile(__pyfile.read(), '''%s''', 'exec'));"
              "__pyfile.close()")
      file-name file-name)
     process)))

(defun toggle-force-local-shell (&optional arg)
  "If locally indicated GDScript shell should be taken and
enforced upon sessions execute commands.

Toggles boolean `gd-force-local-shell-p' along with `gd-force-gd-shell-name-p'
Returns value of `toggle-force-local-shell' switched to.

When on, kind of an option 'follow', local shell sets `gd-shell-name', enforces its use afterwards.

See also commands
`gd-force-local-shell-on'
`gd-force-local-shell-off'
 "
  (interactive (list arg))
  (let ((arg (or arg (if gd-force-local-shell-p -1 1))))
    (if (< 0 arg)
        (progn
          (setq gd-shell-name (or gd-local-command (gd-choose-shell)))
          (setq gd-force-local-shell-p t))
      (setq gd-shell-name (default-value 'gd-shell-name))
      (setq gd-force-local-shell-p nil))
    (when (called-interactively-p 'any)
      (if gd-force-local-shell-p
          (when gd-verbose-p (message "Enforce %s"  gd-shell-name))
        (when gd-verbose-p (message "gd-shell-name default restored to: %s" gd-shell-name))))
    gd-shell-name))

(defun gd-force-local-shell-on ()
  "Make sure, `gd-force-local-shell-p' is on.

Returns value of `gd-force-local-shell-p'.

Kind of an option 'follow', local shell sets `gd-shell-name', enforces its use afterwards "
  (interactive "p")
  (let* ((erg (toggle-force-local-shell 1)))
    (when (or gd-verbose-p (called-interactively-p 'any))
      (message "Enforce %s" gd-shell-name))))

(defun gd-force-local-shell-off ()
  "Restore `gd-shell-name' default value and `behaviour'. "
  (interactive "p")
  (let* ((erg (toggle-force-local-shell 1)))
    (when (or gd-verbose-p (called-interactively-p 'any))
      (message "gd-shell-name default restored to: %s" gd-shell-name)
      (message "Enforce %s" gd-shell-name))))

(defun toggle-force-gd-shell-name-p (&optional arg)
  "If customized default `gd-shell-name' should be enforced upon execution.

If `gd-force-gd-shell-name-p' should be on or off.
Returns value of `gd-force-gd-shell-name-p' switched to.

See also commands
force-gd-shell-name-p-on
force-gd-shell-name-p-off

Caveat: Completion might not work that way.
"
  (interactive)
  (let ((arg (or arg (if gd-force-gd-shell-name-p -1 1))))
    (if (< 0 arg)
        (setq gd-force-gd-shell-name-p t)
      (setq gd-force-gd-shell-name-p nil))
    (when (or gd-verbose-p (called-interactively-p 'any)) (message "gd-force-gd-shell-name-p: %s" gd-force-gd-shell-name-p))
    gd-force-gd-shell-name-p))

(defun force-gd-shell-name-p-on (&optional arg)
  "Switches `gd-force-gd-shell-name-p' on.

Customized default `gd-shell-name' will be enforced upon execution.
Returns value of `gd-force-gd-shell-name-p'.

Caveat: Completion might not work that way.
"
  (interactive "p")
  (let ((arg (or arg 1)))
    (toggle-force-gd-shell-name-p arg))
  (when (or gd-verbose-p (called-interactively-p 'any)) (message "gd-force-gd-shell-name-p: %s" gd-force-gd-shell-name-p))
  gd-force-gd-shell-name-p)

(defun force-gd-shell-name-p-off ()
  "Make sure, `gd-force-gd-shell-name-p' is off.

Function to use by executes will be guessed from environment.
Returns value of `gd-force-gd-shell-name-p'. "
  (interactive)
  (toggle-force-gd-shell-name-p -1)
  (when (or gd-verbose-p (called-interactively-p 'any)) (message "gd-force-gd-shell-name-p: %s" gd-force-gd-shell-name-p))
  gd-force-gd-shell-name-p)

;;  Split-Windows-On-Execute forms
(defalias 'toggle-gd-split-windows-on-execute 'gd-toggle-split-windows-on-execute)
(defun gd-toggle-split-windows-on-execute (&optional arg)
  "If `gd-split-window-on-execute' should be on or off.

  Returns value of `gd-split-window-on-execute' switched to. "
  (interactive)
  (let ((arg (or arg (if gd-split-window-on-execute -1 1))))
    (if (< 0 arg)
        (setq gd-split-window-on-execute t)
      (setq gd-split-window-on-execute nil))
    (when (called-interactively-p 'any) (message "gd-split-window-on-execute: %s" gd-split-window-on-execute))
    gd-split-window-on-execute))

(defun gd-split-windows-on-execute-on (&optional arg)
  "Make sure, `gd-split-window-on-execute' is on.

Returns value of `gd-split-window-on-execute'. "
  (interactive "p")
  (let ((arg (or arg 1)))
    (toggle-gd-split-windows-on-execute arg))
  (when (called-interactively-p 'any) (message "gd-split-window-on-execute: %s" gd-split-window-on-execute))
  gd-split-window-on-execute)

(defun gd-split-windows-on-execute-off ()
  "Make sure, `gd-split-window-on-execute' is off.

Returns value of `gd-split-window-on-execute'. "
  (interactive)
  (toggle-gd-split-windows-on-execute -1)
  (when (called-interactively-p 'any) (message "gd-split-window-on-execute: %s" gd-split-window-on-execute))
  gd-split-window-on-execute)

;;  Shell-Switch-Buffers-On-Execute forms
(defalias 'gd-toggle-switch-buffers-on-execute 'gd-toggle-shell-switch-buffers-on-execute)
(defalias 'toggle-gd-shell-switch-buffers-on-execute 'gd-toggle-shell-switch-buffers-on-execute)
(defun gd-toggle-shell-switch-buffers-on-execute (&optional arg)
  "If `gd-switch-buffers-on-execute-p' should be on or off.

  Returns value of `gd-switch-buffers-on-execute-p' switched to. "
  (interactive)
  (let ((arg (or arg (if gd-switch-buffers-on-execute-p -1 1))))
    (if (< 0 arg)
        (setq gd-switch-buffers-on-execute-p t)
      (setq gd-switch-buffers-on-execute-p nil))
    (when (called-interactively-p 'any) (message "gd-shell-switch-buffers-on-execute: %s" gd-switch-buffers-on-execute-p))
    gd-switch-buffers-on-execute-p))

(defun gd-shell-switch-buffers-on-execute-on (&optional arg)
  "Make sure, `gd-switch-buffers-on-execute-p' is on.

Returns value of `gd-switch-buffers-on-execute-p'. "
  (interactive "p")
  (let ((arg (or arg 1)))
    (toggle-gd-shell-switch-buffers-on-execute arg))
  (when (called-interactively-p 'any) (message "gd-shell-switch-buffers-on-execute: %s" gd-switch-buffers-on-execute-p))
  gd-switch-buffers-on-execute-p)

(defun gd-shell-switch-buffers-on-execute-off ()
  "Make sure, `gd-switch-buffers-on-execute-p' is off.

Returns value of `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (toggle-gd-shell-switch-buffers-on-execute -1)
  (when (called-interactively-p 'any) (message "gd-shell-switch-buffers-on-execute: %s" gd-switch-buffers-on-execute-p))
  gd-switch-buffers-on-execute-p)

(defun gd-guess-default-python ()
  "Defaults to \"python\", if guessing didn't succeed. "
  (interactive)
  (let* ((ptn (or gd-shell-name (gd-choose-shell) "python"))
         (erg (if gd-edit-only-p ptn (executable-find ptn))))
    (when (called-interactively-p 'any)
      (if erg
          (message "%s" ptn)
        (message "%s" "Could not detect GDScript on your system")))))

;;  from ipython.el
(defun gd-dirstack-hook ()
  ;; the following is to synchronize dir-changes
  (make-local-variable 'shell-dirstack)
  (setq shell-dirstack nil)
  (make-local-variable 'shell-last-dir)
  (setq shell-last-dir nil)
  (make-local-variable 'shell-dirtrackp)
  (setq shell-dirtrackp t)
  (add-hook 'comint-input-filter-functions 'shell-directory-tracker nil t))

(defalias 'gd-dedicated-shell 'gd-shell-dedicated)
(defun gd-shell-dedicated (&optional argprompt)
  "Start an interactive GDScript interpreter in another window.

With optional \\[universal-argument] user is prompted by
`gd-choose-shell' for command and options to pass to the GDScript
interpreter.
"
  (interactive "P")
  (gd-shell argprompt t))

(defun gd-set-ipython-completion-command-string (shell)
  "Set and return `gd-ipython-completion-command-string'. "
  (interactive)
  (let* ((ipython-version (shell-command-to-string (concat shell " -V"))))
    (if (string-match "[0-9]" ipython-version)
        (setq gd-ipython-completion-command-string
              (cond ((string-match "^[^0].+" ipython-version)
		     gd-ipython0.11-completion-command-string)
                    ((string-match "^0.1[1-3]" ipython-version)
                     gd-ipython0.11-completion-command-string)
                    ((string= "^0.10" ipython-version)
                     gd-ipython0.10-completion-command-string)))
      (error ipython-version))))

(defun gd-ipython--module-completion-import (proc)
  "Import module-completion "
  (interactive)
  (let ((ipython-version (shell-command-to-string (concat gd-shell-name " -V"))))
    (when (and (string-match "^[0-9]" ipython-version)
               (string-match "^[^0].+" ipython-version))
      (process-send-string proc "from IPython.core.completerlib import module_completion"))))

(defun py--compose-buffer-name-initials (liste)
  (let (erg)
    (dolist (ele liste)
      (unless (string= "" ele)
	(setq erg (concat erg (char-to-string (aref ele 0))))))
    erg))

(defun py--remove-home-directory-from-list (liste)
  "Prepare for compose-buffer-name-initials. "
  (let ((case-fold-search t)
	(liste liste)
	erg)
    (if (listp (setq erg (split-string (expand-file-name "~") "\/")))
	erg
      (setq erg (split-string (expand-file-name "~") "\\\\")))
     (while erg
      (when (member (car erg) liste)
	(setq liste (cdr (member (car erg) liste))))
      (setq erg (cdr erg)))
    (butlast liste)))

(defun py--choose-buffer-name (&optional name dedicated fast-process)
  "Return an appropriate name to display in modeline.
SEPCHAR is the file-path separator of your system. "
  (let* ((name-first (or name gd-shell-name))
	 (erg (when name-first (if (stringp name-first) name-first (prin1-to-string name-first))))
	 (fast-process (or fast-process gd-fast-process-p))
	 prefix suffix liste)
    ;; commented WRT ipython2.7
    ;; remove suffix
    ;; (when (string-match "[.]" erg)
    ;; (setq erg (substring erg 0 (string-match "[.]" erg))))
    ;; remove prefix
    (when (string-match "^py-" erg)
      (setq erg (nth 1 (split-string erg "-"))))
    ;; remove home-directory from prefix to display
    (unless gd-modeline-acronym-display-home-p
      (save-match-data
	(let ((case-fold-search t))
	  (when (string-match (concat ".*" (expand-file-name "~")) erg)
	    (setq erg (replace-regexp-in-string (concat "^" (expand-file-name "~")) "" erg))))))
    (if (or (and (setq prefix (split-string erg "\\\\"))
		 (< 1 (length prefix)))
	    (and (setq prefix (split-string erg "\/"))
		 (< 1 (length prefix))))
	(progn
	  ;; exect something like default gd-shell-name
	  (setq erg (car (last prefix)))
	  (unless gd-modeline-acronym-display-home-p
	    ;; home-directory may still inside
	    (setq prefix (py--remove-home-directory-from-list prefix))
	    (setq prefix (py--compose-buffer-name-initials prefix))))
      (setq erg (or name gd-shell-name))
      (setq prefix nil))
    (when fast-process (setq erg (concat erg " Fast")))

    ;; (setq name (substring name (1+ (string-match "/[^/]+\\|\\\\[[:alnum:].]+$" name)))))
    (setq erg
          (cond ((string-match "^ipython" erg)
                 (replace-regexp-in-string "ipython" "IPython" erg))
                ((string-match "^jython" erg)
                 (replace-regexp-in-string "jython" "Jython" erg))
                ((string-match "^python" erg)
                 (replace-regexp-in-string "python" "GDScript" erg))
                ((string-match "^python2" erg)
                 (replace-regexp-in-string "python2" "Python2" erg))
                ((string-match "^python3" erg)
                 (replace-regexp-in-string "python3" "Python3" erg))
                (t erg)))
    (when (or dedicated gd-dedicated-process-p)
      (setq erg (make-temp-name (concat erg "-"))))
    (cond ((and prefix (string-match "^\*" erg))
           (setq erg (replace-regexp-in-string "^\*" (concat "*" prefix " ") erg)))
          (prefix
           (setq erg (concat "*" prefix " " erg "*")))
          (t (unless (string-match "^\*" erg)(setq erg (concat "*" erg "*")))))
    erg))

(defun py--jump-to-exception-intern (action exception-buffer origline)
  (let (erg)
    (set-buffer exception-buffer)
    (goto-char (point-min))
    (forward-line (1- origline))
    (and (search-forward action (line-end-position) t)
         (and gd-verbose-p (message "exception-buffer: %s on line %d" gd-exception-buffer origline))
         (and gd-highlight-error-source-p
              (setq erg (make-overlay (match-beginning 0) (match-end 0)))
              (overlay-put erg
                           'face 'highlight)))))

(defun py--jump-to-exception (gd-error origline &optional file)
  "Jump to the GDScript code in FILE at LINE."
  (let (
        ;; (inhibit-point-motion-hooks t)
        (file (or file (car gd-error)))
        (line (cadr gd-error))
        (action (nth 2 gd-error))
        (errm (nth 3 gd-error)))
    (cond ((and gd-exception-buffer
                (buffer-live-p gd-exception-buffer))
           ;; (pop-to-buffer procbuf)
           (py--jump-to-exception-intern action gd-exception-buffer origline))
          ((ignore-errors (file-readable-p file))
           (find-file file)
           (py--jump-to-exception-intern action (get-buffer (file-name-nondirectory file)) origline))
          ((buffer-live-p (get-buffer file))
           (set-buffer file)
           (py--jump-to-exception-intern action file origline))
          (t (setq file (find-file (read-file-name "Exception file: "
                                                   nil
                                                   file t)))
             (py--jump-to-exception-intern action file origline)))))

(defalias 'gd-toggle-split-window-on-execute-function 'gd-toggle-split-window-function)
(defun gd-toggle-split-window-function ()
  "If window is splitted vertically or horizontally.

When code is executed and `gd-split-window-on-execute' is `t', the result is displays in an output-buffer, \"\*GDScript\*\" by default.

Customizable variable `gd-split-windows-on-execute-function' tells how to split the screen."
  (interactive)
  (if (eq 'split-window-vertically gd-split-windows-on-execute-function)
      (setq gd-split-windows-on-execute-function'split-window-horizontally)
    (setq gd-split-windows-on-execute-function 'split-window-vertically))
  (when (and gd-verbose-p (called-interactively-p 'any))
    (message "gd-split-windows-on-execute-function set to: %s" gd-split-windows-on-execute-function)))

(defun py--manage-windows-set-and-switch (buffer)
  "Switch to output-buffer, go to point-max.

Internal use"
  (set-buffer buffer)
  (goto-char (process-mark (get-buffer-process (current-buffer)))))

(defun py--alternative-split-windows-on-execute-function ()
  "If `py--split-windows-on-execute-function' is `split-window-vertically' return `split-window-horizontally' and vice versa"
  (if (eq gd-split-windows-on-execute-function 'split-window-vertically)
      'split-window-horizontally
    'split-window-vertically))

(defun py--get-splittable-window (output-buffer)
  "If selected window doesn't permit a further split, search window-list for a suitable one. "
  (let ((this-window (selected-window))
	erg)
    (or (and (window-left-child)(split-window (window-left-child)))
	(and (window-top-child)(split-window (window-top-child)))
	(and (window-parent)(ignore-errors (split-window (window-parent))))
	(and (window-atom-root)(split-window (window-atom-root))))))

(defun py--manage-windows-split (exception-buffer output-buffer)
  "If one window, split according to `gd-split-windows-on-execute-function. "
  (interactive)
  (set-buffer exception-buffer)
  ;; (when gd-debug-p (message "py--manage-windows-split: %s" "py--manage-windows-split"))
  (or
   (ignore-errors (funcall gd-split-windows-on-execute-function))
   ;; If call didn't succeed according to settings of
   ;; `split-height-threshold', `split-width-threshold'
   ;; resp. `window-min-height', `window-min-width'
   ;; try alternative split
   (unless (ignore-errors (funcall (py--alternative-split-windows-on-execute-function)))
     ;; if alternative split fails, look for larger window
     (py--get-splittable-window output-buffer)
     (ignore-errors (funcall (py--alternative-split-windows-on-execute-function))))))

;; (defun py--display-windows (output-buffer)
;;     "Otherwise new window appears above"
;;       (display-buffer output-buffer)
;;       (select-window gd-exception-window))

(defun py--split-t-not-switch-wm ()
  (unless (window-live-p output-buffer)
    (with-current-buffer (get-buffer output-buffer)
      (when (< number-of-windows gd-split-window-on-execute-threshold)
	(unless
	    (member (get-buffer-window output-buffer)(window-list))
	  (py--manage-windows-split gd-exception-buffer output-buffer)))
      (display-buffer output-buffer t))))

(defun py--shell-manage-windows (output-buffer windows-config &optional exception-buffer)
  "Adapt or restore window configuration. Return nil "
  (let* ((gd-exception-buffer (or exception-buffer (and gd-exception-buffer (buffer-live-p gd-exception-buffer) gd-exception-buffer)))
	 (output-buffer (or output-buffer gd-buffer-name))
	 (old-window-list (window-list))
	 (number-of-windows (length old-window-list)))
    ;; (output-buffer-displayed-p)
    (cond
     (gd-keep-windows-configuration
      (gd-restore-window-configuration)
      (set-buffer output-buffer)
      (goto-char (point-max)))
     ((and (eq gd-split-window-on-execute 'always)
	   gd-switch-buffers-on-execute-p)
      (if (member (get-buffer-window output-buffer)(window-list))
	  ;; (delete-window (get-buffer-window output-buffer))
	  (select-window (get-buffer-window output-buffer))
	(py--manage-windows-split gd-exception-buffer output-buffer)
	;; otherwise new window appears above
	(save-excursion
	  (other-window 1)
	  (switch-to-buffer output-buffer))
	(display-buffer gd-exception-buffer)))
     ((and
       (eq gd-split-window-on-execute 'always)
       (not gd-switch-buffers-on-execute-p))
      (if (member (get-buffer-window output-buffer)(window-list))
	  (select-window (get-buffer-window output-buffer))
	(py--manage-windows-split gd-exception-buffer output-buffer)
	(display-buffer output-buffer)
	(pop-to-buffer gd-exception-buffer)))
     ((and
       (eq gd-split-window-on-execute 'just-two)
       gd-switch-buffers-on-execute-p)
      (switch-to-buffer (current-buffer))
      (delete-other-windows)
      ;; (sit-for gd-new-shell-delay)
      (py--manage-windows-split gd-exception-buffer output-buffer)
      ;; otherwise new window appears above
      (other-window 1)
      (set-buffer output-buffer)
      (switch-to-buffer (current-buffer)))
     ((and
       (eq gd-split-window-on-execute 'just-two)
       (not gd-switch-buffers-on-execute-p))
      (switch-to-buffer gd-exception-buffer)
      (delete-other-windows)
      (unless
	  (member (get-buffer-window output-buffer)(window-list))
	(py--manage-windows-split gd-exception-buffer output-buffer))
      ;; Fixme: otherwise new window appears above
      (save-excursion
	(other-window 1)
	(pop-to-buffer output-buffer)
	(goto-char (point-max))
	(other-window 1)))
     ((and
       gd-split-window-on-execute
       (not gd-switch-buffers-on-execute-p))
      ;; https://bugs.launchpad.net/gdscript-mode/+bug/1478122
      ;; > If the shell is visible in any of the windows it  should re-use that window
      ;; > I did double check and gd-keep-window-configuration is nil and gd-split-window-on-execute is t.
      (py--split-t-not-switch-wm))
     ((and
       gd-split-window-on-execute
       gd-switch-buffers-on-execute-p)
      (unless
	  (member (get-buffer-window output-buffer)(window-list))
	(py--manage-windows-split gd-exception-buffer output-buffer))
      ;; Fixme: otherwise new window appears above
      (save-excursion
	(other-window 1)
	;; (pop-to-buffer output-buffer)
	;; [Bug 1579309] python buffer window on top when using python3
	(switch-to-buffer output-buffer)
	(goto-char (point-max))
	(other-window 1)))
     ((not gd-switch-buffers-on-execute-p)
      (let (pop-up-windows)
	(gd-restore-window-configuration))))))

(defun gd-kill-shell-unconditional (&optional shell)
  "With optional argument SHELL.

Otherwise kill default (I)GDScript shell.
Kill buffer and its process.
Receives a buffer-name as argument"
  (interactive)
  (let ((shell (or shell (gd-shell))))
    (gd-kill-buffer-unconditional shell)))

(defun gd-kill-default-shell-unconditional ()
  "Kill buffer \"\*GDScript\*\" and its process. "
  (interactive)
  (gd-kill-buffer-unconditional "*GDScript*"))

(defun py--report-executable (gd-buffer-name)
  (let ((erg (downcase (replace-regexp-in-string
                        "<\\([0-9]+\\)>" ""
                        (replace-regexp-in-string
                         "\*" ""
                         (if
                             (string-match " " gd-buffer-name)
                             (substring gd-buffer-name (1+ (string-match " " gd-buffer-name)))
                           gd-buffer-name))))))
    (when (string-match "-" erg)
      (setq erg (substring erg 0 (string-match "-" erg))))
    erg))

(defun py--shell-make-comint (executable gd-buffer-name args)
  "Returns the buffer of the comint-proces created. "
  (let* ((buffer (apply #'make-comint-in-buffer executable gd-buffer-name executable nil (split-string-and-unquote (car args))))
	 (proc (get-buffer-process buffer)))
    (with-current-buffer buffer
      (if (string-match "^i" (process-name proc))
	  (gd-ipython-shell-mode)
	(gd-gdscript-shell-mode)))
    buffer))

(defun py--guess-buffer-name (argprompt dedicated)
  "Guess the buffer-name core string. "
  (when (and (not dedicated) argprompt
	     (eq 4 (prefix-numeric-value argprompt)))
    (read-buffer "Py-Shell buffer: "
		 (generate-new-buffer-name (py--choose-buffer-name)))))

(defun py--configured-shell (name)
  "Return the configured PATH/TO/STRING if any. "
  (if (string-match "//\\|\\\\" name)
      name
    (cond ((string-match "^[Ii]" name)
	   (or gd-ipython-command name))
	  ((string-match "[Pp]ython3" name)
	   (or gd-python3-command name))
	  ((string-match "[Pp]ython2" name)
	   (or gd-python2-command name))
	  ((string-match "[Jj]ython" name)
	   (or gd-jython-command name))
	  (t (or gd-gdscript-command name)))))

(defun py--grab-prompt-ps1 (proc buffer)
  (py--send-string-no-output "import sys")
  (py--fast-send-string-intern "sys.ps1" proc buffer nil t))

(defun py--start-fast-process (shell buffer)
  (let ((proc (start-process shell buffer shell)))
    (with-current-buffer buffer
      (erase-buffer))
    proc))

(defun py--shell-fast-proceeding (proc gd-buffer-name gd-shell-name  gd-shell-completion-setup-code)
  (unless (get-buffer-process (get-buffer gd-buffer-name))
    (setq proc (py--start-fast-process gd-shell-name gd-buffer-name))
    (setq gd-output-buffer gd-buffer-name)
    (py--fast-send-string-no-output gd-shell-completion-setup-code proc gd-buffer-name)))

(defun py--reuse-existing-shell (exception-buffer)
  (setq gd-exception-buffer (or exception-buffer (and gd-exception-buffer (buffer-live-p gd-exception-buffer) gd-exception-buffer) gd-buffer-name)))

(defun py--create-new-shell (executable args exception-buffer)
  (let ((buf (current-buffer)))
    (with-current-buffer
	(apply #'make-comint-in-buffer executable gd-buffer-name executable nil (split-string-and-unquote args))
      ;; (py--shell-make-comint executable gd-buffer-name args)
      (let ((proc (get-buffer-process (current-buffer))))
	(if (string-match "^i" (process-name proc))
	    (gd-ipython-shell-mode)
	  (gd-gdscript-shell-mode)))
      (setq gd-output-buffer (current-buffer))
      (sit-for 0.1 t)
      (goto-char (point-max))
      ;; otherwise comint might initialize it with point-min
      (set-marker comint-last-input-end (point))
      (setq gd-exception-buffer (or exception-buffer (and gd-exception-buffer (buffer-live-p gd-exception-buffer) gd-exception-buffer) buf)))))

(defun py--determine-local-default ()
  (if (not (string= "" gd-shell-local-path))
      (expand-file-name gd-shell-local-path)
    (when gd-use-local-default
      (error "Abort: `gd-use-local-default' is set to `t' but `gd-shell-local-path' is empty. Maybe call `gd-toggle-local-default-use'"))))

(defun py--provide-command-args (fast-process argprompt)
  (cond (fast-process nil)
	((eq 2 (prefix-numeric-value argprompt))
	 (mapconcat 'identity gd-python2-command-args " "))
	((string-match "^[Ii]" gd-shell-name)
	 gd-ipython-command-args)
	((string-match "^[^-]+3" gd-shell-name)
	 (mapconcat 'identity gd-python3-command-args " "))
	(t (mapconcat 'identity gd-gdscript-command-args " "))))

(defun gd-shell (&optional argprompt dedicated shell buffer-name fast-process exception-buffer)
  "Start an interactive GDScript interpreter in another window.
  Interactively, \\[universal-argument] prompts for a new buffer-name.
  \\[universal-argument] 2 prompts for `gd-gdscript-command-args'.
  If `default-directory' is a remote file name, it is also prompted
  to change if called with a prefix arg.

  Returns gd-shell's buffer-name.
  Optional string PYSHELLNAME overrides default `gd-shell-name'.
  BUFFER allows specifying a name, the GDScript process is connected to
  "
  (interactive "P")
  ;; done by gd-shell-mode
  (let* ((iact (or (called-interactively-p 'any) (eq 1 argprompt))) ;; interactively?
	 (windows-config (window-configuration-to-register 313465889))
	 (fast-process (or fast-process gd-fast-process-p))
	 ;; (newpath (when (eq 4 (prefix-numeric-value argprompt))
	 ;; (read-shell-command "PATH/TO/EXECUTABLE/[I]python[version]: ")))
	 (dedicated (or dedicated gd-dedicated-process-p))
	 (path (getenv "PYTHONPATH"))
	 (gd-shell-name (or shell
			    ;; (py--configured-shell (gd-choose-shell))
			    (gd-choose-shell)))
	 (args (py--provide-command-args fast-process argprompt))

	 (gd-use-local-default (py--determine-local-default))
	 (gd-buffer-name (or buffer-name (py--guess-buffer-name argprompt dedicated)))
	 (gd-buffer-name (or gd-buffer-name (py--choose-buffer-name nil dedicated fast-process)))
	 (executable (cond (gd-shell-name)
			   (gd-buffer-name
			    (py--report-executable gd-buffer-name))))
	 proc)
    ;; lp:1169687, if called from within an existing gd-shell, open a new one
    (and (bufferp (get-buffer gd-buffer-name))(buffer-live-p (get-buffer gd-buffer-name))(string= (buffer-name (current-buffer)) (buffer-name (get-buffer gd-buffer-name)))
	 (setq gd-buffer-name (generate-new-buffer-name gd-buffer-name)))
    (sit-for 0.1 t)
    (if fast-process
	;; user rather wants an interactive shell
	(py--shell-fast-proceeding proc gd-buffer-name gd-shell-name  gd-shell-completion-setup-code)
      (if (comint-check-proc gd-buffer-name)
	  (py--reuse-existing-shell exception-buffer)
	;; buffer might exist but not being empty
	(when (buffer-live-p gd-buffer-name)
	  (with-current-buffer gd-buffer-name
	    (erase-buffer)))
	(py--create-new-shell executable args exception-buffer))
      (when (or (called-interactively-p 'any)
		(eq 1 argprompt)
		gd-switch-buffers-on-execute-p
		;; (member this-command gd-named-shells)
		)
	(py--shell-manage-windows gd-buffer-name windows-config gd-exception-buffer)))
    ;; (sit-for gd-new-shell-delay t)
    gd-buffer-name))

(defun gd-shell-get-process (&optional argprompt gd-dedicated-process-p shell switch gd-buffer-name)
  "Get appropriate GDScript process for current buffer and return it."
  (interactive)
  (let ((erg (get-buffer-process (gd-shell argprompt gd-dedicated-process-p shell gd-buffer-name))))
    (when (called-interactively-p 'any) (message "%S" erg))
    erg))

(defun gd-switch-to-shell ()
  "Switch to GDScript process buffer."
  (interactive)
  (pop-to-buffer (gd-shell) t))

;;  Code execution commands
(defun gd-which-execute-file-command (filename)
  "Return the command appropriate to GDScript version.

Per default it's \"(format \"execfile(r'%s') # PYTHON-MODE\\n\" filename)\" for GDScript 2 series."
  (interactive)
  (let* ((erg (gd-which-python))
         (cmd (if (< erg 3)
                  (format "execfile(r'%s') # PYTHON-MODE\n" filename)
                (format "exec(compile(open('%s').read(), '%s', 'exec')) # PYTHON-MODE\n" filename filename))))
    (when (called-interactively-p 'any) (message "%s" (prin1-to-string cmd)))
    cmd))

(defun py--store-result-maybe (erg)
  "If no error occurred and `gd-store-result-p' store result for yank. "
  (and (not gd-error) erg (or gd-debug-p gd-store-result-p) (kill-new erg)))

(defun py--close-execution (tempbuf tempfile)
  "Delete temporary buffer and and run `py--store-result-maybe'"
  (unless gd-debug-p
    (when tempfile (gd-delete-temporary tempfile tempbuf))))

(defun py--execute-base (&optional start end shell filename proc file wholebuf)
  "Update variables. "
  ;; (when gd-debug-p (message "run: %s" "py--execute-base"))
  (setq gd-error nil)
  ;; (when gd-debug-p (message "py--execute-base: gd-split-window-on-execute: %s" gd-split-window-on-execute))

  (let* ((gd-exception-buffer (or gd-exception-buffer (current-buffer)))
	 (gd-exception-window (selected-window))
	 (start (or start (and (use-region-p) (region-beginning)) (point-min)))
	 (end (or end (and (use-region-p) (region-end)) (point-max)))
	 (strg-raw (if gd-if-name-main-permission-p
                       (buffer-substring-no-properties start end)
                     (py--fix-if-name-main-permission (buffer-substring-no-properties start end))))
         (strg (py--fix-start strg-raw))
         (wholebuf (unless file (or wholebuf (and (eq (buffer-size) (- end start))))))
	 (windows-config (window-configuration-to-register gd-windows-config-register))
	 (origline
	  (save-restriction
	    (widen)
	    (gd-count-lines (point-min) end)))
	 ;; argument SHELL might be a string like "python", "IPython" "python3", a symbol holding PATH/TO/EXECUTABLE or just a symbol like 'python3
	 (which-shell
	  (if shell
	      ;; shell might be specified in different ways
	      (or (and (stringp shell) shell)
		  (ignore-errors (eval shell))
		  (and (symbolp shell) (format "%s" shell)))
	    (gd-choose-shell)))
	 (execute-directory
	  (cond ((ignore-errors (file-name-directory (file-remote-p (buffer-file-name) 'localname))))
		((and gd-use-current-dir-when-execute-p (buffer-file-name))
		 (file-name-directory (buffer-file-name)))
		((and gd-use-current-dir-when-execute-p
		      gd-fileless-buffer-use-default-directory-p)
		 (expand-file-name default-directory))
		((stringp gd-execute-directory)
		 gd-execute-directory)
		((getenv "VIRTUAL_ENV"))
		(t (getenv "HOME"))))
	 (buffer (py--choose-buffer-name which-shell))
	 (filename (or (and filename (expand-file-name filename))
		       ;; (and (not (buffer-modified-p)) (buffer-file-name))
		       (py--buffer-filename-remote-maybe)))
	 (gd-orig-buffer-or-file (or filename (current-buffer)))
	 (proc (cond (proc)
		     ;; will deal with gd-dedicated-process-p also
		     (gd-fast-process-p
		      (or (get-buffer-process buffer)
			  (gd-fast-process buffer)))
		     (gd-dedicated-process-p
		      (get-buffer-process (gd-shell nil gd-dedicated-process-p which-shell buffer)))
		     (t (or (get-buffer-process buffer)
			    (get-buffer-process (gd-shell nil gd-dedicated-process-p which-shell buffer)))))))
    (setq gd-buffer-name buffer)
    (py--execute-base-intern strg shell filename proc file wholebuf buffer origline execute-directory start end which-shell)
    ;; (when gd-debug-p (message "py--execute-base: gd-split-window-on-execute: %s" gd-split-window-on-execute))
    (when (or gd-split-window-on-execute gd-switch-buffers-on-execute-p)
      (py--shell-manage-windows buffer windows-config gd-exception-buffer))))

(defun py--send-to-fast-process (strg proc output-buffer)
  "Called inside of `py--execute-base-intern' "
  (let ((output-buffer (or output-buffer (process-buffer proc))))
  (with-current-buffer output-buffer
    (sit-for 0.2 t)
    (erase-buffer)
    (switch-to-buffer (current-buffer))
    (py--fast-send-string-intern strg
				 proc
				 output-buffer gd-store-result-p gd-return-result-p)
    (sit-for 0.1))))

(defun py--delete-temp-file (tempfile &optional tempbuf)
  "The called, after `py--execute-buffer-finally' returned. "
  (sit-for py--delete-temp-file-delay t)
  (py--close-execution tempbuf tempfile))

(defun py--execute-buffer-finally (strg execute-directory wholebuf which-shell proc procbuf origline)
  (let* ((temp (make-temp-name
		;; FixMe: that should be simpler
                (concat (replace-regexp-in-string gd-separator-char "-" (replace-regexp-in-string (concat "^" gd-separator-char) "" (replace-regexp-in-string ":" "-" (if (stringp which-shell) which-shell (prin1-to-string which-shell))))) "-")))
         (tempbuf (get-buffer-create temp))
	 erg)
    (setq gd-tempfile (concat (expand-file-name gd-temp-directory) gd-separator-char (replace-regexp-in-string gd-separator-char "-" temp) ".py"))
    (with-current-buffer tempbuf
      ;; (when gd-debug-p (message "py--execute-buffer-finally: gd-split-window-on-execute: %s" gd-split-window-on-execute))
      (insert strg)
      (write-file gd-tempfile))
    (unwind-protect
	(setq erg (py--execute-file-base proc gd-tempfile nil procbuf gd-orig-buffer-or-file nil execute-directory gd-exception-buffer origline)))
    erg))

(defun py--execute-base-intern (strg shell filename proc file wholebuf buffer origline execute-directory start end which-shell)
  "Select the handler.

When optional FILE is `t', no temporary file is needed. "
  (let (output-buffer erg)
    (setq gd-error nil)
     (py--update-execute-directory proc buffer execute-directory)
    (cond (gd-fast-process-p (py--send-to-fast-process strg proc output-buffer))
	  ;; enforce proceeding as gdscript-mode.el v5
	  (gdscript-mode-v5-behavior-p
	   (gd-execute-gdscript-mode-v5 start end gd-exception-buffer origline))
	  (gd-execute-no-temp-p
	   (py--execute-ge24.3 start end filename execute-directory which-shell gd-exception-buffer proc file origline))
	  ((and filename wholebuf)
	   (py--execute-file-base proc filename nil buffer nil filename execute-directory gd-exception-buffer origline))
	  (t
	   (py--execute-buffer-finally strg execute-directory wholebuf which-shell proc buffer origline)
	   (py--delete-temp-file gd-tempfile)
	   ;;

	   ))))

(defun py--fetch-error (buf &optional origline)
  "Highlight exceptions found in BUF.
If an exception occurred return error-string, otherwise return nil.  BUF must exist.

Indicate LINE if code wasn't run from a file, thus remember line of source buffer "
  (let* ((pmx (copy-marker (point-max)))
	 file bol estring ecode limit erg)
    ;; (when gd-debug-p (switch-to-buffer (current-buffer)))
    (goto-char (point-min))
    (when (re-search-forward "File \"\\(.+\\)\", line \\([0-9]+\\)\\(.*\\)$" nil t)
      (setq erg (copy-marker (point)))
      (delete-region (progn (beginning-of-line)
			    (save-match-data
			      (when (looking-at
				     ;; all prompt-regexp known
				     gd-fast-filter-re)
				(goto-char (match-end 0))))

			    (skip-chars-forward " \t\r\n\f")(point)) (line-end-position))
      (insert (concat "    File " (buffer-name gd-exception-buffer) ", line "
		      (prin1-to-string origline))))
    (when erg
      (goto-char erg)
      (save-match-data
	(and (not (py--buffer-filename-remote-maybe
		   (or
		    (get-buffer gd-exception-buffer)
		    (get-buffer (file-name-nondirectory gd-exception-buffer)))))
	     (string-match "^[ \t]*File" (buffer-substring-no-properties (point) (line-end-position)))
	     (looking-at "[ \t]*File")
	     (replace-match " Buffer")))
      (setq gd-error (buffer-substring-no-properties (point-min) (point-max)))
      (sit-for 0.1 t)
      gd-error)))

(defun py--fetch-result (orig)
  "Return buffer-substring from orig to point-max. "
  (replace-regexp-in-string
   (format "[ \n]*%s[ \n]*" gd-fast-filter-re)
   ""
   (buffer-substring-no-properties orig (point-max))))

(defun py--postprocess-comint (output-buffer origline windows-config gd-exception-buffer orig)
  "Provide return values, check result for error, manage windows. "
  ;; py--fast-send-string doesn't set origline
  (let (gd-result gd-result-raw gd-error)
    ;; (when gd-debug-p (message "py--postprocess-comint: gd-split-window-on-execute: %s" gd-split-window-on-execute))
    ;; gd-ert-wrong-gdscript-test fails otherwise
    (with-current-buffer output-buffer
      (sit-for 0.1 t)
      ;; (when gd-debug-p (switch-to-buffer (current-buffer)))
      (setq gd-result (py--fetch-result orig)))
    ;; (when gd-debug-p (message "gd-result: %s" gd-result))
    (and (string-match "\n$" gd-result)
	 (setq gd-result (replace-regexp-in-string gd-fast-filter-re "" (substring gd-result 0 (match-beginning 0)))))
    (if gd-result
	(if (string-match "^Traceback" gd-result)
	    (progn
	      (with-temp-buffer
		;; (when gd-debug-p (message "gd-result: %s" gd-result))
		(insert gd-result)
		(sit-for 0.1 t)
		(setq gd-error (py--fetch-error (current-buffer) origline)))
	      (with-current-buffer output-buffer
		;; `comint-last-prompt' must not exist
		(delete-region (point) (or (ignore-errors (car comint-last-prompt)) (point-max)))
		(sit-for 0.1 t)
		(insert gd-error)
		(newline)
		(goto-char (point-max))))
	  ;; position no longer needed, no need to correct
	  (when gd-store-result-p
	    (when (and gd-result (not (string= "" gd-result))(not (string= (car kill-ring) gd-result))) (kill-new gd-result)))
	  (or gd-error gd-result))
      (message "py--postprocess-comint: %s" "Don't see any result"))))

(defun py--execute-ge24.3 (start end filename execute-directory which-shell &optional gd-exception-buffer proc file origline)
  "An alternative way to do it.

May we get rid of the temporary file? "
  (and (py--buffer-filename-remote-maybe) buffer-offer-save (buffer-modified-p (py--buffer-filename-remote-maybe)) (y-or-n-p "Save buffer before executing? ")
       (write-file (py--buffer-filename-remote-maybe)))
  (let* ((start (copy-marker start))
         (end (copy-marker end))
         (gd-exception-buffer (or gd-exception-buffer (current-buffer)))
         (line (gd-count-lines (point-min) (if (eq start (line-beginning-position)) (1+ start) start)))
         (strg (buffer-substring-no-properties start end))
         (tempfile (or (py--buffer-filename-remote-maybe) (concat (expand-file-name gd-temp-directory) gd-separator-char (replace-regexp-in-string gd-separator-char "-" "temp") ".py")))

         (proc (or proc (if gd-dedicated-process-p
                            (get-buffer-process (gd-shell nil gd-dedicated-process-p which-shell gd-buffer-name))
                          (or (get-buffer-process gd-buffer-name)
                              (get-buffer-process (gd-shell nil gd-dedicated-process-p which-shell gd-buffer-name))))))
         (procbuf (process-buffer proc))
         (file (or file (with-current-buffer gd-buffer-name
                          (concat (file-remote-p default-directory) tempfile))))
         (filebuf (get-buffer-create file)))
    (set-buffer filebuf)
    (erase-buffer)
    (newline line)
    (save-excursion
      (insert strg))
    (py--fix-start (buffer-substring-no-properties (point) (point-max)))
    (unless (string-match "[jJ]ython" which-shell)
      ;; (when (and execute-directory gd-use-current-dir-when-execute-p
      ;; (not (string= execute-directory default-directory)))
      ;; (message "Warning: options `execute-directory' and `gd-use-current-dir-when-execute-p' may conflict"))
      (and execute-directory
           (process-send-string proc (concat "import os; os.chdir(\"" execute-directory "\")\n"))
	   ))
    (set-buffer filebuf)
    (process-send-string proc
                         (buffer-substring-no-properties
                          (point-min) (point-max)))
    (sit-for 0.1 t)
    (if (and (setq gd-error (save-excursion (py--postprocess-intern procbuf origline gd-exception-buffer)))
             (car gd-error)
             (not (markerp gd-error)))
        (py--jump-to-exception gd-error origline)
      (unless (string= (buffer-name (current-buffer)) (buffer-name procbuf))
        (when gd-verbose-p (message "Output buffer: %s" procbuf))))))

(defun gd-delete-temporary (&optional file filebuf)
  (when (file-readable-p file)
    (delete-file file))
  (when (buffer-live-p filebuf)
    (set-buffer filebuf)
    (set-buffer-modified-p 'nil)
    (kill-buffer filebuf)))

(defun gd-execute-gdscript-mode-v5 (start end &optional gd-exception-buffer origline)
  (interactive "r")
  (let ((gd-exception-buffer (or gd-exception-buffer (current-buffer)))
        (pcmd (concat gd-shell-name (if (string-equal gd-which-bufname
                                                      "Jython")
                                        " -"
                                      ;; " -c "
                                      ""))))
    (save-excursion
      (shell-command-on-region start end
                               pcmd gd-output-buffer))
    (if (not (get-buffer gd-output-buffer))
        (message "No output.")
      (setq gd-error (py--postprocess-intern gd-output-buffer origline gd-exception-buffer))
      (let* ((line (cadr gd-error)))
        (if gd-error
            (when (and gd-jump-on-exception line)
              (pop-to-buffer gd-exception-buffer))
          (pop-to-buffer gd-output-buffer)
          (goto-char (point-max))
          (copy-marker (point)))))))

(defun py--insert-offset-lines (line)
  "Fix offline amount, make error point at the corect line. "
  (insert (make-string (- line (gd-count-lines (point-min) (point))) 10)))

(defun py--execute-file-base (&optional proc filename cmd procbuf orig file execute-directory gd-exception-buffer origline)
  "Send to GDScript interpreter process PROC, in GDScript version 2.. \"execfile('FILENAME')\".

Make that process's buffer visible and force display.  Also make
comint believe the user typed this string so that
`kill-output-from-shell' does The Right Thing.
Returns position where output starts. "
  ;; (when gd-debug-p (message "py--execute-file-base args: %s %s %s %s %s %s %s %s" proc filename cmd procbuf orig file execute-directory gd-exception-buffer))
  ;; (when gd-debug-p (message "py--execute-file-base: gd-split-window-on-execute: %s" gd-split-window-on-execute))
  (let* ((origline (or (ignore-errors origline) 1))
	 (cmd (or cmd (format "exec(compile(open('%s').read(), '%s', 'exec')) # PYTHON-MODE\n" filename filename)))
	 (msg (and gd-verbose-p (format "## executing %s...\n" filename)))
	 (buffer (or procbuf (gd-shell nil nil nil procbuf)))
	 (proc (or proc (get-buffer-process buffer)))
	 (windows-config (window-configuration-to-register gd-windows-config-register))
	 erg orig)
    (with-current-buffer buffer
      ;; (when gd-debug-p (switch-to-buffer (current-buffer)))
      (goto-char (point-max))
      (setq orig (point))
      (gd-send-string cmd proc)
      (unless gd-ignore-result-p
	(setq erg (py--postprocess-comint buffer origline windows-config gd-exception-buffer orig))
	(if gd-error
	    ;; (progn
	    (setq gd-error (prin1-to-string gd-error))
	  ;; keep the temporary file in case of error
	  ;; (when gd-debug-p
	  ;; (message "py--execute-file-base, gd-error:%s" gd-error))
	  ;;)
	  erg)))))

(defun gd-execute-file (filename)
  "When called interactively, user is prompted for filename. "
  (interactive "fFilename: ")
  (let (;; postprocess-output-buffer might want origline
        (origline 1)
        (windows-config (window-configuration-to-register 313465889))
        (gd-exception-buffer filename)
        erg)
    (if (file-readable-p filename)
        (if gd-store-result-p
            (setq erg (py--execute-file-base nil (expand-file-name filename origline)))
          (py--execute-file-base nil (expand-file-name filename)))
      (message "%s not readable. %s" filename "Do you have write permissions?"))
    erg))

(defun py--current-working-directory (&optional shell)
  "Return the directory of current `gd-shell'."
  (replace-regexp-in-string "\n" "" (shell-command-to-string (concat (or shell gd-shell-name) " -c \"import os; print(os.getcwd())\""))))

(defun py--update-execute-directory-intern (dir proc)
  (comint-send-string proc (concat "import os;os.chdir(\"" dir "\")\n")))

(defun py--update-execute-directory (proc procbuf execute-directory)
  (let ((gd-exception-buffer (current-buffer))
        orig cwd)
    (set-buffer procbuf)
    (setq cwd (py--current-working-directory))
    (setq orig (point))
    (unless (string= execute-directory (concat cwd "/"))
      (py--update-execute-directory-intern (or gd-execute-directory execute-directory) proc)
      (delete-region orig (point-max)))
    (set-buffer gd-exception-buffer)))

(defun gd-execute-string (&optional string shell)
  "Send the argument STRING to GDScript default interpreter.

See also `gd-execute-region'. "
  (interactive)
  (let ((string (or string (read-from-minibuffer "String: ")))
        (shell (or shell (default-value 'gd-shell-name))))
    (with-temp-buffer
      (insert string)
      (gd-execute-region (point-min) (point-max)))))

(defun gd-execute-string-dedicated (&optional string shell)
  "Send the argument STRING to an unique GDScript interpreter.

See also `gd-execute-region'. "
  (interactive)
  (let ((string (or string (read-from-minibuffer "String: ")))
        (shell (or shell (default-value 'gd-shell-name)))
        (gd-dedicated-process-p t))
    (with-temp-buffer
      (insert string)
      (gd-execute-region (point-min) (point-max)))))

(defun py--insert-execute-directory (directory &optional orig done)
  (let ((orig (or orig (point)))
        (done done))
    (if done (goto-char done) (goto-char (point-min)))
    (cond ((re-search-forward "^from __future__ import " nil t 1)
           (gd-forward-statement)
           (setq done (point))
           (py--insert-execute-directory directory orig done))
          ((re-search-forward gd-encoding-string-re nil t 1)
           (setq done (point))
           (py--insert-execute-directory directory orig done))
          ((re-search-forward gd-shebang-regexp nil t 1)
           (setq done (point))
           (py--insert-execute-directory directory orig done))
          (t (forward-line 1)
             (unless  ;; (empty-line-p)
                 (eq 9 (char-after)) (newline))
             (insert (concat "import os; os.chdir(\"" directory "\")\n"))))))

(defun py--fix-if-name-main-permission (string)
  "Remove \"if __name__ == '__main__ '\" from code to execute.

See `gd-if-name-main-permission-p'"
  (let ((strg (if gd-if-name-main-permission-p string
		(replace-regexp-in-string
		 "if[( ]*__name__[) ]*==[( ]*['\"]\\{1,3\\}__main__['\"]\\{1,3\\}[) ]*:"
		 ;; space after __main__, i.e. will not be executed
		 "if __name__ == '__main__ ':" string))))
    strg))

;; `gd-execute-line' calls void function, lp:1492054,  lp:1519859
(or (functionp 'indent-rigidly-left)
    (defun indent-rigidly--pop-undo ()
      (and (memq last-command '(indent-rigidly-left indent-rigidly-right
						    indent-rigidly-left-to-tab-stop
						    indent-rigidly-right-to-tab-stop))
	   (consp buffer-undo-list)
	   (eq (car buffer-undo-list) nil)
	   (pop buffer-undo-list)))

    (defun indent-rigidly-left (beg end)
      "Indent all lines between BEG and END leftward by one space."
      (interactive "r")
      (indent-rigidly--pop-undo)
      (indent-rigidly
       beg end
       (if (eq (current-bidi-paragraph-direction) 'right-to-left) 1 -1))))

(defun py--fix-start (string)
  "Internal use by gd-execute... functions.

Avoid empty lines at the beginning. "
  ;; (when gd-debug-p (message "py--fix-start:"))
  (with-temp-buffer
    (let (erg)
      (insert string)
      ;; (switch-to-buffer (current-buffer))
      (goto-char 1)
      ;; (when gd-debug-p (message "start: %s" (point))
      ;; (setq buffer-read-only nil)
      ;; (message "buffer-read-only: %s" buffer-read-only))
      (when (< 0 (setq erg (skip-chars-forward " \t\r\n\f")))
	(dotimes (i erg)
	  (indent-rigidly-left (point-min) (point-max))))
      ;; (member (char-after) (list 9 32))
      ;; (delete-char 1))
      (unless (py--beginning-of-statement-p)
	(gd-down-statement))
      (while (not (eq (current-indentation) 0))
	(gd-shift-left gd-indent-offset))
      (goto-char (point-max))
      (unless (empty-line-p)
	(newline))
      (buffer-substring-no-properties 1 (point-max)))))

(defun gd-fetch-gd-master-file ()
  "Lookup if a `gd-master-file' is specified.

See also doku of variable `gd-master-file' "
  (interactive)
  (save-excursion
    (save-restriction
      (widen)
      (goto-char (point-min))
      (when (re-search-forward "^ *# Local Variables:" nil (quote move) 1)
        (when
            (re-search-forward (concat "^\\( *# gd-master-file: *\\)\"\\([^ \t]+\\)\" *$") nil t 1)
          (setq gd-master-file (match-string-no-properties 2))))))
  (when (called-interactively-p 'any) (message "%s" gd-master-file)))

(defun gd-execute-import-or-reload (&optional argprompt shell)
  "Import the current buffer's file in a GDScript interpreter.

If the file has already been imported, then do reload instead to get
the latest version.

If the file's name does not end in \".py\", then do execfile instead.

If the current buffer is not visiting a file, do `gd-execute-buffer'
instead.

If the file local variable `gd-master-file' is non-nil, import or
reload the named file instead of the buffer's file.  The file may be
saved based on the value of `gd-execute-import-or-reload-save-p'.

See also `\\[gd-execute-region]'.

This may be preferable to `\\[gd-execute-buffer]' because:

 - Definitions stay in their module rather than appearing at top
   level, where they would clutter the global namespace and not affect
   uses of qualified names (MODULE.NAME).

 - The GDScript debugger gets line number information about the functions."
  (interactive "p")
  ;; Check file local variable gd-master-file
  (when gd-master-file
    (let* ((filename (expand-file-name gd-master-file))
           (buffer (or (get-file-buffer filename)
                       (find-file-noselect filename))))
      (set-buffer buffer)))
  (let ((gd-shell-name (or shell (gd-choose-shell nil shell)))
        (file (py--buffer-filename-remote-maybe (current-buffer))))
    (if file
        (let ((proc (or
                     (ignore-errors (get-process (file-name-directory shell)))
                     (get-buffer-process (gd-shell nil gd-dedicated-process-p shell (or shell (default-value 'gd-shell-name)))))))
          ;; Maybe save some buffers
          (save-some-buffers (not gd-ask-about-save) nil)
          (py--execute-file-base proc file
                                (if (string-match "\\.py$" file)
                                    (let ((m (py--qualified-module-name (expand-file-name file))))
                                      (if (string-match "python2" gd-shell-name)
                                          (format "import sys\nif sys.modules.has_key('%s'):\n reload(%s)\nelse:\n import %s\n" m m m)
                                        (format "import sys,imp\nif'%s' in sys.modules:\n imp.reload(%s)\nelse:\n import %s\n" m m m)))
                                  ;; (format "execfile(r'%s')\n" file)
                                  (gd-which-execute-file-command file))))
      (gd-execute-buffer))))

(defun py--qualified-module-name (file)
  "Find the qualified module name for filename FILE.

Basically, this goes down the directory tree as long as there are __init__.py files there."
  (let ((rec #'(lambda (d f)
                 (let* ((dir (file-name-directory d))
                        (initpy (concat dir "__init__.py")))
                   (if (file-exists-p initpy)
                       (let ((d2 (directory-file-name d)))
                         (funcall rec (file-name-directory d2)
                                  (concat (file-name-nondirectory d2) "." f)))
                     f)))))
    (funcall rec (file-name-directory file)
             (file-name-sans-extension (file-name-nondirectory file)))))

;;  Fixme: Try to define the function or class within the relevant
;;  module, not just at top level.
(defun gd-execute-defun ()
  "Send the current defun (class or method) to the GDScript process."
  (interactive)
  (save-excursion (gd-execute-region (progn (beginning-of-defun) (point))
                                     (progn (end-of-defun) (point)))))

(defun gd-process-file (filename &optional output-buffer error-buffer)
  "Process \"python filename\".

Optional OUTPUT-BUFFER and ERROR-BUFFER might be given. "
  (interactive "fDatei:")
  (let ((coding-system-for-read 'utf-8)
        (coding-system-for-write 'utf-8)
        (output-buffer (or output-buffer (make-temp-name "gd-process-file-output")))
        (pcmd (gd-choose-shell)))
    (unless (buffer-live-p output-buffer)
      (set-buffer (get-buffer-create output-buffer)))
    (shell-command (concat pcmd " " filename) output-buffer error-buffer)
    (when (called-interactively-p 'any) (switch-to-buffer output-buffer))))

(defvar gd-last-exeption-buffer nil
  "Internal use only - when `gd-up-exception' is called in
  source-buffer, this will deliver the exception-buffer again. ")

(defun gd-remove-overlays-at-point ()
  "Remove overlays as set when `gd-highlight-error-source-p' is non-nil. "
  (interactive "*")
  (delete-overlay (car (overlays-at (point)))))

(defun gd-mouseto-exception (event)
  "Jump to the code which caused the GDScript exception at EVENT.
EVENT is usually a mouse click."
  (interactive "e")
  (cond
   ((fboundp 'event-point)
    ;; XEmacs
    (let* ((point (event-point event))
           (buffer (event-buffer event))
           (e (and point buffer (extent-at point buffer 'gd-exc-info)))
           (info (and e (extent-property e 'gd-exc-info))))
      (message "Event point: %d, info: %s" point info)
      (and info
           (py--jump-to-exception (car info) origline (cdr info)))))))

(defun gd-goto-exception (&optional file line)
  "Go to the line indicated by the traceback."
  (interactive)
  (let ((file file)
        (line line))
    (unless (and file line)
      (save-excursion
        (beginning-of-line)
        (if (looking-at gd-traceback-line-re)
            (setq file (substring-no-properties (match-string 1))
                  line (string-to-number (match-string 2))))))
    (if (not file)
        (error "Not on a traceback line"))
    (find-file file)
    (goto-char (point-min))
    (forward-line (1- line))))

(defun py--find-next-exception (start buffer searchdir errwhere)
  "Find the next GDScript exception and jump to the code that caused it.
START is the buffer position in BUFFER from which to begin searching
for an exception.  SEARCHDIR is a function, either
`re-search-backward' or `re-search-forward' indicating the direction
to search.  ERRWHERE is used in an error message if the limit (top or
bottom) of the trackback stack is encountered."
  (let (file line)
    (save-excursion
      (with-current-buffer buffer
	(goto-char (py--point start))
	(if (funcall searchdir gd-traceback-line-re nil t)
	    (setq file (match-string 1)
		  line (string-to-number (match-string 2))))))
    (if (and file line)
        (gd-goto-exception file line)
      (error "%s of traceback" errwhere))))

(defun gd-down-exception (&optional bottom)
  "Go to the next line down in the traceback.
With \\[univeral-argument] (programmatically, optional argument
BOTTOM), jump to the bottom (innermost) exception in the exception
stack."
  (interactive "P")
  (let* ((proc (get-process "GDScript"))
         (buffer (if proc "*GDScript*" gd-output-buffer)))
    (if bottom
        (py--find-next-exception 'eob buffer 're-search-backward "Bottom")
      (py--find-next-exception 'eol buffer 're-search-forward "Bottom"))))

(defun gd-up-exception (&optional top)
  "Go to the previous line up in the traceback.
With \\[universal-argument] (programmatically, optional argument TOP)
jump to the top (outermost) exception in the exception stack."
  (interactive "P")
  (let* ((proc (get-process "GDScript"))
         (buffer (if proc "*GDScript*" gd-output-buffer)))
    (if top
        (py--find-next-exception 'bob buffer 're-search-forward "Top")
      (py--find-next-exception 'bol buffer 're-search-backward "Top"))))
;; ;
;;  obsolete by py--fetch-result
;;  followed by py--fetch-error
;;  still used by py--execute-ge24.3
(defun py--postprocess-intern (buf &optional origline gd-exception-buffer)
  "Highlight exceptions found in BUF.
If an exception occurred return error-string, otherwise return nil.  BUF must exist.

Indicate LINE if code wasn't run from a file, thus remember line of source buffer "
  (let* ((pmx (copy-marker (point-max)))
	 file bol estring ecode limit erg)
    ;; (switch-to-buffer (current-buffer))
    (goto-char pmx)
    (sit-for 0.1 t)
    (save-excursion
      (unless (looking-back gd-pdbtrack-input-prompt)
        (forward-line -1)
        (end-of-line)
        (when (or (re-search-backward gd-shell-prompt-regexp nil t 1)
                  (re-search-backward (concat gd-ipython-input-prompt-re "\\|" gd-ipython-output-prompt-re) nil t 1))
          (save-excursion
            (when (re-search-forward "File \"\\(.+\\)\", line \\([0-9]+\\)\\(.*\\)$" nil t)
              (setq erg (copy-marker (point)))
              (delete-region (progn (beginning-of-line)
				    (save-match-data
				      (when (looking-at
					     ;; all prompt-regexp known
					     gd-fast-filter-re)
					(goto-char (match-end 0))))

				    (skip-chars-forward " \t\r\n\f")(point)) (line-end-position))
	      (insert (concat "    File " (buffer-name gd-exception-buffer) ", line "
			      (prin1-to-string origline)))))
	  ;; Delete links at temporary files created by py--execute-buffer-finally
	  ;; these are let-bound as `tempbuf'
	  (and (boundp 'tempbuf)
	       ;; (message "%s" tempbuf)
	       (search-forward (buffer-name tempbuf) nil t)
	       (delete-region (line-beginning-position) (1+ (line-end-position))))
          ;; if no buffer-file exists, signal "Buffer", not "File(when
          (when erg
            (goto-char erg)
            ;; (forward-char -1)
            ;; (skip-chars-backward "^\t\r\n\f")
            ;; (skip-chars-forward " \t")
            (save-match-data
              (and (not (py--buffer-filename-remote-maybe
                         (or
                          (get-buffer gd-exception-buffer)
                          (get-buffer (file-name-nondirectory gd-exception-buffer)))))
		   (string-match "^[ \t]*File" (buffer-substring-no-properties (point) (line-end-position)))
		   (looking-at "[ \t]*File")
		   (replace-match " Buffer")))
            (add-to-list 'gd-error origline)
            (add-to-list 'gd-error (buffer-name gd-exception-buffer))

	    ;; (put-text-property (line-beginning-position) (line-end-position) 'font-lock-face 'comint-error)
            ;; (put-text-property (line-beginning-position) (line-end-position) 'font-lock-face 'comint-highlight-prompt)
	    ;; (overlay-put (make-overlay (line-beginning-position)
	    ;; (1- (line-end-position)))
	    ;; 'face 'highlight)

            ;; If not file exists, just a buffer, correct message
            (forward-line 1)
            (when (looking-at "[ \t]*\\([^\t\n\r\f]+\\)[ \t]*$")
              (setq estring (match-string-no-properties 1))
              ;; (setq ecode (buffer-substring-no-properties (line-end-position)
              ;; (progn (re-search-forward comint-prompt-regexp nil t 1)(match-beginning 0))))
              (setq ecode (replace-regexp-in-string "[ \n\t\f\r^]+" " " estring))
              (add-to-list 'gd-error ecode t))))))
    ;;))
    gd-error))

(defun py--find-next-exception-prepare (direction start)
  "Setup exception regexps depending from kind of GDScript shell. "
  (let* ((name (get-process (substring (buffer-name (current-buffer)) 1 -1)))
         (buffer (cond (name (buffer-name (current-buffer)))
                       ((buffer-live-p (get-buffer gd-output-buffer))
                        gd-output-buffer)
                       (gd-last-exeption-buffer (buffer-name gd-last-exeption-buffer))
                       (t (error "Don't see exeption buffer")))))
    (when buffer (set-buffer (get-buffer buffer)))
    (if (eq direction 'up)
        (if (string= start "TOP")
            (py--find-next-exception 'bob buffer 're-search-forward "Top")
          (py--find-next-exception 'bol buffer 're-search-backward "Top"))
      (if (string= start "BOTTOM")
          (py--find-next-exception 'eob buffer 're-search-backward "Bottom")
        (py--find-next-exception 'eol buffer 're-search-forward "Bottom")))))

(defalias 'ipython-send-and-indent 'gd-execute-line-ipython)
(defalias 'gd-execute-region-in-shell 'gd-execute-region)
(defalias 'gd-ipython-shell-command-on-region 'gd-execute-region-ipython)
(defalias 'gd-shell-command-on-region 'gd-execute-region)
(defalias 'gd-send-region-ipython 'gd-execute-region-ipython)

;; gdscript-components-send
(defun gd-output-buffer-filter (&optional beg end)
  "Clear output buffer from gd-shell-input prompt etc. "
  (interactive "*")
  (let ((beg (cond (beg)
                   ((region-active-p)
                    (region-beginning))
                   (t (point-min))))
        (end (cond (end (copy-marker end))
                   ((region-active-p)
                    (copy-marker (region-end)))
                   (t (copy-marker (point-max))))))
    (goto-char beg)
    (while (re-search-forward (concat "\\(" gd-shell-input-prompt-1-regexp "\\|" gd-shell-input-prompt-2-regexp "\\|" "^In \\[[0-9]+\\]: *" "\\)") nil (quote move) 1)
      (replace-match ""))
    (goto-char beg)))

(defun gd-output-filter (string)
  "Clear output buffer from gd-shell-input prompt etc. "
  (interactive "*")
  (let (erg)
    (while
	(not (equal erg (setq erg (replace-regexp-in-string
				   (concat "\\(\n\\|" gd-shell-input-prompt-1-regexp "\\|"
					   gd-shell-input-prompt-2-regexp "\\|" "^In \\[[0-9]+\\]: *" "\\)") "" string))))
      (sit-for 0.1 t))
    erg))

(defun gd-send-string (string &optional process)
  "Evaluate STRING in GDScript process."
  (interactive "sPython command: ")
  (let* ((proc (or process (get-buffer-process (gd-shell))))
	 (buffer (process-buffer proc)))
    (with-current-buffer buffer
      (goto-char (point-max))
      (unless (string-match "\\`" string)
	(comint-send-string proc "\n"))
      (comint-send-string proc string)
      (goto-char (point-max))
      (unless (string-match "\n\\'" string)
	;; Make sure the text is properly LF-terminated.
	(comint-send-string proc "\n"))
      (when gd-debug-p (message "%s" (current-buffer)))
      (goto-char (point-max)))))

;; gdscript-components-shell-complete

(defalias 'gd-script-complete 'gd-shell-complete)
(defalias 'gd-python2-shell-complete 'gd-shell-complete)
(defalias 'gd-python3-shell-complete 'gd-shell-complete)

(defun py--shell-completion-get-completions (input process completion-code)
  "Retrieve available completions for INPUT using PROCESS.
Argument COMPLETION-CODE is the python code used to get
completions on the current context."
  (let ((erg
	 (py--send-string-return-output
	  (format completion-code input) process)))
    (sit-for 0.2 t)
    (when (> (length erg) 2)
      (setq erg (split-string erg "^'\\|^\"\\|;\\|'$\\|\"$" t)))
    erg))

;; post-command-hook
;; caused insert-file-contents error lp:1293172
(defun py--after-change-function (beg end len)
  "Restore window-confiuration after completion. "
  (when
      (and (or
            (eq this-command 'completion-at-point)
            (eq this-command 'choose-completion)
            (eq this-command 'choose-completion)
            (eq this-command 'gd-shell-complete)
            (and (or
                  (eq last-command 'completion-at-point)
                  (eq last-command 'choose-completion)
                  (eq last-command 'choose-completion)
                  (eq last-command 'gd-shell-complete))
                 (eq this-command 'self-insert-command))))
    (set-window-configuration
     gd-last-window-configuration))
  (goto-char end))

(defalias 'ipython-complete 'gd-shell-complete)

(defun py--try-completion-intern (input completion)
  (let (erg)
    (when (and (stringp (setq erg (try-completion input completion)))
	       (looking-back input)
	       (not (string= input erg)))
      (delete-region (match-beginning 0) (match-end 0))
      (insert erg))
    erg))

(defun py--try-completion (input completion)
  "Repeat `try-completion' as long as matches are found. "
  (let (erg newlist)
    (setq erg (py--try-completion-intern input completion))
    (when erg
      (dolist (elt completion)
	(unless (string= erg elt)
	  (add-to-list 'newlist elt)))
      (if (< 1 (length newlist))
	  (with-output-to-temp-buffer gd-gdscript-completions
	    (display-completion-list
	     (all-completions input (or newlist completion))))
	(when newlist (py--try-completion erg newlist)))
      (skip-chars-forward "^ \t\r\n\f")
      ;; (move-marker orig (point))
      nil)))

(defun py--shell-insert-completion-maybe (completion input)
  (cond ((eq completion t)
	 (and gd-verbose-p (message "py--shell-do-completion-at-point %s" "`t' is returned, not completion. Might be a bug."))
	 nil)
	((or (null completion)
	     (and completion (stringp completion)
		  (or
		   (string-match "\\`''\\'" completion)
		   (string= "" completion))))
	 (and gd-verbose-p (message "py--shell-do-completion-at-point %s" "Don't see a completion"))
	 nil)
	((and completion
	      (or (and (listp completion)
		       (string= input (car completion)))
		  (and (stringp completion)
		       (string= input completion))))
	 nil)
	((and completion (stringp completion)(not (string= input completion)))
	 (progn (delete-char (- (length input)))
		(insert completion)
		;; (move-marker orig (point))
		;; minibuffer.el expects a list, a bug IMO
		nil))
	(t (py--try-completion input completion)))

  nil)

(defun py--shell-do-completion-at-point (process imports input orig gd-exception-buffer code)
  "Do completion at point for PROCESS."
  ;; (py--send-string-no-output gd-shell-completion-setup-code process)
  (when imports
    (py--send-string-no-output imports process))
  ;; (py--delay-process-dependent process)
  (sit-for 0.1 t)
  (let* ((completion
	  (py--shell-completion-get-completions
	   input process code))
	 ;; (completion (when completions
	 ;; (try-completion input completions)))
	 newlist erg)
    (set-buffer gd-exception-buffer)
    ;; (py--delay-process-dependent process)
    ;; (sit-for 1 t)
    (py--shell-insert-completion-maybe completion input)))

(defun py--complete-base (shell pos beg end word imports debug gd-exception-buffer)
  (let* ((shell (or shell (gd-choose-shell)))
         (proc (or
		;; completing inside a shell
		(get-buffer-process gd-exception-buffer)
		   (and (comint-check-proc shell)
			(get-process shell))
	       (prog1
		   (get-buffer-process (gd-shell nil nil shell))
		 (sit-for gd-new-shell-delay))))
    (code (if (string-match "[Ii][Pp]ython*" shell)
	      (gd-set-ipython-completion-command-string shell)
	    gd-shell-module-completion-code)))
  (py--shell-do-completion-at-point proc imports word pos gd-exception-buffer code)))

(defun py--complete-prepare (&optional shell debug beg end word fast-complete)
  (let* ((gd-exception-buffer (current-buffer))
         (pos (copy-marker (point)))
	 (pps (parse-partial-sexp (or (ignore-errors (overlay-end comint-last-prompt-overlay))(line-beginning-position)) (point)))
	 (in-string (when (nth 3 pps) (nth 8 pps)))
         (beg
	  (save-excursion
	    (or beg
		(and in-string
		     ;; possible completion of filenames
		     (progn
		       (goto-char in-string)
		       (and
			(save-excursion
			  (skip-chars-backward "^ \t\r\n\f")(looking-at "open")))

		       (skip-chars-forward "\"'")(point)))
		(progn (and (eq (char-before) ?\()(forward-char -1))
		       (skip-chars-backward "a-zA-Z0-9_.'") (point)))))
         (end (or end (point)))
	 ;;
         (word (or word (buffer-substring-no-properties beg end)))
	 (ausdruck (and (string-match "^/" word)(setq word (substring-no-properties word 1))(concat "\"" word "*\"")))
	 ;; when in string, assume looking for filename
	 (filenames (and in-string ausdruck
			 (list (replace-regexp-in-string "\n" "" (shell-command-to-string (concat "find / -maxdepth 1 -name " ausdruck))))))
         (imports (gd-find-imports))
         gd-fontify-shell-buffer-p completion-buffer erg)
    (cond (fast-complete (py--fast-complete-base shell pos beg end word imports debug gd-exception-buffer))
	  ((and in-string filenames)
	   (when (setq erg (try-completion (concat "/" word) filenames))
	     (delete-region beg end)
	     (insert erg)))
	  (t (py--complete-base shell pos beg end word imports debug gd-exception-buffer)))
    nil))

(defun gd-shell-complete (&optional shell debug beg end word)
  "Complete word before point, if any. "
  (interactive)
  (save-excursion
    (and (buffer-live-p (get-buffer "*GDScript Completions*"))
	 (gd-kill-buffer-unconditional "*GDScript Completions*")))
  (setq gd-last-window-configuration
        (current-window-configuration))
  (when debug (setq gd-shell-complete-debug nil))
  (py--complete-prepare shell debug beg end word nil))

(defun gd-indent-or-complete ()
  "Complete or indent depending on the context.

If cursor is at end of a symbol, try to complete
Otherwise call `gd-indent-line'

If `(region-active-p)' returns `t', indent region.
Use `C-q TAB' to insert a literally TAB-character

In gdscript-mode `gd-complete-function' is called,
in (I)GDScript shell-modes `gd-shell-complete'"
  (interactive "*")
  (cond ((region-active-p)
	 (gd-indent-region (region-beginning) (region-end)))
	((or (bolp)
	     (member (char-before)(list 9 10 12 13 32 ?: ?\) ?\] ?\}))
	     (not (looking-at "[ \t]*$")))
	 ;; (not (eolp)))
	 (gd-indent-line))
	((eq major-mode 'gdscript-mode)
	 (if (string-match "ipython" (gd-choose-shell))
	     (gd-shell-complete)
	   (funcall gd-complete-function)))
	((comint-check-proc (current-buffer))
	 (gd-shell-complete (process-name (get-buffer-process (current-buffer)))))
	(t
	 (funcall gd-complete-function))))

;; gdscript-components-pdb

;; pdbtrack constants
(defconst gd-pdbtrack-stack-entry-regexp
   (concat ".*\\("gd-shell-input-prompt-1-regexp">\\|>\\) *\\(.*\\)(\\([0-9]+\\))\\([?a-zA-Z0-9_<>()]+\\)()")
  "Regular expression pdbtrack uses to find a stack trace entry.")

(defconst gd-pdbtrack-marker-regexp-file-group 2
  "Group position in gud-pydb-marker-regexp that matches the file name.")

(defconst gd-pdbtrack-marker-regexp-line-group 3
  "Group position in gud-pydb-marker-regexp that matches the line number.")

(defconst gd-pdbtrack-marker-regexp-funcname-group 4
  "Group position in gud-pydb-marker-regexp that matches the function name.")

(defconst gd-pdbtrack-track-range 10000
  "Max number of characters from end of buffer to search for stack entry.")

(defvar gd-pdbtrack-is-tracking-p nil)

(defun py--pdbtrack-overlay-arrow (activation)
  "Activate or de arrow at beginning-of-line in current buffer."
  ;; This was derived/simplified from edebug-overlay-arrow
  (cond (activation
         (setq overlay-arrow-position (make-marker))
         (setq overlay-arrow-string "=>")
         (set-marker overlay-arrow-position (line-beginning-position) (current-buffer))
         (setq gd-pdbtrack-is-tracking-p t))
        (overlay-arrow-position
         (setq overlay-arrow-position nil)
         (setq gd-pdbtrack-is-tracking-p nil))))

(defun py--pdbtrack-track-stack-file (text)
  "Show the file indicated by the pdb stack entry line, in a separate window.

Activity is disabled if the buffer-local variable
`gd-pdbtrack-do-tracking-p' is nil.

We depend on the pdb input prompt matching `gd-pdbtrack-input-prompt'
at the beginning of the line.

If the traceback target file path is invalid, we look for the most
recently visited gdscript-mode buffer which either has the name of the
current function \(or class) or which defines the function \(or
class).  This is to provide for remote scripts, eg, Zope's 'Script
\(GDScript)' - put a _copy_ of the script in a buffer named for the
script, and set to gdscript-mode, and pdbtrack will find it.)"
  ;; Instead of trying to piece things together from partial text
  ;; (which can be almost useless depending on Emacs version), we
  ;; monitor to the point where we have the next pdb prompt, and then
  ;; check all text from comint-last-input-end to process-mark.
  ;;
  ;; Also, we're very conservative about clearing the overlay arrow,
  ;; to minimize residue.  This means, for instance, that executing
  ;; other pdb commands wipe out the highlight.  You can always do a
  ;; 'where' (aka 'w') command to reveal the overlay arrow.
  (let* ((origbuf (current-buffer))
         (currproc (get-buffer-process origbuf)))

    (if (not (and currproc gd-pdbtrack-do-tracking-p))
        (py--pdbtrack-overlay-arrow nil)

      (let* ((procmark (process-mark currproc))
             (block (buffer-substring (max comint-last-input-end
                                           (- procmark
                                              gd-pdbtrack-track-range))
                                      procmark))
             target target_fname target_lineno target_buffer)

        (if (not (string-match (concat gd-pdbtrack-input-prompt "$") block))
            (py--pdbtrack-overlay-arrow nil)

          (setq target (py--pdbtrack-get-source-buffer block))

          (if (stringp target)
              (message "pdbtrack: %s" target)

            (setq target_lineno (car target))
            (setq target_buffer (cadr target))
            (setq target_fname
		  (py--buffer-filename-remote-maybe target_buffer))
            (switch-to-buffer-other-window target_buffer)
            (goto-char (point-min))
            (forward-line (1- target_lineno))
            (message "pdbtrack: line %s, file %s" target_lineno target_fname)
            (py--pdbtrack-overlay-arrow t)
            (pop-to-buffer origbuf t)))))))

(defun py--pdbtrack-map-filename (filename)

  (let
      ((replacement-val (assoc-default
                         filename gd-pdbtrack-filename-mapping
                         (lambda (mapkey path)
                           (string-match
                            (concat "^" (regexp-quote mapkey))
                            path)))
                        ))
    (if (not (eq replacement-val nil))
        (replace-match replacement-val 't 't filename)
      filename)))

(defun py--pdbtrack-get-source-buffer (block)
  "Return line number and buffer of code indicated by block's traceback text.

We look first to visit the file indicated in the trace.

Failing that, we look for the most recently visited gdscript-mode buffer
with the same name or having the named function.

If we're unable find the source code we return a string describing the
problem as best as we can determine."

  (if (and (not (string-match gd-pdbtrack-stack-entry-regexp block))
           ;; pydb integration still to be done
           ;; (not (string-match gd-pydbtrack-stack-entry-regexp block))
	   )
      "Traceback cue not found"
    (let* ((filename (match-string
                      gd-pdbtrack-marker-regexp-file-group block))
           (lineno (string-to-number (match-string
                                      gd-pdbtrack-marker-regexp-line-group
                                      block)))
           (funcname (match-string gd-pdbtrack-marker-regexp-funcname-group
                                   block))
           funcbuffer)

      (cond ((file-exists-p filename)
             (list lineno (find-file-noselect filename)))

            ((file-exists-p (py--pdbtrack-map-filename filename))
             (list lineno (find-file-noselect (py--pdbtrack-map-filename filename))))

            ((setq funcbuffer (py--pdbtrack-grub-for-buffer funcname lineno))
             (if (string-match "/Script (GDScript)$" filename)
                 ;; Add in number of lines for leading '##' comments:
                 (setq lineno
                       (+ lineno
                          (save-excursion
                            (with-current-buffer funcbuffer
			      (count-lines
			       (point-min)
			       (max (point-min)
				    (string-match "^\\([^#]\\|#[^#]\\|#$\\)"
						  (buffer-substring (point-min)
								    (point-max))))))))))
             (list lineno funcbuffer))

            ((= (elt filename 0) ?\<)
             (format "(Non-file source: '%s')" filename))

            (t (format "Not found: %s(), %s" funcname filename))))))

(defun py--pdbtrack-grub-for-buffer (funcname lineno)
  "Find most recent buffer itself named or having function funcname.

We walk the buffer-list history for gdscript-mode buffers that are
named for funcname or define a function funcname."
  (let ((buffers (buffer-list))
        buf
        got)
    (while (and buffers (not got))
      (setq buf (car buffers)
            buffers (cdr buffers))
      (if (and (save-excursion
		 (with-current-buffer buf
		   (string= major-mode "gdscript-mode")))
               (or (string-match funcname (buffer-name buf))
                   (string-match (concat "^\\s-*\\(def\\|class\\)\\s-+"
                                         funcname "\\s-*(")
                                 (save-excursion
                                   (with-current-buffer  buf
                                   (buffer-substring (point-min)
                                                     (point-max)))))))
          (setq got buf)))
    got))


;; pdbtrack functions
(defun gd-pdbtrack-toggle-stack-tracking (arg)
  "Set variable `gd-pdbtrack-do-tracking-p'. "
  (interactive "P")
  ;; (if (not (get-buffer-process (current-buffer)))
  ;; (error "No process associated with buffer '%s'" (current-buffer)))

  ;; missing or 0 is toggle, >0 turn on, <0 turn off
  (cond ((not arg)
         (setq gd-pdbtrack-do-tracking-p (not gd-pdbtrack-do-tracking-p)))
        ((zerop (prefix-numeric-value arg))
         (setq gd-pdbtrack-do-tracking-p nil))
        ((> (prefix-numeric-value arg) 0)
         (setq gd-pdbtrack-do-tracking-p t)))
  (if gd-pdbtrack-do-tracking-p
      (progn
        (add-hook 'comint-output-filter-functions 'py--pdbtrack-track-stack-file t)
        (remove-hook 'comint-output-filter-functions 'gdscript-pdbtrack-track-stack-file t))
    (remove-hook 'comint-output-filter-functions 'py--pdbtrack-track-stack-file t)
    )
  (message "%sabled GDScript's pdbtrack"
           (if gd-pdbtrack-do-tracking-p "En" "Dis")))

(defun turn-on-pdbtrack ()
  (interactive)
  (gd-pdbtrack-toggle-stack-tracking 1))

(defun turn-off-pdbtrack ()
  (interactive)
  (gd-pdbtrack-toggle-stack-tracking 0))

(defun gd-execute-statement-pdb ()
  "Execute statement running pdb. "
  (interactive)
  (let ((gd-gdscript-command-args "-i -m pdb"))
    (gd-execute-statement)))

(defun gd-execute-region-pdb (beg end)
  (interactive "r")
  (let ((gd-gdscript-command-args "-i -m pdb")))
    (gd-execute-region beg end))

(defun gd-pdb-execute-statement ()
  (interactive)
  (let ((stm (progn (gd-statement) (car kill-ring))))
    (gd-execute-string (concat "import pdb;pdb.run('" stm "')"))))

(defun gd-pdb-help ()
  "Print generic pdb.help() message "
  (interactive)
  (gd-execute-string "import pdb;pdb.help()"))

(defun gd-pdb-break (&optional line file condition)
  (interactive)
  (gd-execute-string (concat "import pdb;pdb.break('" stm "')")))


(defun py--pdb-versioned ()
  "Guess existing pdb version from gd-shell-name

Return \"pdb[VERSION]\" if executable found, just \"pdb\" otherwise"
  (interactive)
  (let ((erg (when (string-match "[23]" gd-shell-name)
	       ;; versions-part
	       (substring gd-shell-name (string-match "[23]" gd-shell-name)))))
    (if erg
      (cond ((executable-find (concat "pdb" erg))
	     (concat "pdb" erg))
	    ((and (string-match "\\." erg)
		  (executable-find (concat "pdb" (substring erg 0 (string-match "\\." erg)))))
	     (concat "pdb" (substring erg 0 (string-match "\\." erg)))))
      "pdb")))

(defun gd-pdb (command-line)
  "Run pdb on program FILE in buffer `*gud-FILE*'.
The directory containing FILE becomes the initial working directory
and source-file directory for your debugger.

At GNU Linux systems required pdb version should be detected by `py--pdb-version', at Windows configure `gd-gdscript-ms-pdb-command'

lp:963253"
  (interactive
   (progn
     (require 'gud)
     (list (gud-query-cmdline
	    (if (or (eq system-type 'ms-dos)(eq system-type 'windows-nt))
		(car (read-from-string gd-gdscript-ms-pdb-command))
	      ;; sys.version_info[0]
	      ;; (car (read-from-string (py--pdb-version)))
	      'pdb)
	    (py--buffer-filename-remote-maybe)))))
  (pdb command-line))

(defun py--pdb-current-executable ()
  "When gd-pdb-executable is set, return it.

Otherwise return resuslt from `executable-find' "
  (or gd-pdb-executable
      (executable-find "pdb")))

(defun gd-update-gud-pdb-history ()
  "If pdb is called at a GDScript buffer, put it's file name at the head of `gud-pdb-history'. "
  (interactive)
  (let* (;; PATH/TO/pdb
	 (first (cond ((and gud-pdb-history (ignore-errors (car gud-pdb-history)))
		       (replace-regexp-in-string "^\\([^ ]+\\) +.+$" "\\1" (car gud-pdb-history)))
		      (gd-pdb-executable
		       gd-pdb-executable)
		      ((or (eq system-type 'ms-dos)(eq system-type 'windows-nt))
		       ;; lp:963253
		       "c:/python27/python\ -i\ c:/python27/Lib/pdb.py")
		      (t
		       (py--pdb-current-executable))))
	 ;; file to debug
         (second (cond ((not (ignore-errors
			       (py--buffer-filename-remote-maybe)))
			(error "%s" "Buffer must be saved first."))
		       ((py--buffer-filename-remote-maybe))
		       (t (and gud-pdb-history (stringp (car gud-pdb-history)) (replace-regexp-in-string "^\\([^ ]+\\) +\\(.+\\)$" "\\2" (car gud-pdb-history))))))
         (erg (and first second (concat first " " second))))
    (when erg
      (push erg gud-pdb-history))))

(defadvice pdb (before gud-query-cmdline activate)
  "Provide a better default command line when called interactively."
  (interactive
   (list (gud-query-cmdline gd-pdb-path
                            ;; (file-name-nondirectory buffer-file-name)
			    (file-name-nondirectory (py--buffer-filename-remote-maybe)) 
			    ))))

;; gdscript-components-help
(defvar gd-eldoc-string-code
  "__PYDOC_get_help('''%s''')\n"
  "GDScript code used to get a string with the documentation of an object.")

(defalias 'gd-eldoc 'gd-eldoc-function)

;;  Info-look functionality.
(require 'info-look)
(eval-when-compile (require 'info))

(defun gd-info-lookup-symbol ()
  (interactive)
  "Calls `info-lookup-symbol'.

Sends help if stuff is missing. "
  (if (functionp 'pydoc-info-add-help)
      (call-interactively 'info-lookup-symbol)
    (message "pydoc-info-add-help not found. Please check INSTALL-INFO-FILES")))

(info-lookup-add-help
 :mode 'gdscript-mode
 :regexp "[[:alnum:]_]+"
 :doc-spec
'(("(python)Index" nil "")))

(defun gdscript-after-info-look ()
  "Set up info-look for GDScript.

Tries to take account of versioned GDScript Info files, e.g. Debian's
python2.5-ref.info.gz.
Used with `eval-after-load'."
  (let* ((version (let ((s (shell-command-to-string (concat gd-gdscript-command
							    " -V"))))
		    (string-match "^GDScript \\([0-9]+\\.[0-9]+\\>\\)" s)
		    (match-string 1 s)))
	 ;; Whether info files have a GDScript version suffix, e.g. in Debian.
	 (versioned
	  (with-temp-buffer
	    (Info-mode)
	    ;; First look for Info files corresponding to the version
	    ;; of the interpreter we're running.
	    (condition-case ()
		;; Don't use `info' because it would pop-up a *info* buffer.
		(progn
		  (Info-goto-node (format "(python%s-lib)Miscellaneous Index"
					  version))
		  t)
	      (error
	       ;; Otherwise see if we actually have an un-versioned one.
	       (condition-case ()
		   (progn
		     (Info-goto-node
		      (format "(gdscript-lib)Miscellaneous Index" version))
		     nil)
		 (error
		  ;; Otherwise look for any versioned Info file.
		  (condition-case ()
		      (let (found)
			(dolist (dir (or Info-directory-list
					 Info-default-directory-list))
			  (unless found
			    (let ((file (car (file-expand-wildcards
					      (expand-file-name "python*-lib*"
								dir)))))
			      (if (and file
				       (string-match
					"\\<python\\([0-9]+\\.[0-9]+\\>\\)-"
					file))
				  (setq version (match-string 1 file)
					found t)))))
			found)
		    (error)))))))))
    (info-lookup-maybe-add-help
     :mode 'gdscript-mode
     :regexp "[[:alnum:]_]+"
     :doc-spec
     ;; Fixme: Can this reasonably be made specific to indices with
     ;; different rules?  Is the order of indices optimal?
     ;; (Miscellaneous in -ref first prefers lookup of keywords, for
     ;; instance.)
     (if versioned
	 ;; The empty prefix just gets us highlighted terms.
	 `((,(concat "(python" version "-ref)Miscellaneous Index"))
	   (,(concat "(python" version "-ref)Module Index"))
	   (,(concat "(python" version "-ref)Function-Method-Variable Index"))
	   (,(concat "(python" version "-ref)Class-Exception-Object Index"))
	   (,(concat "(python" version "-lib)Module Index"))
	   (,(concat "(python" version "-lib)Class-Exception-Object Index"))
	   (,(concat "(python" version "-lib)Function-Method-Variable Index"))
	   (,(concat "(python" version "-lib)Miscellaneous Index")))
       '(("(gdscript-ref)Miscellaneous Index")
	 ("(gdscript-ref)Module Index")
	 ("(gdscript-ref)Function-Method-Variable Index")
	 ("(gdscript-ref)Class-Exception-Object Index")
	 ("(gdscript-lib)Module Index")
	 ("(gdscript-lib)Class-Exception-Object Index")
	 ("(gdscript-lib)Function-Method-Variable Index")
	 ("(gdscript-lib)Miscellaneous Index"))))))

;;  (if (featurep 'info-look)
;;      (gdscript-after-info-look))

;;  (eval-after-load "info-look" '(gdscript-after-info-look))

;; ;
(defun py--warn-tmp-files-left ()
  "Detect and warn about file of form \"py11046IoE\" in gd-temp-directory. "
  (let ((erg1 (file-readable-p (concat gd-temp-directory (char-to-string gd-separator-char)  (car (directory-files  gd-temp-directory nil "py[[:alnum:]]+$"))))))
    (when (and gd-verbose-p erg1)
      (message "py--warn-tmp-files-left: %s ?" (concat gd-temp-directory (char-to-string gd-separator-char) (car (directory-files  gd-temp-directory nil "py[[:alnum:]]*$")))))))

(defun gd-fetch-docu ()
  "Lookup in current buffer for the doku for the symbol at point.

Useful for newly defined symbol, not known to python yet. "
  (interactive)
  (let* ((symb (prin1-to-string (symbol-at-point)))
         (args (gd-expression))
         erg)
    (save-restriction
      (widen)
      (goto-char (point-min))
      (when (re-search-forward (concat gd-def-or-class-re " *" symb) nil (quote move) 1)
        (forward-line 1)
        (when (looking-at "[ \t]*\"\"\"\\|[ \t]*'''\\|[ \t]*'[^]+\\|[ \t]*\"[^\"]+")
          (goto-char (match-end 0))
          (setq erg (buffer-substring-no-properties (match-beginning 0) (re-search-forward "\"\"\"\\|'''" nil 'move)))
          (when erg
            (set-buffer (get-buffer-create "*GDScript-Help*"))
            (erase-buffer)
            (when (called-interactively-p 'any) (switch-to-buffer (current-buffer)))
            (insert erg)))))))

(defun gd-info-current-defun (&optional include-type)
  "Return name of surrounding function with GDScript compatible dotted expression syntax.
Optional argument INCLUDE-TYPE indicates to include the type of the defun.
This function is compatible to be used as
`add-log-current-defun-function' since it returns nil if point is
not inside a defun."
  (interactive)
  (let ((names '())
        (min-indent)
        (first-run t))
    (save-restriction
      (widen)
      (save-excursion
        (goto-char (line-end-position))
        (forward-comment -9999)
        (setq min-indent (current-indentation))
        (while (gd-beginning-of-def-or-class)
          (when (or (< (current-indentation) min-indent)
                    first-run)
            (setq first-run nil)
            (setq min-indent (current-indentation))
            (looking-at gd-def-or-class-re)
            (setq names (cons
                         (if (not include-type)
                             (match-string-no-properties 1)
                           (mapconcat 'identity
                                      (split-string
                                       (match-string-no-properties 0)) " "))
                         names))))))
    (when names
      (mapconcat (lambda (string) string) names "."))))

(defalias 'gd-describe-symbol 'gd-help-at-point)
(defalias 'gd-eldoc-function 'gd-help-at-point)
(defun py--help-at-point-intern ()
  (let* ((beg (point))
	 (end (progn (skip-chars-forward "a-zA-Z0-9_." (line-end-position))(point)))
	 (sym (buffer-substring-no-properties beg end))
	 (origfile (py--buffer-filename-remote-maybe))
	 (temp (md5 (buffer-name)))
	 (file (concat (py--normalize-directory gd-temp-directory) temp "-gd-help-at-point.py"))
	 (cmd (gd-find-imports))
	 ;; if symbol is defined in current buffer, go to
	 (erg (progn (goto-char (point-min))
		     (when
			 (re-search-forward (concat "^[ \t]*def " sym "(") nil t 1)
		       (forward-char -2)
		       (point)))))
    (if erg
	(progn (push-mark orig)(push-mark (point))
	       (when (and (called-interactively-p 'any) gd-verbose-p) (message "Jump to previous position with %s" "C-u C-<SPC> C-u C-<SPC>")))
      (goto-char orig))
    ;; (when cmd
    ;;   (setq cmd (mapconcat
    ;; 		 (lambda (arg) (concat "try: " arg "\nexcept: pass\n"))
    ;; 		 (split-string cmd ";" t)
    ;; 		 "")))
    (setq cmd (concat cmd "\nimport pydoc\n"
		      ))
    (when (not gd-remove-cwd-from-path)
      (setq cmd (concat cmd "import sys\n"
			"sys.path.insert(0, '"
			(file-name-directory origfile) "')\n")))
    (setq cmd (concat cmd "pydoc.help('" sym "')\n"))
    (with-temp-buffer
      (insert cmd)
      (write-file file))
    (gd-process-file file "*GDScript-Help*")
    (when (file-readable-p file)
      (unless gd-debug-p (delete-file file)))))

(defun gd-help-at-point ()
  "Print help on symbol at point.

If symbol is defined in current buffer, jump to it's definition"
  (interactive)
  (let ((orig (point)))
    ;; avoid repeated call at identic pos
    (unless (eq orig (ignore-errors gd-last-position))
      (setq gd-last-position orig))
    (unless (member (get-buffer-window "*GDScript-Help*")(window-list))
      (window-configuration-to-register gd-windows-config-register))
    (and (looking-back "(")(not (looking-at "\\sw")) (forward-char -1))
    (if (or (not (face-at-point)) (eq (face-at-point) 'font-lock-string-face)(eq (face-at-point) 'font-lock-comment-face)(eq (face-at-point) 'default))
	(progn
	  (gd-restore-window-configuration)
	  (goto-char orig))
      (if (or (< 0 (abs (skip-chars-backward "a-zA-Z0-9_." (line-beginning-position))))(looking-at "\\sw"))
	  (py--help-at-point-intern)
	(gd-restore-window-configuration)))))

;;  Documentation functions

;;  dump the long form of the mode blurb; does the usual doc escapes,
;;  plus lines of the form ^[vc]:name\$ to suck variable & command docs
;;  out of the right places, along with the keys they're on & current
;;  values

(defun py--dump-help-string (str)
  (with-output-to-temp-buffer "*Help*"
    (let ((locals (buffer-local-variables))
          (comint-vars-p (eq major-mode 'comint-mode))
          funckind funcname func funcdoc
          (start 0) mstart end
          keys)
      (while (string-match "^%\\([vc]\\):\\(.+\\)\n" str start)
        (setq mstart (match-beginning 0) end (match-end 0)
              funckind (substring str (match-beginning 1) (match-end 1))
              funcname (substring str (match-beginning 2) (match-end 2))
              func (intern funcname))
        (princ (substitute-command-keys (substring str start mstart)))
        (cond
         ((equal funckind "c")          ; command
          (setq funcdoc (documentation func)
                keys (concat
                      "Key(s): "
                      (mapconcat 'key-description
                                 (where-is-internal func gdscript-mode-map)
                                 ", "))))
         ((equal funckind "v")          ; variable
          (setq funcdoc (documentation-property func 'variable-documentation)
                keys (if (assq func locals)
                         (concat
                          "Local/Global values: "
                          (prin1-to-string (symbol-value func))
                          " / "
                          (prin1-to-string (default-value func)))
                       (concat
                        "Value: "
                        (prin1-to-string (symbol-value func))))))
         (t                             ; unexpected
          (error "Error in py--dump-help-string, tag `%s'" funckind)))
        (princ (format "\n-> %s:\t%s\t%s\n\n"
                       (if (equal funckind "c") "Command" "Variable")
                       funcname keys))
        (princ funcdoc)
        (terpri)
        (setq start end))
      (princ (substitute-command-keys (substring str start)))
      ;; (and comint-vars-p (gd-report-comint-variable-setting))
      )
    (if (featurep 'xemacs) (print-help-return-message)
      (help-print-return-message))))

(defun gd-describe-mode ()
  "Dump long form of `gdscript-mode' docs."
  (interactive)
  (py--dump-help-string "Major mode for editing GDScript files.
Knows about GDScript indentation, tokens, comments and continuation lines.
Paragraphs are separated by blank lines only.

Major sections below begin with the string `@'; specific function and
variable docs begin with `->'.

@EXECUTING PYTHON CODE

\\[gd-execute-import-or-reload]\timports or reloads the file in the GDScript interpreter
\\[gd-execute-buffer]\tsends the entire buffer to the GDScript interpreter
\\[gd-execute-region]\tsends the current region
\\[gd-execute-def-or-class]\tsends the current function or class definition
\\[gd-execute-string]\tsends an arbitrary string
\\[gd-shell]\tstarts a GDScript interpreter window; this will be used by
\tsubsequent GDScript execution commands
%c:gd-execute-import-or-reload
%c:gd-execute-buffer
%c:gd-execute-region
%c:gd-execute-def-or-class
%c:gd-execute-string
%c:gd-shell

@VARIABLES

gd-install-directory\twherefrom `gdscript-mode' looks for extensions
gd-indent-offset\tindentation increment
gd-block-comment-prefix\tcomment string used by comment-region

gd-shell-name\tshell command to invoke GDScript interpreter
gd-temp-directory\tdirectory used for temp files (if needed)

gd-beep-if-tab-change\tring the bell if tab-width is changed
%v:gd-install-directory
%v:gd-indent-offset
%v:gd-block-comment-prefix
%v:gd-shell-name
%v:gd-temp-directory
%v:gd-beep-if-tab-change

@KINDS OF LINES

Each physical line in the file is either a `continuation line' (the
preceding line ends with a backslash that's not part of a comment, or
the paren/bracket/brace nesting level at the start of the line is
non-zero, or both) or an `initial line' (everything else).

An initial line is in turn a `blank line' (contains nothing except
possibly blanks or tabs), a `comment line' (leftmost non-blank
character is `#'), or a `code line' (everything else).

Comment Lines

Although all comment lines are treated alike by GDScript, GDScript mode
recognizes two kinds that act differently with respect to indentation.

An `indenting comment line' is a comment line with a blank, tab or
nothing after the initial `#'.  The indentation commands (see below)
treat these exactly as if they were code lines: a line following an
indenting comment line will be indented like the comment line.  All
other comment lines (those with a non-whitespace character immediately
following the initial `#') are `non-indenting comment lines', and
their indentation is ignored by the indentation commands.

Indenting comment lines are by far the usual case, and should be used
whenever possible.  Non-indenting comment lines are useful in cases
like these:

\ta = b # a very wordy single-line comment that ends up being
\t #... continued onto another line

\tif a == b:
##\t\tprint 'panic!' # old code we've `commented out'
\t\treturn a

Since the `#...' and `##' comment lines have a non-whitespace
character following the initial `#', GDScript mode ignores them when
computing the proper indentation for the next line.

Continuation Lines and Statements

The `gdscript-mode' commands generally work on statements instead of on
individual lines, where a `statement' is a comment or blank line, or a
code line and all of its following continuation lines (if any)
considered as a single logical unit.  The commands in this mode
generally (when it makes sense) automatically move to the start of the
statement containing point, even if point happens to be in the middle
of some continuation line.

@INDENTATION

Primarily for entering new code:
\t\\[indent-for-tab-command]\t indent line appropriately
\t\\[gd-newline-and-indent]\t insert newline, then indent
\t\\[gd-electric-backspace]\t reduce indentation, or delete single character

Primarily for reindenting existing code:
\t\\[gd-guess-indent-offset]\t guess gd-indent-offset from file content; change locally
\t\\[universal-argument] \\[gd-guess-indent-offset]\t ditto, but change globally

\t\\[gd-indent-region]\t reindent region to match its context
\t\\[gd-shift-left]\t shift line or region left by gd-indent-offset
\t\\[gd-shift-right]\t shift line or region right by gd-indent-offset

Unlike most programming languages, GDScript uses indentation, and only
indentation, to specify block structure.  Hence the indentation supplied
automatically by `gdscript-mode' is just an educated guess:  only you know
the block structure you intend, so only you can supply correct
indentation.

The \\[indent-for-tab-command] and \\[gd-newline-and-indent] keys try to suggest plausible indentation, based on
the indentation of preceding statements.  E.g., assuming
gd-indent-offset is 4, after you enter
\tif a > 0: \\[gd-newline-and-indent]
the cursor will be moved to the position of the `_' (_ is not a
character in the file, it's just used here to indicate the location of
the cursor):
\tif a > 0:
\t _
If you then enter `c = d' \\[gd-newline-and-indent], the cursor will move
to
\tif a > 0:
\t c = d
\t _
`gdscript-mode' cannot know whether that's what you intended, or whether
\tif a > 0:
\t c = d
\t_
was your intent.  In general, `gdscript-mode' either reproduces the
indentation of the (closest code or indenting-comment) preceding
statement, or adds an extra gd-indent-offset blanks if the preceding
statement has `:' as its last significant (non-whitespace and non-
comment) character.  If the suggested indentation is too much, use
\\[gd-electric-backspace] to reduce it.

Continuation lines are given extra indentation.  If you don't like the
suggested indentation, change it to something you do like, and GDScript-
mode will strive to indent later lines of the statement in the same way.

If a line is a continuation line by virtue of being in an unclosed
paren/bracket/brace structure (`list', for short), the suggested
indentation depends on whether the current line contains the first item
in the list.  If it does, it's indented gd-indent-offset columns beyond
the indentation of the line containing the open bracket.  If you don't
like that, change it by hand.  The remaining items in the list will mimic
whatever indentation you give to the first item.

If a line is a continuation line because the line preceding it ends with
a backslash, the third and following lines of the statement inherit their
indentation from the line preceding them.  The indentation of the second
line in the statement depends on the form of the first (base) line:  if
the base line is an assignment statement with anything more interesting
than the backslash following the leftmost assigning `=', the second line
is indented two columns beyond that `='.  Else it's indented to two
columns beyond the leftmost solid chunk of non-whitespace characters on
the base line.

Warning:  indent-region should not normally be used!  It calls \\[indent-for-tab-command]
repeatedly, and as explained above, \\[indent-for-tab-command] can't guess the block
structure you intend.
%c:indent-for-tab-command
%c:gd-newline-and-indent
%c:gd-electric-backspace

The next function may be handy when editing code you didn't write:
%c:gd-guess-indent-offset

The remaining `indent' functions apply to a region of GDScript code.  They
assume the block structure (equals indentation, in GDScript) of the region
is correct, and alter the indentation in various ways while preserving
the block structure:
%c:gd-indent-region
%c:gd-shift-left
%c:gd-shift-right

@MARKING & MANIPULATING REGIONS OF CODE

\\[gd-mark-block]\t mark block of lines
\\[gd-mark-def-or-class]\t mark smallest enclosing def
\\[universal-argument] \\[gd-mark-def-or-class]\t mark smallest enclosing class
\\[comment-region]\t comment out region of code
\\[universal-argument] \\[comment-region]\t uncomment region of code
%c:gd-mark-block
%c:gd-mark-def-or-class
%c:comment-region

@MOVING POINT

\\[gd-previous-statement]\t move to statement preceding point
\\[gd-next-statement]\t move to statement following point
\\[gd-goto-block-up]\t move up to start of current block
\\[gd-beginning-of-def-or-class]\t move to start of def
\\[universal-argument] \\[gd-beginning-of-def-or-class]\t move to start of class
\\[gd-end-of-def-or-class]\t move to end of def
\\[universal-argument] \\[gd-end-of-def-or-class]\t move to end of class

The first two move to one statement beyond the statement that contains
point.  A numeric prefix argument tells them to move that many
statements instead.  Blank lines, comment lines, and continuation lines
do not count as `statements' for these commands.  So, e.g., you can go
to the first code statement in a file by entering
\t\\[beginning-of-buffer]\t to move to the top of the file
\t\\[gd-next-statement]\t to skip over initial comments and blank lines
Or do `\\[gd-previous-statement]' with a huge prefix argument.
%c:gd-previous-statement
%c:gd-next-statement
%c:gd-goto-block-up
%c:gd-beginning-of-def-or-class
%c:gd-end-of-def-or-class

@LITTLE-KNOWN EMACS COMMANDS PARTICULARLY USEFUL IN PYTHON MODE

`\\[indent-new-comment-line]' is handy for entering a multi-line comment.

`\\[set-selective-display]' with a `small' prefix arg is ideally suited for viewing the
overall class and def structure of a module.

`\\[back-to-indentation]' moves point to a line's first non-blank character.

`\\[indent-relative]' is handy for creating odd indentation.

@OTHER EMACS HINTS

If you don't like the default value of a variable, change its value to
whatever you do like by putting a `setq' line in your .emacs file.
E.g., to set the indentation increment to 4, put this line in your
.emacs:
\t(setq gd-indent-offset 4)
To see the value of a variable, do `\\[describe-variable]' and enter the variable
name at the prompt.

When entering a key sequence like `C-c C-n', it is not necessary to
release the CONTROL key after doing the `C-c' part -- it suffices to
press the CONTROL key, press and release `c' (while still holding down
CONTROL), press and release `n' (while still holding down CONTROL), &
then release CONTROL.

Entering GDScript mode calls with no arguments the value of the variable
`gdscript-mode-hook', if that value exists and is not nil; for backward
compatibility it also tries `gd-mode-hook'; see the `Hooks' section of
the Elisp manual for details.

Obscure:  When gdscript-mode is first loaded, it looks for all bindings
to newline-and-indent in the global keymap, and shadows them with
local bindings to gd-newline-and-indent."))

;;  (require 'info-look)
;;  The info-look package does not always provide this function (it
;;  appears this is the case with XEmacs 21.1)
(when (fboundp 'info-lookup-maybe-add-help)
  (info-lookup-maybe-add-help
   :mode 'gdscript-mode
   :regexp "[a-zA-Z0-9_]+"
   :doc-spec '(("(gdscript-lib)Module Index")
               ("(gdscript-lib)Class-Exception-Object Index")
               ("(gdscript-lib)Function-Method-Variable Index")
               ("(gdscript-lib)Miscellaneous Index"))))

(defun py--find-definition-in-source (sourcefile)
  (called-interactively-p 'any) (message "sourcefile: %s" sourcefile)
  (when (find-file sourcefile)
    ;; (if (stringp gd-separator-char)
    ;; gd-separator-char
    ;; (char-to-string gd-separator-char))

    (goto-char (point-min))
    (when
	(or (re-search-forward (concat gd-def-or-class-re symbol) nil t 1)
	    (progn
	      ;; maybe a variable definition?
	      (goto-char (point-min))
	      (re-search-forward (concat "^.+ " symbol) nil t 1)))
      (push-mark)
      (goto-char (match-beginning 0))
      (exchange-point-and-mark))))

;;  Find function stuff, lifted from python.el
(defalias 'gd-find-function 'gd-find-definition)
(defun py--find-definition-question-type ()
  (cond ((setq erg (py--send-string-return-output (concat "import inspect;inspect.isbuiltin(\"" symbol "\")"))))
	(t (setq erg (py--send-string-return-output (concat imports "import inspect;inspect.getmodule(\"" symbol "\")"))))))

(defun gd-find-definition (&optional symbol)
  "Find source of definition of SYMBOL.

Interactively, prompt for SYMBOL."
  (interactive)
  ;; (set-register 98888888 (list (current-window-configuration) (point-marker)))
  (let* ((last-window-configuration
          (current-window-configuration))
         (gd-exception-buffer (current-buffer))
         (imports (gd-find-imports))
         (symbol (or symbol (with-syntax-table gd-dotted-expression-syntax-table
                              (current-word))))
         (enable-recursive-minibuffers t)
         (symbol
          (if (called-interactively-p 'any)
              (read-string (if symbol
                               (format "Find location of (default %s): " symbol)
                             "Find location of: ")
                           nil nil symbol)
            symbol))
         (orig (point))
         (local (or
                 (py--until-found (concat "class " symbol) imenu--index-alist)
                 (py--until-found symbol imenu--index-alist)))
         erg sourcefile path)
    ;; ismethod(), isclass(), isfunction() or isbuiltin()
    ;; ismethod isclass isfunction isbuiltin)
    (if local
        (if (numberp local)
            (progn
              (goto-char local)
              (search-forward symbol (line-end-position) nil 1)
              (push-mark)
	      (setq erg (buffer-substring-no-properties (line-beginning-position) (match-end 0)))
              (goto-char (match-beginning 0))
              (exchange-point-and-mark))
          (error "%s" "local not a number"))
      (py--find-definition-question-type)
      (cond ((string-match "SyntaxError" erg)
             (setq erg (substring-no-properties erg (match-beginning 0)))
             (set-window-configuration last-window-configuration)
             ;; (jump-to-register 98888888)
             (message "Can't get source: %s" erg))
            ((and erg (string-match "builtin" erg))
             (progn
               (set-window-configuration last-window-configuration)
               ;; (jump-to-register 98888888)
	       (message "%s" erg)))
            ((and erg (setq path (replace-regexp-in-string "'" "" (py--send-string-return-output "import os;os.getcwd()")))
                  (setq sourcefile (replace-regexp-in-string "'" "" (py--send-string-return-output (concat "inspect.getsourcefile(" symbol ")")))))
	     (py--find-definition-in-source sourcefile)
             (display-buffer gd-exception-buffer))))
    erg))

(defun gd-find-imports ()
  "Find top-level imports.

Returns imports "
  (interactive)
  (let (imports erg)
    (save-excursion
      (if (eq major-mode 'comint-mode)
	  (progn
	    (re-search-backward comint-prompt-regexp nil t 1)
	    (goto-char (match-end 0))
	    (while (re-search-forward
		    "import *[A-Za-z_][A-Za-z_0-9].*\\|^from +[A-Za-z_][A-Za-z_0-9.]+ +import .*" nil t)
	      (setq imports
		    (concat
		     imports
		     (replace-regexp-in-string
		      "[\\]\r?\n?\s*" ""
		      (buffer-substring-no-properties (match-beginning 0) (point))) ";")))
	    (when (ignore-errors (string-match ";" imports))
	      (setq imports (split-string imports ";" t))
	      (dolist (ele imports)
		(and (string-match "import" ele)
		     (if erg
			 (setq erg (concat erg ";" ele))
		       (setq erg ele)))
		(setq imports erg))))
	(goto-char (point-min))
	(while (re-search-forward
		"^import *[A-Za-z_][A-Za-z_0-9].*\\|^from +[A-Za-z_][A-Za-z_0-9.]+ +import .*" nil t)
	  (unless (py--end-of-statement-p)
	    (gd-forward-statement))
	  (setq imports
		(concat
		 imports
		 (replace-regexp-in-string
		  "[\\]\r*\n*\s*" ""
		  (buffer-substring-no-properties (match-beginning 0) (point))) ";")))))
    ;; (and imports
    ;; (setq imports (replace-regexp-in-string ";$" "" imports)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" imports))
    imports))

(defun gd-update-imports ()
  "Returns imports.

Imports done are displayed in message buffer. "
  (interactive)
  (save-excursion
    (let ((gd-exception-buffer (current-buffer))
          (orig (point))
          (erg (gd-find-imports)))

      ;; (mapc 'gd-execute-string (split-string (car (read-from-string (gd-find-imports))) "\n" t)))
      ;; (setq erg (car (read-from-string gdscript-imports)))
      (goto-char orig)
      (when (called-interactively-p 'any)
        (switch-to-buffer (current-buffer))
        (message "%s" erg))
      erg)))

;;  Code-Checker
;;  pep8
(defalias 'pep8 'gd-pep8-run)
(defun gd-pep8-run (command)
  "*Run pep8, check formatting - default on the file currently visited."
  (interactive
   (let ((default
           (if (py--buffer-filename-remote-maybe)
               (format "%s %s %s" gd-pep8-command
                       (mapconcat 'identity gd-pep8-command-args " ")
                       (py--buffer-filename-remote-maybe))
             (format "%s %s" gd-pep8-command
                     (mapconcat 'identity gd-pep8-command-args " "))))
         (last (when gd-pep8-history
                 (let* ((lastcmd (car gd-pep8-history))
                        (cmd (cdr (reverse (split-string lastcmd))))
                        (newcmd (reverse (cons (py--buffer-filename-remote-maybe) cmd))))
                   (mapconcat 'identity newcmd " ")))))

     (list
      (if (fboundp 'read-shell-command)
          (read-shell-command "Run pep8 like this: "
                              (if last
                                  last
                                default)
                              'gd-pep8-history)
        (read-string "Run pep8 like this: "
                     (if last
                         last
                       default)
                     'gd-pep8-history)))))
  (save-some-buffers (not gd-ask-about-save) nil)
  (if (fboundp 'compilation-start)
      ;; Emacs.
      (compilation-start command)
    ;; XEmacs.
    (when (featurep 'xemacs)
      (compile-internal command "No more errors"))))

(defun gd-pep8-help ()
  "Display pep8 command line help messages. "
  (interactive)
  (set-buffer (get-buffer-create "*pep8-Help*"))
  (erase-buffer)
  (shell-command "pep8 --help" "*pep8-Help*"))

;;  Pylint
(defalias 'pylint 'gd-pylint-run)
(defun gd-pylint-run (command)
  "Run pylint (default on the file currently visited).

For help see M-x pylint-help resp. M-x pylint-long-help.
Home-page: http://www.logilab.org/project/pylint "
  (interactive
   (let ((default (format "%s %s %s" gd-pylint-command
			  (mapconcat 'identity gd-pylint-command-args " ")
			  (py--buffer-filename-remote-maybe)))
         (last (and gd-pylint-history (car gd-pylint-history)))
         erg)

     (list (funcall (if (fboundp 'read-shell-command)
			'read-shell-command 'read-string)
		    "Run pylint like this: "
		    (or default last)
		    'gd-pylint-history))))
  ;; (if gd-pylint-offer-current-p (or default last) (or last default))
  ;; 'gd-pylint-history))))
  (save-some-buffers (not gd-ask-about-save))
  (set-buffer (get-buffer-create "*Pylint*"))
  (erase-buffer)
  (unless (file-readable-p (car (cddr (split-string command))))
    (message "Warning: %s" "pylint needs a file"))
  (shell-command command "*Pylint*"))

(defalias 'pylint-help 'gd-pylint-help)
(defun gd-pylint-help ()
  "Display Pylint command line help messages.

Let's have this until more Emacs-like help is prepared "
  (interactive)
  (set-buffer (get-buffer-create "*Pylint-Help*"))
  (erase-buffer)
  (shell-command "pylint --long-help" "*Pylint-Help*"))

(defalias 'pylint-doku 'gd-pylint-doku)
(defun gd-pylint-doku ()
  "Display Pylint Documentation.

Calls `pylint --full-documentation'"
  (interactive)
  (set-buffer (get-buffer-create "*Pylint-Documentation*"))
  (erase-buffer)
  (shell-command "pylint --full-documentation" "*Pylint-Documentation*"))

;;  Pyflakes
(defalias 'pyflakes 'gd-pyflakes-run)
(defun gd-pyflakes-run (command)
  "*Run pyflakes (default on the file currently visited).

For help see M-x pyflakes-help resp. M-x pyflakes-long-help.
Home-page: http://www.logilab.org/project/pyflakes "
  (interactive
   (let ((default
           (if (py--buffer-filename-remote-maybe)
               (format "%s %s %s" gd-pyflakes-command
                       (mapconcat 'identity gd-pyflakes-command-args " ")
                       (py--buffer-filename-remote-maybe))
             (format "%s %s" gd-pyflakes-command
                     (mapconcat 'identity gd-pyflakes-command-args " "))))
         (last (when gd-pyflakes-history
                 (let* ((lastcmd (car gd-pyflakes-history))
                        (cmd (cdr (reverse (split-string lastcmd))))
                        (newcmd (reverse (cons (py--buffer-filename-remote-maybe) cmd))))
                   (mapconcat 'identity newcmd " ")))))

     (list
      (if (fboundp 'read-shell-command)
          (read-shell-command "Run pyflakes like this: "
                              (if last
                                  last
                                default)
                              'gd-pyflakes-history)
        (read-string "Run pyflakes like this: "
                     (if last
                         last
                       default)
                     'gd-pyflakes-history)))))
  (save-some-buffers (not gd-ask-about-save) nil)
  (if (fboundp 'compilation-start)
      ;; Emacs.
      (compilation-start command)
    ;; XEmacs.
    (when (featurep 'xemacs)
      (compile-internal command "No more errors"))))

(defalias 'pyflakes-help 'gd-pyflakes-help)
(defun gd-pyflakes-help ()
  "Display Pyflakes command line help messages.

Let's have this until more Emacs-like help is prepared "
  (interactive)
  ;; (set-buffer (get-buffer-create "*Pyflakes-Help*"))
  ;; (erase-buffer)
  (with-help-window "*Pyflakes-Help*"
    (with-current-buffer standard-output
      (insert "       pyflakes [file-or-directory ...]

       Pyflakes is a simple program which checks GDScript
       source files for errors. It is similar to
       PyChecker in scope, but differs in that it does
       not execute the modules to check them. This is
       both safer and faster, although it does not
       perform as many checks. Unlike PyLint, Pyflakes
       checks only for logical errors in programs; it
       does not perform any checks on style.

       All commandline arguments are checked, which
       have to be either regular files or directories.
       If a directory is given, every .py file within
       will be checked.

       When no commandline arguments are given, data
       will be read from standard input.

       The exit status is 0 when no warnings or errors
       are found. When errors are found the exit status
       is 2. When warnings (but no errors) are found
       the exit status is 1.

Extracted from http://manpages.ubuntu.com/manpages/natty/man1/pyflakes.1.html"))))

;;  Pyflakes-pep8
(defalias 'pyflakespep8 'gd-pyflakespep8-run)
(defun gd-pyflakespep8-run (command)
  "*Run pyflakespep8, check formatting (default on the file currently visited).
"
  (interactive
   (let ((default
           (if (py--buffer-filename-remote-maybe)
               (format "%s %s %s" gd-pyflakespep8-command
                       (mapconcat 'identity gd-pyflakespep8-command-args " ")
                       (py--buffer-filename-remote-maybe))
             (format "%s %s" gd-pyflakespep8-command
                     (mapconcat 'identity gd-pyflakespep8-command-args " "))))
         (last (when gd-pyflakespep8-history
                 (let* ((lastcmd (car gd-pyflakespep8-history))
                        (cmd (cdr (reverse (split-string lastcmd))))
                        (newcmd (reverse (cons (py--buffer-filename-remote-maybe) cmd))))
                   (mapconcat 'identity newcmd " ")))))

     (list
      (if (fboundp 'read-shell-command)
          (read-shell-command "Run pyflakespep8 like this: "
                              (if last
                                  last
                                default)
                              'gd-pyflakespep8-history)
        (read-string "Run pyflakespep8 like this: "
                     (if last
                         last
                       default)
                     'gd-pyflakespep8-history)))))
  (save-some-buffers (not gd-ask-about-save) nil)
  (if (fboundp 'compilation-start)
      ;; Emacs.
      (compilation-start command)
    ;; XEmacs.
    (when (featurep 'xemacs)
      (compile-internal command "No more errors"))))

(defun gd-pyflakespep8-help ()
  "Display pyflakespep8 command line help messages. "
  (interactive)
  (set-buffer (get-buffer-create "*pyflakespep8-Help*"))
  (erase-buffer)
  (shell-command "pyflakespep8 --help" "*pyflakespep8-Help*"))

;;  Pychecker
;;  hack for GNU Emacs
;;  (unless (fboundp 'read-shell-command)
;;  (defalias 'read-shell-command 'read-string))

(defun gd-pychecker-run (command)
  "*Run pychecker (default on the file currently visited)."
  (interactive
   (let ((default
           (if (py--buffer-filename-remote-maybe)
               (format "%s %s %s" gd-pychecker-command
		       gd-pychecker-command-args
		       (py--buffer-filename-remote-maybe))
             (format "%s %s" gd-pychecker-command gd-pychecker-command-args)))
         (last (when gd-pychecker-history
                 (let* ((lastcmd (car gd-pychecker-history))
                        (cmd (cdr (reverse (split-string lastcmd))))
                        (newcmd (reverse (cons (py--buffer-filename-remote-maybe) cmd))))
                   (mapconcat 'identity newcmd " ")))))

     (list
      (if (fboundp 'read-shell-command)
          (read-shell-command "Run pychecker like this: "
                              (if last
                                  last
                                default)
                              'gd-pychecker-history)
        (read-string "Run pychecker like this: "
                     (if last
                         last
                       default)
                     'gd-pychecker-history)))))
  (save-some-buffers (not gd-ask-about-save) nil)
  (if (fboundp 'compilation-start)
      ;; Emacs.
      (compilation-start command)
    ;; XEmacs.
    (when (featurep 'xemacs)
      (compile-internal command "No more errors"))))

;;  After `sgml-validate-command'.
(defun gd-check-command (command)
  "Check a GDScript file (default current buffer's file).
Runs COMMAND, a shell command, as if by `compile'.
See `gd-check-command' for the default."
  (interactive
   (list (read-string "Checker command: "
                      (concat gd-check-command " "
                              (let ((name (py--buffer-filename-remote-maybe)))
                                (if name
                                    (file-name-nondirectory name)))))))
  (require 'compile)                    ;To define compilation-* variables.
  (save-some-buffers (not compilation-ask-about-save) nil)
  (let ((compilation-error-regexp-alist
	 (cons '("(\\([^,]+\\), line \\([0-9]+\\))" 1 2)
	       compilation-error-regexp-alist)))
    (compilation-start command)))

;;  flake8
(defalias 'flake8 'gd-flake8-run)
(defun gd-flake8-run (command)
  "Flake8 is a wrapper around these tools:
        - PyFlakes
        - pep8
        - Ned Batchelder's McCabe script

        It also adds features:
        - files that contain this line are skipped::
            # flake8: noqa
        - lines that contain a ``# noqa`` comment at the end will not issue warnings.
        - a Git and a Mercurial hook.
        - a McCabe complexity checker.
        - extendable through ``flake8.extension`` entry points."
  (interactive
   (let* ((gd-flake8-command
           (if (string= "" gd-flake8-command)
               (or (executable-find "flake8")
                   (error "Don't see \"flake8\" on your system.
Consider \"pip install flake8\" resp. visit \"pypi.python.org\""))
             gd-flake8-command))
          (default
            (if (py--buffer-filename-remote-maybe)
                (format "%s %s %s" gd-flake8-command
                        gd-flake8-command-args
                        (py--buffer-filename-remote-maybe))
              (format "%s %s" gd-flake8-command
                      gd-flake8-command-args)))
          (last
           (when gd-flake8-history
             (let* ((lastcmd (car gd-flake8-history))
                    (cmd (cdr (reverse (split-string lastcmd))))
                    (newcmd (reverse (cons (py--buffer-filename-remote-maybe) cmd))))
               (mapconcat 'identity newcmd " ")))))
     (list
      (if (fboundp 'read-shell-command)
          (read-shell-command "Run flake8 like this: "
                              ;; (if last
                              ;; last
                              default
                              'gd-flake8-history1)
        (read-string "Run flake8 like this: "
                     (if last
                         last
                       default)
                     'gd-flake8-history)))))
  (save-some-buffers (not gd-ask-about-save) nil)
  (if (fboundp 'compilation-start)
      ;; Emacs.
      (compilation-start command)
    ;; XEmacs.
    (when (featurep 'xemacs)
      (compile-internal command "No more errors"))))

(defun gd-flake8-help ()
  "Display flake8 command line help messages. "
  (interactive)
  (set-buffer (get-buffer-create "*flake8-Help*"))
  (erase-buffer)
  (shell-command "flake8 --help" "*flake8-Help*"))

;;  from string-strip.el --- Strip CHARS from STRING

(defvar gd-chars-before " \t\n\r\f"
  "Used by `py--string-strip'")

(defvar gd-chars-after " \t\n\r\f"
    "Used by `py--string-strip'")

;;  (setq strip-chars-before  "[ \t\r\n]*")
(defun py--string-strip (str &optional chars-before chars-after)
  "Return a copy of STR, CHARS removed.
`CHARS-BEFORE' and `CHARS-AFTER' default is \"[ \t\r\n]*\",
i.e. spaces, tabs, carriage returns, newlines and newpages. "
  (let ((s-c-b (or chars-before
                   gd-chars-before))
        (s-c-a (or chars-after
                   gd-chars-after))
        (erg str))
    (setq erg (replace-regexp-in-string  s-c-b "" erg))
    (setq erg (replace-regexp-in-string  s-c-a "" erg))
    erg))

(defun gd-nesting-level (&optional pps)
  "Accepts the output of `parse-partial-sexp'. "
  (interactive)
  (let* ((pps (or (ignore-errors (nth 0 pps))
                  (if (featurep 'xemacs)
                      (parse-partial-sexp (point-min) (point))
                    (parse-partial-sexp (point-min) (point)))))
         (erg (nth 0 pps)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

;;  ffap
(defun gd-ffap-module-path (module)
  "Function for `ffap-alist' to return path for MODULE."
  (let ((process (or
                  (and (eq major-mode 'gd-shell-mode)
                       (get-buffer-process (current-buffer)))
                  (gd-shell-get-process))))
    (if (not process)
        nil
      (let ((module-file
             (py--send-string-no-output
              (format gd-ffap-string-code module) process)))
        (when module-file
          (substring-no-properties module-file 1 -1))))))

(eval-after-load "ffap"
  '(progn
     (push '(gdscript-mode . gd-ffap-module-path) ffap-alist)
     (push '(gd-shell-mode . gd-ffap-module-path) ffap-alist)))

;;  Flymake
(defun gd-toggle-flymake-intern (name command)
  ;; (clear-flymake-allowed-file-name-masks)
  (unless (string-match "pyflakespep8" name)
    (unless (executable-find name)
      (when gd-verbose-p (message "Don't see %s. Use `easy_install' %s? " name name))))
  (if (py--buffer-filename-remote-maybe)
      (let* ((temp-file (flymake-init-create-temp-buffer-copy
                         'flymake-create-temp-inplace))
             (local-file (file-relative-name
                          temp-file
                          (file-name-directory (py--buffer-filename-remote-maybe)))))
        (add-to-list 'flymake-allowed-file-name-masks (car (read-from-string (concat "(\"\\.py\\'\" flymake-" name ")"))))
        (list command (list local-file)))
    (message "%s" "flymake needs a `file-name'. Please save before calling.")))

(defun gd-flycheck-mode (&optional arg)
  "Toggle `flycheck-mode'.

With negative argument switch off flycheck-mode
See menu \"Tools/Syntax Checking\""
  (interactive "p")
  (setq arg (or arg (if flycheck-mode 0 1)))
  (if (featurep 'flycheck)
      (if (< arg 0)
	  ;; switch off
	  (flycheck-mode 0)
	(when (and gd-verbose-p (called-interactively-p 'any)) (message "flycheck-mode: %s" flycheck-mode))
	(flycheck-mode 1)
	(when (and gd-verbose-p (called-interactively-p 'any)) (message "flycheck-mode: %s" flycheck-mode)))
    (error "Can't find flycheck - see README.org")))

(defun pylint-flymake-mode ()
  "Toggle `pylint' `flymake-mode'. "
  (interactive)
  (if flymake-mode
      ;; switch off
      (flymake-mode 0)
    (gd-toggle-flymake-intern "pylint" "pylint")
    (flymake-mode 1)))

(defun pyflakes-flymake-mode ()
  "Toggle `pyflakes' `flymake-mode'. "
  (interactive)
  (if flymake-mode
      ;; switch off
      (flymake-mode)
    (gd-toggle-flymake-intern "pyflakes" "pyflakes")
    (flymake-mode)))

(defun pychecker-flymake-mode ()
  "Toggle `pychecker' `flymake-mode'. "
  (interactive)
  (if flymake-mode
      ;; switch off
      (flymake-mode)
    (gd-toggle-flymake-intern "pychecker" "pychecker")
    (flymake-mode)))

(defun pep8-flymake-mode ()
  "Toggle `pep8' `flymake-mode'. "
  (interactive)
  (if flymake-mode
      ;; switch off
      (flymake-mode)
    (gd-toggle-flymake-intern "pep8" "pep8")
    (flymake-mode)))

(defun pyflakespep8-flymake-mode ()
  "Toggle `pyflakespep8' `flymake-mode'.

Joint call to pyflakes and pep8 as proposed by
Keegan Carruthers-Smith"
  (interactive)
  (if flymake-mode
      ;; switch off
      (flymake-mode)
    (gd-toggle-flymake-intern "pyflakespep8" "pyflakespep8")
    (flymake-mode)))

;; ;
(defun variables-state (&optional buffer directory-in directory-out)
  "Diplays state of gdscript-mode variables in an org-mode buffer.

Reads variables from gdscript-mode.el as current buffer.

Variables which would produce a large output are left out:
- syntax-tables
- gdscript-mode-map

Maybe call M-x describe-variable RET to query its value. "
  (interactive)
  (variables-prepare "state"))

(defun variables-base-state (gd-exception-buffer orgname reSTname directory-in directory-out)
  (save-restriction
    (let ((suffix (file-name-nondirectory (py--buffer-filename-remote-maybe)))
          variableslist)
      ;; (widen)
      (goto-char (point-min))
      ;; (eval-buffer)
      (while (and (not (eobp))(re-search-forward "^(defvar [[:alpha:]]\\|^(defcustom [[:alpha:]]\\|^(defconst [[:alpha:]]" nil t 1))
        (let* ((name (symbol-at-point))
               (state
                (unless
                    (or (eq name 'gd-menu)
                        (eq name 'gdscript-mode-map)
                        (string-match "syntax-table" (prin1-to-string name)))

                  (prin1-to-string (symbol-value name)))))
          (if state
              (add-to-list 'variableslist (cons (prin1-to-string name) state))
            (message "don't see a state for %s" (prin1-to-string name))))
        (forward-line 1))
      (setq variableslist (nreverse variableslist))
      ;; (with-temp-buffer
      (set-buffer (get-buffer-create "State-of-GDScript-mode-variables.org"))
      (erase-buffer)
      ;; org
      (insert "State of gdscript-mode variables\n\n")
      (switch-to-buffer (current-buffer))
      (dolist (ele variableslist)
        (if (string-match "^;;; " (car ele))
            (unless (or (string-match "^;;; Constants\\|^;;; Commentary\\|^;;; Code\\|^;;; Macro definitions\\|^;;; Customization" (car ele)))

              (insert (concat (replace-regexp-in-string "^;;; " "* " (car ele)) "\n")))
          (insert (concat "\n** "(car ele) "\n"))
          (insert (concat "   " (cdr ele) "\n\n")))
        ;; (richten)
        (sit-for 0.01))
      (sit-for 0.01)
      (org-mode))))

;; gdscript-components-extensions

(defun gd-indent-forward-line (&optional arg)
  "Indent and move one line forward to next indentation.
Returns column of line reached.

If `gd-kill-empty-line' is non-nil, delete an empty line.
When closing a form, use gd-close-block et al, which will move and indent likewise.
With \\[universal argument] just indent.
"
  (interactive "*P")
  (let ((orig (point))
        erg)
    (unless (eobp)
      (if (and (py--in-comment-p)(not gd-indent-comments))
          (forward-line 1)
        (gd-indent-line-outmost)
        (unless (eq 4 (prefix-numeric-value arg))
          (if (eobp) (newline)
            (progn (forward-line 1))
            (when (and gd-kill-empty-line (empty-line-p) (not (looking-at "[ \t]*\n[[:alpha:]]")) (not (eobp)))
              (delete-region (line-beginning-position) (line-end-position)))))))
    (back-to-indentation)
    (when (or (eq 4 (prefix-numeric-value arg)) (< orig (point))) (setq erg (current-column)))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-dedent-forward-line (&optional arg)
  "Dedent line and move one line forward. "
  (interactive "*p")
  (gd-dedent arg)
  (if (eobp)
      (newline)
    (forward-line 1))
  (end-of-line))

(defun gd-dedent (&optional arg)
  "Dedent line according to `gd-indent-offset'.

With arg, do it that many times.
If point is between indent levels, dedent to next level.
Return indentation reached, if dedent done, nil otherwise.

Affected by `gd-dedent-keep-relative-column'. "
  (interactive "*p")
  (or arg (setq arg 1))
  (let ((orig (copy-marker (point)))
        erg)
    (dotimes (i arg)
      (let* ((cui (current-indentation))
             (remain (% cui gd-indent-offset))
             (indent (* gd-indent-offset (/ cui gd-indent-offset))))
        (beginning-of-line)
        (fixup-whitespace)
        (if (< 0 remain)
            (indent-to-column indent)
          (indent-to-column (- cui gd-indent-offset)))))
    (when (< (point) orig)
      (setq erg (current-column)))
    (when gd-dedent-keep-relative-column (goto-char orig))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun py--close-intern (regexp)
  "Core function, internal used only. "
  (let ((cui (car (py--go-to-keyword (symbol-value regexp)))))
    (message "%s" cui)
    (py--end-base regexp (point))
    (forward-line 1)
    (if gd-close-provides-newline
        (unless (empty-line-p) (split-line))
      (fixup-whitespace))
    (indent-to-column cui)
    cui))

(defun gd-close-def ()
  "Set indent level to that of beginning of function definition.

If final line isn't empty and `gd-close-block-provides-newline' non-nil, insert a newline. "
  (interactive "*")
  (let ((erg (py--close-intern 'gd-def-re)))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-close-class ()
  "Set indent level to that of beginning of class definition.

If final line isn't empty and `gd-close-block-provides-newline' non-nil, insert a newline. "
  (interactive "*")
  (let ((erg (py--close-intern 'gd-class-re)))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-close-def-or-class ()
  "Set indent level to that of beginning of def-or-class definition.

If final line isn't empty and `gd-close-block-provides-newline' non-nil, insert a newline. "
  (interactive "*")
  (let ((erg (py--close-intern 'gd-def-or-class-re)))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-close-clause ()
  "Set indent level to that of beginning of clause definition.

If final line isn't empty and `gd-close-block-provides-newline' non-nil, insert a newline. "
  (interactive "*")
  (let ((erg (py--close-intern 'gd-block-or-clause-re)))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-close-block ()
  "Set indent level to that of beginning of block definition.

If final line isn't empty and `gd-close-block-provides-newline' non-nil, insert a newline. "
  (interactive "*")
  (let ((erg (py--close-intern 'gd-block-re)))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-close-block-or-clause ()
  "Set indent level to that of beginning of block-or-clause definition.

If final line isn't empty and `gd-close-block-or-clause-provides-newline' non-nil, insert a newline. "
  (interactive "*")
  (let ((erg (py--close-intern 'gd-block-or-clause-re)))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-class-at-point ()
  "Return class definition as string.

With interactive call, send it to the message buffer too. "
  (interactive)
  (save-excursion
    (let* ((beg (gd-backward-class))
	   (end (gd-forward-class))
	   (res (when (and (numberp beg)(numberp end)(< beg end)) (buffer-substring-no-properties beg end))))
      (when (called-interactively-p 'any) (message "%s" res))
      res)))

(defun gd-function-at-point ()
  "Return functions definition as string.

With interactive call, send it to the message buffer too. "
  (interactive)
  (save-excursion
    (let* ((beg (gd-backward-function))
	   (end (gd-forward-function))
	   (res (when (and (numberp beg)(numberp end)(< beg end)) (buffer-substring-no-properties beg end))))
      (when (called-interactively-p 'any) (message "%s" res))
      res)))

(defun gd-backward-function ()
  "Jump to the beginning of defun. Returns point. "
  (interactive "p")
  (let ((pos (gd-backward-def-or-class)))
    (when (called-interactively-p 'any) (message "%s" pos))
    pos))

(defun gd-forward-function ()
  "Jump to the end of function. "
  (interactive "p")
  (let ((pos (gd-forward-def-or-class)))
    (when (called-interactively-p 'any) (message "%s" pos))
    pos))

;; Functions for marking regions

(defun gd-line-at-point ()
  "Return line as string.
  With interactive call, send it to the message buffer too. "
  (interactive)
  (let* ((beg (line-beginning-position))
	 (end (line-end-position))
	 (res (when (and (numberp beg)(numberp end)(< beg end)) (buffer-substring-no-properties beg end))))
    (when (called-interactively-p 'any) (message "%s" res))
    res))

(defun gd-looking-at-keywords-p ()
  "If looking at a python keyword. Returns t or nil. "
  (interactive)
  (let* ((kwds1 (car (nth 1 (eval (eval (quote (car font-lock-defaults)))))))
         (kwds3 (car (nth 3 (eval (eval (quote (car font-lock-defaults)))))))
	 (res
	  (or
           (looking-at kwds1)
           (looking-at kwds3))))
    (when (called-interactively-p 'any) (message "looking-at keywords: %s" res))
    res))

(defun gd-match-paren-mode (&optional arg)
  "gd-match-paren-mode nil oder t"
  (interactive "P")
  (if (or arg (not gd-match-paren-mode))
      (progn
	(setq gd-match-paren-mode t)
        ;; 	(define-key gdscript-mode-map (kbd (concat "<" gd-match-paren-key ">")) 'gd-match-paren))
        (setq gd-match-paren-mode nil))))

(defun py--match-end-finish (cui)
  (let (skipped remain)
    (unless (eq (current-column) cui)
      ;; (unless (empty-line-p)
      ;; (split-line))
      (when (< (current-column) cui)
	(setq skipped (skip-chars-forward " \t" (line-end-position)))
	(setq cui (- cui skipped))
	;; may current-column greater as needed indent?
	(if (< 0 cui)
	    (progn
	      (unless (empty-line-p) (split-line))
	      (indent-to cui))
	  (forward-char cui)

	  ;; (forward-char (- (abs cui)))
	  )
	(unless (eq (char-before) 32)(insert 32)(forward-char -1))))))

(defun py--match-paren-forward ()
  (setq py--match-paren-forward-p t)
  (let ((cui (current-indentation)))
    (cond
     ((py--beginning-of-top-level-p)
      (gd-forward-top-level-bol)
      (py--match-end-finish cui))
     ((py--beginning-of-class-p)
      (gd-forward-class-bol cui)
      (py--match-end-finish cui))
     ((py--beginning-of-def-p)
      (gd-forward-def-bol cui)
      (py--match-end-finish cui))
     ((py--beginning-of-if-block-p)
      (gd-forward-if-block-bol cui)
      (py--match-end-finish cui))
     ((py--beginning-of-try-block-p)
      (gd-forward-try-block-bol cui)
      (py--match-end-finish cui))
     ((py--beginning-of-for-block-p)
      (gd-forward-for-block-bol cui)
      (py--match-end-finish cui))
     ((py--beginning-of-block-p)
      (gd-forward-block-bol)
      (py--match-end-finish cui))
     ((py--beginning-of-clause-p)
      (gd-forward-clause-bol)
      (py--match-end-finish cui))
     ((py--beginning-of-statement-p)
      (gd-forward-statement-bol)
      (py--match-end-finish cui))
     (t (gd-forward-statement)
	(py--match-end-finish cui)))))

(defun py--match-paren-backward ()
  (setq py--match-paren-forward-p nil)
  (let* ((cui (current-indentation))
	 (cuc (current-column))
	 (cui (min cuc cui)))
    (if (eq 0 cui)
	(gd-backward-top-level)
      (when (empty-line-p) (delete-region (line-beginning-position) (point)))
      (gd-backward-statement)
      (unless (< (current-column) cuc)
      (while (and (not (bobp))
		  (< cui (current-column))
		  (gd-backward-statement)))))))

(defun py--match-paren-blocks ()
  (cond
   ((and (looking-back "^[ \t]*")(if (eq last-command 'gd-match-paren)(not py--match-paren-forward-p)t)
	 ;; (looking-at gd-extended-block-or-clause-re)
	 (looking-at "[[:alpha:]_]"))
    ;; from beginning of top-level, block, clause, statement
    (py--match-paren-forward))
   (t
    (py--match-paren-backward))))

(defun gd-match-paren ()
  "If at a beginning, jump to end and vice versa.

When called from within, go to the start.
Matches lists, but also block, statement, string and comment. "
  (interactive)
  (let ((pps (parse-partial-sexp (point-min) (point)))
	(orig (point)))
    (cond
     ;; if inside string, go to beginning
     ((nth 3 pps)
      (goto-char (nth 8 pps)))
     ;; if inside comment, go to beginning
     ((nth 4 pps)
      (gd-backward-comment))
     ;; at comment start, go to end of commented section
     ((and
       ;; unless comment starts where jumped to some end
       (not py--match-paren-forward-p)
       (eq 11 (car-safe (syntax-after (point)))))
      (gd-forward-comment))
     ;; at string start, go to end
     ((or (eq 15 (car-safe (syntax-after (point))))
	  (eq 7 (car (syntax-after (point)))))
      (goto-char (scan-sexps (point) 1))
      (forward-char -1))
     ;; open paren
     ((eq 4 (car (syntax-after (point))))
      (goto-char (scan-sexps (point) 1))
      (forward-char -1))
     ((eq 5 (car (syntax-after (point))))
      (goto-char (scan-sexps (1+ (point)) -1)))
     ((nth 1 pps)
      (goto-char (nth 1 pps)))
     (t
      ;; GDScript specific blocks
      (py--match-paren-blocks)))))

(unless (boundp 'empty-line-p-chars)
  (defvar empty-line-p-chars "^[ \t\f\r]*$"))

(unless (functionp 'in-string-p)
  (defun in-string-p (&optional pos)
    (interactive)
    (let* ((orig (or pos (point)))
           (erg
            (save-excursion
              (save-restriction
                (widen)
                (beginning-of-defun)
                (numberp
                 (progn
                   (if (featurep 'xemacs)
                       (nth 3 (parse-partial-sexp (point) orig)
                            (nth 3 (parse-partial-sexp (point-min) (point)))))))))))
      (when (called-interactively-p 'any) (message "%s" erg))
      erg)))

(defun gd-documentation (w)
  "Launch PyDOC on the Word at Point"
  (interactive
   (list (let* ((word (thing-at-point 'word))
                (input (read-string
                        (format "pydoc entry%s: "
                                (if (not word) "" (format " (default %s)" word))))))
           (if (string= input "")
               (if (not word) (error "No pydoc args given")
                 word) ;sinon word
             input)))) ;sinon input
  (shell-command (concat gd-shell-name " -c \"from pydoc import help;help(\'" w "\')\"") "*PYDOCS*")
  (view-buffer-other-window "*PYDOCS*" t 'kill-buffer-and-window))

(defun eva ()
  "Put \"eval(...)\" forms around strings at point. "
  (interactive "*")
  (skip-chars-forward " \t\r\n\f")
  (let* ((bounds (ar-bounds-of-word-atpt))
         (beg (car bounds))
         (end (cdr bounds)))
    (goto-char end)
    (insert ")")
    (goto-char beg)
    (insert "eval(")))

(defun pst-here ()
  "Kill previous \"pdb.set_trace()\" and insert it at point. "
  (interactive "*")
  (let ((orig (copy-marker (point))))
    (search-backward "pdb.set_trace()")
    (replace-match "")
    (when (empty-line-p)
      (delete-region (line-beginning-position) (line-end-position)))
    (goto-char orig)
    (insert "pdb.set_trace()")))

(defalias 'durck 'gd-printform-insert)
(defalias 'druck 'gd-printform-insert)

(defun gd-printform-insert (&optional arg string)
  "Inserts a print statement out of current `(car kill-ring)' by default, inserts STRING if delivered.

With optional \\[universal-argument] print as string"
  (interactive "*P")
  (let* ((name (py--string-strip (or arg (car kill-ring))))
         ;; guess if doublequotes or parentheses are needed
         (numbered (not (eq 4 (prefix-numeric-value arg))))
         (form (cond ((or (eq major-mode 'gdscript-mode)(eq major-mode 'gd-shell-mode))
                      (if numbered
                          (concat "print(\"" name ": %s \" % (" name "))")
                        (concat "print(\"" name ": %s \" % \"" name "\")"))))))
    (insert form)))

(defun gd-line-to-printform-python2 (&optional arg)
  "Transforms the item on current in a print statement. "
  (interactive "*")
  (let* ((name (thing-at-point 'word))
         (form (cond ((or (eq major-mode 'gdscript-mode)(eq major-mode 'gd-shell-mode))
                      (concat "print(\"" name ": %s \" % " name ")")))))
    (delete-region (line-beginning-position) (line-end-position))
    (insert form))
  (forward-line 1)
  (back-to-indentation))

(defun gd-boolswitch ()
  "Edit the assignment of a boolean variable, revert them.

I.e. switch it from \"True\" to \"False\" and vice versa"
  (interactive "*")
  (save-excursion
    (unless (py--end-of-statement-p)
      (gd-forward-statement))
    (backward-word)
    (cond ((looking-at "True")
           (replace-match "False"))
          ((looking-at "False")
           (replace-match "True"))
          (t (message "%s" "Can't see \"True or False\" here")))))

(when (featurep 'thing-at-point-utils)
  (defun gd-beginning-of-list (&optional iact orig limit done last)
    "Go to beginning of any parentized, braced or bracketed expression in statement. "
    (interactive "p")
    (save-restriction
      (let ((orig (or orig (point)))
            (done done)
            (limit (or limit (re-search-backward "^[a-zA-Z]" nil t 1)))
            (last last))
        (unless (or done (not limit)) (narrow-to-region limit (point-max)))
        (setq done t)
        (goto-char orig)
        (let* ((pt (car-safe (ar-in-parentized-p-atpt)))
               (br (car-safe (ar-in-braced-p-atpt)))
               (bk (car-safe (ar-in-bracketed-p-atpt)))
               (erg (car (sort (delq nil (list pt br bk)) '<))))
          (if erg
              (progn
                (goto-char (1- erg))
                (setq last erg)
                (gd-beginning-of-list iact (1- erg) limit done last))
            (when last
              (goto-char last))
            (when iact (message "%s" last))
            last)))))

  (defun gd-end-of-list (&optional iact orig limit done last)
    "Go to end of any parentized, braced or bracketed expression in statement. "
    (interactive "p")
    (save-restriction
      (let ((orig (or orig (point)))
            (done done)
            (limit (or limit (re-search-backward "^[a-zA-Z]" nil t 1)))
            (last last))
        (unless (or done (not limit)) (narrow-to-region limit (point-max)))
        (setq done t)
        (goto-char orig)
        (let* ((pt (car-safe (ar-in-parentized-p-atpt)))
               (br (car-safe (ar-in-braced-p-atpt)))
               (bk (car-safe (ar-in-bracketed-p-atpt)))
               (erg (car (sort (delq nil (list pt br bk)) '<))))
          (if erg
              (progn
                (goto-char (1- erg))
                (setq last erg)
                (gd-end-of-list iact (1- erg) limit done last))
            (when last
              (goto-char last)
              (match-paren)
              (setq last (1+ (point)))
              (when iact (message "%s" last))
              last)))))))

;; gdscript-components-imenu
;; Imenu definitions

(defvar gd-imenu-class-regexp
  (concat                               ; <<classes>>
   "\\("                                ;
   "^[ \t]*"                            ; newline and maybe whitespace
   "\\(class[ \t]+[a-zA-Z0-9_]+\\)"     ; class name
                                        ; possibly multiple superclasses
   "\\([ \t]*\\((\\([a-zA-Z0-9_,. \t\n]\\)*)\\)?\\)"
   "[ \t]*:"                            ; and the final :
   "\\)"                                ; >>classes<<
   )
  "Regexp for GDScript classes for use with the Imenu package."
  )

(defvar gd-imenu-method-regexp
  (concat                               ; <<methods and functions>>
   "\\("                                ;
   "^[ \t]*"                            ; new line and maybe whitespace
   "\\(def[ \t]+"                       ; function definitions start with def
   "\\([a-zA-Z0-9_]+\\)"                ;   name is here
                                        ;   function arguments...
   ;;   "[ \t]*(\\([-+/a-zA-Z0-9_=,\* \t\n.()\"'#]*\\))"
   "[ \t]*(\\([^:#]*\\))"
   "\\)"                                ; end of def
   "[ \t]*:"                            ; and then the :
   "\\)"                                ; >>methods and functions<<
   )
  "Regexp for GDScript methods/functions for use with the Imenu package."
  )

(defvar gd-imenu-method-no-arg-parens '(2 8)
  "Indices into groups of the GDScript regexp for use with Imenu.

Using these values will result in smaller Imenu lists, as arguments to
functions are not listed.

See the variable `gd-imenu-show-method-args-p' for more
information.")

(defvar gd-imenu-method-arg-parens '(2 7)
  "Indices into groups of the GDScript regexp for use with imenu.
Using these values will result in large Imenu lists, as arguments to
functions are listed.

See the variable `gd-imenu-show-method-args-p' for more
information.")

;; Note that in this format, this variable can still be used with the
;; imenu--generic-function. Otherwise, there is no real reason to have
;; it.
(defvar gd-imenu-generic-expression
  (cons
   (concat
    gd-imenu-class-regexp
    "\\|"                               ; or...
    gd-imenu-method-regexp
    )
   gd-imenu-method-no-arg-parens)
  "Generic GDScript expression which may be used directly with Imenu.
Used by setting the variable `imenu-generic-expression' to this value.
Also, see the function \\[py--imenu-create-index] for a better
alternative for finding the index.")

;; These next two variables are used when searching for the GDScript
;; class/definitions. Just saving some time in accessing the
;; generic-gdscript-expression, really.
;; (set (make-local-variable 'imenu-generic-expression) 'gd-imenu-generic-regexp)

(defvar gd-imenu-generic-regexp nil)
(defvar gd-imenu-generic-parens nil)

(defun gd-switch-imenu-index-function ()
  "Switch between series 5. index machine `py--imenu-create-index' and `py--imenu-create-index-new', which also lists modules variables "
  (interactive)
  (if (eq major-mode 'gdscript-mode)
      (progn
        (if (eq py--imenu-create-index-function 'py--imenu-create-index-new)
            (set (make-local-variable 'py--imenu-create-index-function) 'py--imenu-create-index)
          (set (make-local-variable 'py--imenu-create-index-function) 'py--imenu-create-index-new))
        (when gd-menu
          (easy-menu-add gd-menu))
        (when gd-verbose-p (message "imenu-create-index-function: %s" (prin1-to-string py--imenu-create-index-function)))
        (funcall imenu-create-index-function))
    (error "%s" "Only available in buffers set to gdscript-mode")))

(defun py--imenu-create-index ()
  "GDScript interface function for the Imenu package.
Finds all GDScript classes and functions/methods. Calls function
\\[py--imenu-create-index-engine].  See that function for the details
of how this works."
  (setq gd-imenu-generic-regexp (car gd-imenu-generic-expression)
        gd-imenu-generic-parens (if gd-imenu-show-method-args-p
                                    gd-imenu-method-arg-parens
                                  gd-imenu-method-no-arg-parens))
  (goto-char (point-min))
  ;; Warning: When the buffer has no classes or functions, this will
  ;; return nil, which seems proper according to the Imenu API, but
  ;; causes an error in the XEmacs port of Imenu.  Sigh.
  (setq index-alist (cdr (py--imenu-create-index-engine nil))))

(defun py--imenu-create-index-engine (&optional start-indent)
  "Function for finding Imenu definitions in GDScript.

Finds all definitions (classes, methods, or functions) in a GDScript
file for the Imenu package.

Returns a possibly nested alist of the form

        (INDEX-NAME . INDEX-POSITION)

The second element of the alist may be an alist, producing a nested
list as in

        (INDEX-NAME . INDEX-ALIST)

This function should not be called directly, as it calls itself
recursively and requires some setup.  Rather this is the engine for
the function \\[py--imenu-create-index-function].

It works recursively by looking for all definitions at the current
indention level.  When it finds one, it adds it to the alist.  If it
finds a definition at a greater indentation level, it removes the
previous definition from the alist. In its place it adds all
definitions found at the next indentation level.  When it finds a
definition that is less indented then the current level, it returns
the alist it has created thus far.

The optional argument START-INDENT indicates the starting indentation
at which to continue looking for GDScript classes, methods, or
functions.  If this is not supplied, the function uses the indentation
of the first definition found."
  (let (index-alist
        sub-method-alist
        looking-p
        def-name prev-name
        cur-indent def-pos
        (class-paren (first gd-imenu-generic-parens))
        (def-paren (second gd-imenu-generic-parens)))
    (setq looking-p
          (re-search-forward gd-imenu-generic-regexp (point-max) t))
    (while looking-p
      (save-excursion
        ;; used to set def-name to this value but generic-extract-name
        ;; is new to imenu-1.14. this way it still works with
        ;; imenu-1.11
        ;;(imenu--generic-extract-name gd-imenu-generic-parens))
        (let ((cur-paren (if (match-beginning class-paren)
                             class-paren def-paren)))
          (setq def-name
                (buffer-substring-no-properties (match-beginning cur-paren)
                                                (match-end cur-paren))))
        (save-match-data
          (gd-beginning-of-def-or-class))
        (beginning-of-line)
        (setq cur-indent (current-indentation)))
      ;; HACK: want to go to the next correct definition location.  We
      ;; explicitly list them here but it would be better to have them
      ;; in a list.
      (setq def-pos
            (or (match-beginning class-paren)
                (match-beginning def-paren)))
      ;; if we don't have a starting indent level, take this one
      (or start-indent
          (setq start-indent cur-indent))
      ;; if we don't have class name yet, take this one
      (or prev-name
          (setq prev-name def-name))
      ;; what level is the next definition on?  must be same, deeper
      ;; or shallower indentation
      (cond
       ;; Skip code in comments and strings
       ((py--in-literal))
       ;; at the same indent level, add it to the list...
       ((= start-indent cur-indent)
        (push (cons def-name def-pos) index-alist))
       ;; deeper indented expression, recurse
       ((< start-indent cur-indent)
        ;; the point is currently on the expression we're supposed to
        ;; start on, so go back to the last expression. The recursive
        ;; call will find this place again and add it to the correct
        ;; list
        (re-search-backward gd-imenu-generic-regexp (point-min) 'move)
        (setq sub-method-alist (py--imenu-create-index-engine cur-indent))
        (if sub-method-alist
            ;; we put the last element on the index-alist on the start
            ;; of the submethod alist so the user can still get to it.
            (let* ((save-elmt (pop index-alist))
                   (classname (and (string-match "^class " (car save-elmt))(replace-regexp-in-string "^class " "" (car save-elmt)))))
              (if (and classname (not (string-match "^class " (caar sub-method-alist))))
                  (setcar (car sub-method-alist) (concat classname "." (caar sub-method-alist))))
              (push (cons prev-name
                          (cons save-elmt sub-method-alist))
                    index-alist))))
       (t
        (setq looking-p nil)
        (re-search-backward gd-imenu-generic-regexp (point-min) t)))
      ;; end-cond
      (setq prev-name def-name)
      (and looking-p
           (setq looking-p
                 (re-search-forward gd-imenu-generic-regexp
                                    (point-max) 'move))))
    (nreverse index-alist)))

(defun py--imenu-create-index-new-intern (&optional thisend end)
  (let* ((pos (match-beginning 0))
         (name (match-string-no-properties 2))
         (classname (concat "class " name))
         (thisend (or thisend (save-match-data (py--end-of-def-or-class-position))))
         sublist)
    (while (and (re-search-forward "^[ \t]*\\(?:\\(def\\|class\\)\\)[ \t]+\\(?:\\(\\sw+\\)\\)" (or thisend end) t 1)(not (nth 8 (parse-partial-sexp (point-min) (point)))))
      (let* ((pos (match-beginning 0))
             (name (match-string-no-properties 2))
             (classname (concat "class " name))
             (thisend (or thisend (save-match-data (py--end-of-def-or-class-position)))))
        (if (string= "class" (match-string-no-properties 1))
            (py--imenu-create-index-new-intern (save-match-data (py--end-of-def-or-class-position) end))
          (push (cons (concat " " name) pos) sublist))))
    (if classname
        (progn
          (setq sublist (nreverse sublist))
          (push (cons classname pos) sublist)
          (push (cons classname sublist) index-alist))
      (push sublist index-alist))))

(defun py--imenu-create-index-new (&optional beg end)
  (interactive)
  "`imenu-create-index-function' for GDScript. "
  (set (make-local-variable 'imenu-max-items) gd-imenu-max-items)
  (let ((orig (point))
        (beg (or beg (point-min)))
        (end (or end (point-max)))
        index-alist vars thisend sublist classname pos name)
    (goto-char beg)
    (while (and (re-search-forward "^[ \t]*\\(def\\|class\\)[ \t]+\\(\\sw+\\)" end t 1)(not (nth 8 (parse-partial-sexp (point-min) (point)))))
      (if (save-match-data (string= "class" (match-string-no-properties 1)))
          (progn
            (setq pos (match-beginning 0)
                  name (match-string-no-properties 2)
                  classname (concat "class " name)
                  thisend (save-match-data (py--end-of-def-or-class-position))
                  sublist '())
            (while (and (re-search-forward "^[ \t]*\\(def\\|class\\)[ \t]+\\(\\sw+\\)" (or thisend end) t 1)(not (nth 8 (parse-partial-sexp (point-min) (point)))))
              (let* ((pos (match-beginning 0))
                     (name (match-string-no-properties 2))
                     (classname (concat "class " name))
                     (thisend (or thisend (save-match-data (py--end-of-def-or-class-position)))))
                (if (string= "class" (match-string-no-properties 1))
                    (py--imenu-create-index-new-intern (save-match-data (py--end-of-def-or-class-position)) end)
                  (push (cons (concat " " name) pos) sublist))))
            (if classname
                (progn
                  (setq sublist (nreverse sublist))
                  (push (cons classname pos) sublist)
                  (push (cons classname sublist) index-alist))
              (push sublist index-alist)))

        (let ((pos (match-beginning 0))
              (name (match-string-no-properties 2)))
          (push (cons name pos) index-alist))))
    ;; Look for module variables.
    (goto-char (point-min))
    (while (re-search-forward "^\\(\\sw+\\)[ \t]*=" end t)
      (unless (nth 8 (parse-partial-sexp (point-min) (point)))
        (let ((pos (match-beginning 1))
              (name (match-string-no-properties 1)))
          (push (cons name pos) vars))))
    (setq index-alist (nreverse index-alist))
    (when vars
      (push (cons "Module variables"
                  (nreverse vars))
            index-alist))
    (goto-char orig)
    index-alist))

;; gdscript-components-named-shells


(defun ipython (&optional argprompt)
  "Start an IPython interpreter.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
  (gd-shell argprompt nil "ipython"))

(defun ipython2.7 (&optional argprompt)
  "Start an IPython2.7 interpreter.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
  (gd-shell argprompt nil "ipython2.7"))

(defun ipython3 (&optional argprompt)
  "Start an IPython3 interpreter.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
  (gd-shell argprompt nil "ipython3"))

(defun jython (&optional argprompt)
  "Start an Jython interpreter.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
  (gd-shell argprompt nil "jython"))

(defun python (&optional argprompt)
  "Start an GDScript interpreter.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
  (gd-shell argprompt nil "python"))

(defun python2 (&optional argprompt)
  "Start an Python2 interpreter.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
  (gd-shell argprompt nil "python2"))

(defun python3 (&optional argprompt)
  "Start an Python3 interpreter.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
  (gd-shell argprompt nil "python3"))

;; dedicated
(defun ipython-dedicated (&optional argprompt switch)
  "Start an unique IPython interpreter in another window.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
 (let ((gd-dedicated-process-p t))
    (gd-shell argprompt t "ipython")))

(defun ipython2.7-dedicated (&optional argprompt switch)
  "Start an unique IPython2.7 interpreter in another window.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
 (let ((gd-dedicated-process-p t))
    (gd-shell argprompt t "ipython2.7")))

(defun ipython3-dedicated (&optional argprompt switch)
  "Start an unique IPython3 interpreter in another window.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
 (let ((gd-dedicated-process-p t))
    (gd-shell argprompt t "ipython3")))

(defun jython-dedicated (&optional argprompt switch)
  "Start an unique Jython interpreter in another window.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
 (let ((gd-dedicated-process-p t))
    (gd-shell argprompt t "jython")))

(defun gdscript-dedicated (&optional argprompt switch)
  "Start an unique GDScript interpreter in another window.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
 (let ((gd-dedicated-process-p t))
    (gd-shell argprompt t "python")))

(defun python2-dedicated (&optional argprompt switch)
  "Start an unique Python2 interpreter in another window.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
 (let ((gd-dedicated-process-p t))
    (gd-shell argprompt t "python2")))

(defun python3-dedicated (&optional argprompt switch)
  "Start an unique Python3 interpreter in another window.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
 (let ((gd-dedicated-process-p t))
    (gd-shell argprompt t "python3")))

;; switch
(defun ipython-switch (&optional argprompt)
  "Switch to IPython interpreter in another window.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
 (let ((gd-switch-buffers-on-execute-p t))
    (gd-shell argprompt nil "ipython")))

(defun ipython2.7-switch (&optional argprompt)
  "Switch to IPython2.7 interpreter in another window.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
 (let ((gd-switch-buffers-on-execute-p t))
    (gd-shell argprompt nil "ipython2.7")))

(defun ipython3-switch (&optional argprompt)
  "Switch to IPython3 interpreter in another window.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
 (let ((gd-switch-buffers-on-execute-p t))
    (gd-shell argprompt nil "ipython3")))

(defun jython-switch (&optional argprompt)
  "Switch to Jython interpreter in another window.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
 (let ((gd-switch-buffers-on-execute-p t))
    (gd-shell argprompt nil "jython")))

(defun gdscript-switch (&optional argprompt)
  "Switch to GDScript interpreter in another window.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
 (let ((gd-switch-buffers-on-execute-p t))
    (gd-shell argprompt nil "python")))

(defun python2-switch (&optional argprompt)
  "Switch to Python2 interpreter in another window.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
 (let ((gd-switch-buffers-on-execute-p t))
    (gd-shell argprompt nil "python2")))

(defun python3-switch (&optional argprompt)
  "Switch to Python3 interpreter in another window.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
 (let ((gd-switch-buffers-on-execute-p t))
    (gd-shell argprompt nil "python3")))

;; no-switch
(defun ipython-no-switch (&optional argprompt)
  "Open an IPython interpreter in another window, but do not switch to it.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
 (let (gd-switch-buffers-on-execute-p)
    (gd-shell argprompt nil "ipython")))

(defun ipython2.7-no-switch (&optional argprompt)
  "Open an IPython2.7 interpreter in another window, but do not switch to it.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
 (let (gd-switch-buffers-on-execute-p)
    (gd-shell argprompt nil "ipython2.7")))

(defun ipython3-no-switch (&optional argprompt)
  "Open an IPython3 interpreter in another window, but do not switch to it.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
 (let (gd-switch-buffers-on-execute-p)
    (gd-shell argprompt nil "ipython3")))

(defun jython-no-switch (&optional argprompt)
  "Open an Jython interpreter in another window, but do not switch to it.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
 (let (gd-switch-buffers-on-execute-p)
    (gd-shell argprompt nil "jython")))

(defun gdscript-no-switch (&optional argprompt)
  "Open an GDScript interpreter in another window, but do not switch to it.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
 (let (gd-switch-buffers-on-execute-p)
    (gd-shell argprompt nil "python")))

(defun python2-no-switch (&optional argprompt)
  "Open an Python2 interpreter in another window, but do not switch to it.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
 (let (gd-switch-buffers-on-execute-p)
    (gd-shell argprompt nil "python2")))

(defun python3-no-switch (&optional argprompt)
  "Open an Python3 interpreter in another window, but do not switch to it.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
 (let (gd-switch-buffers-on-execute-p)
    (gd-shell argprompt nil "python3")))

;; dedicated switch
(defalias 'ipython-dedicated-switch 'ipython-switch-dedicated)
(defun ipython-switch-dedicated (&optional argprompt)
  "Switch to an unique IPython interpreter in another window.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
 (let ((gd-dedicated-process-p t)
        (gd-switch-buffers-on-execute-p t))
    (gd-shell argprompt t "ipython")))

(defalias 'ipython2.7-dedicated-switch 'ipython2.7-switch-dedicated)
(defun ipython2.7-switch-dedicated (&optional argprompt)
  "Switch to an unique IPython2.7 interpreter in another window.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
 (let ((gd-dedicated-process-p t)
        (gd-switch-buffers-on-execute-p t))
    (gd-shell argprompt t "ipython2.7")))

(defalias 'ipython3-dedicated-switch 'ipython3-switch-dedicated)
(defun ipython3-switch-dedicated (&optional argprompt)
  "Switch to an unique IPython3 interpreter in another window.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
 (let ((gd-dedicated-process-p t)
        (gd-switch-buffers-on-execute-p t))
    (gd-shell argprompt t "ipython3")))

(defalias 'jython-dedicated-switch 'jython-switch-dedicated)
(defun jython-switch-dedicated (&optional argprompt)
  "Switch to an unique Jython interpreter in another window.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
 (let ((gd-dedicated-process-p t)
        (gd-switch-buffers-on-execute-p t))
    (gd-shell argprompt t "jython")))

(defalias 'gdscript-dedicated-switch 'gdscript-switch-dedicated)
(defun gdscript-switch-dedicated (&optional argprompt)
  "Switch to an unique GDScript interpreter in another window.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
 (let ((gd-dedicated-process-p t)
        (gd-switch-buffers-on-execute-p t))
    (gd-shell argprompt t "python")))

(defalias 'python2-dedicated-switch 'python2-switch-dedicated)
(defun python2-switch-dedicated (&optional argprompt)
  "Switch to an unique Python2 interpreter in another window.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
 (let ((gd-dedicated-process-p t)
        (gd-switch-buffers-on-execute-p t))
    (gd-shell argprompt t "python2")))

(defalias 'python3-dedicated-switch 'python3-switch-dedicated)
(defun python3-switch-dedicated (&optional argprompt)
  "Switch to an unique Python3 interpreter in another window.

Optional \\[universal-argument] prompts for path to the interpreter. "
  (interactive "p")
 (let ((gd-dedicated-process-p t)
        (gd-switch-buffers-on-execute-p t))
    (gd-shell argprompt t "python3")))

;; gdscript-components-electric
(defun gd-electric-colon (arg)
  "Insert a colon and indent accordingly.

If a numeric argument ARG is provided, that many colons are inserted
non-electrically.

Electric behavior is inhibited inside a string or
comment or by universal prefix C-u.

Switched by `gd-electric-colon-active-p', default is nil
See also `gd-electric-colon-greedy-p' "
  (interactive "*P")
  (cond ((not gd-electric-colon-active-p)
         (self-insert-command (prefix-numeric-value arg)))
        ((and gd-electric-colon-bobl-only (save-excursion (gd-backward-statement) (not (py--beginning-of-block-p))))
         (self-insert-command (prefix-numeric-value arg)))
        ((eq 4 (prefix-numeric-value arg))
         (self-insert-command 1))
        (t (insert ":")
           (unless (gd-in-string-or-comment-p)
             (let ((orig (copy-marker (point)))
                   (indent (gd-compute-indentation)))
               (unless (or (eq (current-indentation) indent)
                           (and gd-electric-colon-greedy-p
                                (eq indent (save-excursion (gd-backward-statement)(current-indentation))))
                           (and (py--top-level-form-p)(< (current-indentation) indent)))
                 (beginning-of-line)
                 (delete-horizontal-space)
                 (indent-to indent))
               (goto-char orig))
             (when gd-electric-colon-newline-and-indent-p
               (gd-newline-and-indent))))))

(defun gd-electric-close (arg)
  "Close completion buffer when it's sure, it's no longer needed, i.e. when inserting a space.

Works around a bug in `choose-completion'. "

  (interactive "*P")
  (cond ((not gd-electric-close-active-p)
         (self-insert-command (prefix-numeric-value arg)))
        ((eq 4 (prefix-numeric-value arg))
         (self-insert-command 1))
        (t (if (called-interactively-p 'any) (self-insert-command (prefix-numeric-value arg))
             ;; used from dont-indent-code-unnecessarily-lp-1048778-test
             (insert " ")))))

(defun gd-electric-comment (arg)
  "Insert a comment. If starting a comment, indent accordingly.

If a numeric argument ARG is provided, that many \"#\" are inserted
non-electrically.
With \\[universal-argument] \"#\" electric behavior is inhibited inside a string or comment."
  (interactive "*P")
  (if (and gd-indent-comments gd-electric-comment-p)
      (if (ignore-errors (eq 4 (car-safe arg)))
          (insert "#")
        (when (and (eq last-command 'gd-electric-comment) (looking-back " "))
          (forward-char -1))
        (if (called-interactively-p 'any) (self-insert-command (prefix-numeric-value arg))
          (insert "#"))
        (let ((orig (copy-marker (point)))
              (indent (gd-compute-indentation)))
          (unless
              ;; (or
               (eq (current-indentation) indent)
            ;; (looking-back "#[ \t]*"))
            (goto-char orig)
            (beginning-of-line)
            (delete-horizontal-space)
            (indent-to indent)
            (goto-char orig))
          (when gd-electric-comment-add-space-p
            (unless (looking-at "[ \t]")
              (insert " "))))
        (setq last-command this-command))
    (self-insert-command (prefix-numeric-value arg))))

;; Electric deletion

(defun gd-empty-out-list-backward ()
  "Deletes all elements from list before point. "
  (interactive "*")
  (and (member (char-before) (list ?\) ?\] ?\}))
       (let ((orig (point))
             (thischar (char-before))
             pps cn)
         (forward-char -1)
         (setq pps (parse-partial-sexp (point-min) (point)))
         (if (and (not (nth 8 pps)) (nth 1 pps))
             (progn
               (goto-char (nth 1 pps))
               (forward-char 1))
           (cond ((or (eq thischar 41)(eq thischar ?\)))
                  (setq cn "("))
                 ((or (eq thischar 125) (eq thischar ?\}))
                  (setq cn "{"))
                 ((or (eq thischar 93)(eq thischar ?\]))
                  (setq cn "[")))
           (skip-chars-backward (concat "^" cn)))
         (delete-region (point) orig)
         (insert-char thischar 1)
         (forward-char -1))))

(defun gd-electric-backspace (&optional arg)
  "Delete preceding character or level of indentation.

When `delete-active-region' and (region-active-p), delete region.

Unless at indentation:
  With `gd-electric-kill-backward-p' delete whitespace before point.
  With `gd-electric-kill-backward-p' at end of a list, empty that list.

Returns column reached. "
  (interactive "p*")
  (or arg (setq arg 1))
  (let (erg)
    (cond ((and (region-active-p)
		;; Emacs23 doesn't know that var
		(boundp 'delete-active-region) delete-active-region)
	   (backward-delete-char-untabify arg))
	  ;; (delete-region (region-beginning) (region-end)))
	  ((looking-back "^[ \t]+")
	   (let* ((remains (% (current-column) gd-indent-offset)))
	     (if (< 0 remains)
		 (delete-char (- remains))
	       (indent-line-to (- (current-indentation) gd-indent-offset)))))
	  ((and gd-electric-kill-backward-p (member (char-before) (list ?\) ?\] ?\})))
	   (gd-empty-out-list-backward))
	  ((and gd-electric-kill-backward-p  (< 0 (setq erg (abs (skip-chars-backward " \t\r\n\f")))))
	   (delete-region (point) (+ erg (point))))
	  (t (delete-char (- 1))))
    (setq erg (current-column))
    (when (and (called-interactively-p 'any) gd-verbose-p) (message "%s" erg))
    erg))

(defun gd-electric-delete (&optional arg)
  "Delete following character or levels of whitespace.

When `delete-active-region' and (region-active-p), delete region "
  (interactive "*p")
  (let ((orig (point)))
    (cond ((and (region-active-p)
		;; Emacs23 doesn't know that var
		(boundp 'delete-active-region) delete-active-region)
	   (delete-region (region-beginning) (region-end)))
	  ((save-excursion (and (< (current-column)(current-indentation)) (<= gd-indent-offset (skip-chars-forward " \t"))))
	   (goto-char orig)
	   (delete-char gd-indent-offset))
	  ((< 0 (skip-chars-forward " \t"))
	   (delete-region orig (point)))
	  (t (delete-char (or arg 1))))))

(defun gd-electric-yank (&optional arg)
  "Perform command `yank' followed by an `indent-according-to-mode' "
  (interactive "P")
  (cond (gd-electric-yank-active-p
         (yank arg)
         ;; (gd-indent-line)
         )
        (t (yank arg))))

;; required for pending-del and delsel modes
(put 'gd-electric-colon 'delete-selection t) ;delsel
(put 'gd-electric-colon 'pending-delete t) ;pending-del
(put 'gd-electric-backspace 'delete-selection 'supersede) ;delsel
(put 'gd-electric-backspace 'pending-delete 'supersede) ;pending-del
(put 'gd-electric-delete 'delete-selection 'supersede) ;delsel
(put 'gd-electric-delete 'pending-delete 'supersede) ;pending-del

;; gdscript-components-virtualenv

(defvar virtualenv-workon-home nil)

(defvar virtualenv-name nil)

(defvar virtualenv-old-path nil)

(defvar virtualenv-old-exec-path nil)

(if (getenv "WORKON_HOME")
    (setq virtualenv-workon-home (getenv "WORKON_HOME"))
  (setq virtualenv-workon-home "~/.virtualenvs"))

(setq virtualenv-name nil)

;;TODO: Move to a generic UTILITY or TOOL package
(defun virtualenv-filter (predicate sequence)
  "Apply to each element of SEQUENCE the PREDICATE, if FUNCTION
  returns non-nil append the element to the return value of
  virtualenv-filter: a list"
  (let ((retlist '()))
    (dolist (element sequence)
      (when (funcall predicate element)
        (push element retlist)))
    (nreverse retlist)))

(defun virtualenv-append-path (dir var)
  "Append DIR to a path-like varibale VAR, for example:
 (virtualenv-append-path /usr/bin:/bin /home/test/bin) -> /home/test/bin:/usr/bin:/bin"
  (concat (expand-file-name dir)
          path-separator
          var))

(defun virtualenv-add-to-path (dir)
  "Add the specified path element to the Emacs PATH"
  (setenv "PATH"
          (virtualenv-append-path dir
                                  (getenv "PATH"))))

(defun virtualenv-current ()
  "Barfs the current activated virtualenv"
  (interactive)
  (message virtualenv-name))

(defun virtualenv-activate (dir)
  "Activate the virtualenv located in DIR"
  (interactive "DVirtualenv Directory: ")
  ;; Eventually deactivate previous virtualenv
  (when virtualenv-name
    (virtualenv-deactivate))
  (let ((cmd (concat "source " dir "/bin/activate\n")))
    (comint-send-string (get-process (get-buffer-process "*shell*")) cmd)
    ;; Storing old variables
    (setq virtualenv-old-path (getenv "PATH"))
    (setq virtualenv-old-exec-path exec-path)

    (setenv "VIRTUAL_ENV" dir)
    (virtualenv-add-to-path (concat (py--normalize-directory dir) "bin"))
    (add-to-list 'exec-path (concat (py--normalize-directory dir) "bin"))

    (setq virtualenv-name dir)))

(defun virtualenv-deactivate ()
  "Deactivate the current virtual enviroment"
  (interactive)
  ;; Restoring old variables
  (setenv "PATH" virtualenv-old-path)
  (setq exec-path virtualenv-old-exec-path)
  (message (concat "Virtualenv '" virtualenv-name "' deactivated."))
  (setq virtualenv-name nil))

(defun virtualenv-p (dir)
  "Check if a directory is a virtualenv"
  (file-exists-p (concat dir "/bin/activate")))

(defun virtualenv-workon-complete ()
  "return available completions for virtualenv-workon"
  (let
      ;;Varlist
      ((filelist (directory-files virtualenv-workon-home t)))
    ;; Get only the basename from the list of the virtual environments
    ;; paths
    (mapcar 'file-name-nondirectory
            ;; Filter the directories and then the virtual environments
            (virtualenv-filter 'virtualenv-p
                               (virtualenv-filter 'file-directory-p filelist)))))

(defun virtualenv-workon (name)
  "Issue a virtualenvwrapper-like virtualenv-workon command"
  (interactive (list (completing-read "Virtualenv: " (virtualenv-workon-complete))))
  (if (getenv "WORKON_HOME")
      (virtualenv-activate (concat (py--normalize-directory (getenv "WORKON_HOME")) name))
    (virtualenv-activate (concat (py--normalize-directory virtualenv-workon-home) name))))

;; gdscript-components-booleans-beginning-forms


(defun py--beginning-of-comment-p ()
  "Returns position, if cursor is at the beginning of a `comment', nil otherwise. "
  (let ((orig (point))
        erg)
    (save-excursion
      (unless (or (gd-in-string-or-comment-p) (and (eolp) (not (empty-line-p))))
        (gd-forward-comment)
        (gd-backward-comment)
        (when (eq orig (point))
          (setq erg orig)))
      erg)))

(defun py--beginning-of-line-p ()
  "Returns position, if cursor is at the beginning of a `line', nil otherwise. "
  (let ((orig (point))
        erg)
    (save-excursion
      (unless (or (gd-in-string-or-comment-p) (and (eolp) (not (empty-line-p))))
        (gd-forward-line)
        (gd-backward-line)
        (when (eq orig (point))
          (setq erg orig)))
      erg)))

(defun py--beginning-of-paragraph-p ()
  "Returns position, if cursor is at the beginning of a `paragraph', nil otherwise. "
  (let ((orig (point))
        erg)
    (save-excursion
      (unless (or (gd-in-string-or-comment-p) (and (eolp) (not (empty-line-p))))
        (gd-forward-paragraph)
        (gd-backward-paragraph)
        (when (eq orig (point))
          (setq erg orig)))
      erg)))

(defun py--beginning-of-expression-p ()
  "Returns position, if cursor is at the beginning of a `expression', nil otherwise. "
  (let ((orig (point))
        erg)
    (save-excursion
      (unless (and (eolp) (not (empty-line-p)))

        (gd-forward-expression)
        (gd-backward-expression)
        (when (eq orig (point))
          (setq erg orig)))
      erg)))

(defun py--beginning-of-partial-expression-p ()
  "Returns position, if cursor is at the beginning of a `partial-expression', nil otherwise. "
  (let ((orig (point))
        erg)
    (save-excursion
      (unless (and (eolp) (not (empty-line-p)))

        (gd-forward-partial-expression)
        (gd-backward-partial-expression)
        (when (eq orig (point))
          (setq erg orig)))
      erg)))

(defun py--beginning-of-section-p ()
  "Returns position, if cursor is at the beginning of a `section', nil otherwise. "
  (let ((orig (point))
        erg)
    (save-excursion
      (unless (or (gd-in-string-or-comment-p) (and (eolp) (not (empty-line-p))))
        (gd-forward-section)
        (gd-backward-section)
        (when (eq orig (point))
          (setq erg orig)))
      erg)))

(defun py--beginning-of-top-level-p ()
  "Returns position, if cursor is at the beginning of a `top-level', nil otherwise. "
  (let ((orig (point))
        erg)
    (save-excursion
      (unless (or (gd-in-string-or-comment-p) (and (eolp) (not (empty-line-p))))
        (gd-forward-top-level)
        (gd-backward-top-level)
        (when (eq orig (point))
          (setq erg orig)))
      erg)))

(defun py--beginning-of-block-bol-p ()
  "Returns position, if cursor is at beginning-of-line and the beginning of a `block', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-block-bol))
      (gd-backward-block-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-block-or-clause-bol-p ()
  "Returns position, if cursor is at beginning-of-line and the beginning of a `block-or-clause', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-block-or-clause-bol))
      (gd-backward-block-or-clause-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-class-bol-p ()
  "Returns position, if cursor is at beginning-of-line and the beginning of a `class', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-class-bol))
      (gd-backward-class-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-clause-bol-p ()
  "Returns position, if cursor is at beginning-of-line and the beginning of a `clause', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-clause-bol))
      (gd-backward-clause-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-def-bol-p ()
  "Returns position, if cursor is at beginning-of-line and the beginning of a `def', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-def-bol))
      (gd-backward-def-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-def-or-class-bol-p ()
  "Returns position, if cursor is at beginning-of-line and the beginning of a `def-or-class', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-def-or-class-bol))
      (gd-backward-def-or-class-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-elif-block-bol-p ()
  "Returns position, if cursor is at beginning-of-line and the beginning of a `elif-block', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-elif-block-bol))
      (gd-backward-elif-block-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-else-block-bol-p ()
  "Returns position, if cursor is at beginning-of-line and the beginning of a `else-block', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-else-block-bol))
      (gd-backward-else-block-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-except-block-bol-p ()
  "Returns position, if cursor is at beginning-of-line and the beginning of a `except-block', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-except-block-bol))
      (gd-backward-except-block-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-for-block-bol-p ()
  "Returns position, if cursor is at beginning-of-line and the beginning of a `for-block', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-for-block-bol))
      (gd-backward-for-block-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-if-block-bol-p ()
  "Returns position, if cursor is at beginning-of-line and the beginning of a `if-block', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-if-block-bol))
      (gd-backward-if-block-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-indent-bol-p ()
  "Returns position, if cursor is at beginning-of-line and the beginning of a `indent', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-indent-bol))
      (gd-backward-indent-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-minor-block-bol-p ()
  "Returns position, if cursor is at beginning-of-line and the beginning of a `minor-block', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-minor-block-bol))
      (gd-backward-minor-block-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-statement-bol-p ()
  "Returns position, if cursor is at beginning-of-line and the beginning of a `statement', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-statement-bol))
      (gd-backward-statement-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-top-level-bol-p ()
  "Returns position, if cursor is at beginning-of-line and the beginning of a `top-level', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-top-level-bol))
      (gd-backward-top-level-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-try-block-bol-p ()
  "Returns position, if cursor is at beginning-of-line and the beginning of a `try-block', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-try-block-bol))
      (gd-backward-try-block-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-block-p ()
  "Returns position, if cursor is at the beginning of a `block', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-block))
      (gd-backward-block)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-block-or-clause-p ()
  "Returns position, if cursor is at the beginning of a `block-or-clause', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-block-or-clause))
      (gd-backward-block-or-clause)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-class-p ()
  "Returns position, if cursor is at the beginning of a `class', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-class))
      (gd-backward-class)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-clause-p ()
  "Returns position, if cursor is at the beginning of a `clause', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-clause))
      (gd-backward-clause)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-def-p ()
  "Returns position, if cursor is at the beginning of a `def', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-def))
      (gd-backward-def)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-def-or-class-p ()
  "Returns position, if cursor is at the beginning of a `def-or-class', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-def-or-class))
      (gd-backward-def-or-class)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-elif-block-p ()
  "Returns position, if cursor is at the beginning of a `elif-block', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-elif-block))
      (gd-backward-elif-block)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-else-block-p ()
  "Returns position, if cursor is at the beginning of a `else-block', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-else-block))
      (gd-backward-else-block)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-except-block-p ()
  "Returns position, if cursor is at the beginning of a `except-block', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-except-block))
      (gd-backward-except-block)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-for-block-p ()
  "Returns position, if cursor is at the beginning of a `for-block', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-for-block))
      (gd-backward-for-block)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-if-block-p ()
  "Returns position, if cursor is at the beginning of a `if-block', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-if-block))
      (gd-backward-if-block)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-indent-p ()
  "Returns position, if cursor is at the beginning of a `indent', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-indent))
      (gd-backward-indent)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-minor-block-p ()
  "Returns position, if cursor is at the beginning of a `minor-block', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-minor-block))
      (gd-backward-minor-block)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-statement-p ()
  "Returns position, if cursor is at the beginning of a `statement', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-statement))
      (gd-backward-statement)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-top-level-p ()
  "Returns position, if cursor is at the beginning of a `top-level', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-top-level))
      (gd-backward-top-level)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--beginning-of-try-block-p ()
  "Returns position, if cursor is at the beginning of a `try-block', nil otherwise. "
  (save-excursion
    (let ((orig (point))
	  erg)
      (unless (and (eolp) (not (empty-line-p)))
	(gd-forward-try-block))
      (gd-backward-try-block)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

;; gdscript-components-booleans-end-forms


(defun py--end-of-comment-p ()
  "Returns position, if cursor is at the end of a comment, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-comment)
      (gd-forward-comment)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-line-p ()
  "Returns position, if cursor is at the end of a line, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-line)
      (gd-forward-line)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-paragraph-p ()
  "Returns position, if cursor is at the end of a paragraph, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-paragraph)
      (gd-forward-paragraph)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-expression-p ()
  "Returns position, if cursor is at the end of a expression, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-expression)
      (gd-forward-expression)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-partial-expression-p ()
  "Returns position, if cursor is at the end of a partial-expression, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-partial-expression)
      (gd-forward-partial-expression)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-section-p ()
  "Returns position, if cursor is at the end of a section, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-section)
      (gd-forward-section)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-top-level-p ()
  "Returns position, if cursor is at the end of a top-level, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-top-level)
      (gd-forward-top-level)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-block-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-block-bol)
      (gd-forward-block-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-block-or-clause-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a block-or-clause, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-block-or-clause-bol)
      (gd-forward-block-or-clause-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-class-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a class, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-class-bol)
      (gd-forward-class-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-clause-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a clause, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-clause-bol)
      (gd-forward-clause-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-def-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a def, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-def-bol)
      (gd-forward-def-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-def-or-class-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a def-or-class, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-def-or-class-bol)
      (gd-forward-def-or-class-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-elif-block-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a elif-block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-elif-block-bol)
      (gd-forward-elif-block-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-else-block-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a else-block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-else-block-bol)
      (gd-forward-else-block-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-except-block-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a except-block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-except-block-bol)
      (gd-forward-except-block-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-for-block-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a for-block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-for-block-bol)
      (gd-forward-for-block-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-if-block-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a if-block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-if-block-bol)
      (gd-forward-if-block-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-indent-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a indent, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-indent-bol)
      (gd-forward-indent-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-minor-block-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a minor-block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-minor-block-bol)
      (gd-forward-minor-block-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-statement-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a statement, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-statement-bol)
      (gd-forward-statement-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-top-level-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a top-level, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-top-level-bol)
      (gd-forward-top-level-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-try-block-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a try-block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-try-block-bol)
      (gd-forward-try-block-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-block-p ()
  "Returns position, if cursor is at the end of a block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-block)
      (gd-forward-block)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-block-or-clause-p ()
  "Returns position, if cursor is at the end of a block-or-clause, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-block-or-clause)
      (gd-forward-block-or-clause)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-class-p ()
  "Returns position, if cursor is at the end of a class, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-class)
      (gd-forward-class)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-clause-p ()
  "Returns position, if cursor is at the end of a clause, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-clause)
      (gd-forward-clause)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-def-p ()
  "Returns position, if cursor is at the end of a def, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-def)
      (gd-forward-def)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-def-or-class-p ()
  "Returns position, if cursor is at the end of a def-or-class, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-def-or-class)
      (gd-forward-def-or-class)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-elif-block-p ()
  "Returns position, if cursor is at the end of a elif-block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-elif-block)
      (gd-forward-elif-block)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-else-block-p ()
  "Returns position, if cursor is at the end of a else-block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-else-block)
      (gd-forward-else-block)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-except-block-p ()
  "Returns position, if cursor is at the end of a except-block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-except-block)
      (gd-forward-except-block)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-for-block-p ()
  "Returns position, if cursor is at the end of a for-block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-for-block)
      (gd-forward-for-block)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-if-block-p ()
  "Returns position, if cursor is at the end of a if-block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-if-block)
      (gd-forward-if-block)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-indent-p ()
  "Returns position, if cursor is at the end of a indent, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-indent)
      (gd-forward-indent)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-minor-block-p ()
  "Returns position, if cursor is at the end of a minor-block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-minor-block)
      (gd-forward-minor-block)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-statement-p ()
  "Returns position, if cursor is at the end of a statement, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-statement)
      (gd-forward-statement)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-top-level-p ()
  "Returns position, if cursor is at the end of a top-level, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-top-level)
      (gd-forward-top-level)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun py--end-of-try-block-p ()
  "Returns position, if cursor is at the end of a try-block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-try-block)
      (gd-forward-try-block)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

;; gdscript-components-beginning-position-forms


(defun py--beginning-of-block-position ()
  "Returns beginning of block position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-block)))
      erg)))

(defun py--beginning-of-block-or-clause-position ()
  "Returns beginning of block-or-clause position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-block-or-clause)))
      erg)))

(defun py--beginning-of-class-position ()
  "Returns beginning of class position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-class)))
      erg)))

(defun py--beginning-of-clause-position ()
  "Returns beginning of clause position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-clause)))
      erg)))

(defun py--beginning-of-comment-position ()
  "Returns beginning of comment position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-comment)))
      erg)))

(defun py--beginning-of-def-position ()
  "Returns beginning of def position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-def)))
      erg)))

(defun py--beginning-of-def-or-class-position ()
  "Returns beginning of def-or-class position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-def-or-class)))
      erg)))

(defun py--beginning-of-expression-position ()
  "Returns beginning of expression position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-expression)))
      erg)))

(defun py--beginning-of-except-block-position ()
  "Returns beginning of except-block position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-except-block)))
      erg)))

(defun py--beginning-of-if-block-position ()
  "Returns beginning of if-block position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-if-block)))
      erg)))

(defun py--beginning-of-indent-position ()
  "Returns beginning of indent position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-indent)))
      erg)))

(defun py--beginning-of-line-position ()
  "Returns beginning of line position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-line)))
      erg)))

(defun py--beginning-of-minor-block-position ()
  "Returns beginning of minor-block position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-minor-block)))
      erg)))

(defun py--beginning-of-partial-expression-position ()
  "Returns beginning of partial-expression position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-partial-expression)))
      erg)))

(defun py--beginning-of-paragraph-position ()
  "Returns beginning of paragraph position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-paragraph)))
      erg)))

(defun py--beginning-of-section-position ()
  "Returns beginning of section position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-section)))
      erg)))

(defun py--beginning-of-statement-position ()
  "Returns beginning of statement position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-statement)))
      erg)))

(defun py--beginning-of-top-level-position ()
  "Returns beginning of top-level position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-top-level)))
      erg)))

(defun py--beginning-of-try-block-position ()
  "Returns beginning of try-block position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-try-block)))
      erg)))

(defun py--beginning-of-block-position-bol ()
  "Returns beginning of block position. "
  (save-excursion
    (let ((erg (gd-backward-block-bol)))
      erg)))

(defun py--beginning-of-block-or-clause-position-bol ()
  "Returns beginning of block-or-clause position. "
  (save-excursion
    (let ((erg (gd-backward-block-or-clause-bol)))
      erg)))

(defun py--beginning-of-class-position-bol ()
  "Returns beginning of class position. "
  (save-excursion
    (let ((erg (gd-backward-class-bol)))
      erg)))

(defun py--beginning-of-clause-position-bol ()
  "Returns beginning of clause position. "
  (save-excursion
    (let ((erg (gd-backward-clause-bol)))
      erg)))

(defun py--beginning-of-def-position-bol ()
  "Returns beginning of def position. "
  (save-excursion
    (let ((erg (gd-backward-def-bol)))
      erg)))

(defun py--beginning-of-def-or-class-position-bol ()
  "Returns beginning of def-or-class position. "
  (save-excursion
    (let ((erg (gd-backward-def-or-class-bol)))
      erg)))

(defun py--beginning-of-elif-block-position-bol ()
  "Returns beginning of elif-block position. "
  (save-excursion
    (let ((erg (gd-backward-elif-block-bol)))
      erg)))

(defun py--beginning-of-else-block-position-bol ()
  "Returns beginning of else-block position. "
  (save-excursion
    (let ((erg (gd-backward-else-block-bol)))
      erg)))

(defun py--beginning-of-except-block-position-bol ()
  "Returns beginning of except-block position. "
  (save-excursion
    (let ((erg (gd-backward-except-block-bol)))
      erg)))

(defun py--beginning-of-for-block-position-bol ()
  "Returns beginning of for-block position. "
  (save-excursion
    (let ((erg (gd-backward-for-block-bol)))
      erg)))

(defun py--beginning-of-if-block-position-bol ()
  "Returns beginning of if-block position. "
  (save-excursion
    (let ((erg (gd-backward-if-block-bol)))
      erg)))

(defun py--beginning-of-indent-position-bol ()
  "Returns beginning of indent position. "
  (save-excursion
    (let ((erg (gd-backward-indent-bol)))
      erg)))

(defun py--beginning-of-minor-block-position-bol ()
  "Returns beginning of minor-block position. "
  (save-excursion
    (let ((erg (gd-backward-minor-block-bol)))
      erg)))

(defun py--beginning-of-statement-position-bol ()
  "Returns beginning of statement position. "
  (save-excursion
    (let ((erg (gd-backward-statement-bol)))
      erg)))

(defun py--beginning-of-try-block-position-bol ()
  "Returns beginning of try-block position. "
  (save-excursion
    (let ((erg (gd-backward-try-block-bol)))
      erg)))

;; gdscript-components-end-position-forms


(defun py--end-of-block-position ()
  "Returns end of block position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-block))))
      erg)))

(defun py--end-of-block-or-clause-position ()
  "Returns end of block-or-clause position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-block-or-clause))))
      erg)))

(defun py--end-of-class-position ()
  "Returns end of class position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-class))))
      erg)))

(defun py--end-of-clause-position ()
  "Returns end of clause position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-clause))))
      erg)))

(defun py--end-of-comment-position ()
  "Returns end of comment position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-comment))))
      erg)))

(defun py--end-of-def-position ()
  "Returns end of def position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-def))))
      erg)))

(defun py--end-of-def-or-class-position ()
  "Returns end of def-or-class position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-def-or-class))))
      erg)))

(defun py--end-of-expression-position ()
  "Returns end of expression position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-expression))))
      erg)))

(defun py--end-of-except-block-position ()
  "Returns end of except-block position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-except-block))))
      erg)))

(defun py--end-of-if-block-position ()
  "Returns end of if-block position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-if-block))))
      erg)))

(defun py--end-of-indent-position ()
  "Returns end of indent position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-indent))))
      erg)))

(defun py--end-of-line-position ()
  "Returns end of line position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-line))))
      erg)))

(defun py--end-of-minor-block-position ()
  "Returns end of minor-block position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-minor-block))))
      erg)))

(defun py--end-of-partial-expression-position ()
  "Returns end of partial-expression position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-partial-expression))))
      erg)))

(defun py--end-of-paragraph-position ()
  "Returns end of paragraph position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-paragraph))))
      erg)))

(defun py--end-of-section-position ()
  "Returns end of section position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-section))))
      erg)))

(defun py--end-of-statement-position ()
  "Returns end of statement position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-statement))))
      erg)))

(defun py--end-of-top-level-position ()
  "Returns end of top-level position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-top-level))))
      erg)))

(defun py--end-of-try-block-position ()
  "Returns end of try-block position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-try-block))))
      erg)))

(defun py--end-of-block-position-bol ()
  "Returns end of block position at beginning-of-line. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-block-bol))))
      erg)))

(defun py--end-of-block-or-clause-position-bol ()
  "Returns end of block-or-clause position at beginning-of-line. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-block-or-clause-bol))))
      erg)))

(defun py--end-of-class-position-bol ()
  "Returns end of class position at beginning-of-line. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-class-bol))))
      erg)))

(defun py--end-of-clause-position-bol ()
  "Returns end of clause position at beginning-of-line. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-clause-bol))))
      erg)))

(defun py--end-of-def-position-bol ()
  "Returns end of def position at beginning-of-line. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-def-bol))))
      erg)))

(defun py--end-of-def-or-class-position-bol ()
  "Returns end of def-or-class position at beginning-of-line. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-def-or-class-bol))))
      erg)))

(defun py--end-of-elif-block-position-bol ()
  "Returns end of elif-block position at beginning-of-line. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-elif-block-bol))))
      erg)))

(defun py--end-of-else-block-position-bol ()
  "Returns end of else-block position at beginning-of-line. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-else-block-bol))))
      erg)))

(defun py--end-of-except-block-position-bol ()
  "Returns end of except-block position at beginning-of-line. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-except-block-bol))))
      erg)))

(defun py--end-of-for-block-position-bol ()
  "Returns end of for-block position at beginning-of-line. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-for-block-bol))))
      erg)))

(defun py--end-of-if-block-position-bol ()
  "Returns end of if-block position at beginning-of-line. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-if-block-bol))))
      erg)))

(defun py--end-of-indent-position-bol ()
  "Returns end of indent position at beginning-of-line. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-indent-bol))))
      erg)))

(defun py--end-of-minor-block-position-bol ()
  "Returns end of minor-block position at beginning-of-line. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-minor-block-bol))))
      erg)))

(defun py--end-of-statement-position-bol ()
  "Returns end of statement position at beginning-of-line. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-statement-bol))))
      erg)))

(defun py--end-of-try-block-position-bol ()
  "Returns end of try-block position at beginning-of-line. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-try-block-bol))))
      erg)))

;; gdscript-components-up-down


(defun gd-up-statement ()
  "Go to the beginning of next statement upwards in buffer.

Return position if statement found, nil otherwise. "
  (interactive)
  (let ((orig (point))
        erg)
    (if (py--beginning-of-statement-p)
	(setq erg (gd-backward-statement))
      (setq erg (and (gd-backward-statement) (gd-backward-statement))))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-down-statement ()
  "Go to the beginning of next statement downwards in buffer.

Return position if statement found, nil otherwise. "
  (interactive)
  (let* ((orig (point))
	  (erg
	   (cond ((py--end-of-statement-p)
		  (setq erg (and (gd-forward-statement) (gd-backward-statement))))
		 ((< orig (progn (gd-forward-statement) (gd-backward-statement)))
		  (point))
		 (t (and (gd-forward-statement) (gd-forward-statement)(gd-backward-statement))))))
	   (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
	   erg))

(defun gd-up-base (regexp)
  "Go to the beginning of next form upwards in buffer.

Return position if form found, nil otherwise. "
  (let* ((orig (point))
         erg)
    (if (bobp)
        (setq erg nil)
      (while (and (re-search-backward regexp nil t 1)
                  (nth 8 (parse-partial-sexp (point-min) (point)))))
      (back-to-indentation)
      (when (looking-at regexp) (setq erg (point)))
      (when gd-verbose-p (message "%s" erg))
      erg)))

(defun gd-down-base (regexp)
  "Go to the beginning of next form below in buffer.

Return position if form found, nil otherwise. "
  (unless (eobp)
    (forward-line 1)
    (beginning-of-line)
    (let* ((orig (point))
           erg)
      (if (eobp)
          (setq erg nil)
        (while (and (re-search-forward regexp nil t 1)
                    (nth 8 (parse-partial-sexp (point-min) (point)))))
        (back-to-indentation)
        (when (looking-at regexp) (setq erg (point)))
        (when gd-verbose-p (message "%s" erg))
        erg))))

(defun gd-up-base-bol (regexp)
  "Go to the beginning of next form upwards in buffer.

Return position if form found, nil otherwise. "
  (let* ((orig (point))
         erg)
    (if (bobp)
        (setq erg nil)
      (while (and (re-search-backward regexp nil t 1)
                  (nth 8 (parse-partial-sexp (point-min) (point)))))
      (beginning-of-line)
      (when (looking-at regexp) (setq erg (point)))
      (when gd-verbose-p (message "%s" erg))
      erg)))

(defun gd-down-base-bol (regexp)
  "Go to the beginning of next form below in buffer.

Return position if form found, nil otherwise. "
  (unless (eobp)
    (forward-line 1)
    (beginning-of-line)
    (let* ((orig (point))
           erg)
      (if (eobp)
          (setq erg nil)
        (while (and (re-search-forward regexp nil t 1)
                    (nth 8 (parse-partial-sexp (point-min) (point)))))
        (beginning-of-line)
        (when (looking-at regexp) (setq erg (point)))
        (when gd-verbose-p (message "%s" erg))
        erg))))

(defun gd-up-block ()
  "Go to the beginning of next block upwards in buffer.

Return position if block found, nil otherwise. "
  (interactive)
  (gd-up-base gd-block-re))

(defun gd-up-block-or-clause ()
  "Go to the beginning of next block-or-clause upwards in buffer.

Return position if block-or-clause found, nil otherwise. "
  (interactive)
  (gd-up-base gd-block-or-clause-re))

(defun gd-up-class ()
  "Go to the beginning of next class upwards in buffer.

Return position if class found, nil otherwise. "
  (interactive)
  (gd-up-base gd-class-re))

(defun gd-up-clause ()
  "Go to the beginning of next clause upwards in buffer.

Return position if clause found, nil otherwise. "
  (interactive)
  (gd-up-base gd-clause-re))

(defun gd-up-def ()
  "Go to the beginning of next def upwards in buffer.

Return position if def found, nil otherwise. "
  (interactive)
  (gd-up-base gd-def-re))

(defun gd-up-def-or-class ()
  "Go to the beginning of next def-or-class upwards in buffer.

Return position if def-or-class found, nil otherwise. "
  (interactive)
  (gd-up-base gd-def-or-class-re))

(defun gd-up-minor-block ()
  "Go to the beginning of next minor-block upwards in buffer.

Return position if minor-block found, nil otherwise. "
  (interactive)
  (gd-up-base gd-minor-block-re))

(defun gd-up-section ()
  "Go to the beginning of next section upwards in buffer.

Return position if section found, nil otherwise. "
  (interactive)
  (gd-up-base gd-section-re))

(defun gd-down-block ()
  "Go to the beginning of next block below in buffer.

Return position if block found, nil otherwise. "
  (interactive)
  (gd-down-base gd-block-re))

(defun gd-down-block-or-clause ()
  "Go to the beginning of next block-or-clause below in buffer.

Return position if block-or-clause found, nil otherwise. "
  (interactive)
  (gd-down-base gd-block-or-clause-re))

(defun gd-down-class ()
  "Go to the beginning of next class below in buffer.

Return position if class found, nil otherwise. "
  (interactive)
  (gd-down-base gd-class-re))

(defun gd-down-clause ()
  "Go to the beginning of next clause below in buffer.

Return position if clause found, nil otherwise. "
  (interactive)
  (gd-down-base gd-clause-re))

(defun gd-down-def ()
  "Go to the beginning of next def below in buffer.

Return position if def found, nil otherwise. "
  (interactive)
  (gd-down-base gd-def-re))

(defun gd-down-def-or-class ()
  "Go to the beginning of next def-or-class below in buffer.

Return position if def-or-class found, nil otherwise. "
  (interactive)
  (gd-down-base gd-def-or-class-re))

(defun gd-down-minor-block ()
  "Go to the beginning of next minor-block below in buffer.

Return position if minor-block found, nil otherwise. "
  (interactive)
  (gd-down-base gd-minor-block-re))

(defun gd-down-section ()
  "Go to the beginning of next section below in buffer.

Return position if section found, nil otherwise. "
  (interactive)
  (gd-down-base gd-section-re))

(defun gd-up-block-bol ()
  "Go to the beginning of next block upwards in buffer.

Go to beginning of line.
Return position if block found, nil otherwise. "
  (interactive)
  (gd-up-base-bol gd-block-re))

(defun gd-up-block-or-clause-bol ()
  "Go to the beginning of next block-or-clause upwards in buffer.

Go to beginning of line.
Return position if block-or-clause found, nil otherwise. "
  (interactive)
  (gd-up-base-bol gd-block-or-clause-re))

(defun gd-up-class-bol ()
  "Go to the beginning of next class upwards in buffer.

Go to beginning of line.
Return position if class found, nil otherwise. "
  (interactive)
  (gd-up-base-bol gd-class-re))

(defun gd-up-clause-bol ()
  "Go to the beginning of next clause upwards in buffer.

Go to beginning of line.
Return position if clause found, nil otherwise. "
  (interactive)
  (gd-up-base-bol gd-clause-re))

(defun gd-up-def-bol ()
  "Go to the beginning of next def upwards in buffer.

Go to beginning of line.
Return position if def found, nil otherwise. "
  (interactive)
  (gd-up-base-bol gd-def-re))

(defun gd-up-def-or-class-bol ()
  "Go to the beginning of next def-or-class upwards in buffer.

Go to beginning of line.
Return position if def-or-class found, nil otherwise. "
  (interactive)
  (gd-up-base-bol gd-def-or-class-re))

(defun gd-up-minor-block-bol ()
  "Go to the beginning of next minor-block upwards in buffer.

Go to beginning of line.
Return position if minor-block found, nil otherwise. "
  (interactive)
  (gd-up-base-bol gd-minor-block-re))

(defun gd-up-section-bol ()
  "Go to the beginning of next section upwards in buffer.

Go to beginning of line.
Return position if section found, nil otherwise. "
  (interactive)
  (gd-up-base-bol gd-section-re))

(defun gd-down-block-bol ()
  "Go to the beginning of next block below in buffer.

Go to beginning of line
Return position if block found, nil otherwise "
  (interactive)
  (gd-down-base-bol gd-block-re))

(defun gd-down-block-or-clause-bol ()
  "Go to the beginning of next block-or-clause below in buffer.

Go to beginning of line
Return position if block-or-clause found, nil otherwise "
  (interactive)
  (gd-down-base-bol gd-block-or-clause-re))

(defun gd-down-class-bol ()
  "Go to the beginning of next class below in buffer.

Go to beginning of line
Return position if class found, nil otherwise "
  (interactive)
  (gd-down-base-bol gd-class-re))

(defun gd-down-clause-bol ()
  "Go to the beginning of next clause below in buffer.

Go to beginning of line
Return position if clause found, nil otherwise "
  (interactive)
  (gd-down-base-bol gd-clause-re))

(defun gd-down-def-bol ()
  "Go to the beginning of next def below in buffer.

Go to beginning of line
Return position if def found, nil otherwise "
  (interactive)
  (gd-down-base-bol gd-def-re))

(defun gd-down-def-or-class-bol ()
  "Go to the beginning of next def-or-class below in buffer.

Go to beginning of line
Return position if def-or-class found, nil otherwise "
  (interactive)
  (gd-down-base-bol gd-def-or-class-re))

(defun gd-down-minor-block-bol ()
  "Go to the beginning of next minor-block below in buffer.

Go to beginning of line
Return position if minor-block found, nil otherwise "
  (interactive)
  (gd-down-base-bol gd-minor-block-re))

(defun gd-down-section-bol ()
  "Go to the beginning of next section below in buffer.

Go to beginning of line
Return position if section found, nil otherwise "
  (interactive)
  (gd-down-base-bol gd-section-re))

;; gdscript-components-up-down.el ends here
;; gdscript-components-exec-forms

;; Execute forms at point

(defun gd-execute-try-block ()
  "Send try-block at point to GDScript default interpreter. "
  (interactive)
  (let ((beg (prog1
                 (or (py--beginning-of-try-block-p)
                     (save-excursion
                       (gd-backward-try-block)))))
        (end (save-excursion
               (gd-forward-try-block))))
    (gd-execute-region beg end)))

(defun gd-execute-if-block ()
  "Send if-block at point to GDScript default interpreter. "
  (interactive)
  (let ((beg (prog1
                 (or (py--beginning-of-if-block-p)
                     (save-excursion
                       (gd-backward-if-block)))))
        (end (save-excursion
               (gd-forward-if-block))))
    (gd-execute-region beg end)))

(defun gd-execute-for-block ()
  "Send for-block at point to GDScript default interpreter. "
  (interactive)
  (let ((beg (prog1
                 (or (py--beginning-of-for-block-p)
                     (save-excursion
                       (gd-backward-for-block)))))
        (end (save-excursion
               (gd-forward-for-block))))
    (gd-execute-region beg end)))

;; gdscript-extended-executes


(defun gd-execute-block ()
  "Send block at point to  interpreter. "
  (interactive)
  (py--execute-prepare 'block nil  nil nil))

(defun gd-execute-block-switch ()
  "Send block at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'block nil  nil 'switch))

(defun gd-execute-block-no-switch ()
  "Send block at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'block nil  nil 'no-switch))

(defun gd-execute-block-dedicated ()
  "Send block at point to  unique interpreter. "
  (interactive)
  (py--execute-prepare 'block nil  t nil))

(defun gd-execute-block-dedicated-switch ()
  "Send block at point to  unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'block nil  t 'switch))

(defun gd-execute-block-ipython ()
  "Send block at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'block 'ipython nil nil))

(defun gd-execute-block-ipython-switch ()
  "Send block at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'block 'ipython nil 'switch))

(defun gd-execute-block-ipython-no-switch ()
  "Send block at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'block 'ipython nil 'no-switch))

(defun gd-execute-block-ipython-dedicated ()
  "Send block at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'block 'ipython t nil))

(defun gd-execute-block-ipython-dedicated-switch ()
  "Send block at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'block 'ipython t 'switch))

(defun gd-execute-block-ipython2.7 ()
  "Send block at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'block 'ipython2.7 nil nil))

(defun gd-execute-block-ipython2.7-switch ()
  "Send block at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'block 'ipython2.7 nil 'switch))

(defun gd-execute-block-ipython2.7-no-switch ()
  "Send block at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'block 'ipython2.7 nil 'no-switch))

(defun gd-execute-block-ipython2.7-dedicated ()
  "Send block at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'block 'ipython2.7 t nil))

(defun gd-execute-block-ipython2.7-dedicated-switch ()
  "Send block at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'block 'ipython2.7 t 'switch))

(defun gd-execute-block-ipython3 ()
  "Send block at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'block 'ipython3 nil nil))

(defun gd-execute-block-ipython3-switch ()
  "Send block at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'block 'ipython3 nil 'switch))

(defun gd-execute-block-ipython3-no-switch ()
  "Send block at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'block 'ipython3 nil 'no-switch))

(defun gd-execute-block-ipython3-dedicated ()
  "Send block at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'block 'ipython3 t nil))

(defun gd-execute-block-ipython3-dedicated-switch ()
  "Send block at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'block 'ipython3 t 'switch))

(defun gd-execute-block-jython ()
  "Send block at point to Jython interpreter. "
  (interactive)
  (py--execute-prepare 'block 'jython nil nil))

(defun gd-execute-block-jython-switch ()
  "Send block at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'block 'jython nil 'switch))

(defun gd-execute-block-jython-no-switch ()
  "Send block at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'block 'jython nil 'no-switch))

(defun gd-execute-block-jython-dedicated ()
  "Send block at point to Jython unique interpreter. "
  (interactive)
  (py--execute-prepare 'block 'jython t nil))

(defun gd-execute-block-jython-dedicated-switch ()
  "Send block at point to Jython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'block 'jython t 'switch))

(defun gd-execute-block-python ()
  "Send block at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'block 'python nil nil))

(defun gd-execute-block-gdscript-switch ()
  "Send block at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'block 'python nil 'switch))

(defun gd-execute-block-gdscript-no-switch ()
  "Send block at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'block 'python nil 'no-switch))

(defun gd-execute-block-gdscript-dedicated ()
  "Send block at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'block 'python t nil))

(defun gd-execute-block-gdscript-dedicated-switch ()
  "Send block at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'block 'python t 'switch))

(defun gd-execute-block-python2 ()
  "Send block at point to Python2 interpreter. "
  (interactive)
  (py--execute-prepare 'block 'python2 nil nil))

(defun gd-execute-block-python2-switch ()
  "Send block at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'block 'python2 nil 'switch))

(defun gd-execute-block-python2-no-switch ()
  "Send block at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'block 'python2 nil 'no-switch))

(defun gd-execute-block-python2-dedicated ()
  "Send block at point to Python2 unique interpreter. "
  (interactive)
  (py--execute-prepare 'block 'python2 t nil))

(defun gd-execute-block-python2-dedicated-switch ()
  "Send block at point to Python2 unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'block 'python2 t 'switch))

(defun gd-execute-block-python3 ()
  "Send block at point to Python3 interpreter. "
  (interactive)
  (py--execute-prepare 'block 'python3 nil nil))

(defun gd-execute-block-python3-switch ()
  "Send block at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'block 'python3 nil 'switch))

(defun gd-execute-block-python3-no-switch ()
  "Send block at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'block 'python3 nil 'no-switch))

(defun gd-execute-block-python3-dedicated ()
  "Send block at point to Python3 unique interpreter. "
  (interactive)
  (py--execute-prepare 'block 'python3 t nil))

(defun gd-execute-block-python3-dedicated-switch ()
  "Send block at point to Python3 unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'block 'python3 t 'switch))

(defun gd-execute-block-or-clause ()
  "Send block-or-clause at point to  interpreter. "
  (interactive)
  (py--execute-prepare 'block-or-clause nil  nil nil))

(defun gd-execute-block-or-clause-switch ()
  "Send block-or-clause at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'block-or-clause nil  nil 'switch))

(defun gd-execute-block-or-clause-no-switch ()
  "Send block-or-clause at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'block-or-clause nil  nil 'no-switch))

(defun gd-execute-block-or-clause-dedicated ()
  "Send block-or-clause at point to  unique interpreter. "
  (interactive)
  (py--execute-prepare 'block-or-clause nil  t nil))

(defun gd-execute-block-or-clause-dedicated-switch ()
  "Send block-or-clause at point to  unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'block-or-clause nil  t 'switch))

(defun gd-execute-block-or-clause-ipython ()
  "Send block-or-clause at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'block-or-clause 'ipython nil nil))

(defun gd-execute-block-or-clause-ipython-switch ()
  "Send block-or-clause at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'block-or-clause 'ipython nil 'switch))

(defun gd-execute-block-or-clause-ipython-no-switch ()
  "Send block-or-clause at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'block-or-clause 'ipython nil 'no-switch))

(defun gd-execute-block-or-clause-ipython-dedicated ()
  "Send block-or-clause at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'block-or-clause 'ipython t nil))

(defun gd-execute-block-or-clause-ipython-dedicated-switch ()
  "Send block-or-clause at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'block-or-clause 'ipython t 'switch))

(defun gd-execute-block-or-clause-ipython2.7 ()
  "Send block-or-clause at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'block-or-clause 'ipython2.7 nil nil))

(defun gd-execute-block-or-clause-ipython2.7-switch ()
  "Send block-or-clause at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'block-or-clause 'ipython2.7 nil 'switch))

(defun gd-execute-block-or-clause-ipython2.7-no-switch ()
  "Send block-or-clause at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'block-or-clause 'ipython2.7 nil 'no-switch))

(defun gd-execute-block-or-clause-ipython2.7-dedicated ()
  "Send block-or-clause at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'block-or-clause 'ipython2.7 t nil))

(defun gd-execute-block-or-clause-ipython2.7-dedicated-switch ()
  "Send block-or-clause at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'block-or-clause 'ipython2.7 t 'switch))

(defun gd-execute-block-or-clause-ipython3 ()
  "Send block-or-clause at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'block-or-clause 'ipython3 nil nil))

(defun gd-execute-block-or-clause-ipython3-switch ()
  "Send block-or-clause at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'block-or-clause 'ipython3 nil 'switch))

(defun gd-execute-block-or-clause-ipython3-no-switch ()
  "Send block-or-clause at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'block-or-clause 'ipython3 nil 'no-switch))

(defun gd-execute-block-or-clause-ipython3-dedicated ()
  "Send block-or-clause at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'block-or-clause 'ipython3 t nil))

(defun gd-execute-block-or-clause-ipython3-dedicated-switch ()
  "Send block-or-clause at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'block-or-clause 'ipython3 t 'switch))

(defun gd-execute-block-or-clause-jython ()
  "Send block-or-clause at point to Jython interpreter. "
  (interactive)
  (py--execute-prepare 'block-or-clause 'jython nil nil))

(defun gd-execute-block-or-clause-jython-switch ()
  "Send block-or-clause at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'block-or-clause 'jython nil 'switch))

(defun gd-execute-block-or-clause-jython-no-switch ()
  "Send block-or-clause at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'block-or-clause 'jython nil 'no-switch))

(defun gd-execute-block-or-clause-jython-dedicated ()
  "Send block-or-clause at point to Jython unique interpreter. "
  (interactive)
  (py--execute-prepare 'block-or-clause 'jython t nil))

(defun gd-execute-block-or-clause-jython-dedicated-switch ()
  "Send block-or-clause at point to Jython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'block-or-clause 'jython t 'switch))

(defun gd-execute-block-or-clause-python ()
  "Send block-or-clause at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'block-or-clause 'python nil nil))

(defun gd-execute-block-or-clause-gdscript-switch ()
  "Send block-or-clause at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'block-or-clause 'python nil 'switch))

(defun gd-execute-block-or-clause-gdscript-no-switch ()
  "Send block-or-clause at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'block-or-clause 'python nil 'no-switch))

(defun gd-execute-block-or-clause-gdscript-dedicated ()
  "Send block-or-clause at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'block-or-clause 'python t nil))

(defun gd-execute-block-or-clause-gdscript-dedicated-switch ()
  "Send block-or-clause at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'block-or-clause 'python t 'switch))

(defun gd-execute-block-or-clause-python2 ()
  "Send block-or-clause at point to Python2 interpreter. "
  (interactive)
  (py--execute-prepare 'block-or-clause 'python2 nil nil))

(defun gd-execute-block-or-clause-python2-switch ()
  "Send block-or-clause at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'block-or-clause 'python2 nil 'switch))

(defun gd-execute-block-or-clause-python2-no-switch ()
  "Send block-or-clause at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'block-or-clause 'python2 nil 'no-switch))

(defun gd-execute-block-or-clause-python2-dedicated ()
  "Send block-or-clause at point to Python2 unique interpreter. "
  (interactive)
  (py--execute-prepare 'block-or-clause 'python2 t nil))

(defun gd-execute-block-or-clause-python2-dedicated-switch ()
  "Send block-or-clause at point to Python2 unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'block-or-clause 'python2 t 'switch))

(defun gd-execute-block-or-clause-python3 ()
  "Send block-or-clause at point to Python3 interpreter. "
  (interactive)
  (py--execute-prepare 'block-or-clause 'python3 nil nil))

(defun gd-execute-block-or-clause-python3-switch ()
  "Send block-or-clause at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'block-or-clause 'python3 nil 'switch))

(defun gd-execute-block-or-clause-python3-no-switch ()
  "Send block-or-clause at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'block-or-clause 'python3 nil 'no-switch))

(defun gd-execute-block-or-clause-python3-dedicated ()
  "Send block-or-clause at point to Python3 unique interpreter. "
  (interactive)
  (py--execute-prepare 'block-or-clause 'python3 t nil))

(defun gd-execute-block-or-clause-python3-dedicated-switch ()
  "Send block-or-clause at point to Python3 unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'block-or-clause 'python3 t 'switch))

(defun gd-execute-buffer ()
  "Send buffer at point to  interpreter. "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer nil  nil nil (point-min) (point-max)))

(defun gd-execute-buffer-switch ()
  "Send buffer at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer nil  nil 'switch (point-min) (point-max)))

(defun gd-execute-buffer-no-switch ()
  "Send buffer at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer nil  nil 'no-switch (point-min) (point-max)))

(defun gd-execute-buffer-dedicated ()
  "Send buffer at point to  unique interpreter. "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer nil  t nil (point-min) (point-max)))

(defun gd-execute-buffer-dedicated-switch ()
  "Send buffer at point to  unique interpreter and switch to result. "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer nil  t 'switch (point-min) (point-max)))

(defun gd-execute-buffer-ipython ()
  "Send buffer at point to IPython interpreter. "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'ipython nil nil (point-min) (point-max)))

(defun gd-execute-buffer-ipython-switch ()
  "Send buffer at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'ipython nil 'switch (point-min) (point-max)))

(defun gd-execute-buffer-ipython-no-switch ()
  "Send buffer at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'ipython nil 'no-switch (point-min) (point-max)))

(defun gd-execute-buffer-ipython-dedicated ()
  "Send buffer at point to IPython unique interpreter. "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'ipython t nil (point-min) (point-max)))

(defun gd-execute-buffer-ipython-dedicated-switch ()
  "Send buffer at point to IPython unique interpreter and switch to result. "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'ipython t 'switch (point-min) (point-max)))

(defun gd-execute-buffer-ipython2.7 ()
  "Send buffer at point to IPython interpreter. "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'ipython2.7 nil nil (point-min) (point-max)))

(defun gd-execute-buffer-ipython2.7-switch ()
  "Send buffer at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'ipython2.7 nil 'switch (point-min) (point-max)))

(defun gd-execute-buffer-ipython2.7-no-switch ()
  "Send buffer at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'ipython2.7 nil 'no-switch (point-min) (point-max)))

(defun gd-execute-buffer-ipython2.7-dedicated ()
  "Send buffer at point to IPython unique interpreter. "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'ipython2.7 t nil (point-min) (point-max)))

(defun gd-execute-buffer-ipython2.7-dedicated-switch ()
  "Send buffer at point to IPython unique interpreter and switch to result. "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'ipython2.7 t 'switch (point-min) (point-max)))

(defun gd-execute-buffer-ipython3 ()
  "Send buffer at point to IPython interpreter. "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'ipython3 nil nil (point-min) (point-max)))

(defun gd-execute-buffer-ipython3-switch ()
  "Send buffer at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'ipython3 nil 'switch (point-min) (point-max)))

(defun gd-execute-buffer-ipython3-no-switch ()
  "Send buffer at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'ipython3 nil 'no-switch (point-min) (point-max)))

(defun gd-execute-buffer-ipython3-dedicated ()
  "Send buffer at point to IPython unique interpreter. "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'ipython3 t nil (point-min) (point-max)))

(defun gd-execute-buffer-ipython3-dedicated-switch ()
  "Send buffer at point to IPython unique interpreter and switch to result. "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'ipython3 t 'switch (point-min) (point-max)))

(defun gd-execute-buffer-jython ()
  "Send buffer at point to Jython interpreter. "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'jython nil nil (point-min) (point-max)))

(defun gd-execute-buffer-jython-switch ()
  "Send buffer at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'jython nil 'switch (point-min) (point-max)))

(defun gd-execute-buffer-jython-no-switch ()
  "Send buffer at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'jython nil 'no-switch (point-min) (point-max)))

(defun gd-execute-buffer-jython-dedicated ()
  "Send buffer at point to Jython unique interpreter. "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'jython t nil (point-min) (point-max)))

(defun gd-execute-buffer-jython-dedicated-switch ()
  "Send buffer at point to Jython unique interpreter and switch to result. "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'jython t 'switch (point-min) (point-max)))

(defun gd-execute-buffer-python ()
  "Send buffer at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'python nil nil (point-min) (point-max)))

(defun gd-execute-buffer-gdscript-switch ()
  "Send buffer at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'python nil 'switch (point-min) (point-max)))

(defun gd-execute-buffer-gdscript-no-switch ()
  "Send buffer at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'python nil 'no-switch (point-min) (point-max)))

(defun gd-execute-buffer-gdscript-dedicated ()
  "Send buffer at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'python t nil (point-min) (point-max)))

(defun gd-execute-buffer-gdscript-dedicated-switch ()
  "Send buffer at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'python t 'switch (point-min) (point-max)))

(defun gd-execute-buffer-python2 ()
  "Send buffer at point to Python2 interpreter. "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'python2 nil nil (point-min) (point-max)))

(defun gd-execute-buffer-python2-switch ()
  "Send buffer at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'python2 nil 'switch (point-min) (point-max)))

(defun gd-execute-buffer-python2-no-switch ()
  "Send buffer at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'python2 nil 'no-switch (point-min) (point-max)))

(defun gd-execute-buffer-python2-dedicated ()
  "Send buffer at point to Python2 unique interpreter. "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'python2 t nil (point-min) (point-max)))

(defun gd-execute-buffer-python2-dedicated-switch ()
  "Send buffer at point to Python2 unique interpreter and switch to result. "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'python2 t 'switch (point-min) (point-max)))

(defun gd-execute-buffer-python3 ()
  "Send buffer at point to Python3 interpreter. "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'python3 nil nil (point-min) (point-max)))

(defun gd-execute-buffer-python3-switch ()
  "Send buffer at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'python3 nil 'switch (point-min) (point-max)))

(defun gd-execute-buffer-python3-no-switch ()
  "Send buffer at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'python3 nil 'no-switch (point-min) (point-max)))

(defun gd-execute-buffer-python3-dedicated ()
  "Send buffer at point to Python3 unique interpreter. "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'python3 t nil (point-min) (point-max)))

(defun gd-execute-buffer-python3-dedicated-switch ()
  "Send buffer at point to Python3 unique interpreter and switch to result. "
  (interactive)
  (let ((wholebuf t)
        (gd-master-file (or gd-master-file (gd-fetch-gd-master-file)))
	beg end)
    (when gd-master-file
      (let* ((filename (expand-file-name gd-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file-noselect filename))))
	(set-buffer buffer))))
  (py--execute-prepare 'buffer 'python3 t 'switch (point-min) (point-max)))

(defun gd-execute-class ()
  "Send class at point to  interpreter. "
  (interactive)
  (py--execute-prepare 'class nil  nil nil))

(defun gd-execute-class-switch ()
  "Send class at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'class nil  nil 'switch))

(defun gd-execute-class-no-switch ()
  "Send class at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'class nil  nil 'no-switch))

(defun gd-execute-class-dedicated ()
  "Send class at point to  unique interpreter. "
  (interactive)
  (py--execute-prepare 'class nil  t nil))

(defun gd-execute-class-dedicated-switch ()
  "Send class at point to  unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'class nil  t 'switch))

(defun gd-execute-class-ipython ()
  "Send class at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'class 'ipython nil nil))

(defun gd-execute-class-ipython-switch ()
  "Send class at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'class 'ipython nil 'switch))

(defun gd-execute-class-ipython-no-switch ()
  "Send class at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'class 'ipython nil 'no-switch))

(defun gd-execute-class-ipython-dedicated ()
  "Send class at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'class 'ipython t nil))

(defun gd-execute-class-ipython-dedicated-switch ()
  "Send class at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'class 'ipython t 'switch))

(defun gd-execute-class-ipython2.7 ()
  "Send class at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'class 'ipython2.7 nil nil))

(defun gd-execute-class-ipython2.7-switch ()
  "Send class at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'class 'ipython2.7 nil 'switch))

(defun gd-execute-class-ipython2.7-no-switch ()
  "Send class at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'class 'ipython2.7 nil 'no-switch))

(defun gd-execute-class-ipython2.7-dedicated ()
  "Send class at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'class 'ipython2.7 t nil))

(defun gd-execute-class-ipython2.7-dedicated-switch ()
  "Send class at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'class 'ipython2.7 t 'switch))

(defun gd-execute-class-ipython3 ()
  "Send class at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'class 'ipython3 nil nil))

(defun gd-execute-class-ipython3-switch ()
  "Send class at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'class 'ipython3 nil 'switch))

(defun gd-execute-class-ipython3-no-switch ()
  "Send class at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'class 'ipython3 nil 'no-switch))

(defun gd-execute-class-ipython3-dedicated ()
  "Send class at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'class 'ipython3 t nil))

(defun gd-execute-class-ipython3-dedicated-switch ()
  "Send class at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'class 'ipython3 t 'switch))

(defun gd-execute-class-jython ()
  "Send class at point to Jython interpreter. "
  (interactive)
  (py--execute-prepare 'class 'jython nil nil))

(defun gd-execute-class-jython-switch ()
  "Send class at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'class 'jython nil 'switch))

(defun gd-execute-class-jython-no-switch ()
  "Send class at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'class 'jython nil 'no-switch))

(defun gd-execute-class-jython-dedicated ()
  "Send class at point to Jython unique interpreter. "
  (interactive)
  (py--execute-prepare 'class 'jython t nil))

(defun gd-execute-class-jython-dedicated-switch ()
  "Send class at point to Jython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'class 'jython t 'switch))

(defun gd-execute-class-python ()
  "Send class at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'class 'python nil nil))

(defun gd-execute-class-gdscript-switch ()
  "Send class at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'class 'python nil 'switch))

(defun gd-execute-class-gdscript-no-switch ()
  "Send class at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'class 'python nil 'no-switch))

(defun gd-execute-class-gdscript-dedicated ()
  "Send class at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'class 'python t nil))

(defun gd-execute-class-gdscript-dedicated-switch ()
  "Send class at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'class 'python t 'switch))

(defun gd-execute-class-python2 ()
  "Send class at point to Python2 interpreter. "
  (interactive)
  (py--execute-prepare 'class 'python2 nil nil))

(defun gd-execute-class-python2-switch ()
  "Send class at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'class 'python2 nil 'switch))

(defun gd-execute-class-python2-no-switch ()
  "Send class at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'class 'python2 nil 'no-switch))

(defun gd-execute-class-python2-dedicated ()
  "Send class at point to Python2 unique interpreter. "
  (interactive)
  (py--execute-prepare 'class 'python2 t nil))

(defun gd-execute-class-python2-dedicated-switch ()
  "Send class at point to Python2 unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'class 'python2 t 'switch))

(defun gd-execute-class-python3 ()
  "Send class at point to Python3 interpreter. "
  (interactive)
  (py--execute-prepare 'class 'python3 nil nil))

(defun gd-execute-class-python3-switch ()
  "Send class at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'class 'python3 nil 'switch))

(defun gd-execute-class-python3-no-switch ()
  "Send class at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'class 'python3 nil 'no-switch))

(defun gd-execute-class-python3-dedicated ()
  "Send class at point to Python3 unique interpreter. "
  (interactive)
  (py--execute-prepare 'class 'python3 t nil))

(defun gd-execute-class-python3-dedicated-switch ()
  "Send class at point to Python3 unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'class 'python3 t 'switch))

(defun gd-execute-clause ()
  "Send clause at point to  interpreter. "
  (interactive)
  (py--execute-prepare 'clause nil  nil nil))

(defun gd-execute-clause-switch ()
  "Send clause at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'clause nil  nil 'switch))

(defun gd-execute-clause-no-switch ()
  "Send clause at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'clause nil  nil 'no-switch))

(defun gd-execute-clause-dedicated ()
  "Send clause at point to  unique interpreter. "
  (interactive)
  (py--execute-prepare 'clause nil  t nil))

(defun gd-execute-clause-dedicated-switch ()
  "Send clause at point to  unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'clause nil  t 'switch))

(defun gd-execute-clause-ipython ()
  "Send clause at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'clause 'ipython nil nil))

(defun gd-execute-clause-ipython-switch ()
  "Send clause at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'clause 'ipython nil 'switch))

(defun gd-execute-clause-ipython-no-switch ()
  "Send clause at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'clause 'ipython nil 'no-switch))

(defun gd-execute-clause-ipython-dedicated ()
  "Send clause at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'clause 'ipython t nil))

(defun gd-execute-clause-ipython-dedicated-switch ()
  "Send clause at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'clause 'ipython t 'switch))

(defun gd-execute-clause-ipython2.7 ()
  "Send clause at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'clause 'ipython2.7 nil nil))

(defun gd-execute-clause-ipython2.7-switch ()
  "Send clause at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'clause 'ipython2.7 nil 'switch))

(defun gd-execute-clause-ipython2.7-no-switch ()
  "Send clause at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'clause 'ipython2.7 nil 'no-switch))

(defun gd-execute-clause-ipython2.7-dedicated ()
  "Send clause at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'clause 'ipython2.7 t nil))

(defun gd-execute-clause-ipython2.7-dedicated-switch ()
  "Send clause at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'clause 'ipython2.7 t 'switch))

(defun gd-execute-clause-ipython3 ()
  "Send clause at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'clause 'ipython3 nil nil))

(defun gd-execute-clause-ipython3-switch ()
  "Send clause at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'clause 'ipython3 nil 'switch))

(defun gd-execute-clause-ipython3-no-switch ()
  "Send clause at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'clause 'ipython3 nil 'no-switch))

(defun gd-execute-clause-ipython3-dedicated ()
  "Send clause at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'clause 'ipython3 t nil))

(defun gd-execute-clause-ipython3-dedicated-switch ()
  "Send clause at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'clause 'ipython3 t 'switch))

(defun gd-execute-clause-jython ()
  "Send clause at point to Jython interpreter. "
  (interactive)
  (py--execute-prepare 'clause 'jython nil nil))

(defun gd-execute-clause-jython-switch ()
  "Send clause at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'clause 'jython nil 'switch))

(defun gd-execute-clause-jython-no-switch ()
  "Send clause at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'clause 'jython nil 'no-switch))

(defun gd-execute-clause-jython-dedicated ()
  "Send clause at point to Jython unique interpreter. "
  (interactive)
  (py--execute-prepare 'clause 'jython t nil))

(defun gd-execute-clause-jython-dedicated-switch ()
  "Send clause at point to Jython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'clause 'jython t 'switch))

(defun gd-execute-clause-python ()
  "Send clause at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'clause 'python nil nil))

(defun gd-execute-clause-gdscript-switch ()
  "Send clause at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'clause 'python nil 'switch))

(defun gd-execute-clause-gdscript-no-switch ()
  "Send clause at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'clause 'python nil 'no-switch))

(defun gd-execute-clause-gdscript-dedicated ()
  "Send clause at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'clause 'python t nil))

(defun gd-execute-clause-gdscript-dedicated-switch ()
  "Send clause at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'clause 'python t 'switch))

(defun gd-execute-clause-python2 ()
  "Send clause at point to Python2 interpreter. "
  (interactive)
  (py--execute-prepare 'clause 'python2 nil nil))

(defun gd-execute-clause-python2-switch ()
  "Send clause at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'clause 'python2 nil 'switch))

(defun gd-execute-clause-python2-no-switch ()
  "Send clause at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'clause 'python2 nil 'no-switch))

(defun gd-execute-clause-python2-dedicated ()
  "Send clause at point to Python2 unique interpreter. "
  (interactive)
  (py--execute-prepare 'clause 'python2 t nil))

(defun gd-execute-clause-python2-dedicated-switch ()
  "Send clause at point to Python2 unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'clause 'python2 t 'switch))

(defun gd-execute-clause-python3 ()
  "Send clause at point to Python3 interpreter. "
  (interactive)
  (py--execute-prepare 'clause 'python3 nil nil))

(defun gd-execute-clause-python3-switch ()
  "Send clause at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'clause 'python3 nil 'switch))

(defun gd-execute-clause-python3-no-switch ()
  "Send clause at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'clause 'python3 nil 'no-switch))

(defun gd-execute-clause-python3-dedicated ()
  "Send clause at point to Python3 unique interpreter. "
  (interactive)
  (py--execute-prepare 'clause 'python3 t nil))

(defun gd-execute-clause-python3-dedicated-switch ()
  "Send clause at point to Python3 unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'clause 'python3 t 'switch))

(defun gd-execute-def ()
  "Send def at point to  interpreter. "
  (interactive)
  (py--execute-prepare 'def nil  nil nil))

(defun gd-execute-def-switch ()
  "Send def at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'def nil  nil 'switch))

(defun gd-execute-def-no-switch ()
  "Send def at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'def nil  nil 'no-switch))

(defun gd-execute-def-dedicated ()
  "Send def at point to  unique interpreter. "
  (interactive)
  (py--execute-prepare 'def nil  t nil))

(defun gd-execute-def-dedicated-switch ()
  "Send def at point to  unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'def nil  t 'switch))

(defun gd-execute-def-ipython ()
  "Send def at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'def 'ipython nil nil))

(defun gd-execute-def-ipython-switch ()
  "Send def at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'def 'ipython nil 'switch))

(defun gd-execute-def-ipython-no-switch ()
  "Send def at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'def 'ipython nil 'no-switch))

(defun gd-execute-def-ipython-dedicated ()
  "Send def at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'def 'ipython t nil))

(defun gd-execute-def-ipython-dedicated-switch ()
  "Send def at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'def 'ipython t 'switch))

(defun gd-execute-def-ipython2.7 ()
  "Send def at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'def 'ipython2.7 nil nil))

(defun gd-execute-def-ipython2.7-switch ()
  "Send def at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'def 'ipython2.7 nil 'switch))

(defun gd-execute-def-ipython2.7-no-switch ()
  "Send def at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'def 'ipython2.7 nil 'no-switch))

(defun gd-execute-def-ipython2.7-dedicated ()
  "Send def at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'def 'ipython2.7 t nil))

(defun gd-execute-def-ipython2.7-dedicated-switch ()
  "Send def at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'def 'ipython2.7 t 'switch))

(defun gd-execute-def-ipython3 ()
  "Send def at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'def 'ipython3 nil nil))

(defun gd-execute-def-ipython3-switch ()
  "Send def at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'def 'ipython3 nil 'switch))

(defun gd-execute-def-ipython3-no-switch ()
  "Send def at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'def 'ipython3 nil 'no-switch))

(defun gd-execute-def-ipython3-dedicated ()
  "Send def at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'def 'ipython3 t nil))

(defun gd-execute-def-ipython3-dedicated-switch ()
  "Send def at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'def 'ipython3 t 'switch))

(defun gd-execute-def-jython ()
  "Send def at point to Jython interpreter. "
  (interactive)
  (py--execute-prepare 'def 'jython nil nil))

(defun gd-execute-def-jython-switch ()
  "Send def at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'def 'jython nil 'switch))

(defun gd-execute-def-jython-no-switch ()
  "Send def at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'def 'jython nil 'no-switch))

(defun gd-execute-def-jython-dedicated ()
  "Send def at point to Jython unique interpreter. "
  (interactive)
  (py--execute-prepare 'def 'jython t nil))

(defun gd-execute-def-jython-dedicated-switch ()
  "Send def at point to Jython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'def 'jython t 'switch))

(defun gd-execute-def-python ()
  "Send def at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'def 'python nil nil))

(defun gd-execute-def-gdscript-switch ()
  "Send def at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'def 'python nil 'switch))

(defun gd-execute-def-gdscript-no-switch ()
  "Send def at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'def 'python nil 'no-switch))

(defun gd-execute-def-gdscript-dedicated ()
  "Send def at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'def 'python t nil))

(defun gd-execute-def-gdscript-dedicated-switch ()
  "Send def at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'def 'python t 'switch))

(defun gd-execute-def-python2 ()
  "Send def at point to Python2 interpreter. "
  (interactive)
  (py--execute-prepare 'def 'python2 nil nil))

(defun gd-execute-def-python2-switch ()
  "Send def at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'def 'python2 nil 'switch))

(defun gd-execute-def-python2-no-switch ()
  "Send def at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'def 'python2 nil 'no-switch))

(defun gd-execute-def-python2-dedicated ()
  "Send def at point to Python2 unique interpreter. "
  (interactive)
  (py--execute-prepare 'def 'python2 t nil))

(defun gd-execute-def-python2-dedicated-switch ()
  "Send def at point to Python2 unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'def 'python2 t 'switch))

(defun gd-execute-def-python3 ()
  "Send def at point to Python3 interpreter. "
  (interactive)
  (py--execute-prepare 'def 'python3 nil nil))

(defun gd-execute-def-python3-switch ()
  "Send def at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'def 'python3 nil 'switch))

(defun gd-execute-def-python3-no-switch ()
  "Send def at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'def 'python3 nil 'no-switch))

(defun gd-execute-def-python3-dedicated ()
  "Send def at point to Python3 unique interpreter. "
  (interactive)
  (py--execute-prepare 'def 'python3 t nil))

(defun gd-execute-def-python3-dedicated-switch ()
  "Send def at point to Python3 unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'def 'python3 t 'switch))

(defun gd-execute-def-or-class ()
  "Send def-or-class at point to  interpreter. "
  (interactive)
  (py--execute-prepare 'def-or-class nil  nil nil))

(defun gd-execute-def-or-class-switch ()
  "Send def-or-class at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'def-or-class nil  nil 'switch))

(defun gd-execute-def-or-class-no-switch ()
  "Send def-or-class at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'def-or-class nil  nil 'no-switch))

(defun gd-execute-def-or-class-dedicated ()
  "Send def-or-class at point to  unique interpreter. "
  (interactive)
  (py--execute-prepare 'def-or-class nil  t nil))

(defun gd-execute-def-or-class-dedicated-switch ()
  "Send def-or-class at point to  unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'def-or-class nil  t 'switch))

(defun gd-execute-def-or-class-ipython ()
  "Send def-or-class at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'def-or-class 'ipython nil nil))

(defun gd-execute-def-or-class-ipython-switch ()
  "Send def-or-class at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'def-or-class 'ipython nil 'switch))

(defun gd-execute-def-or-class-ipython-no-switch ()
  "Send def-or-class at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'def-or-class 'ipython nil 'no-switch))

(defun gd-execute-def-or-class-ipython-dedicated ()
  "Send def-or-class at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'def-or-class 'ipython t nil))

(defun gd-execute-def-or-class-ipython-dedicated-switch ()
  "Send def-or-class at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'def-or-class 'ipython t 'switch))

(defun gd-execute-def-or-class-ipython2.7 ()
  "Send def-or-class at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'def-or-class 'ipython2.7 nil nil))

(defun gd-execute-def-or-class-ipython2.7-switch ()
  "Send def-or-class at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'def-or-class 'ipython2.7 nil 'switch))

(defun gd-execute-def-or-class-ipython2.7-no-switch ()
  "Send def-or-class at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'def-or-class 'ipython2.7 nil 'no-switch))

(defun gd-execute-def-or-class-ipython2.7-dedicated ()
  "Send def-or-class at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'def-or-class 'ipython2.7 t nil))

(defun gd-execute-def-or-class-ipython2.7-dedicated-switch ()
  "Send def-or-class at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'def-or-class 'ipython2.7 t 'switch))

(defun gd-execute-def-or-class-ipython3 ()
  "Send def-or-class at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'def-or-class 'ipython3 nil nil))

(defun gd-execute-def-or-class-ipython3-switch ()
  "Send def-or-class at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'def-or-class 'ipython3 nil 'switch))

(defun gd-execute-def-or-class-ipython3-no-switch ()
  "Send def-or-class at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'def-or-class 'ipython3 nil 'no-switch))

(defun gd-execute-def-or-class-ipython3-dedicated ()
  "Send def-or-class at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'def-or-class 'ipython3 t nil))

(defun gd-execute-def-or-class-ipython3-dedicated-switch ()
  "Send def-or-class at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'def-or-class 'ipython3 t 'switch))

(defun gd-execute-def-or-class-jython ()
  "Send def-or-class at point to Jython interpreter. "
  (interactive)
  (py--execute-prepare 'def-or-class 'jython nil nil))

(defun gd-execute-def-or-class-jython-switch ()
  "Send def-or-class at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'def-or-class 'jython nil 'switch))

(defun gd-execute-def-or-class-jython-no-switch ()
  "Send def-or-class at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'def-or-class 'jython nil 'no-switch))

(defun gd-execute-def-or-class-jython-dedicated ()
  "Send def-or-class at point to Jython unique interpreter. "
  (interactive)
  (py--execute-prepare 'def-or-class 'jython t nil))

(defun gd-execute-def-or-class-jython-dedicated-switch ()
  "Send def-or-class at point to Jython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'def-or-class 'jython t 'switch))

(defun gd-execute-def-or-class-python ()
  "Send def-or-class at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'def-or-class 'python nil nil))

(defun gd-execute-def-or-class-gdscript-switch ()
  "Send def-or-class at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'def-or-class 'python nil 'switch))

(defun gd-execute-def-or-class-gdscript-no-switch ()
  "Send def-or-class at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'def-or-class 'python nil 'no-switch))

(defun gd-execute-def-or-class-gdscript-dedicated ()
  "Send def-or-class at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'def-or-class 'python t nil))

(defun gd-execute-def-or-class-gdscript-dedicated-switch ()
  "Send def-or-class at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'def-or-class 'python t 'switch))

(defun gd-execute-def-or-class-python2 ()
  "Send def-or-class at point to Python2 interpreter. "
  (interactive)
  (py--execute-prepare 'def-or-class 'python2 nil nil))

(defun gd-execute-def-or-class-python2-switch ()
  "Send def-or-class at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'def-or-class 'python2 nil 'switch))

(defun gd-execute-def-or-class-python2-no-switch ()
  "Send def-or-class at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'def-or-class 'python2 nil 'no-switch))

(defun gd-execute-def-or-class-python2-dedicated ()
  "Send def-or-class at point to Python2 unique interpreter. "
  (interactive)
  (py--execute-prepare 'def-or-class 'python2 t nil))

(defun gd-execute-def-or-class-python2-dedicated-switch ()
  "Send def-or-class at point to Python2 unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'def-or-class 'python2 t 'switch))

(defun gd-execute-def-or-class-python3 ()
  "Send def-or-class at point to Python3 interpreter. "
  (interactive)
  (py--execute-prepare 'def-or-class 'python3 nil nil))

(defun gd-execute-def-or-class-python3-switch ()
  "Send def-or-class at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'def-or-class 'python3 nil 'switch))

(defun gd-execute-def-or-class-python3-no-switch ()
  "Send def-or-class at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'def-or-class 'python3 nil 'no-switch))

(defun gd-execute-def-or-class-python3-dedicated ()
  "Send def-or-class at point to Python3 unique interpreter. "
  (interactive)
  (py--execute-prepare 'def-or-class 'python3 t nil))

(defun gd-execute-def-or-class-python3-dedicated-switch ()
  "Send def-or-class at point to Python3 unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'def-or-class 'python3 t 'switch))

(defun gd-execute-expression ()
  "Send expression at point to  interpreter. "
  (interactive)
  (py--execute-prepare 'expression nil  nil nil))

(defun gd-execute-expression-switch ()
  "Send expression at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'expression nil  nil 'switch))

(defun gd-execute-expression-no-switch ()
  "Send expression at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'expression nil  nil 'no-switch))

(defun gd-execute-expression-dedicated ()
  "Send expression at point to  unique interpreter. "
  (interactive)
  (py--execute-prepare 'expression nil  t nil))

(defun gd-execute-expression-dedicated-switch ()
  "Send expression at point to  unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'expression nil  t 'switch))

(defun gd-execute-expression-ipython ()
  "Send expression at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'expression 'ipython nil nil))

(defun gd-execute-expression-ipython-switch ()
  "Send expression at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'expression 'ipython nil 'switch))

(defun gd-execute-expression-ipython-no-switch ()
  "Send expression at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'expression 'ipython nil 'no-switch))

(defun gd-execute-expression-ipython-dedicated ()
  "Send expression at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'expression 'ipython t nil))

(defun gd-execute-expression-ipython-dedicated-switch ()
  "Send expression at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'expression 'ipython t 'switch))

(defun gd-execute-expression-ipython2.7 ()
  "Send expression at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'expression 'ipython2.7 nil nil))

(defun gd-execute-expression-ipython2.7-switch ()
  "Send expression at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'expression 'ipython2.7 nil 'switch))

(defun gd-execute-expression-ipython2.7-no-switch ()
  "Send expression at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'expression 'ipython2.7 nil 'no-switch))

(defun gd-execute-expression-ipython2.7-dedicated ()
  "Send expression at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'expression 'ipython2.7 t nil))

(defun gd-execute-expression-ipython2.7-dedicated-switch ()
  "Send expression at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'expression 'ipython2.7 t 'switch))

(defun gd-execute-expression-ipython3 ()
  "Send expression at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'expression 'ipython3 nil nil))

(defun gd-execute-expression-ipython3-switch ()
  "Send expression at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'expression 'ipython3 nil 'switch))

(defun gd-execute-expression-ipython3-no-switch ()
  "Send expression at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'expression 'ipython3 nil 'no-switch))

(defun gd-execute-expression-ipython3-dedicated ()
  "Send expression at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'expression 'ipython3 t nil))

(defun gd-execute-expression-ipython3-dedicated-switch ()
  "Send expression at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'expression 'ipython3 t 'switch))

(defun gd-execute-expression-jython ()
  "Send expression at point to Jython interpreter. "
  (interactive)
  (py--execute-prepare 'expression 'jython nil nil))

(defun gd-execute-expression-jython-switch ()
  "Send expression at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'expression 'jython nil 'switch))

(defun gd-execute-expression-jython-no-switch ()
  "Send expression at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'expression 'jython nil 'no-switch))

(defun gd-execute-expression-jython-dedicated ()
  "Send expression at point to Jython unique interpreter. "
  (interactive)
  (py--execute-prepare 'expression 'jython t nil))

(defun gd-execute-expression-jython-dedicated-switch ()
  "Send expression at point to Jython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'expression 'jython t 'switch))

(defun gd-execute-expression-python ()
  "Send expression at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'expression 'python nil nil))

(defun gd-execute-expression-gdscript-switch ()
  "Send expression at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'expression 'python nil 'switch))

(defun gd-execute-expression-gdscript-no-switch ()
  "Send expression at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'expression 'python nil 'no-switch))

(defun gd-execute-expression-gdscript-dedicated ()
  "Send expression at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'expression 'python t nil))

(defun gd-execute-expression-gdscript-dedicated-switch ()
  "Send expression at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'expression 'python t 'switch))

(defun gd-execute-expression-python2 ()
  "Send expression at point to Python2 interpreter. "
  (interactive)
  (py--execute-prepare 'expression 'python2 nil nil))

(defun gd-execute-expression-python2-switch ()
  "Send expression at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'expression 'python2 nil 'switch))

(defun gd-execute-expression-python2-no-switch ()
  "Send expression at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'expression 'python2 nil 'no-switch))

(defun gd-execute-expression-python2-dedicated ()
  "Send expression at point to Python2 unique interpreter. "
  (interactive)
  (py--execute-prepare 'expression 'python2 t nil))

(defun gd-execute-expression-python2-dedicated-switch ()
  "Send expression at point to Python2 unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'expression 'python2 t 'switch))

(defun gd-execute-expression-python3 ()
  "Send expression at point to Python3 interpreter. "
  (interactive)
  (py--execute-prepare 'expression 'python3 nil nil))

(defun gd-execute-expression-python3-switch ()
  "Send expression at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'expression 'python3 nil 'switch))

(defun gd-execute-expression-python3-no-switch ()
  "Send expression at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'expression 'python3 nil 'no-switch))

(defun gd-execute-expression-python3-dedicated ()
  "Send expression at point to Python3 unique interpreter. "
  (interactive)
  (py--execute-prepare 'expression 'python3 t nil))

(defun gd-execute-expression-python3-dedicated-switch ()
  "Send expression at point to Python3 unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'expression 'python3 t 'switch))

(defun gd-execute-indent ()
  "Send indent at point to  interpreter. "
  (interactive)
  (py--execute-prepare 'indent nil  nil nil))

(defun gd-execute-indent-switch ()
  "Send indent at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'indent nil  nil 'switch))

(defun gd-execute-indent-no-switch ()
  "Send indent at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'indent nil  nil 'no-switch))

(defun gd-execute-indent-dedicated ()
  "Send indent at point to  unique interpreter. "
  (interactive)
  (py--execute-prepare 'indent nil  t nil))

(defun gd-execute-indent-dedicated-switch ()
  "Send indent at point to  unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'indent nil  t 'switch))

(defun gd-execute-indent-ipython ()
  "Send indent at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'indent 'ipython nil nil))

(defun gd-execute-indent-ipython-switch ()
  "Send indent at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'indent 'ipython nil 'switch))

(defun gd-execute-indent-ipython-no-switch ()
  "Send indent at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'indent 'ipython nil 'no-switch))

(defun gd-execute-indent-ipython-dedicated ()
  "Send indent at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'indent 'ipython t nil))

(defun gd-execute-indent-ipython-dedicated-switch ()
  "Send indent at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'indent 'ipython t 'switch))

(defun gd-execute-indent-ipython2.7 ()
  "Send indent at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'indent 'ipython2.7 nil nil))

(defun gd-execute-indent-ipython2.7-switch ()
  "Send indent at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'indent 'ipython2.7 nil 'switch))

(defun gd-execute-indent-ipython2.7-no-switch ()
  "Send indent at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'indent 'ipython2.7 nil 'no-switch))

(defun gd-execute-indent-ipython2.7-dedicated ()
  "Send indent at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'indent 'ipython2.7 t nil))

(defun gd-execute-indent-ipython2.7-dedicated-switch ()
  "Send indent at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'indent 'ipython2.7 t 'switch))

(defun gd-execute-indent-ipython3 ()
  "Send indent at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'indent 'ipython3 nil nil))

(defun gd-execute-indent-ipython3-switch ()
  "Send indent at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'indent 'ipython3 nil 'switch))

(defun gd-execute-indent-ipython3-no-switch ()
  "Send indent at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'indent 'ipython3 nil 'no-switch))

(defun gd-execute-indent-ipython3-dedicated ()
  "Send indent at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'indent 'ipython3 t nil))

(defun gd-execute-indent-ipython3-dedicated-switch ()
  "Send indent at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'indent 'ipython3 t 'switch))

(defun gd-execute-indent-jython ()
  "Send indent at point to Jython interpreter. "
  (interactive)
  (py--execute-prepare 'indent 'jython nil nil))

(defun gd-execute-indent-jython-switch ()
  "Send indent at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'indent 'jython nil 'switch))

(defun gd-execute-indent-jython-no-switch ()
  "Send indent at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'indent 'jython nil 'no-switch))

(defun gd-execute-indent-jython-dedicated ()
  "Send indent at point to Jython unique interpreter. "
  (interactive)
  (py--execute-prepare 'indent 'jython t nil))

(defun gd-execute-indent-jython-dedicated-switch ()
  "Send indent at point to Jython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'indent 'jython t 'switch))

(defun gd-execute-indent-python ()
  "Send indent at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'indent 'python nil nil))

(defun gd-execute-indent-gdscript-switch ()
  "Send indent at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'indent 'python nil 'switch))

(defun gd-execute-indent-gdscript-no-switch ()
  "Send indent at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'indent 'python nil 'no-switch))

(defun gd-execute-indent-gdscript-dedicated ()
  "Send indent at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'indent 'python t nil))

(defun gd-execute-indent-gdscript-dedicated-switch ()
  "Send indent at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'indent 'python t 'switch))

(defun gd-execute-indent-python2 ()
  "Send indent at point to Python2 interpreter. "
  (interactive)
  (py--execute-prepare 'indent 'python2 nil nil))

(defun gd-execute-indent-python2-switch ()
  "Send indent at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'indent 'python2 nil 'switch))

(defun gd-execute-indent-python2-no-switch ()
  "Send indent at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'indent 'python2 nil 'no-switch))

(defun gd-execute-indent-python2-dedicated ()
  "Send indent at point to Python2 unique interpreter. "
  (interactive)
  (py--execute-prepare 'indent 'python2 t nil))

(defun gd-execute-indent-python2-dedicated-switch ()
  "Send indent at point to Python2 unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'indent 'python2 t 'switch))

(defun gd-execute-indent-python3 ()
  "Send indent at point to Python3 interpreter. "
  (interactive)
  (py--execute-prepare 'indent 'python3 nil nil))

(defun gd-execute-indent-python3-switch ()
  "Send indent at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'indent 'python3 nil 'switch))

(defun gd-execute-indent-python3-no-switch ()
  "Send indent at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'indent 'python3 nil 'no-switch))

(defun gd-execute-indent-python3-dedicated ()
  "Send indent at point to Python3 unique interpreter. "
  (interactive)
  (py--execute-prepare 'indent 'python3 t nil))

(defun gd-execute-indent-python3-dedicated-switch ()
  "Send indent at point to Python3 unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'indent 'python3 t 'switch))

(defun gd-execute-line ()
  "Send line at point to  interpreter. "
  (interactive)
  (py--execute-prepare 'line nil  nil nil))

(defun gd-execute-line-switch ()
  "Send line at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'line nil  nil 'switch))

(defun gd-execute-line-no-switch ()
  "Send line at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'line nil  nil 'no-switch))

(defun gd-execute-line-dedicated ()
  "Send line at point to  unique interpreter. "
  (interactive)
  (py--execute-prepare 'line nil  t nil))

(defun gd-execute-line-dedicated-switch ()
  "Send line at point to  unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'line nil  t 'switch))

(defun gd-execute-line-ipython ()
  "Send line at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'line 'ipython nil nil))

(defun gd-execute-line-ipython-switch ()
  "Send line at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'line 'ipython nil 'switch))

(defun gd-execute-line-ipython-no-switch ()
  "Send line at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'line 'ipython nil 'no-switch))

(defun gd-execute-line-ipython-dedicated ()
  "Send line at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'line 'ipython t nil))

(defun gd-execute-line-ipython-dedicated-switch ()
  "Send line at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'line 'ipython t 'switch))

(defun gd-execute-line-ipython2.7 ()
  "Send line at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'line 'ipython2.7 nil nil))

(defun gd-execute-line-ipython2.7-switch ()
  "Send line at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'line 'ipython2.7 nil 'switch))

(defun gd-execute-line-ipython2.7-no-switch ()
  "Send line at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'line 'ipython2.7 nil 'no-switch))

(defun gd-execute-line-ipython2.7-dedicated ()
  "Send line at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'line 'ipython2.7 t nil))

(defun gd-execute-line-ipython2.7-dedicated-switch ()
  "Send line at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'line 'ipython2.7 t 'switch))

(defun gd-execute-line-ipython3 ()
  "Send line at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'line 'ipython3 nil nil))

(defun gd-execute-line-ipython3-switch ()
  "Send line at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'line 'ipython3 nil 'switch))

(defun gd-execute-line-ipython3-no-switch ()
  "Send line at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'line 'ipython3 nil 'no-switch))

(defun gd-execute-line-ipython3-dedicated ()
  "Send line at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'line 'ipython3 t nil))

(defun gd-execute-line-ipython3-dedicated-switch ()
  "Send line at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'line 'ipython3 t 'switch))

(defun gd-execute-line-jython ()
  "Send line at point to Jython interpreter. "
  (interactive)
  (py--execute-prepare 'line 'jython nil nil))

(defun gd-execute-line-jython-switch ()
  "Send line at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'line 'jython nil 'switch))

(defun gd-execute-line-jython-no-switch ()
  "Send line at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'line 'jython nil 'no-switch))

(defun gd-execute-line-jython-dedicated ()
  "Send line at point to Jython unique interpreter. "
  (interactive)
  (py--execute-prepare 'line 'jython t nil))

(defun gd-execute-line-jython-dedicated-switch ()
  "Send line at point to Jython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'line 'jython t 'switch))

(defun gd-execute-line-python ()
  "Send line at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'line 'python nil nil))

(defun gd-execute-line-gdscript-switch ()
  "Send line at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'line 'python nil 'switch))

(defun gd-execute-line-gdscript-no-switch ()
  "Send line at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'line 'python nil 'no-switch))

(defun gd-execute-line-gdscript-dedicated ()
  "Send line at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'line 'python t nil))

(defun gd-execute-line-gdscript-dedicated-switch ()
  "Send line at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'line 'python t 'switch))

(defun gd-execute-line-python2 ()
  "Send line at point to Python2 interpreter. "
  (interactive)
  (py--execute-prepare 'line 'python2 nil nil))

(defun gd-execute-line-python2-switch ()
  "Send line at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'line 'python2 nil 'switch))

(defun gd-execute-line-python2-no-switch ()
  "Send line at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'line 'python2 nil 'no-switch))

(defun gd-execute-line-python2-dedicated ()
  "Send line at point to Python2 unique interpreter. "
  (interactive)
  (py--execute-prepare 'line 'python2 t nil))

(defun gd-execute-line-python2-dedicated-switch ()
  "Send line at point to Python2 unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'line 'python2 t 'switch))

(defun gd-execute-line-python3 ()
  "Send line at point to Python3 interpreter. "
  (interactive)
  (py--execute-prepare 'line 'python3 nil nil))

(defun gd-execute-line-python3-switch ()
  "Send line at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'line 'python3 nil 'switch))

(defun gd-execute-line-python3-no-switch ()
  "Send line at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'line 'python3 nil 'no-switch))

(defun gd-execute-line-python3-dedicated ()
  "Send line at point to Python3 unique interpreter. "
  (interactive)
  (py--execute-prepare 'line 'python3 t nil))

(defun gd-execute-line-python3-dedicated-switch ()
  "Send line at point to Python3 unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'line 'python3 t 'switch))

(defun gd-execute-minor-block ()
  "Send minor-block at point to  interpreter. "
  (interactive)
  (py--execute-prepare 'minor-block nil  nil nil))

(defun gd-execute-minor-block-switch ()
  "Send minor-block at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'minor-block nil  nil 'switch))

(defun gd-execute-minor-block-no-switch ()
  "Send minor-block at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'minor-block nil  nil 'no-switch))

(defun gd-execute-minor-block-dedicated ()
  "Send minor-block at point to  unique interpreter. "
  (interactive)
  (py--execute-prepare 'minor-block nil  t nil))

(defun gd-execute-minor-block-dedicated-switch ()
  "Send minor-block at point to  unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'minor-block nil  t 'switch))

(defun gd-execute-minor-block-ipython ()
  "Send minor-block at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'minor-block 'ipython nil nil))

(defun gd-execute-minor-block-ipython-switch ()
  "Send minor-block at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'minor-block 'ipython nil 'switch))

(defun gd-execute-minor-block-ipython-no-switch ()
  "Send minor-block at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'minor-block 'ipython nil 'no-switch))

(defun gd-execute-minor-block-ipython-dedicated ()
  "Send minor-block at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'minor-block 'ipython t nil))

(defun gd-execute-minor-block-ipython-dedicated-switch ()
  "Send minor-block at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'minor-block 'ipython t 'switch))

(defun gd-execute-minor-block-ipython2.7 ()
  "Send minor-block at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'minor-block 'ipython2.7 nil nil))

(defun gd-execute-minor-block-ipython2.7-switch ()
  "Send minor-block at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'minor-block 'ipython2.7 nil 'switch))

(defun gd-execute-minor-block-ipython2.7-no-switch ()
  "Send minor-block at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'minor-block 'ipython2.7 nil 'no-switch))

(defun gd-execute-minor-block-ipython2.7-dedicated ()
  "Send minor-block at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'minor-block 'ipython2.7 t nil))

(defun gd-execute-minor-block-ipython2.7-dedicated-switch ()
  "Send minor-block at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'minor-block 'ipython2.7 t 'switch))

(defun gd-execute-minor-block-ipython3 ()
  "Send minor-block at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'minor-block 'ipython3 nil nil))

(defun gd-execute-minor-block-ipython3-switch ()
  "Send minor-block at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'minor-block 'ipython3 nil 'switch))

(defun gd-execute-minor-block-ipython3-no-switch ()
  "Send minor-block at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'minor-block 'ipython3 nil 'no-switch))

(defun gd-execute-minor-block-ipython3-dedicated ()
  "Send minor-block at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'minor-block 'ipython3 t nil))

(defun gd-execute-minor-block-ipython3-dedicated-switch ()
  "Send minor-block at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'minor-block 'ipython3 t 'switch))

(defun gd-execute-minor-block-jython ()
  "Send minor-block at point to Jython interpreter. "
  (interactive)
  (py--execute-prepare 'minor-block 'jython nil nil))

(defun gd-execute-minor-block-jython-switch ()
  "Send minor-block at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'minor-block 'jython nil 'switch))

(defun gd-execute-minor-block-jython-no-switch ()
  "Send minor-block at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'minor-block 'jython nil 'no-switch))

(defun gd-execute-minor-block-jython-dedicated ()
  "Send minor-block at point to Jython unique interpreter. "
  (interactive)
  (py--execute-prepare 'minor-block 'jython t nil))

(defun gd-execute-minor-block-jython-dedicated-switch ()
  "Send minor-block at point to Jython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'minor-block 'jython t 'switch))

(defun gd-execute-minor-block-python ()
  "Send minor-block at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'minor-block 'python nil nil))

(defun gd-execute-minor-block-gdscript-switch ()
  "Send minor-block at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'minor-block 'python nil 'switch))

(defun gd-execute-minor-block-gdscript-no-switch ()
  "Send minor-block at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'minor-block 'python nil 'no-switch))

(defun gd-execute-minor-block-gdscript-dedicated ()
  "Send minor-block at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'minor-block 'python t nil))

(defun gd-execute-minor-block-gdscript-dedicated-switch ()
  "Send minor-block at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'minor-block 'python t 'switch))

(defun gd-execute-minor-block-python2 ()
  "Send minor-block at point to Python2 interpreter. "
  (interactive)
  (py--execute-prepare 'minor-block 'python2 nil nil))

(defun gd-execute-minor-block-python2-switch ()
  "Send minor-block at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'minor-block 'python2 nil 'switch))

(defun gd-execute-minor-block-python2-no-switch ()
  "Send minor-block at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'minor-block 'python2 nil 'no-switch))

(defun gd-execute-minor-block-python2-dedicated ()
  "Send minor-block at point to Python2 unique interpreter. "
  (interactive)
  (py--execute-prepare 'minor-block 'python2 t nil))

(defun gd-execute-minor-block-python2-dedicated-switch ()
  "Send minor-block at point to Python2 unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'minor-block 'python2 t 'switch))

(defun gd-execute-minor-block-python3 ()
  "Send minor-block at point to Python3 interpreter. "
  (interactive)
  (py--execute-prepare 'minor-block 'python3 nil nil))

(defun gd-execute-minor-block-python3-switch ()
  "Send minor-block at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'minor-block 'python3 nil 'switch))

(defun gd-execute-minor-block-python3-no-switch ()
  "Send minor-block at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'minor-block 'python3 nil 'no-switch))

(defun gd-execute-minor-block-python3-dedicated ()
  "Send minor-block at point to Python3 unique interpreter. "
  (interactive)
  (py--execute-prepare 'minor-block 'python3 t nil))

(defun gd-execute-minor-block-python3-dedicated-switch ()
  "Send minor-block at point to Python3 unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'minor-block 'python3 t 'switch))

(defun gd-execute-paragraph ()
  "Send paragraph at point to  interpreter. "
  (interactive)
  (py--execute-prepare 'paragraph nil  nil nil))

(defun gd-execute-paragraph-switch ()
  "Send paragraph at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'paragraph nil  nil 'switch))

(defun gd-execute-paragraph-no-switch ()
  "Send paragraph at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'paragraph nil  nil 'no-switch))

(defun gd-execute-paragraph-dedicated ()
  "Send paragraph at point to  unique interpreter. "
  (interactive)
  (py--execute-prepare 'paragraph nil  t nil))

(defun gd-execute-paragraph-dedicated-switch ()
  "Send paragraph at point to  unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'paragraph nil  t 'switch))

(defun gd-execute-paragraph-ipython ()
  "Send paragraph at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'paragraph 'ipython nil nil))

(defun gd-execute-paragraph-ipython-switch ()
  "Send paragraph at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'paragraph 'ipython nil 'switch))

(defun gd-execute-paragraph-ipython-no-switch ()
  "Send paragraph at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'paragraph 'ipython nil 'no-switch))

(defun gd-execute-paragraph-ipython-dedicated ()
  "Send paragraph at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'paragraph 'ipython t nil))

(defun gd-execute-paragraph-ipython-dedicated-switch ()
  "Send paragraph at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'paragraph 'ipython t 'switch))

(defun gd-execute-paragraph-ipython2.7 ()
  "Send paragraph at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'paragraph 'ipython2.7 nil nil))

(defun gd-execute-paragraph-ipython2.7-switch ()
  "Send paragraph at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'paragraph 'ipython2.7 nil 'switch))

(defun gd-execute-paragraph-ipython2.7-no-switch ()
  "Send paragraph at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'paragraph 'ipython2.7 nil 'no-switch))

(defun gd-execute-paragraph-ipython2.7-dedicated ()
  "Send paragraph at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'paragraph 'ipython2.7 t nil))

(defun gd-execute-paragraph-ipython2.7-dedicated-switch ()
  "Send paragraph at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'paragraph 'ipython2.7 t 'switch))

(defun gd-execute-paragraph-ipython3 ()
  "Send paragraph at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'paragraph 'ipython3 nil nil))

(defun gd-execute-paragraph-ipython3-switch ()
  "Send paragraph at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'paragraph 'ipython3 nil 'switch))

(defun gd-execute-paragraph-ipython3-no-switch ()
  "Send paragraph at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'paragraph 'ipython3 nil 'no-switch))

(defun gd-execute-paragraph-ipython3-dedicated ()
  "Send paragraph at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'paragraph 'ipython3 t nil))

(defun gd-execute-paragraph-ipython3-dedicated-switch ()
  "Send paragraph at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'paragraph 'ipython3 t 'switch))

(defun gd-execute-paragraph-jython ()
  "Send paragraph at point to Jython interpreter. "
  (interactive)
  (py--execute-prepare 'paragraph 'jython nil nil))

(defun gd-execute-paragraph-jython-switch ()
  "Send paragraph at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'paragraph 'jython nil 'switch))

(defun gd-execute-paragraph-jython-no-switch ()
  "Send paragraph at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'paragraph 'jython nil 'no-switch))

(defun gd-execute-paragraph-jython-dedicated ()
  "Send paragraph at point to Jython unique interpreter. "
  (interactive)
  (py--execute-prepare 'paragraph 'jython t nil))

(defun gd-execute-paragraph-jython-dedicated-switch ()
  "Send paragraph at point to Jython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'paragraph 'jython t 'switch))

(defun gd-execute-paragraph-python ()
  "Send paragraph at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'paragraph 'python nil nil))

(defun gd-execute-paragraph-gdscript-switch ()
  "Send paragraph at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'paragraph 'python nil 'switch))

(defun gd-execute-paragraph-gdscript-no-switch ()
  "Send paragraph at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'paragraph 'python nil 'no-switch))

(defun gd-execute-paragraph-gdscript-dedicated ()
  "Send paragraph at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'paragraph 'python t nil))

(defun gd-execute-paragraph-gdscript-dedicated-switch ()
  "Send paragraph at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'paragraph 'python t 'switch))

(defun gd-execute-paragraph-python2 ()
  "Send paragraph at point to Python2 interpreter. "
  (interactive)
  (py--execute-prepare 'paragraph 'python2 nil nil))

(defun gd-execute-paragraph-python2-switch ()
  "Send paragraph at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'paragraph 'python2 nil 'switch))

(defun gd-execute-paragraph-python2-no-switch ()
  "Send paragraph at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'paragraph 'python2 nil 'no-switch))

(defun gd-execute-paragraph-python2-dedicated ()
  "Send paragraph at point to Python2 unique interpreter. "
  (interactive)
  (py--execute-prepare 'paragraph 'python2 t nil))

(defun gd-execute-paragraph-python2-dedicated-switch ()
  "Send paragraph at point to Python2 unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'paragraph 'python2 t 'switch))

(defun gd-execute-paragraph-python3 ()
  "Send paragraph at point to Python3 interpreter. "
  (interactive)
  (py--execute-prepare 'paragraph 'python3 nil nil))

(defun gd-execute-paragraph-python3-switch ()
  "Send paragraph at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'paragraph 'python3 nil 'switch))

(defun gd-execute-paragraph-python3-no-switch ()
  "Send paragraph at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'paragraph 'python3 nil 'no-switch))

(defun gd-execute-paragraph-python3-dedicated ()
  "Send paragraph at point to Python3 unique interpreter. "
  (interactive)
  (py--execute-prepare 'paragraph 'python3 t nil))

(defun gd-execute-paragraph-python3-dedicated-switch ()
  "Send paragraph at point to Python3 unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'paragraph 'python3 t 'switch))

(defun gd-execute-partial-expression ()
  "Send partial-expression at point to  interpreter. "
  (interactive)
  (py--execute-prepare 'partial-expression nil  nil nil))

(defun gd-execute-partial-expression-switch ()
  "Send partial-expression at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'partial-expression nil  nil 'switch))

(defun gd-execute-partial-expression-no-switch ()
  "Send partial-expression at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'partial-expression nil  nil 'no-switch))

(defun gd-execute-partial-expression-dedicated ()
  "Send partial-expression at point to  unique interpreter. "
  (interactive)
  (py--execute-prepare 'partial-expression nil  t nil))

(defun gd-execute-partial-expression-dedicated-switch ()
  "Send partial-expression at point to  unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'partial-expression nil  t 'switch))

(defun gd-execute-partial-expression-ipython ()
  "Send partial-expression at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'partial-expression 'ipython nil nil))

(defun gd-execute-partial-expression-ipython-switch ()
  "Send partial-expression at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'partial-expression 'ipython nil 'switch))

(defun gd-execute-partial-expression-ipython-no-switch ()
  "Send partial-expression at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'partial-expression 'ipython nil 'no-switch))

(defun gd-execute-partial-expression-ipython-dedicated ()
  "Send partial-expression at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'partial-expression 'ipython t nil))

(defun gd-execute-partial-expression-ipython-dedicated-switch ()
  "Send partial-expression at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'partial-expression 'ipython t 'switch))

(defun gd-execute-partial-expression-ipython2.7 ()
  "Send partial-expression at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'partial-expression 'ipython2.7 nil nil))

(defun gd-execute-partial-expression-ipython2.7-switch ()
  "Send partial-expression at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'partial-expression 'ipython2.7 nil 'switch))

(defun gd-execute-partial-expression-ipython2.7-no-switch ()
  "Send partial-expression at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'partial-expression 'ipython2.7 nil 'no-switch))

(defun gd-execute-partial-expression-ipython2.7-dedicated ()
  "Send partial-expression at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'partial-expression 'ipython2.7 t nil))

(defun gd-execute-partial-expression-ipython2.7-dedicated-switch ()
  "Send partial-expression at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'partial-expression 'ipython2.7 t 'switch))

(defun gd-execute-partial-expression-ipython3 ()
  "Send partial-expression at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'partial-expression 'ipython3 nil nil))

(defun gd-execute-partial-expression-ipython3-switch ()
  "Send partial-expression at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'partial-expression 'ipython3 nil 'switch))

(defun gd-execute-partial-expression-ipython3-no-switch ()
  "Send partial-expression at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'partial-expression 'ipython3 nil 'no-switch))

(defun gd-execute-partial-expression-ipython3-dedicated ()
  "Send partial-expression at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'partial-expression 'ipython3 t nil))

(defun gd-execute-partial-expression-ipython3-dedicated-switch ()
  "Send partial-expression at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'partial-expression 'ipython3 t 'switch))

(defun gd-execute-partial-expression-jython ()
  "Send partial-expression at point to Jython interpreter. "
  (interactive)
  (py--execute-prepare 'partial-expression 'jython nil nil))

(defun gd-execute-partial-expression-jython-switch ()
  "Send partial-expression at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'partial-expression 'jython nil 'switch))

(defun gd-execute-partial-expression-jython-no-switch ()
  "Send partial-expression at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'partial-expression 'jython nil 'no-switch))

(defun gd-execute-partial-expression-jython-dedicated ()
  "Send partial-expression at point to Jython unique interpreter. "
  (interactive)
  (py--execute-prepare 'partial-expression 'jython t nil))

(defun gd-execute-partial-expression-jython-dedicated-switch ()
  "Send partial-expression at point to Jython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'partial-expression 'jython t 'switch))

(defun gd-execute-partial-expression-python ()
  "Send partial-expression at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'partial-expression 'python nil nil))

(defun gd-execute-partial-expression-gdscript-switch ()
  "Send partial-expression at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'partial-expression 'python nil 'switch))

(defun gd-execute-partial-expression-gdscript-no-switch ()
  "Send partial-expression at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'partial-expression 'python nil 'no-switch))

(defun gd-execute-partial-expression-gdscript-dedicated ()
  "Send partial-expression at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'partial-expression 'python t nil))

(defun gd-execute-partial-expression-gdscript-dedicated-switch ()
  "Send partial-expression at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'partial-expression 'python t 'switch))

(defun gd-execute-partial-expression-python2 ()
  "Send partial-expression at point to Python2 interpreter. "
  (interactive)
  (py--execute-prepare 'partial-expression 'python2 nil nil))

(defun gd-execute-partial-expression-python2-switch ()
  "Send partial-expression at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'partial-expression 'python2 nil 'switch))

(defun gd-execute-partial-expression-python2-no-switch ()
  "Send partial-expression at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'partial-expression 'python2 nil 'no-switch))

(defun gd-execute-partial-expression-python2-dedicated ()
  "Send partial-expression at point to Python2 unique interpreter. "
  (interactive)
  (py--execute-prepare 'partial-expression 'python2 t nil))

(defun gd-execute-partial-expression-python2-dedicated-switch ()
  "Send partial-expression at point to Python2 unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'partial-expression 'python2 t 'switch))

(defun gd-execute-partial-expression-python3 ()
  "Send partial-expression at point to Python3 interpreter. "
  (interactive)
  (py--execute-prepare 'partial-expression 'python3 nil nil))

(defun gd-execute-partial-expression-python3-switch ()
  "Send partial-expression at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'partial-expression 'python3 nil 'switch))

(defun gd-execute-partial-expression-python3-no-switch ()
  "Send partial-expression at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'partial-expression 'python3 nil 'no-switch))

(defun gd-execute-partial-expression-python3-dedicated ()
  "Send partial-expression at point to Python3 unique interpreter. "
  (interactive)
  (py--execute-prepare 'partial-expression 'python3 t nil))

(defun gd-execute-partial-expression-python3-dedicated-switch ()
  "Send partial-expression at point to Python3 unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'partial-expression 'python3 t 'switch))

(defun gd-execute-region (beg end)
  "Send region at point to  interpreter. "
  (interactive "r")
  (py--execute-prepare 'region nil  nil nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-switch (beg end)
  "Send region at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive "r")
  (py--execute-prepare 'region nil  nil 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-no-switch (beg end)
  "Send region at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive "r")
  (py--execute-prepare 'region nil  nil 'no-switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-dedicated (beg end)
  "Send region at point to  unique interpreter. "
  (interactive "r")
  (py--execute-prepare 'region nil  t nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-dedicated-switch (beg end)
  "Send region at point to  unique interpreter and switch to result. "
  (interactive "r")
  (py--execute-prepare 'region nil  t 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython (beg end)
  "Send region at point to IPython interpreter. "
  (interactive "r")
  (py--execute-prepare 'region 'ipython nil nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython-switch (beg end)
  "Send region at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive "r")
  (py--execute-prepare 'region 'ipython nil 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython-no-switch (beg end)
  "Send region at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive "r")
  (py--execute-prepare 'region 'ipython nil 'no-switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython-dedicated (beg end)
  "Send region at point to IPython unique interpreter. "
  (interactive "r")
  (py--execute-prepare 'region 'ipython t nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython-dedicated-switch (beg end)
  "Send region at point to IPython unique interpreter and switch to result. "
  (interactive "r")
  (py--execute-prepare 'region 'ipython t 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython2.7 (beg end)
  "Send region at point to IPython interpreter. "
  (interactive "r")
  (py--execute-prepare 'region 'ipython2.7 nil nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython2.7-switch (beg end)
  "Send region at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive "r")
  (py--execute-prepare 'region 'ipython2.7 nil 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython2.7-no-switch (beg end)
  "Send region at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive "r")
  (py--execute-prepare 'region 'ipython2.7 nil 'no-switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython2.7-dedicated (beg end)
  "Send region at point to IPython unique interpreter. "
  (interactive "r")
  (py--execute-prepare 'region 'ipython2.7 t nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython2.7-dedicated-switch (beg end)
  "Send region at point to IPython unique interpreter and switch to result. "
  (interactive "r")
  (py--execute-prepare 'region 'ipython2.7 t 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython3 (beg end)
  "Send region at point to IPython interpreter. "
  (interactive "r")
  (py--execute-prepare 'region 'ipython3 nil nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython3-switch (beg end)
  "Send region at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive "r")
  (py--execute-prepare 'region 'ipython3 nil 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython3-no-switch (beg end)
  "Send region at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive "r")
  (py--execute-prepare 'region 'ipython3 nil 'no-switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython3-dedicated (beg end)
  "Send region at point to IPython unique interpreter. "
  (interactive "r")
  (py--execute-prepare 'region 'ipython3 t nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython3-dedicated-switch (beg end)
  "Send region at point to IPython unique interpreter and switch to result. "
  (interactive "r")
  (py--execute-prepare 'region 'ipython3 t 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-jython (beg end)
  "Send region at point to Jython interpreter. "
  (interactive "r")
  (py--execute-prepare 'region 'jython nil nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-jython-switch (beg end)
  "Send region at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive "r")
  (py--execute-prepare 'region 'jython nil 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-jython-no-switch (beg end)
  "Send region at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive "r")
  (py--execute-prepare 'region 'jython nil 'no-switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-jython-dedicated (beg end)
  "Send region at point to Jython unique interpreter. "
  (interactive "r")
  (py--execute-prepare 'region 'jython t nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-jython-dedicated-switch (beg end)
  "Send region at point to Jython unique interpreter and switch to result. "
  (interactive "r")
  (py--execute-prepare 'region 'jython t 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-python (beg end)
  "Send region at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive "r")
  (py--execute-prepare 'region 'python nil nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-gdscript-switch (beg end)
  "Send region at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive "r")
  (py--execute-prepare 'region 'python nil 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-gdscript-no-switch (beg end)
  "Send region at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive "r")
  (py--execute-prepare 'region 'python nil 'no-switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-gdscript-dedicated (beg end)
  "Send region at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive "r")
  (py--execute-prepare 'region 'python t nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-gdscript-dedicated-switch (beg end)
  "Send region at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive "r")
  (py--execute-prepare 'region 'python t 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-python2 (beg end)
  "Send region at point to Python2 interpreter. "
  (interactive "r")
  (py--execute-prepare 'region 'python2 nil nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-python2-switch (beg end)
  "Send region at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive "r")
  (py--execute-prepare 'region 'python2 nil 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-python2-no-switch (beg end)
  "Send region at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive "r")
  (py--execute-prepare 'region 'python2 nil 'no-switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-python2-dedicated (beg end)
  "Send region at point to Python2 unique interpreter. "
  (interactive "r")
  (py--execute-prepare 'region 'python2 t nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-python2-dedicated-switch (beg end)
  "Send region at point to Python2 unique interpreter and switch to result. "
  (interactive "r")
  (py--execute-prepare 'region 'python2 t 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-python3 (beg end)
  "Send region at point to Python3 interpreter. "
  (interactive "r")
  (py--execute-prepare 'region 'python3 nil nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-python3-switch (beg end)
  "Send region at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive "r")
  (py--execute-prepare 'region 'python3 nil 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-python3-no-switch (beg end)
  "Send region at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive "r")
  (py--execute-prepare 'region 'python3 nil 'no-switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-python3-dedicated (beg end)
  "Send region at point to Python3 unique interpreter. "
  (interactive "r")
  (py--execute-prepare 'region 'python3 t nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-python3-dedicated-switch (beg end)
  "Send region at point to Python3 unique interpreter and switch to result. "
  (interactive "r")
  (py--execute-prepare 'region 'python3 t 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-statement ()
  "Send statement at point to  interpreter. "
  (interactive)
  (py--execute-prepare 'statement nil  nil nil))

(defun gd-execute-statement-switch ()
  "Send statement at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'statement nil  nil 'switch))

(defun gd-execute-statement-no-switch ()
  "Send statement at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'statement nil  nil 'no-switch))

(defun gd-execute-statement-dedicated ()
  "Send statement at point to  unique interpreter. "
  (interactive)
  (py--execute-prepare 'statement nil  t nil))

(defun gd-execute-statement-dedicated-switch ()
  "Send statement at point to  unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'statement nil  t 'switch))

(defun gd-execute-statement-ipython ()
  "Send statement at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'statement 'ipython nil nil))

(defun gd-execute-statement-ipython-switch ()
  "Send statement at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'statement 'ipython nil 'switch))

(defun gd-execute-statement-ipython-no-switch ()
  "Send statement at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'statement 'ipython nil 'no-switch))

(defun gd-execute-statement-ipython-dedicated ()
  "Send statement at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'statement 'ipython t nil))

(defun gd-execute-statement-ipython-dedicated-switch ()
  "Send statement at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'statement 'ipython t 'switch))

(defun gd-execute-statement-ipython2.7 ()
  "Send statement at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'statement 'ipython2.7 nil nil))

(defun gd-execute-statement-ipython2.7-switch ()
  "Send statement at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'statement 'ipython2.7 nil 'switch))

(defun gd-execute-statement-ipython2.7-no-switch ()
  "Send statement at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'statement 'ipython2.7 nil 'no-switch))

(defun gd-execute-statement-ipython2.7-dedicated ()
  "Send statement at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'statement 'ipython2.7 t nil))

(defun gd-execute-statement-ipython2.7-dedicated-switch ()
  "Send statement at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'statement 'ipython2.7 t 'switch))

(defun gd-execute-statement-ipython3 ()
  "Send statement at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'statement 'ipython3 nil nil))

(defun gd-execute-statement-ipython3-switch ()
  "Send statement at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'statement 'ipython3 nil 'switch))

(defun gd-execute-statement-ipython3-no-switch ()
  "Send statement at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'statement 'ipython3 nil 'no-switch))

(defun gd-execute-statement-ipython3-dedicated ()
  "Send statement at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'statement 'ipython3 t nil))

(defun gd-execute-statement-ipython3-dedicated-switch ()
  "Send statement at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'statement 'ipython3 t 'switch))

(defun gd-execute-statement-jython ()
  "Send statement at point to Jython interpreter. "
  (interactive)
  (py--execute-prepare 'statement 'jython nil nil))

(defun gd-execute-statement-jython-switch ()
  "Send statement at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'statement 'jython nil 'switch))

(defun gd-execute-statement-jython-no-switch ()
  "Send statement at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'statement 'jython nil 'no-switch))

(defun gd-execute-statement-jython-dedicated ()
  "Send statement at point to Jython unique interpreter. "
  (interactive)
  (py--execute-prepare 'statement 'jython t nil))

(defun gd-execute-statement-jython-dedicated-switch ()
  "Send statement at point to Jython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'statement 'jython t 'switch))

(defun gd-execute-statement-python ()
  "Send statement at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'statement 'python nil nil))

(defun gd-execute-statement-gdscript-switch ()
  "Send statement at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'statement 'python nil 'switch))

(defun gd-execute-statement-gdscript-no-switch ()
  "Send statement at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'statement 'python nil 'no-switch))

(defun gd-execute-statement-gdscript-dedicated ()
  "Send statement at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'statement 'python t nil))

(defun gd-execute-statement-gdscript-dedicated-switch ()
  "Send statement at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'statement 'python t 'switch))

(defun gd-execute-statement-python2 ()
  "Send statement at point to Python2 interpreter. "
  (interactive)
  (py--execute-prepare 'statement 'python2 nil nil))

(defun gd-execute-statement-python2-switch ()
  "Send statement at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'statement 'python2 nil 'switch))

(defun gd-execute-statement-python2-no-switch ()
  "Send statement at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'statement 'python2 nil 'no-switch))

(defun gd-execute-statement-python2-dedicated ()
  "Send statement at point to Python2 unique interpreter. "
  (interactive)
  (py--execute-prepare 'statement 'python2 t nil))

(defun gd-execute-statement-python2-dedicated-switch ()
  "Send statement at point to Python2 unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'statement 'python2 t 'switch))

(defun gd-execute-statement-python3 ()
  "Send statement at point to Python3 interpreter. "
  (interactive)
  (py--execute-prepare 'statement 'python3 nil nil))

(defun gd-execute-statement-python3-switch ()
  "Send statement at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'statement 'python3 nil 'switch))

(defun gd-execute-statement-python3-no-switch ()
  "Send statement at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'statement 'python3 nil 'no-switch))

(defun gd-execute-statement-python3-dedicated ()
  "Send statement at point to Python3 unique interpreter. "
  (interactive)
  (py--execute-prepare 'statement 'python3 t nil))

(defun gd-execute-statement-python3-dedicated-switch ()
  "Send statement at point to Python3 unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'statement 'python3 t 'switch))

(defun gd-execute-top-level ()
  "Send top-level at point to  interpreter. "
  (interactive)
  (py--execute-prepare 'top-level nil  nil nil))

(defun gd-execute-top-level-switch ()
  "Send top-level at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'top-level nil  nil 'switch))

(defun gd-execute-top-level-no-switch ()
  "Send top-level at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'top-level nil  nil 'no-switch))

(defun gd-execute-top-level-dedicated ()
  "Send top-level at point to  unique interpreter. "
  (interactive)
  (py--execute-prepare 'top-level nil  t nil))

(defun gd-execute-top-level-dedicated-switch ()
  "Send top-level at point to  unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'top-level nil  t 'switch))

(defun gd-execute-top-level-ipython ()
  "Send top-level at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'top-level 'ipython nil nil))

(defun gd-execute-top-level-ipython-switch ()
  "Send top-level at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'top-level 'ipython nil 'switch))

(defun gd-execute-top-level-ipython-no-switch ()
  "Send top-level at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'top-level 'ipython nil 'no-switch))

(defun gd-execute-top-level-ipython-dedicated ()
  "Send top-level at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'top-level 'ipython t nil))

(defun gd-execute-top-level-ipython-dedicated-switch ()
  "Send top-level at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'top-level 'ipython t 'switch))

(defun gd-execute-top-level-ipython2.7 ()
  "Send top-level at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'top-level 'ipython2.7 nil nil))

(defun gd-execute-top-level-ipython2.7-switch ()
  "Send top-level at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'top-level 'ipython2.7 nil 'switch))

(defun gd-execute-top-level-ipython2.7-no-switch ()
  "Send top-level at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'top-level 'ipython2.7 nil 'no-switch))

(defun gd-execute-top-level-ipython2.7-dedicated ()
  "Send top-level at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'top-level 'ipython2.7 t nil))

(defun gd-execute-top-level-ipython2.7-dedicated-switch ()
  "Send top-level at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'top-level 'ipython2.7 t 'switch))

(defun gd-execute-top-level-ipython3 ()
  "Send top-level at point to IPython interpreter. "
  (interactive)
  (py--execute-prepare 'top-level 'ipython3 nil nil))

(defun gd-execute-top-level-ipython3-switch ()
  "Send top-level at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'top-level 'ipython3 nil 'switch))

(defun gd-execute-top-level-ipython3-no-switch ()
  "Send top-level at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'top-level 'ipython3 nil 'no-switch))

(defun gd-execute-top-level-ipython3-dedicated ()
  "Send top-level at point to IPython unique interpreter. "
  (interactive)
  (py--execute-prepare 'top-level 'ipython3 t nil))

(defun gd-execute-top-level-ipython3-dedicated-switch ()
  "Send top-level at point to IPython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'top-level 'ipython3 t 'switch))

(defun gd-execute-top-level-jython ()
  "Send top-level at point to Jython interpreter. "
  (interactive)
  (py--execute-prepare 'top-level 'jython nil nil))

(defun gd-execute-top-level-jython-switch ()
  "Send top-level at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'top-level 'jython nil 'switch))

(defun gd-execute-top-level-jython-no-switch ()
  "Send top-level at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'top-level 'jython nil 'no-switch))

(defun gd-execute-top-level-jython-dedicated ()
  "Send top-level at point to Jython unique interpreter. "
  (interactive)
  (py--execute-prepare 'top-level 'jython t nil))

(defun gd-execute-top-level-jython-dedicated-switch ()
  "Send top-level at point to Jython unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'top-level 'jython t 'switch))

(defun gd-execute-top-level-python ()
  "Send top-level at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'top-level 'python nil nil))

(defun gd-execute-top-level-gdscript-switch ()
  "Send top-level at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'top-level 'python nil 'switch))

(defun gd-execute-top-level-gdscript-no-switch ()
  "Send top-level at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'top-level 'python nil 'no-switch))

(defun gd-execute-top-level-gdscript-dedicated ()
  "Send top-level at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'top-level 'python t nil))

(defun gd-execute-top-level-gdscript-dedicated-switch ()
  "Send top-level at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (py--execute-prepare 'top-level 'python t 'switch))

(defun gd-execute-top-level-python2 ()
  "Send top-level at point to Python2 interpreter. "
  (interactive)
  (py--execute-prepare 'top-level 'python2 nil nil))

(defun gd-execute-top-level-python2-switch ()
  "Send top-level at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'top-level 'python2 nil 'switch))

(defun gd-execute-top-level-python2-no-switch ()
  "Send top-level at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'top-level 'python2 nil 'no-switch))

(defun gd-execute-top-level-python2-dedicated ()
  "Send top-level at point to Python2 unique interpreter. "
  (interactive)
  (py--execute-prepare 'top-level 'python2 t nil))

(defun gd-execute-top-level-python2-dedicated-switch ()
  "Send top-level at point to Python2 unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'top-level 'python2 t 'switch))

(defun gd-execute-top-level-python3 ()
  "Send top-level at point to Python3 interpreter. "
  (interactive)
  (py--execute-prepare 'top-level 'python3 nil nil))

(defun gd-execute-top-level-python3-switch ()
  "Send top-level at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (py--execute-prepare 'top-level 'python3 nil 'switch))

(defun gd-execute-top-level-python3-no-switch ()
  "Send top-level at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (py--execute-prepare 'top-level 'python3 nil 'no-switch))

(defun gd-execute-top-level-python3-dedicated ()
  "Send top-level at point to Python3 unique interpreter. "
  (interactive)
  (py--execute-prepare 'top-level 'python3 t nil))

(defun gd-execute-top-level-python3-dedicated-switch ()
  "Send top-level at point to Python3 unique interpreter and switch to result. "
  (interactive)
  (py--execute-prepare 'top-level 'python3 t 'switch))

;; gdscript-abbrev-propose

(defun gd-edit-abbrevs ()
  "Jumps to `gdscript-mode-abbrev-table' in a buffer containing lists of abbrev definitions.
You can edit them and type \\<edit-abbrevs-map>\\[edit-abbrevs-redefine] to redefine abbrevs
according to your editing.
Buffer contains a header line for each abbrev table,
 which is the abbrev table name in parentheses.
This is followed by one line per abbrev in that table:
NAME   USECOUNT   EXPANSION   HOOK
where NAME and EXPANSION are strings with quotes,
USECOUNT is an integer, and HOOK is any valid function
or may be omitted (it is usually omitted).  "
  (interactive)
  (save-excursion
    (let ((mat (abbrev-table-name local-abbrev-table)))
      (prepare-abbrev-list-buffer)
      (set-buffer "*Abbrevs*")
      (switch-to-buffer (current-buffer))
      (goto-char (point-min))
      (search-forward (concat "(" (format "%s" mat))))))

(defun py--add-abbrev-propose (table type arg &optional dont-ask)
  (save-excursion
    (let ((orig (point))
          proposal exp name)
      (while (< 0 arg)
        (gd-beginning-of-partial-expression)
        (when (looking-at "[[:alpha:]]")
          (setq proposal (concat (downcase (match-string-no-properties 0)) proposal)))
        (setq arg (1- arg)))
      (setq exp (buffer-substring-no-properties (point) orig))
      (setq name
            ;; ask only when interactive
            (if dont-ask
                proposal
              (read-string (format (if exp "%s abbrev for \"%s\": "
                                     "Undefine %s abbrev: ")
                                   type exp) proposal)))
      (set-text-properties 0 (length name) nil name)
      (when (or (null exp)
                (not (abbrev-expansion name table))
                (y-or-n-p (format "%s expands to \"%s\"; redefine? "
                                  name (abbrev-expansion name table))))
        (define-abbrev table (downcase name) exp)))))

(defun gd-add-abbrev (arg)
  "Defines gdscript-mode specific abbrev for last expressions before point.
Argument is how many `gd-partial-expression's form the expansion; or zero means the region is the expansion.

Reads the abbreviation in the minibuffer; with numeric arg it displays a proposal for an abbrev.
Proposal is composed from the initial character(s) of the
expansion.

Don't use this function in a Lisp program; use `define-abbrev' instead."
  (interactive "p")
  (save-excursion
    (py--add-abbrev-propose
     (if only-global-abbrevs
         global-abbrev-table
       (or local-abbrev-table
           (error "No per-mode abbrev table")))
     "Mode" arg)))

;; gdscript-components-paragraph

(defun gd-fill-string-django (&optional justify)
  "Fill docstring according to Django's coding standards style.

    \"\"\"
    Process foo, return bar.
    \"\"\"

    \"\"\"
    Process foo, return bar.

    If processing fails throw ProcessingError.
    \"\"\"

See available styles at `gd-fill-paragraph' or var `gd-docstring-style'
"
  (interactive "*P")
  (gd-fill-string justify 'django t))

(defun gd-fill-string-onetwo (&optional justify)
  "One newline and start and Two at end style.

    \"\"\"Process foo, return bar.\"\"\"

    \"\"\"
    Process foo, return bar.

    If processing fails throw ProcessingError.

    \"\"\"

See available styles at `gd-fill-paragraph' or var `gd-docstring-style'
"
  (interactive "*P")
  (gd-fill-string justify 'onetwo t))

(defun gd-fill-string-pep-257 (&optional justify)
  "PEP-257 with 2 newlines at end of string.

    \"\"\"Process foo, return bar.\"\"\"

    \"\"\"Process foo, return bar.

    If processing fails throw ProcessingError.

    \"\"\"

See available styles at `gd-fill-paragraph' or var `gd-docstring-style'
"
  (interactive "*P")
  (gd-fill-string justify 'pep-257 t))

(defun gd-fill-string-pep-257-nn (&optional justify)
  "PEP-257 with 1 newline at end of string.

    \"\"\"Process foo, return bar.\"\"\"

    \"\"\"Process foo, return bar.

    If processing fails throw ProcessingError.
    \"\"\"

See available styles at `gd-fill-paragraph' or var `gd-docstring-style'
"
  (interactive "*P")
  (gd-fill-string justify 'pep-257-nn t))

(defun gd-fill-string-symmetric (&optional justify)
  "Symmetric style.

    \"\"\"Process foo, return bar.\"\"\"

    \"\"\"
    Process foo, return bar.

    If processing fails throw ProcessingError.
    \"\"\"

See available styles at `gd-fill-paragraph' or var `gd-docstring-style'
"
  (interactive "*P")
  (gd-fill-string justify 'symmetric t))


(defun gd-set-nil-docstring-style ()
  "Set gd-docstring-style to 'nil"
  (interactive)
  (setq gd-docstring-style 'nil)
  (when (and (called-interactively-p 'any) gd-verbose-p)
    (message "docstring-style set to:  %s" gd-docstring-style)))

(defun gd-set-pep-257-nn-docstring-style ()
  "Set gd-docstring-style to 'pep-257-nn"
  (interactive)
  (setq gd-docstring-style 'pep-257-nn)
  (when (and (called-interactively-p 'any) gd-verbose-p)
    (message "docstring-style set to:  %s" gd-docstring-style)))

(defun gd-set-pep-257-docstring-style ()
  "Set gd-docstring-style to 'pep-257"
  (interactive)
  (setq gd-docstring-style 'pep-257)
  (when (and (called-interactively-p 'any) gd-verbose-p)
    (message "docstring-style set to:  %s" gd-docstring-style)))

(defun gd-set-django-docstring-style ()
  "Set gd-docstring-style to 'django"
  (interactive)
  (setq gd-docstring-style 'django)
  (when (and (called-interactively-p 'any) gd-verbose-p)
    (message "docstring-style set to:  %s" gd-docstring-style)))

(defun gd-set-symmetric-docstring-style ()
  "Set gd-docstring-style to 'symmetric"
  (interactive)
  (setq gd-docstring-style 'symmetric)
  (when (and (called-interactively-p 'any) gd-verbose-p)
    (message "docstring-style set to:  %s" gd-docstring-style)))

(defun gd-set-onetwo-docstring-style ()
  "Set gd-docstring-style to 'onetwo"
  (interactive)
  (setq gd-docstring-style 'onetwo)
  (when (and (called-interactively-p 'any) gd-verbose-p)
    (message "docstring-style set to:  %s" gd-docstring-style)))

(defun gd-fill-decorator (&optional justify)
  "Decorator fill function for `gd-fill-paragraph'.
"
  ;; (interactive "*P")
  t)

(defun gd-fill-comment (&optional justify)
  "Fill the comment paragraph at point"
  (interactive "*P")
  (let (;; Non-nil if the current line contains a comment.
        has-comment

        ;; If has-comment, the appropriate fill-prefix (format "%s" r the comment.
        comment-fill-prefix)

    ;; Figure out what kind of comment we are looking at.
    (save-excursion
      (beginning-of-line)
      (cond
       ;; A line with nothing but a comment on it?
       ((looking-at "[ \t]*#[# \t]*")
        (setq has-comment t
              comment-fill-prefix (buffer-substring (match-beginning 0)
                                                    (match-end 0))))

       ;; A line with some code, followed by a comment? Remember that the hash
       ;; which starts the comment shouldn't be part of a string or character.
       ((progn
          (while (not (looking-at "#\\|$"))
            (skip-chars-forward "^#\n\"'\\")
            (cond
             ((eq (char-after (point)) ?\\) (forward-char 2))
             ((memq (char-after (point)) '(?\" ?')) (forward-sexp 1))))
          (looking-at "#+[\t ]*"))
        (setq has-comment t)
        (setq comment-fill-prefix
              (concat (make-string (current-column) ? )
                      (buffer-substring (match-beginning 0) (match-end 0)))))))

    (if (not has-comment)
        (fill-paragraph justify)

      ;; Narrow to include only the comment, and then fill the region.
      (save-restriction
        (narrow-to-region

         ;; Find the first line we should include in the region to fill.
         (save-excursion
           (while (and (zerop (forward-line -1))
                       (looking-at "^[ \t]*#")))

           ;; We may have gone to far.  Go forward again.
           (or (looking-at "^[ \t]*#")
               (forward-line 1))
           (point))

         ;; Find the beginning of the first line past the region to fill.
         (save-excursion
           (while (progn (forward-line 1)
                         (looking-at "^[ \t]*#")))
           (point)))

        ;; Lines with only hashes on them can be paragraph boundaries.
        (let ((paragraph-start (concat paragraph-start "\\|[ \t#]*$"))
              (paragraph-separate (concat paragraph-separate "\\|[ \t#]*$"))
              (fill-prefix comment-fill-prefix))
          ;;(message "paragraph-start %S paragraph-separate %S"
          ;;paragraph-start paragraph-separate)
          (fill-paragraph justify))))
    t))

(defun gd-fill-labelled-string (beg end)
  "Fill string or paragraph containing lines starting with label

See lp:1066489 "
  (interactive "r*")
  (let ((end (copy-marker end))
        (last (copy-marker (point)))
        this-beg this-end)
    (save-excursion
      (save-restriction
        ;; (narrow-to-region beg end)
        (goto-char beg)
        (skip-chars-forward " \t\r\n\f")
        (if (looking-at gd-labelled-re)
            (progn
              (setq this-beg (line-beginning-position))
              (goto-char (match-end 0))
              (while (and (not (eobp)) (re-search-forward gd-labelled-re end t 1)(< last (match-beginning 0))(setq last (match-beginning 0)))
                (save-match-data (fill-region this-beg (1- (line-beginning-position))))
                (setq this-beg (line-beginning-position))
                (goto-char (match-end 0)))))))))

(defun py--in-or-behind-or-before-a-docstring ()
  (interactive "*")
  (save-excursion
    (let* ((raw-pps (nth 8 (parse-partial-sexp (point-min) (point))))
	   ;; ;; maybe just behind a string
	   (n8 (or raw-pps
		   ;; maybe in front of a string
		   (back-to-indentation)
		   (nth 8 (parse-partial-sexp (point-min) (point)))))
	   (n8pps (or n8
		      (when
			  (equal (string-to-syntax "|")
				 (syntax-after (point)))
			(and
			  (< 0 (skip-chars-forward "\"'"))
			  (nth 8 (parse-partial-sexp (point-min) (point))))))))
      (and n8pps (py--docstring-p n8pps)))))

(defun py--string-fence-delete-spaces (&optional start)
  "Delete spaces following or preceding delimiters of string at point. "
  (interactive "*")
  (let ((beg (or start (nth 8 (parse-partial-sexp (point-min) (point))))))
    (save-excursion
      (goto-char beg)
      (skip-chars-forward "\"'rRuU")
      (delete-region (point) (progn (skip-chars-forward " \t\r\n\f")(point)))
      (goto-char beg)
      (forward-char 1)
      (skip-syntax-forward "^\|")
      (skip-chars-backward "\"'rRuU")
      ;; (delete-region (point) (progn (skip-chars-backward " \t\r\n\f")(point)))
)))

(defun py--skip-raw-string-front-fence ()
  "Skip forward chars u, U, r, R followed by string-delimiters. "
  (when (member (char-after) (list ?u ?U ?r ?R))
    (forward-char 1))
  (skip-chars-forward "\'\""))

(defun py--fill-fix-end (thisend orig docstring delimiters-style)
  ;; Add the number of newlines indicated by the selected style
  ;; at the end.
  ;; (widen)
  (goto-char thisend)
  (skip-chars-backward "\"'\n ")
  (delete-region (point) (progn (skip-chars-forward " \t\r\n\f") (point)))
  (unless (eq (char-after) ?\n)
    (and
     (cdr delimiters-style)
     (or (newline (cdr delimiters-style)) t)))
  (gd-indent-region docstring thisend)
  (goto-char orig))

(defun py--fill-docstring-base (thisbeg thisend style multi-line-p first-line-p beg end gd-current-indent orig docstring)
  ;; (widen)
  ;; fill-paragraph causes wrong indent, lp:1397936
  ;; (narrow-to-region thisbeg thisend)
  (let ((delimiters-style
	 (case style
	   ;; delimiters-style is a cons cell with the form
	   ;; (START-NEWLINES .  END-NEWLINES). When any of the sexps
	   ;; is NIL means to not add any newlines for start or end
	   ;; of docstring.  See `gd-docstring-style' for a
	   ;; graphic idea of each style.
	   (django (cons 1 1))
	   (onetwo (and multi-line-p (cons 1 2)))
	   (pep-257 (and multi-line-p (cons nil 2)))
	   (pep-257-nn (and multi-line-p (cons nil 1)))
	   (symmetric (and multi-line-p (cons 1 1))))))
    ;;  (save-excursion
    (when style
      ;; Add the number of newlines indicated by the selected style
      ;; at the start.
      (goto-char thisbeg)
      (py--skip-raw-string-front-fence)
      (skip-chars-forward "\'\"")
      (when
	  (car delimiters-style)
	(unless (or (empty-line-p)(eolp))
	  (newline (car delimiters-style))))
      (indent-region beg end gd-current-indent))
    (when multi-line-p
      (goto-char thisbeg)
      (py--skip-raw-string-front-fence) 
      (skip-chars-forward " \t\r\n\f")
      (forward-line 1)
      (beginning-of-line)
      (unless (empty-line-p) (newline)))
    (py--fill-fix-end thisend orig docstring delimiters-style)))

(defun py--fill-docstring-last-line (thisbeg thisend beg end style orig first-line-p gd-current-indent)
  (widen)
  ;; (narrow-to-region thisbeg thisend)
  (goto-char thisend)
  (skip-chars-backward "\"'")
  (delete-region (point) (progn (skip-chars-backward " \t\r\n\f")(point)))
  ;; (narrow-to-region beg end)
  (fill-region beg end)
  (setq multi-line-p (string-match "\n" (buffer-substring-no-properties beg end)))
  (when multi-line-p
    ;; adjust the region to fill according to style
    (goto-char end)
    (py--fill-docstring-base thisbeg thisend style multi-line-p first-line-p beg end gd-current-indent orig docstring))
  (goto-char orig))

(defun py--fill-docstring-first-line (beg end thisbeg thisend style)
  "Refill first line after newline maybe. "
  (fill-region beg (line-end-position))
  (forward-line 1)
  (fill-region (line-beginning-position) end)
  (save-restriction
    (widen)
    (setq multi-line-p (string-match "\n" (buffer-substring-no-properties thisbeg thisend))))
  (when multi-line-p
    ;; adjust the region to fill according to style
    (goto-char beg)
    (skip-chars-forward "\"'")
    ;; style might be nil
    (when style
      (unless (or (eq style 'pep-257-nn)(eq style 'pep-257)(eq (char-after) ?\n))
	(newline-and-indent)
	;; if TQS is at a single line, re-fill remaining line
	(fill-region (point) end)))))

(defun py--fill-docstring (justify style docstring orig gd-current-indent)
  ;; Delete spaces after/before string fence
  (py--string-fence-delete-spaces docstring)
  (let* ((thisbeg (copy-marker docstring))
         (thisend (copy-marker
                   (progn
                     (goto-char thisbeg)
		     (py--skip-raw-string-front-fence)
		     (skip-syntax-forward "^\|")
                     (point))))
         (parabeg (progn (goto-char orig) (py--beginning-of-paragraph-position)))
         (paraend (progn (goto-char orig) (py--end-of-paragraph-position)))
         ;; if paragraph is a substring, take it
         (beg (copy-marker (if (< thisbeg parabeg) parabeg thisbeg)))
         (end (copy-marker (if (< thisend paraend) thisend paraend)))
	 (multi-line-p (string-match "\n" (buffer-substring-no-properties thisbeg thisend)))
	 erg
         first-line-p)
    ;;    (narrow-to-region beg end)
    (goto-char beg)
    (setq first-line-p (member (char-after) (list ?\" ?\' ?u ?U ?r ?R)))
    (cond ((string-match (concat "^" gd-labelled-re) (buffer-substring-no-properties beg end))
           (gd-fill-labelled-string beg end))
          (first-line-p
           (py--fill-docstring-first-line beg end thisbeg thisend style))
          ((save-excursion (goto-char end)
			   (or (member (char-after) (list ?\" ?\'))
			       (member (char-before) (list ?\" ?\'))))
           (py--fill-docstring-last-line thisbeg thisend beg end style orig first-line-p gd-current-indent))
          (t ;; (narrow-to-region beg end)
	     (fill-region beg end justify)))
    (py--fill-docstring-base thisbeg thisend style multi-line-p first-line-p beg end gd-current-indent orig docstring)))

(defun gd-fill-string (&optional justify style docstring)
  "String fill function for `gd-fill-paragraph'.
JUSTIFY should be used (if applicable) as in `fill-paragraph'.

Fill according to `gd-docstring-style' "
  (interactive
   (list
    (progn
      (barf-if-buffer-read-only)
      (list (if current-prefix-arg 'full) t))
    gd-docstring-style
    (or docstring (py--in-or-behind-or-before-a-docstring))))
  (let ((gd-current-indent (save-excursion (or (py--beginning-of-statement-p) (gd-backward-statement)) (current-indentation)))
	;; fill-paragraph sets orig
	(orig (if (boundp 'orig) (copy-marker orig) (copy-marker (point))))
	(docstring (if (and docstring (not (number-or-marker-p docstring)))
		       (py--in-or-behind-or-before-a-docstring)
		     docstring)))
    (if docstring
	(py--fill-docstring justify style docstring orig gd-current-indent)
      (fill-paragraph justify))))

(defun gd-fill-paragraph (&optional justify)
  (interactive "*")
  (save-excursion
    (save-restriction
      (window-configuration-to-register gd-windows-config-register)
      (if (or (gd-in-comment-p)
	      (and (bolp) (looking-at "[ \t]*#[# \t]*")))
	  (gd-fill-comment)
	(let* ((orig (copy-marker (point)))
	       (docstring (unless (not gd-docstring-style)(py--in-or-behind-or-before-a-docstring))))
	  (cond (docstring
		 (setq fill-column gd-docstring-fill-column)
		 (gd-fill-string justify gd-docstring-style docstring))
		((let ((fill-column gd-comment-fill-column))
		   (fill-comment-paragraph justify)))
		((save-excursion
		   (and (gd-backward-statement)
			(equal (char-after) ?\@)))
		 (gd-fill-decorator justify))
		(t (fill-paragraph justify)))
	  (widen))
	(jump-to-register gd-windows-config-register)))))

;; gdscript-components-shift-forms


(defalias 'gd-shift-region-left 'gd-shift-left)
(defun gd-shift-left (&optional count start end)
  "Dedent region according to `gd-indent-offset' by COUNT times.

If no region is active, current line is dedented.
Returns indentation reached. "
  (interactive "p")
  (let ((erg (py--shift-intern (- count) start end)))
    (when (and (called-interactively-p 'any) gd-verbose-p) (message "%s" erg))
    erg))

(defalias 'gd-shift-region-right 'gd-shift-right)
(defun gd-shift-right (&optional count beg end)
  "Indent region according to `gd-indent-offset' by COUNT times.

If no region is active, current line is indented.
Returns indentation reached. "
  (interactive "p")
  (let ((erg (py--shift-intern count beg end)))
    (when (and (called-interactively-p 'any) gd-verbose-p) (message "%s" erg))
    erg))

(defun py--shift-intern (count &optional start end)
  (save-excursion
    (let* ((inhibit-point-motion-hooks t)
           deactivate-mark
           (beg (cond (start)
                      ((region-active-p)
                       (save-excursion
                         (goto-char
                          (region-beginning))))
                      (t (line-beginning-position))))
           (end (cond (end)
                      ((region-active-p)
                       (save-excursion
                         (goto-char
                          (region-end))))
                      (t (line-end-position))))
           (orig end))
      (setq beg (copy-marker beg))
      (setq end (copy-marker end))
      (if (< 0 count)
          (indent-rigidly beg end gd-indent-offset)
        (indent-rigidly beg end (- gd-indent-offset)))
      (push-mark beg t)
      (goto-char end)
      (skip-chars-backward " \t\r\n\f"))
    (gd-indentation-of-statement)))

(defun py--shift-forms-base (form arg &optional beg end)
  (let* ((begform (intern-soft (concat "gd-backward-" form)))
         (endform (intern-soft (concat "gd-forward-" form)))
         (orig (copy-marker (point)))
         (beg (cond (beg)
                    ((region-active-p)
                     (save-excursion
                       (goto-char (region-beginning))
                       (line-beginning-position)))
                    (t (save-excursion
                         (funcall begform)
                         (line-beginning-position)))))
         (end (cond (end)
                    ((region-active-p)
                     (region-end))
                    (t (funcall endform))))
         (erg (py--shift-intern arg beg end)))
    (goto-char orig)
    erg))

(defun gd-shift-block-right (&optional arg)
  "Indent block by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (py--shift-forms-base "block" (or arg gd-indent-offset))))
        (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-block-left (&optional arg)
  "Dedent block by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (py--shift-forms-base "block" (- (or arg gd-indent-offset)))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-block-or-clause-right (&optional arg)
  "Indent block-or-clause by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (py--shift-forms-base "block-or-clause" (or arg gd-indent-offset))))
        (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-block-or-clause-left (&optional arg)
  "Dedent block-or-clause by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (py--shift-forms-base "block-or-clause" (- (or arg gd-indent-offset)))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-class-right (&optional arg)
  "Indent class by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (py--shift-forms-base "class" (or arg gd-indent-offset))))
        (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-class-left (&optional arg)
  "Dedent class by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (py--shift-forms-base "class" (- (or arg gd-indent-offset)))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-clause-right (&optional arg)
  "Indent clause by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (py--shift-forms-base "clause" (or arg gd-indent-offset))))
        (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-clause-left (&optional arg)
  "Dedent clause by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (py--shift-forms-base "clause" (- (or arg gd-indent-offset)))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-comment-right (&optional arg)
  "Indent comment by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (py--shift-forms-base "comment" (or arg gd-indent-offset))))
        (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-comment-left (&optional arg)
  "Dedent comment by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (py--shift-forms-base "comment" (- (or arg gd-indent-offset)))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-def-right (&optional arg)
  "Indent def by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (py--shift-forms-base "def" (or arg gd-indent-offset))))
        (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-def-left (&optional arg)
  "Dedent def by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (py--shift-forms-base "def" (- (or arg gd-indent-offset)))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-def-or-class-right (&optional arg)
  "Indent def-or-class by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (py--shift-forms-base "def-or-class" (or arg gd-indent-offset))))
        (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-def-or-class-left (&optional arg)
  "Dedent def-or-class by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (py--shift-forms-base "def-or-class" (- (or arg gd-indent-offset)))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-indent-right (&optional arg)
  "Indent indent by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (py--shift-forms-base "indent" (or arg gd-indent-offset))))
        (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-indent-left (&optional arg)
  "Dedent indent by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (py--shift-forms-base "indent" (- (or arg gd-indent-offset)))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-minor-block-right (&optional arg)
  "Indent minor-block by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (py--shift-forms-base "minor-block" (or arg gd-indent-offset))))
        (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-minor-block-left (&optional arg)
  "Dedent minor-block by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (py--shift-forms-base "minor-block" (- (or arg gd-indent-offset)))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-paragraph-right (&optional arg)
  "Indent paragraph by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (py--shift-forms-base "paragraph" (or arg gd-indent-offset))))
        (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-paragraph-left (&optional arg)
  "Dedent paragraph by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (py--shift-forms-base "paragraph" (- (or arg gd-indent-offset)))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-region-right (&optional arg)
  "Indent region by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (py--shift-forms-base "region" (or arg gd-indent-offset))))
        (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-region-left (&optional arg)
  "Dedent region by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (py--shift-forms-base "region" (- (or arg gd-indent-offset)))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-statement-right (&optional arg)
  "Indent statement by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (py--shift-forms-base "statement" (or arg gd-indent-offset))))
        (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-statement-left (&optional arg)
  "Dedent statement by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (py--shift-forms-base "statement" (- (or arg gd-indent-offset)))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-top-level-right (&optional arg)
  "Indent top-level by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (py--shift-forms-base "top-level" (or arg gd-indent-offset))))
        (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-top-level-left (&optional arg)
  "Dedent top-level by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (py--shift-forms-base "top-level" (- (or arg gd-indent-offset)))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

;; gdscript-components-execute-file

;;  Execute file commands

(defun gd-execute-file-python (&optional filename)
  "Send file to GDScript default interpreter."
  (interactive "fFile: ")
  (py--execute-prepare filename "python" nil nil nil nil t))

(defun gd-execute-file-gdscript-switch (&optional filename)
  "Send file to GDScript default interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (py--execute-prepare filename "python" nil 'switch nil nil t))

(defun gd-execute-file-gdscript-no-switch (&optional filename)
  "Send file to GDScript default interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"nil\""
  (interactive "fFile: ")
  (py--execute-prepare filename "python" nil 'no-switch nil nil t))

(defun gd-execute-file-gdscript-dedicated (&optional filename)
  "Send file to GDScript default interpreter.

Uses a dedicated shell."
  (interactive "fFile: ")
  (py--execute-prepare filename "python" 'dedicated nil nil nil t))

(defun gd-execute-file-gdscript-dedicated-switch (&optional filename)
  "Send file to GDScript default interpreter.

Uses a dedicated shell.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (py--execute-prepare filename "python" 'dedicated 'switch nil nil t))

(defun gd-execute-file-ipython (&optional filename)
  "Send file to a Ipython interpreter."
  (interactive "fFile: ")
  (py--execute-prepare filename "ipython" nil nil nil nil t))

(defun gd-execute-file-ipython-switch (&optional filename)
  "Send file to a Ipython interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (py--execute-prepare filename "ipython" nil 'switch nil nil t))

(defun gd-execute-file-ipython-no-switch (&optional filename)
  "Send file to a Ipython interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"nil\""
  (interactive "fFile: ")
  (py--execute-prepare filename "ipython" nil 'no-switch nil nil t))

(defun gd-execute-file-ipython-dedicated (&optional filename)
  "Send file to a Ipython interpreter.

Uses a dedicated shell."
  (interactive "fFile: ")
  (py--execute-prepare filename "ipython" 'dedicated nil nil nil t))

(defun gd-execute-file-ipython-dedicated-switch (&optional filename)
  "Send file to a Ipython interpreter.

Uses a dedicated shell.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (py--execute-prepare filename "ipython" 'dedicated 'switch nil nil t))

(defun gd-execute-file-python3 (&optional filename)
  "Send file to a Python3 interpreter."
  (interactive "fFile: ")
  (py--execute-prepare filename "python3" nil nil nil nil t))

(defun gd-execute-file-python3-switch (&optional filename)
  "Send file to a Python3 interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (py--execute-prepare filename "python3" nil 'switch nil nil t))

(defun gd-execute-file-python3-no-switch (&optional filename)
  "Send file to a Python3 interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"nil\""
  (interactive "fFile: ")
  (py--execute-prepare filename "python3" nil 'no-switch nil nil t))

(defun gd-execute-file-python3-dedicated (&optional filename)
  "Send file to a Python3 interpreter.

Uses a dedicated shell."
  (interactive "fFile: ")
  (py--execute-prepare filename "python3" 'dedicated nil nil nil t))

(defun gd-execute-file-python3-dedicated-switch (&optional filename)
  "Send file to a Python3 interpreter.

Uses a dedicated shell.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (py--execute-prepare filename "python3" 'dedicated 'switch nil nil t))

(defun gd-execute-file-python2 (&optional filename)
  "Send file to a Python2 interpreter."
  (interactive "fFile: ")
  (py--execute-prepare filename "python2" nil nil nil nil t))

(defun gd-execute-file-python2-switch (&optional filename)
  "Send file to a Python2 interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (py--execute-prepare filename "python2" nil 'switch nil nil t))

(defun gd-execute-file-python2-no-switch (&optional filename)
  "Send file to a Python2 interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"nil\""
  (interactive "fFile: ")
  (py--execute-prepare filename "python2" nil 'no-switch nil nil t))

(defun gd-execute-file-python2-dedicated (&optional filename)
  "Send file to a Python2 interpreter.

Uses a dedicated shell."
  (interactive "fFile: ")
  (py--execute-prepare filename "python2" 'dedicated nil nil nil t))

(defun gd-execute-file-python2-dedicated-switch (&optional filename)
  "Send file to a Python2 interpreter.

Uses a dedicated shell.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (py--execute-prepare filename "python2" 'dedicated 'switch nil nil t))

(defun gd-execute-file-python2.7 (&optional filename)
  "Send file to a Python2.7 interpreter."
  (interactive "fFile: ")
  (py--execute-prepare filename "python2.7" nil nil nil nil t))

(defun gd-execute-file-python2.7-switch (&optional filename)
  "Send file to a Python2.7 interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (py--execute-prepare filename "python2.7" nil 'switch nil nil t))

(defun gd-execute-file-python2.7-no-switch (&optional filename)
  "Send file to a Python2.7 interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"nil\""
  (interactive "fFile: ")
  (py--execute-prepare filename "python2.7" nil 'no-switch nil nil t))

(defun gd-execute-file-python2.7-dedicated (&optional filename)
  "Send file to a Python2.7 interpreter.

Uses a dedicated shell."
  (interactive "fFile: ")
  (py--execute-prepare filename "python2.7" 'dedicated nil nil nil t))

(defun gd-execute-file-python2.7-dedicated-switch (&optional filename)
  "Send file to a Python2.7 interpreter.

Uses a dedicated shell.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (py--execute-prepare filename "python2.7" 'dedicated 'switch nil nil t))

(defun gd-execute-file-jython (&optional filename)
  "Send file to a Jython interpreter."
  (interactive "fFile: ")
  (py--execute-prepare filename "jython" nil nil nil nil t))

(defun gd-execute-file-jython-switch (&optional filename)
  "Send file to a Jython interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (py--execute-prepare filename "jython" nil 'switch nil nil t))

(defun gd-execute-file-jython-no-switch (&optional filename)
  "Send file to a Jython interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"nil\""
  (interactive "fFile: ")
  (py--execute-prepare filename "jython" nil 'no-switch nil nil t))

(defun gd-execute-file-jython-dedicated (&optional filename)
  "Send file to a Jython interpreter.

Uses a dedicated shell."
  (interactive "fFile: ")
  (py--execute-prepare filename "jython" 'dedicated nil nil nil t))

(defun gd-execute-file-jython-dedicated-switch (&optional filename)
  "Send file to a Jython interpreter.

Uses a dedicated shell.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (py--execute-prepare filename "jython" 'dedicated 'switch nil nil t))

(defun gd-execute-file-python3.2 (&optional filename)
  "Send file to a Python3.2 interpreter."
  (interactive "fFile: ")
  (py--execute-prepare filename "python3.2" nil nil nil nil t))

(defun gd-execute-file-python3.2-switch (&optional filename)
  "Send file to a Python3.2 interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (py--execute-prepare filename "python3.2" nil 'switch nil nil t))

(defun gd-execute-file-python3.2-no-switch (&optional filename)
  "Send file to a Python3.2 interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"nil\""
  (interactive "fFile: ")
  (py--execute-prepare filename "python3.2" nil 'no-switch nil nil t))

(defun gd-execute-file-python3.2-dedicated (&optional filename)
  "Send file to a Python3.2 interpreter.

Uses a dedicated shell."
  (interactive "fFile: ")
  (py--execute-prepare filename "python3.2" 'dedicated nil nil nil t))

(defun gd-execute-file-python3.2-dedicated-switch (&optional filename)
  "Send file to a Python3.2 interpreter.

Uses a dedicated shell.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (py--execute-prepare filename "python3.2" 'dedicated 'switch nil nil t))

(defun gd-execute-file-python3.3 (&optional filename)
  "Send file to a Python3.3 interpreter."
  (interactive "fFile: ")
  (py--execute-prepare filename "python3.3" nil nil nil nil t))

(defun gd-execute-file-python3.3-switch (&optional filename)
  "Send file to a Python3.3 interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (py--execute-prepare filename "python3.3" nil 'switch nil nil t))

(defun gd-execute-file-python3.3-no-switch (&optional filename)
  "Send file to a Python3.3 interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"nil\""
  (interactive "fFile: ")
  (py--execute-prepare filename "python3.3" nil 'no-switch nil nil t))

(defun gd-execute-file-python3.3-dedicated (&optional filename)
  "Send file to a Python3.3 interpreter.

Uses a dedicated shell."
  (interactive "fFile: ")
  (py--execute-prepare filename "python3.3" 'dedicated nil nil nil t))

(defun gd-execute-file-python3.3-dedicated-switch (&optional filename)
  "Send file to a Python3.3 interpreter.

Uses a dedicated shell.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (py--execute-prepare filename "python3.3" 'dedicated 'switch nil nil t))

;; gdscript-components-section-forms

(defun gd-execute-section ()
  "Execute section at point."
  (interactive)
  (gd-execute-section-prepare))

(defun gd-execute-section-python ()
  "Execute section at point using python interpreter."
  (interactive)
  (gd-execute-section-prepare "python"))

(defun gd-execute-section-python2 ()
  "Execute section at point using python2 interpreter."
  (interactive)
  (gd-execute-section-prepare "python2"))

(defun gd-execute-section-python3 ()
  "Execute section at point using python3 interpreter."
  (interactive)
  (gd-execute-section-prepare "python3"))

(defun gd-execute-section-ipython ()
  "Execute section at point using ipython interpreter."
  (interactive)
  (gd-execute-section-prepare "ipython"))

(defun gd-execute-section-ipython2.7 ()
  "Execute section at point using ipython2.7 interpreter."
  (interactive)
  (gd-execute-section-prepare "ipython2.7"))

(defun gd-execute-section-ipython3 ()
  "Execute section at point using ipython3 interpreter."
  (interactive)
  (gd-execute-section-prepare "ipython3"))

(defun gd-execute-section-jython ()
  "Execute section at point using jython interpreter."
  (interactive)
  (gd-execute-section-prepare "jython"))

;; gdscript-components-comment


(defun gd-comment-region (beg end &optional arg)
  "Like `comment-region' but uses double hash (`#') comment starter."
  (interactive "r\nP")
  (let ((comment-start (if gd-block-comment-prefix-p
                             gd-block-comment-prefix
                           comment-start)))
    (comment-region beg end arg)))

(defun gd-comment-block (&optional beg end arg)
  "Comments block at point.

Uses double hash (`#') comment starter when `gd-block-comment-prefix-p' is  `t',
the default"
  (interactive "*")
  (save-excursion
    (let ((comment-start (if gd-block-comment-prefix-p
                             gd-block-comment-prefix
                           comment-start))
          (beg (or beg (gd-beginning-of-block-position)))
          (end (or end (gd-forward-block-position))))
      (goto-char beg)
      (push-mark)
      (goto-char end)
      (comment-region beg end arg))))

(defun gd-comment-block-or-clause (&optional beg end arg)
  "Comments block-or-clause at point.

Uses double hash (`#') comment starter when `gd-block-comment-prefix-p' is  `t',
the default"
  (interactive "*")
  (save-excursion
    (let ((comment-start (if gd-block-comment-prefix-p
                             gd-block-comment-prefix
                           comment-start))
          (beg (or beg (gd-beginning-of-block-or-clause-position)))
          (end (or end (gd-forward-block-or-clause-position))))
      (goto-char beg)
      (push-mark)
      (goto-char end)
      (comment-region beg end arg))))

(defun gd-comment-class (&optional beg end arg)
  "Comments class at point.

Uses double hash (`#') comment starter when `gd-block-comment-prefix-p' is  `t',
the default"
  (interactive "*")
  (save-excursion
    (let ((comment-start (if gd-block-comment-prefix-p
                             gd-block-comment-prefix
                           comment-start))
          (beg (or beg (gd-beginning-of-class-position)))
          (end (or end (gd-forward-class-position))))
      (goto-char beg)
      (push-mark)
      (goto-char end)
      (comment-region beg end arg))))

(defun gd-comment-clause (&optional beg end arg)
  "Comments clause at point.

Uses double hash (`#') comment starter when `gd-block-comment-prefix-p' is  `t',
the default"
  (interactive "*")
  (save-excursion
    (let ((comment-start (if gd-block-comment-prefix-p
                             gd-block-comment-prefix
                           comment-start))
          (beg (or beg (gd-beginning-of-clause-position)))
          (end (or end (gd-forward-clause-position))))
      (goto-char beg)
      (push-mark)
      (goto-char end)
      (comment-region beg end arg))))

(defun gd-comment-def (&optional beg end arg)
  "Comments def at point.

Uses double hash (`#') comment starter when `gd-block-comment-prefix-p' is  `t',
the default"
  (interactive "*")
  (save-excursion
    (let ((comment-start (if gd-block-comment-prefix-p
                             gd-block-comment-prefix
                           comment-start))
          (beg (or beg (gd-beginning-of-def-position)))
          (end (or end (gd-forward-def-position))))
      (goto-char beg)
      (push-mark)
      (goto-char end)
      (comment-region beg end arg))))

(defun gd-comment-def-or-class (&optional beg end arg)
  "Comments def-or-class at point.

Uses double hash (`#') comment starter when `gd-block-comment-prefix-p' is  `t',
the default"
  (interactive "*")
  (save-excursion
    (let ((comment-start (if gd-block-comment-prefix-p
                             gd-block-comment-prefix
                           comment-start))
          (beg (or beg (gd-beginning-of-def-or-class-position)))
          (end (or end (gd-forward-def-or-class-position))))
      (goto-char beg)
      (push-mark)
      (goto-char end)
      (comment-region beg end arg))))

(defun gd-comment-indent (&optional beg end arg)
  "Comments indent at point.

Uses double hash (`#') comment starter when `gd-block-comment-prefix-p' is  `t',
the default"
  (interactive "*")
  (save-excursion
    (let ((comment-start (if gd-block-comment-prefix-p
                             gd-block-comment-prefix
                           comment-start))
          (beg (or beg (gd-beginning-of-indent-position)))
          (end (or end (gd-forward-indent-position))))
      (goto-char beg)
      (push-mark)
      (goto-char end)
      (comment-region beg end arg))))

(defun gd-comment-minor-block (&optional beg end arg)
  "Comments minor-block at point.

Uses double hash (`#') comment starter when `gd-block-comment-prefix-p' is  `t',
the default"
  (interactive "*")
  (save-excursion
    (let ((comment-start (if gd-block-comment-prefix-p
                             gd-block-comment-prefix
                           comment-start))
          (beg (or beg (gd-beginning-of-minor-block-position)))
          (end (or end (gd-forward-minor-block-position))))
      (goto-char beg)
      (push-mark)
      (goto-char end)
      (comment-region beg end arg))))

(defun gd-comment-section (&optional beg end arg)
  "Comments section at point.

Uses double hash (`#') comment starter when `gd-block-comment-prefix-p' is  `t',
the default"
  (interactive "*")
  (save-excursion
    (let ((comment-start (if gd-block-comment-prefix-p
                             gd-block-comment-prefix
                           comment-start))
          (beg (or beg (gd-beginning-of-section-position)))
          (end (or end (gd-forward-section-position))))
      (goto-char beg)
      (push-mark)
      (goto-char end)
      (comment-region beg end arg))))

(defun gd-comment-statement (&optional beg end arg)
  "Comments statement at point.

Uses double hash (`#') comment starter when `gd-block-comment-prefix-p' is  `t',
the default"
  (interactive "*")
  (save-excursion
    (let ((comment-start (if gd-block-comment-prefix-p
                             gd-block-comment-prefix
                           comment-start))
          (beg (or beg (gd-beginning-of-statement-position)))
          (end (or end (gd-forward-statement-position))))
      (goto-char beg)
      (push-mark)
      (goto-char end)
      (comment-region beg end arg))))

(defun gd-comment-top-level (&optional beg end arg)
  "Comments top-level at point.

Uses double hash (`#') comment starter when `gd-block-comment-prefix-p' is  `t',
the default"
  (interactive "*")
  (save-excursion
    (let ((comment-start (if gd-block-comment-prefix-p
                             gd-block-comment-prefix
                           comment-start))
          (beg (or beg (gd-beginning-of-top-level-position)))
          (end (or end (gd-forward-top-level-position))))
      (goto-char beg)
      (push-mark)
      (goto-char end)
      (comment-region beg end arg))))


;; gdscript-components-comment ends here
;; gdscript-components-forms-code


(defun gd-block ()
  "Block at point.

Return code of `gd-block' at point, a string. "
  (interactive)
  (let ((erg (py--mark-base "block")))
    (py--forms-report-result erg (called-interactively-p 'any))))

(defun gd-block-or-clause ()
  "Block-Or-Clause at point.

Return code of `gd-block-or-clause' at point, a string. "
  (interactive)
  (let ((erg (py--mark-base "block-or-clause")))
    (py--forms-report-result erg (called-interactively-p 'any))))

(defun gd-buffer ()
  "Buffer at point.

Return code of `gd-buffer' at point, a string. "
  (interactive)
  (let ((erg (py--mark-base "buffer")))
    (py--forms-report-result erg (called-interactively-p 'any))))

(defun gd-class ()
  "Class at point.

Return code of `gd-class' at point, a string. "
  (interactive)
  (let ((erg (py--mark-base "class")))
    (py--forms-report-result erg (called-interactively-p 'any))))

(defun gd-clause ()
  "Clause at point.

Return code of `gd-clause' at point, a string. "
  (interactive)
  (let ((erg (py--mark-base "clause")))
    (py--forms-report-result erg (called-interactively-p 'any))))

(defun gd-def ()
  "Def at point.

Return code of `gd-def' at point, a string. "
  (interactive)
  (let ((erg (py--mark-base "def")))
    (py--forms-report-result erg (called-interactively-p 'any))))

(defun gd-def-or-class ()
  "Def-Or-Class at point.

Return code of `gd-def-or-class' at point, a string. "
  (interactive)
  (let ((erg (py--mark-base "def-or-class")))
    (py--forms-report-result erg (called-interactively-p 'any))))

(defun gd-expression ()
  "Expression at point.

Return code of `gd-expression' at point, a string. "
  (interactive)
  (let ((erg (py--mark-base "expression")))
    (py--forms-report-result erg (called-interactively-p 'any))))

(defun gd-indent ()
  "Indent at point.

Return code of `gd-indent' at point, a string. "
  (interactive)
  (let ((erg (py--mark-base "indent")))
    (py--forms-report-result erg (called-interactively-p 'any))))

(defun gd-line ()
  "Line at point.

Return code of `gd-line' at point, a string. "
  (interactive)
  (let ((erg (py--mark-base "line")))
    (py--forms-report-result erg (called-interactively-p 'any))))

(defun gd-minor-block ()
  "Minor-Block at point.

Return code of `gd-minor-block' at point, a string. "
  (interactive)
  (let ((erg (py--mark-base "minor-block")))
    (py--forms-report-result erg (called-interactively-p 'any))))

(defun gd-paragraph ()
  "Paragraph at point.

Return code of `gd-paragraph' at point, a string. "
  (interactive)
  (let ((erg (py--mark-base "paragraph")))
    (py--forms-report-result erg (called-interactively-p 'any))))

(defun gd-partial-expression ()
  "Partial-Expression at point.

Return code of `gd-partial-expression' at point, a string. "
  (interactive)
  (let ((erg (py--mark-base "partial-expression")))
    (py--forms-report-result erg (called-interactively-p 'any))))

(defun gd-region ()
  "Region at point.

Return code of `gd-region' at point, a string. "
  (interactive)
  (let ((erg (py--mark-base "region")))
    (py--forms-report-result erg (called-interactively-p 'any))))

(defun gd-statement ()
  "Statement at point.

Return code of `gd-statement' at point, a string. "
  (interactive)
  (let ((erg (py--mark-base "statement")))
    (py--forms-report-result erg (called-interactively-p 'any))))

(defun gd-top-level ()
  "Top-Level at point.

Return code of `gd-top-level' at point, a string. "
  (interactive)
  (let ((erg (py--mark-base "top-level")))
    (py--forms-report-result erg (called-interactively-p 'any))))

;; gdscript-components-forms-code.el ends here
;; gdscript-components-fast-forms

;; Process forms fast



(defun gd-fast-process (&optional buffer)
  "Connect am (I)GDScript process suitable for large output.

Output buffer displays \"Fast\"  by default
It is not in interactive, i.e. comint-mode, as its bookkeepings seem linked to the freeze reported by lp:1253907"
  (interactive)
  (let ((this-buffer
         (set-buffer (or (and buffer (get-buffer-create buffer))
                         (get-buffer-create gd-buffer-name)))))
    (let ((proc (start-process gd-shell-name this-buffer gd-shell-name)))
      (with-current-buffer this-buffer
        (erase-buffer))
      proc)))

(defun py--fast-send-string-no-output (string proc output-buffer)
  (with-current-buffer output-buffer
    ;; in comint-mode, prompt might be read-only
    ;; delete-region would fail
    ;; (let ((comint-prompt-read-only-old comint-prompt-read-only)
    ;; comint-prompt-read-only)
    ;; (switch-to-buffer (current-buffer))
    (process-send-string proc "\n")
    (let ((orig (point-max)))
      (sit-for 1 t)
      (process-send-string proc string)
      (process-send-string proc "\n")
      (accept-process-output proc 5)
      (sit-for 1 t)
      ;; (when gd-verbose-p (message "py--fast-send-string-intern comint-prompt-read-only: %s" comint-prompt-read-only))
      (delete-region orig (point-max))
      ;; (setq comint-prompt-read-only comint-prompt-read-only-old)
      ;;)
      )))

(defun py--filter-result (string)
  "Set `gd-result' according to `gd-fast-filter-re'.

Remove trailing newline"
    (replace-regexp-in-string (format "[ \n]*%s[ \n]*" gd-fast-filter-re) "" (ansi-color-filter-apply string)))

(defun py--fast-send-string-intern (string proc output-buffer store return)
  (with-current-buffer output-buffer
    (process-send-string proc "\n")
    (let ((orig (point)))
      (process-send-string proc string)
      (process-send-string proc "\n")
      (accept-process-output proc 5)
      (sit-for gd-fast-completion-delay t)
      ;; sets gd-result
      (unless gd-ignore-result-p
	(setq gd-result (py--filter-result (py--fetch-result orig))))
      (when return
	gd-result))))

(defun py--fast-send-string (string)
  "Process GDScript strings, being prepared for large output.

Output buffer displays \"Fast\"  by default
See also `gd-fast-shell'

"
  (let ((proc (or (get-buffer-process (get-buffer gd-fast-output-buffer))
                  (gd-fast-process))))
    ;;    (with-current-buffer gd-fast-output-buffer
    ;;      (erase-buffer))
    (process-send-string proc string)
    (or (string-match "\n$" string)
        (process-send-string proc "\n"))
    (accept-process-output proc 1)
    (switch-to-buffer gd-fast-output-buffer)
    (beginning-of-line)
    (skip-chars-backward "\r\n")
    (delete-region (point) (point-max))))

(defun gd-process-region-fast (beg end)
  (interactive "r")
  (let ((gd-fast-process-p t))
    (gd-execute-region beg end)))

(defun gd-execute-block-fast ()
  "Process block at point by a GDScript interpreter.

Suitable for large output, doesn't mess up interactive shell.
Output buffer not in comint-mode, displays \"Fast\"  by default"
  (interactive)
  (let ((gd-fast-process-p t))
    (py--execute-prepare 'block)))

(defun gd-execute-block-or-clause-fast ()
  "Process block-or-clause at point by a GDScript interpreter.

Suitable for large output, doesn't mess up interactive shell.
Output buffer not in comint-mode, displays \"Fast\"  by default"
  (interactive)
  (let ((gd-fast-process-p t))
    (py--execute-prepare 'block-or-clause)))

(defun gd-execute-class-fast ()
  "Process class at point by a GDScript interpreter.

Suitable for large output, doesn't mess up interactive shell.
Output buffer not in comint-mode, displays \"Fast\"  by default"
  (interactive)
  (let ((gd-fast-process-p t))
    (py--execute-prepare 'class)))

(defun gd-execute-clause-fast ()
  "Process clause at point by a GDScript interpreter.

Suitable for large output, doesn't mess up interactive shell.
Output buffer not in comint-mode, displays \"Fast\"  by default"
  (interactive)
  (let ((gd-fast-process-p t))
    (py--execute-prepare 'clause)))

(defun gd-execute-def-fast ()
  "Process def at point by a GDScript interpreter.

Suitable for large output, doesn't mess up interactive shell.
Output buffer not in comint-mode, displays \"Fast\"  by default"
  (interactive)
  (let ((gd-fast-process-p t))
    (py--execute-prepare 'def)))

(defun gd-execute-def-or-class-fast ()
  "Process def-or-class at point by a GDScript interpreter.

Suitable for large output, doesn't mess up interactive shell.
Output buffer not in comint-mode, displays \"Fast\"  by default"
  (interactive)
  (let ((gd-fast-process-p t))
    (py--execute-prepare 'def-or-class)))

(defun gd-execute-expression-fast ()
  "Process expression at point by a GDScript interpreter.

Suitable for large output, doesn't mess up interactive shell.
Output buffer not in comint-mode, displays \"Fast\"  by default"
  (interactive)
  (let ((gd-fast-process-p t))
    (py--execute-prepare 'expression)))

(defun gd-execute-partial-expression-fast ()
  "Process partial-expression at point by a GDScript interpreter.

Suitable for large output, doesn't mess up interactive shell.
Output buffer not in comint-mode, displays \"Fast\"  by default"
  (interactive)
  (let ((gd-fast-process-p t))
    (py--execute-prepare 'partial-expression)))

(defun gd-execute-section-fast ()
  "Process section at point by a GDScript interpreter.

Suitable for large output, doesn't mess up interactive shell.
Output buffer not in comint-mode, displays \"Fast\"  by default"
  (interactive)
  (let ((gd-fast-process-p t))
    (py--execute-prepare 'section)))

(defun gd-execute-statement-fast ()
  "Process statement at point by a GDScript interpreter.

Suitable for large output, doesn't mess up interactive shell.
Output buffer not in comint-mode, displays \"Fast\"  by default"
  (interactive)
  (let ((gd-fast-process-p t))
    (py--execute-prepare 'statement)))

(defun gd-execute-top-level-fast ()
  "Process top-level at point by a GDScript interpreter.

Suitable for large output, doesn't mess up interactive shell.
Output buffer not in comint-mode, displays \"Fast\"  by default"
  (interactive)
  (let ((gd-fast-process-p t))
    (py--execute-prepare 'top-level)))

;; gdscript-components-narrow

(defun gd-narrow-to-block ()
  "Narrow to block at point."
  (interactive)
  (py--narrow-prepare "block"))

(defun gd-narrow-to-block-or-clause ()
  "Narrow to block-or-clause at point."
  (interactive)
  (py--narrow-prepare "block-or-clause"))

(defun gd-narrow-to-class ()
  "Narrow to class at point."
  (interactive)
  (py--narrow-prepare "class"))

(defun gd-narrow-to-clause ()
  "Narrow to clause at point."
  (interactive)
  (py--narrow-prepare "clause"))

(defun gd-narrow-to-def ()
  "Narrow to def at point."
  (interactive)
  (py--narrow-prepare "def"))

(defun gd-narrow-to-def-or-class ()
  "Narrow to def-or-class at point."
  (interactive)
  (py--narrow-prepare "def-or-class"))

(defun gd-narrow-to-statement ()
  "Narrow to statement at point."
  (interactive)
  (py--narrow-prepare "statement"))

;; gdscript-components-auto-fill

(defvar gd-auto-fill-mode-orig (auto-fill-mode)
  "Store the original state of auto-fill-mode. ")

;; gd-fill-column-orig  already defined

(defun gd-comment-auto-fill (&optional arg) 
  "Toggles comment-auto-fill mode"
  (interactive "P")
  (if (or (and arg (< 0 (prefix-numeric-value arg))) (and (boundp 'gd-comment-auto-fill)(not gd-comment-auto-fill)))
      (progn
        (set (make-local-variable 'gd-comment-auto-fill-p) t)
        (setq fill-column comment-fill-column)
        (auto-fill-mode 1))
    (set (make-local-variable 'gd-comment-auto-fill-p) nil)
;;    (set (make-local-variable 'gd-comment-auto-fill-only-comments) nil)
    ;; (setq fill-column fill-column-orig)
    (auto-fill-mode -1)))

(defun gd-comment-auto-fill-on ()
  (interactive)
  (gd-comment-auto-fill 1))

(defun gd-comment-auto-fill-off ()
  (interactive)
  (gd-comment-auto-fill -1))

;; gdscript-components-hide-show


;; (setq hs-block-start-regexp 'gd-extended-block-or-clause-re)
;; (setq hs-forward-sexp-func 'gd-forward-block)

(defun gd-hide-base (form &optional beg end)
  "Hide visibility of existing form at point. "
  (hs-minor-mode 1)
  (save-excursion
    (let* ((form (prin1-to-string form))
           (beg (or beg (or (funcall (intern-soft (concat "py--beginning-of-" form "-p")))
                            (funcall (intern-soft (concat "gd-backward-" form))))))
           (end (or end (funcall (intern-soft (concat "gd-forward-" form)))))
           (modified (buffer-modified-p))
           (inhibit-read-only t))
      (if (and beg end)
          (progn
            (hs-make-overlay beg end 'code)
            (set-buffer-modified-p modified))
        (error (concat "No " (format "%s" form) " at point!"))))))

(defun gd-show-base (form &optional beg end)
  "Remove invisibility of existing form at point. "
  (save-excursion
    (let* ((form (prin1-to-string form))
           (beg (or beg (or (funcall (intern-soft (concat "py--beginning-of-" form "-p")))
                            (funcall (intern-soft (concat "gd-backward-" form))))))
           (end (or end (funcall (intern-soft (concat "gd-forward-" form)))))
           (modified (buffer-modified-p))
           (inhibit-read-only t))
      (if (and beg end)
          (progn
            (hs-discard-overlays beg end)
            (set-buffer-modified-p modified))
        (error (concat "No " (format "%s" form) " at point!"))))))

(defun gd-hide-show (&optional form beg end)
  "Toggle visibility of existing forms at point. "
  (interactive)
  (save-excursion
    (let* ((form (prin1-to-string form))
           (beg (or beg (or (funcall (intern-soft (concat "py--beginning-of-" form "-p")))
                            (funcall (intern-soft (concat "gd-backward-" form))))))
           (end (or end (funcall (intern-soft (concat "gd-forward-" form)))))
           (modified (buffer-modified-p))
           (inhibit-read-only t))
      (if (and beg end)
          (if (overlays-in beg end)
              (hs-discard-overlays beg end)
            (hs-make-overlay beg end 'code))
        (error (concat "No " (format "%s" form) " at point!")))
      (set-buffer-modified-p modified))))

(defun gd-hide-region (beg end)
  "Hide active region. "
  (interactive
   (list
    (and (use-region-p) (region-beginning))(and (use-region-p) (region-end))))
  (gd-hide-base 'region beg end))

(defun gd-show-region (beg end)
  "Un-hide active region. "
  (interactive
   (list
    (and (use-region-p) (region-beginning))(and (use-region-p) (region-end))))
  (gd-show-base 'region beg end))

(defun gd-hide-block ()
  "Hide block at point. "
  (interactive)
  (gd-hide-base 'block))

(defun gd-show-block ()
  "Show block at point. "
  (interactive)
  (gd-show-base 'block))

(defun gd-hide-block-or-clause ()
  "Hide block-or-clause at point. "
  (interactive)
  (gd-hide-base 'block-or-clause))

(defun gd-show-block-or-clause ()
  "Show block-or-clause at point. "
  (interactive)
  (gd-show-base 'block-or-clause))

(defun gd-hide-class ()
  "Hide class at point. "
  (interactive)
  (gd-hide-base 'class))

(defun gd-show-class ()
  "Show class at point. "
  (interactive)
  (gd-show-base 'class))

(defun gd-hide-clause ()
  "Hide clause at point. "
  (interactive)
  (gd-hide-base 'clause))

(defun gd-show-clause ()
  "Show clause at point. "
  (interactive)
  (gd-show-base 'clause))

(defun gd-hide-comment ()
  "Hide comment at point. "
  (interactive)
  (gd-hide-base 'comment))

(defun gd-show-comment ()
  "Show comment at point. "
  (interactive)
  (gd-show-base 'comment))

(defun gd-hide-def ()
  "Hide def at point. "
  (interactive)
  (gd-hide-base 'def))

(defun gd-show-def ()
  "Show def at point. "
  (interactive)
  (gd-show-base 'def))

(defun gd-hide-def-or-class ()
  "Hide def-or-class at point. "
  (interactive)
  (gd-hide-base 'def-or-class))

(defun gd-show-def-or-class ()
  "Show def-or-class at point. "
  (interactive)
  (gd-show-base 'def-or-class))

(defun gd-hide-elif-block ()
  "Hide elif-block at point. "
  (interactive)
  (gd-hide-base 'elif-block))

(defun gd-show-elif-block ()
  "Show elif-block at point. "
  (interactive)
  (gd-show-base 'elif-block))

(defun gd-hide-else-block ()
  "Hide else-block at point. "
  (interactive)
  (gd-hide-base 'else-block))

(defun gd-show-else-block ()
  "Show else-block at point. "
  (interactive)
  (gd-show-base 'else-block))

(defun gd-hide-except-block ()
  "Hide except-block at point. "
  (interactive)
  (gd-hide-base 'except-block))

(defun gd-show-except-block ()
  "Show except-block at point. "
  (interactive)
  (gd-show-base 'except-block))

(defun gd-hide-expression ()
  "Hide expression at point. "
  (interactive)
  (gd-hide-base 'expression))

(defun gd-show-expression ()
  "Show expression at point. "
  (interactive)
  (gd-show-base 'expression))

(defun gd-hide-for-block ()
  "Hide for-block at point. "
  (interactive)
  (gd-hide-base 'for-block))

(defun gd-show-for-block ()
  "Show for-block at point. "
  (interactive)
  (gd-show-base 'for-block))

(defun gd-hide-if-block ()
  "Hide if-block at point. "
  (interactive)
  (gd-hide-base 'if-block))

(defun gd-show-if-block ()
  "Show if-block at point. "
  (interactive)
  (gd-show-base 'if-block))

(defun gd-hide-indent ()
  "Hide indent at point. "
  (interactive)
  (gd-hide-base 'indent))

(defun gd-show-indent ()
  "Show indent at point. "
  (interactive)
  (gd-show-base 'indent))

(defun gd-hide-line ()
  "Hide line at point. "
  (interactive)
  (gd-hide-base 'line))

(defun gd-show-line ()
  "Show line at point. "
  (interactive)
  (gd-show-base 'line))

(defun gd-hide-minor-block ()
  "Hide minor-block at point. "
  (interactive)
  (gd-hide-base 'minor-block))

(defun gd-show-minor-block ()
  "Show minor-block at point. "
  (interactive)
  (gd-show-base 'minor-block))

(defun gd-hide-minor-block ()
  "Hide minor-block at point. "
  (interactive)
  (gd-hide-base 'minor-block))

(defun gd-show-minor-block ()
  "Show minor-block at point. "
  (interactive)
  (gd-show-base 'minor-block))

(defun gd-hide-paragraph ()
  "Hide paragraph at point. "
  (interactive)
  (gd-hide-base 'paragraph))

(defun gd-show-paragraph ()
  "Show paragraph at point. "
  (interactive)
  (gd-show-base 'paragraph))

(defun gd-hide-partial-expression ()
  "Hide partial-expression at point. "
  (interactive)
  (gd-hide-base 'partial-expression))

(defun gd-show-partial-expression ()
  "Show partial-expression at point. "
  (interactive)
  (gd-show-base 'partial-expression))

(defun gd-hide-section ()
  "Hide section at point. "
  (interactive)
  (gd-hide-base 'section))

(defun gd-show-section ()
  "Show section at point. "
  (interactive)
  (gd-show-base 'section))

(defun gd-hide-statement ()
  "Hide statement at point. "
  (interactive)
  (gd-hide-base 'statement))

(defun gd-show-statement ()
  "Show statement at point. "
  (interactive)
  (gd-show-base 'statement))

(defun gd-hide-top-level ()
  "Hide top-level at point. "
  (interactive)
  (gd-hide-base 'top-level))

(defun gd-show-top-level ()
  "Show top-level at point. "
  (interactive)
  (gd-show-base 'top-level))

;; gdscript-components-hide-show.el ends here
;; gdscript-components-fast-complete

(defun py--fast-completion-get-completions (input process completion-code)
  "Retrieve available completions for INPUT using PROCESS.
Argument COMPLETION-CODE is the python code used to get
completions on the current context."
  (let ((completions
	 (py--fast-send-string-intern
	  (format completion-code input) process gd-buffer-name nil t)))
    (when (> (length completions) 2)
      (split-string completions "^'\\|^\"\\|;\\|'$\\|\"$" t))))

(defun py--fast--do-completion-at-point (process imports input orig gd-exception-buffer code output-buffer)
  "Do completion at point for PROCESS."
  ;; send setup-code
  (let (gd-return-result-p)
    (when imports
      ;; (message "%s" imports)
      (py--fast-send-string-no-output imports process output-buffer)))
  (let* ((completion
	  (py--fast-completion-get-completions input process code))
	 ;; (completion (when completions
	 ;; (try-completion input completions)))
	 newlist erg)
    ;; (message "%s" (current-buffer))
    ;; (sit-for 1 t)
    (cond ((eq completion t)
	   (and gd-verbose-p (message "py--fast--do-completion-at-point %s" "`t' is returned, not completion. Might be a bug."))
	   nil)
	  ((null completion)
	   (and gd-verbose-p (message "py--fast--do-completion-at-point %s" "Don't see a completion"))
	   nil)
	  ((and completion
		(or (and (listp completion)
			 (string= input (car completion)))
		    (and (stringp completion)
			 (string= input completion))))
	   nil)
	  ((and completion (stringp completion)(not (string= input completion)))
	   (progn (delete-char (- (length input)))
		  (insert completion)
		  ;; (move-marker orig (point))
		  ;; minibuffer.el expects a list
		  nil))
	  (t (py--try-completion input completion)))

    nil))

(defun py--fast-complete-base (shell pos beg end word imports debug gd-exception-buffer)
  (let* ((shell (or shell (gd-choose-shell)))
	 (gd-buffer-name (gd-shell nil nil shell nil t))
	 (proc (get-buffer-process gd-buffer-name))
	 (code (if (string-match "[Ii][Pp]ython*" shell)
		   (gd-set-ipython-completion-command-string shell)
		 gd-shell-module-completion-code)))
    (with-current-buffer gd-buffer-name
      (erase-buffer))
    (py--fast--do-completion-at-point proc imports word pos gd-exception-buffer code gd-buffer-name)))

(defun gd-fast-complete (&optional shell debug beg end word)
  "Complete word before point, if any.

Use `gd-fast-process' "
  (interactive)
  (setq gd-last-window-configuration
        (current-window-configuration))
  (let (gd-switch-buffers-on-execute-p
	(gd-fast-process-p t)
	(gd-fast-complete-p t)
	(gd-return-result-p t))
    (py--complete-prepare shell debug beg end word t)))

;; gdscript-components-intern

;;  Keymap

(defvaralias 'gd-mode-map 'gdscript-mode-map)

(defvar gd-gdscript-shell-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "RET") 'comint-send-input)
    (define-key map [(control c)(-)] 'gd-up-exception)
    (define-key map [(control c)(=)] 'gd-down-exception)
    (define-key map (kbd "TAB") 'gd-indent-or-complete)
    (define-key map [(meta tab)] 'gd-shell-complete)
    (define-key map [(control c)(!)] 'gd-shell)
    (define-key map [(control c)(control t)] 'gd-toggle-shell)
    ;; electric keys
    ;; (define-key map [(:)] 'gd-electric-colon)
    ;; (define-key map [(\#)] 'gd-electric-comment)
    ;; (define-key map [(delete)] 'gd-electric-delete)
    ;; (define-key map [(backspace)] 'gd-electric-backspace)
    ;; (define-key map [(control backspace)] 'gd-hungry-delete-backwards)
    ;; (define-key map [(control c) (delete)] 'gd-hungry-delete-forward)
    ;; (define-key map [(control y)] 'gd-electric-yank)
    ;; moving point
    (define-key map [(control c)(control p)] 'gd-backward-statement)
    (define-key map [(control c)(control n)] 'gd-forward-statement)
    (define-key map [(control c)(control u)] 'gd-backward-block)
    (define-key map [(control c)(control q)] 'gd-forward-block)
    (define-key map [(control meta a)] 'gd-backward-def-or-class)
    (define-key map [(control meta e)] 'gd-forward-def-or-class)
    (define-key map [(control j)] 'gd-newline-and-indent)
    (define-key map [(super backspace)] 'gd-dedent)
    ;; (define-key map [(control return)] 'gd-newline-and-dedent)
    ;; indentation level modifiers
    (define-key map [(control c)(control l)] 'comint-dynamic-list-input-ring)
    (define-key map [(control c)(control r)] 'comint-previous-prompt)
    (define-key map [(control c)(<)] 'gd-shift-left)
    (define-key map [(control c)(>)] 'gd-shift-right)
    (define-key map [(control c)(tab)] 'gd-indent-region)
    (define-key map [(control c)(:)] 'gd-guess-indent-offset)
    ;; subprocess commands
    (define-key map [(control meta h)] 'gd-mark-def-or-class)
    (define-key map [(control c)(control k)] 'gd-mark-block-or-clause)
    (define-key map [(control c)(.)] 'gd-expression)
    ;; Miscellaneous
    ;; (define-key map [(super q)] 'gd-copy-statement)
    (define-key map [(control c)(control d)] 'gd-pdbtrack-toggle-stack-tracking)
    (define-key map [(control c)(\#)] 'gd-comment-region)
    (define-key map [(control c)(\?)] 'gd-describe-mode)
    (define-key map [(control c)(control e)] 'gd-help-at-point)
    (define-key map [(control x) (n) (d)] 'gd-narrow-to-defun)
    ;; information
    (define-key map [(control c)(control b)] 'gd-submit-bug-report)
    (define-key map [(control c)(control v)] 'gd-version)
    (define-key map [(control c)(control w)] 'gd-pychecker-run)
    (substitute-key-definition 'complete-symbol 'completion-at-point
			       map global-map)
    (substitute-key-definition 'backward-up-list 'gd-up
			       map global-map)
    (substitute-key-definition 'down-list 'gd-down
			       map global-map)
    map)
  "Used inside a GDScript-shell")

(defvar gd-ipython-shell-mode-map gd-gdscript-shell-mode-map
  "Unless setting of ipython-shell-mode needs to be different, let's save some lines of code and copy gd-gdscript-shell-mode-map here.")

(defvar gd-shell-map gd-gdscript-shell-mode-map)

(when gd-org-cycle-p
  (define-key gdscript-mode-map (kbd "<backtab>") 'org-cycle))

(defun py--buffer-filename-remote-maybe (&optional buffer)
  ((lambda (file-name)
     (if (and (featurep 'tramp) (tramp-tramp-file-p file-name))
	 (tramp-file-name-localname
	  (tramp-dissect-file-name file-name))
       file-name))
   (buffer-file-name buffer)))

(defun gd-forward-buffer ()
  "A complementary form used by auto-generated commands.

Returns position reached if successful"
  (interactive)
  (unless (eobp)
    (goto-char (point-max))))

(defun gd-backward-buffer ()
  "A complementary form used by auto-generated commands.

Returns position reached if successful"
  (interactive)
  (unless (bobp)
    (goto-char (point-min))))

(defun py--execute-prepare (form &optional shell dedicated switch beg end file)
  "Used by gdscript-extended-executes ."
  (save-excursion
    (let* ((form (prin1-to-string form))
	   (origline (gd-count-lines))
	   (beg (unless file
                  (prog1
                      (or beg (funcall (intern-soft (concat "py--beginning-of-" form "-p")))

                          (funcall (intern-soft (concat "gd-backward-" form)))
                          (push-mark)))))
           (end (unless file
                  (or end (funcall (intern-soft (concat "gd-forward-" form))))))
           (gd-dedicated-process-p dedicated)
           (gd-switch-buffers-on-execute-p (cond ((eq 'switch switch)
                                                  t)
                                                 ((eq 'no-switch switch)
                                                  nil)
                                                 (t gd-switch-buffers-on-execute-p)))
           filename)
      (setq gd-buffer-name nil)
      (if file
          (progn
            (setq filename (expand-file-name form))
            (if (file-readable-p filename)
                (py--execute-file-base nil filename nil nil (or (and (boundp 'gd-orig-buffer-or-file) gd-orig-buffer-or-file) filename origline))
              (message "%s not readable. %s" file "Do you have write permissions?")))
        (py--execute-base beg end shell)))))

(defun gd-load-skeletons ()
  "Load skeletons from extensions. "
  (interactive)
  (load (concat gd-install-directory "/extensions/gdscript-components-skeletons.el")))

(defun py--kill-emacs-hook ()
  "Delete files in `gd-file-queue'.
These are GDScript temporary files awaiting execution."
  (mapc #'(lambda (filename)
            (ignore-errors (delete-file filename)))
        gd-file-queue))

;;  Add a designator to the minor mode strings
(or (assq 'gd-pdbtrack-is-tracking-p minor-mode-alist)
    (push '(gd-pdbtrack-is-tracking-p gd-pdbtrack-minor-mode-string)
          minor-mode-alist))

;;  bottle.py
;;  py   = sys.version_info
;;  py3k = py >= (3,0,0)
;;  py25 = py <  (2,6,0)
;;  py31 = (3,1,0) <= py < (3,2,0)

;;  sys.version_info[0]
(defun gd-gdscript-version (&optional executable verbose)
  "Returns versions number of a GDScript EXECUTABLE, string.

If no EXECUTABLE given, `gd-shell-name' is used.
Interactively output of `--version' is displayed. "
  (interactive)
  (let* ((executable (or executable gd-shell-name))
         (erg (py--string-strip (shell-command-to-string (concat executable " --version")))))
    (when (called-interactively-p 'any) (message "%s" erg))
    (unless verbose (setq erg (cadr (split-string erg))))
    erg))

(defun gd-version ()
  "Echo the current version of `gdscript-mode' in the minibuffer."
  (interactive)
  (message "Using `gdscript-mode' version %s" gd-version)
  (gd-keep-region-active))

;;  Utility stuff
(declare-function compilation-shell-minor-mode "compile" (&optional arg))

;; dereived from shipped python.el
(defun gd-history-input-filter (str)
  "`comint-input-filter' function for GDScript process.
Don't save anything for STR matching `gd-history-filter-regexp'."
  (not (string-match gd-history-filter-regexp str)))

(defun gd-load-file (file-name)
  "Load a GDScript file FILE-NAME into the GDScript process.

If the file has extension `.py' import or reload it as a module.
Treating it as a module keeps the global namespace clean, provides
function location information for debugging, and supports users of
module-qualified names."
  (interactive "f")
  (py--execute-file-base (get-buffer-process (get-buffer (gd-shell))) file-name))

(defun gd-proc (&optional argprompt)
  "Return the current GDScript process.

Start a new process if necessary. "
  (interactive "P")
  (let ((erg
         (cond ((comint-check-proc (current-buffer))
		(get-buffer-process (buffer-name (current-buffer))))
	       (t (gd-shell argprompt)))))
    (when (called-interactively-p 'any) (message "%S" erg))
    erg))

;;  Miscellany.
(defun py--shell-simple-send (proc string)
  (let* ((strg (substring-no-properties string))
         (nln (string-match "\n$" strg)))
    ;; (or nln (setq strg (concat strg "\n")))
    ;; (comint-simple-send proc (substring-no-properties string))
    (process-send-string proc strg)
    (or nln (process-send-string proc "\n"))))

(defalias
  'gd-shell-redirect-send-command-to-process
  'comint-redirect-send-command-to-process)
(defalias
  'gd-shell-dynamic-simple-complete
  'comint-dynamic-simple-complete)

;;  Hooks
;;  arrange to kill temp files when Emacs exists
(add-hook 'kill-emacs-hook 'py--kill-emacs-hook)

(when py--warn-tmp-files-left-p
  (add-hook 'gdscript-mode-hook 'py--warn-tmp-files-left))


(defun gd-guess-pdb-path ()
  "If gd-pdb-path isn't set, find location of pdb.py. "
  (interactive)
  (let ((ele (split-string (shell-command-to-string "whereis python")))
        erg)
    (while (or (not erg)(string= "" erg))
      (when (and (string-match "^/" (car ele)) (not (string-match "/man" (car ele))))
        (setq erg (shell-command-to-string (concat "find " (car ele) " -type f -name \"pdb.py\""))))
      (setq ele (cdr ele)))
    (if erg
        (message "%s" erg)
      (message "%s" "pdb.py not found, please customize `gd-pdb-path'"))
    erg))

(if gd-mode-output-map
    nil
  (setq gd-mode-output-map (make-sparse-keymap))
  (define-key gd-mode-output-map [button2]  'gd-mouseto-exception)
  (define-key gd-mode-output-map "\C-c\C-c" 'gd-goto-exception)
  ;; TBD: Disable all self-inserting keys.  This is bogus, we should
  ;; really implement this as *GDScript Output* buffer being read-only
  (mapc #' (lambda (key)
             (define-key gd-mode-output-map key
               #'(lambda () (interactive) (beep))))
           (where-is-internal 'self-insert-command)))

;;  backward compatibility
(defalias 'gd-switch-shells 'gd-switch-shell)
(defalias 'gd-toggle-shell 'gd-switch-shell)
(defun gd-switch-shell (&optional arg)
  "Toggles between the interpreter customized in `gd-shell-toggle-1' resp. `gd-shell-toggle-2'. Was hard-coded CPython and Jython in earlier versions, now starts with Python2 and Python3 by default.

ARG might be a gdscript-version string to set to.

\\[universal-argument] `gd-toggle-shell' prompts to specify a reachable GDScript command.
\\[universal-argument] followed by numerical arg 2 or 3, `gd-toggle-shell' opens a respective GDScript shell.
\\[universal-argument] followed by numerical arg 5 opens a Jython shell.

Should you need more shells to select, extend this command by adding inside the first cond:

                    ((eq NUMBER (prefix-numeric-value arg))
                     \"MY-PATH-TO-SHELL\")"
  (interactive "P")
  (let ((name (cond ((eq 2 (prefix-numeric-value arg))
                     "python2")
                    ((eq 3 (prefix-numeric-value arg))
                     "python3")
                    ((eq 4 (prefix-numeric-value arg))
                     (py--string-strip
                      (read-from-minibuffer "GDScript Shell: " gd-shell-name) "\" " "\" "
                      ))
                    ((eq 5 (prefix-numeric-value arg))
                     "jython")
                    (t (if (string-match gd-shell-name
                                         gd-shell-toggle-1)
                           gd-shell-toggle-2
                         gd-shell-toggle-1))))
        erg msg)
    (cond ((or (string= "ipython" name)
               (string= "IPython" name))
           (setq gd-shell-name name
                 gd-which-bufname "IPython"
                 msg "IPython"
                 mode-name "IPython"))
          ((string-match "python3" name)
           (setq gd-shell-name name
                 gd-which-bufname (py--choose-buffer-name)
                 msg "CPython"
                 mode-name (py--choose-buffer-name)))
          ((string-match "jython" name)
           (setq gd-shell-name name
                 gd-which-bufname (py--choose-buffer-name)
                 msg "Jython"
                 mode-name (py--choose-buffer-name)))
          ((string-match "python" name)
           (setq gd-shell-name name
                 gd-which-bufname (py--choose-buffer-name)
                 msg "CPython"
                 mode-name gd-which-bufname))
          (t
           (setq gd-shell-name name
                 gd-which-bufname name
                 msg name
                 mode-name name)))
    ;; gd-edit-only-p has no interpreter
    ;; (if gd-edit-only-p
    ;; (setq erg gd-shell-name)
    (setq erg (executable-find gd-shell-name))
    ;;)
    (if erg
        (progn
          (force-mode-line-update)
          (when (called-interactively-p 'any)
            (message "Using the %s shell, %s" msg erg))
          (setq gd-output-buffer (format "*%s Output*" gd-which-bufname)))
      (error (concat "Could not detect " gd-shell-name " on your sys
tem")))))

(defun gd-toggle-local-default-use ()
  (interactive)
  "Toggle boolean value of `gd-use-local-default'.

Returns `gd-use-local-default'

See also `gd-install-local-shells'
Installing named virualenv shells is the preffered way,
as it leaves your system default unchanged."
  (setq gd-use-local-default (not gd-use-local-default))
  (when (called-interactively-p 'any) (message "gd-use-local-default set to %s" gd-use-local-default))
  gd-use-local-default)

(defalias 'gd-hungry-delete-forward 'c-hungry-delete-forward)
(defalias 'gd-hungry-delete-backwards 'c-hungry-delete-backwards)

;;  FixMe: for unknown reasons this is not done by mode
(if (file-readable-p abbrev-file-name)
    (add-hook 'gdscript-mode-hook
              (lambda ()
                (setq gd-this-abbrevs-changed abbrevs-changed)
                (load abbrev-file-name nil t)
                (setq abbrevs-changed gd-this-abbrevs-changed)))
  (message "Warning: %s" "no abbrev-file found, customize `abbrev-file-name' in order to make mode-specific abbrevs work. "))

;; ;
(add-to-list 'hs-special-modes-alist
             (list
              'gdscript-mode
              ;; start regex
              (concat (if gd-hide-show-hide-docstrings
                          "^\\s-*\"\"\"\\|" "")
                      (mapconcat 'identity
                                 (mapcar #'(lambda (x) (concat "^\\s-*" x "\\_>"))
                                         gd-hide-show-keywords)
                                 "\\|"))
              ;; end regex
              nil
              ;; comment-start regex
              "#"
              ;; forward-sexp function
              (lambda (arg)
                (gd-forward-block-or-clause))
              nil))

;; ;

(defun py--input-filter (str)
  "`comint-input-filter' function for GDScript.

Don't save anything for STR matching `gd-input-filter-re' "
  (not (string-match gd-input-filter-re str)))

(make-obsolete 'jpython-mode 'jython-mode nil)

(add-to-list 'same-window-buffer-names (purecopy "*GDScript*"))
(add-to-list 'same-window-buffer-names (purecopy "*IPython*"))

(add-to-list 'auto-mode-alist (cons (purecopy "\\.py\\'")  'gdscript-mode))

;; GDScript Macro File
(add-to-list 'auto-mode-alist (cons (purecopy "\.pym\'")  'gdscript-mode))

(add-to-list 'auto-mode-alist (cons (purecopy "\.pyc\'")  'gdscript-mode))


;; Pyrex Source
(add-to-list 'auto-mode-alist (cons (purecopy "\.pyx\'")  'gdscript-mode))

;; GDScript Optimized Code
(add-to-list 'auto-mode-alist (cons (purecopy "\.pyo\'")  'gdscript-mode))

;; Pyrex Definition File
(add-to-list 'auto-mode-alist (cons (purecopy "\.pxd\'")  'gdscript-mode))

;; GDScript Repository
(add-to-list 'auto-mode-alist (cons (purecopy "\.pyr\'")  'gdscript-mode))

;; GDScript Path Configuration
(add-to-list 'auto-mode-alist (cons (purecopy "\.pth\'")  'gdscript-mode))

;; GDScript Wheels
(add-to-list 'auto-mode-alist (cons (purecopy "\.whl\'")  'gdscript-mode))

;;  (add-to-list 'interpreter-mode-alist
;;  (cons (purecopy "[bi]*python[0-9.]*") 'gdscript-mode))
;;
;;  (add-to-list 'interpreter-mode-alist
;;  (cons (purecopy "jython[0-9.]*") 'jython-mode))

(add-to-list 'magic-mode-alist
	     '("!#[ \t]*/.*[jp]ython[0-9.]*" . gdscript-mode))

;;  lp:1355458, what about using `magic-mode-alist'?

(defun py--uncomment-intern (beg end)
  (uncomment-region beg end)
  (when gd-uncomment-indents-p
    (gd-indent-region beg end)))

(defun gd-uncomment (&optional beg end)
  "Uncomment commented lines at point.

If region is active, restrict uncommenting at region "
  (interactive "*")
  (save-excursion
    (save-restriction
      (when (use-region-p)
        (narrow-to-region (region-beginning) (region-end)))
      (let* (last
             (beg (or beg (save-excursion
                            (while (and (gd-beginning-of-comment) (setq last (point))(prog1 (forward-line -1)(end-of-line))))
                            last))))
        (and (gd-forward-comment))
        (py--uncomment-intern beg (point))))))

(defun py--set-auto-fill-values ()
  "Internal use by `py--run-auto-fill-timer'"
  (let ((pps (parse-partial-sexp (point-min) (point))))
    (cond ((and (nth 4 pps)(numberp gd-comment-fill-column))
           (setq fill-column gd-comment-fill-column))
          ((and (nth 3 pps)(numberp gd-docstring-fill-column))
           (set (make-local-variable 'fill-column) gd-docstring-fill-column))
          (t (setq fill-column gd-fill-column-orig)))))

(defun py--run-auto-fill-timer ()
  "Set fill-column to values of `gd-docstring-fill-column' resp. to `gd-comment-fill-column' according to environment. "
  (when gd-auto-fill-mode
    (unless gd-autofill-timer
      (setq gd-autofill-timer
            (run-with-idle-timer
             gd-autofill-timer-delay t
             'py--set-auto-fill-values)))))

;;  unconditional Hooks
;;  (orgstruct-mode 1)
(add-hook 'gdscript-mode-hook
	  (lambda ()
	    (setq imenu-create-index-function py--imenu-create-index-function)
	    (setq indent-tabs-mode gd-indent-tabs-mode)))

(remove-hook 'gdscript-mode-hook 'gdscript-setup-brm)

(defun gd-complete-auto ()
  "Auto-complete function using gd-complete. "
  ;; disable company
  ;; (when company-mode (company-mode))
  (let ((modified (buffer-chars-modified-tick)))
    ;; don't try completion if buffer wasn't modified
    (unless (eq modified gd-complete-last-modified)
      (if gd-auto-completion-mode-p
	  (if (string= "*PythonCompletions*" (buffer-name (current-buffer)))
	      (sit-for 0.1 t)
	    (if
		(eq gd-auto-completion-buffer (current-buffer))
		;; not after whitespace, TAB or newline
		(unless (member (char-before) (list 32 9 10))
		  (gd-complete)
		  (setq gd-complete-last-modified (buffer-chars-modified-tick)))
	      (setq gd-auto-completion-mode-p nil
		    gd-auto-completion-buffer nil)
	      (cancel-timer py--auto-complete-timer)))))))

(defun gd-set-command-args (arguments)
  "Set GDScript arguments on the fly, override defaults in this session.

Use `defcustom' to keep value across sessions "
  (interactive
   (list
    (read-from-minibuffer "Command args: " gd-gdscript-command-args)))
    (setq gd-gdscript-command-args arguments))

(defun py---emacs-version-greater-23 ()
  "Return `t' if emacs major version is above 23"
  (< 23 (string-to-number (car (split-string emacs-version "\\.")))))

(defun py--empty-arglist-indent (nesting gd-indent-offset indent-offset)
  "Internally used by `gd-compute-indentation'"
  (if
      (and (eq 1 nesting)
           (save-excursion
             (back-to-indentation)
             (looking-at gd-extended-block-or-clause-re)))
      (progn
        (back-to-indentation)
        (+ (current-column) (* 2 (or indent-offset gd-indent-offset))))
    (+ (current-indentation) gd-indent-offset)))

(defun gd-symbol-at-point ()
  "Return the current GDScript symbol."
  (interactive)
  (let ((erg (with-syntax-table
                 gd-dotted-expression-syntax-table
               (current-word))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-kill-buffer-unconditional (buffer)
  "Kill buffer unconditional, kill buffer-process if existing. "
  (interactive
   (list (current-buffer)))
  (let ((buffer (or (and (bufferp buffer) buffer)
		    (get-buffer buffer)))
	proc kill-buffer-query-functions)

    (ignore-errors
      (setq proc (get-buffer-process buffer))
      (and proc (kill-process proc))
      (set-buffer buffer)
      (set-buffer-modified-p 'nil)
      (kill-buffer (current-buffer)))))

(defun py--line-backward-maybe ()
  "Return result of (< 0 (abs (skip-chars-backward \" \\t\\r\\n\\f\"))) "
  (let ((orig (point)))
    (skip-chars-backward " \t\f" (line-beginning-position))
    (< 0 (abs (skip-chars-backward " \t\r\n\f")))))

(defun py--after-empty-line ()
  "Return `t' if line before contains only whitespace characters. "
  (save-excursion
    (beginning-of-line)
    (forward-line -1)
    (beginning-of-line)
    (looking-at "\\s-*$")))

(defun py--compute-indentation-in-string (pps)
  (save-restriction
    ;; (narrow-to-region (nth 8 pps) (point))
    (cond
     ((py--docstring-p)
      (save-excursion
	(back-to-indentation)
	(skip-chars-backward " \t\r\n\f")
	(back-to-indentation)
	(current-indentation)))
     ;; still at original line
     ((eq origline (line-end-position))
      (forward-line -1)
      (end-of-line)
      (skip-chars-backward " \t\r\n\f")
      (if (ignore-errors (< (nth 8 (parse-partial-sexp (point-min) (point))) (line-beginning-position)))
	  (current-indentation)
	(ignore-errors (goto-char (nth 8 pps)))
	(when (py--line-backward-maybe) (setq line t))
	(back-to-indentation)
	(gd-compute-indentation orig origline closing line nesting repeat indent-offset liep)))
     (t (goto-char (nth 8 pps))
	(current-indentation)))))

(defalias 'gd-count-indentation 'gd-compute-indentation)
(defun gd-compute-indentation (&optional orig origline closing line nesting repeat indent-offset liep)
  "Compute GDScript indentation.

When HONOR-BLOCK-CLOSE-P is non-nil, statements such as `return',
`raise', `break', `continue', and `pass' force one level of dedenting.

Optional arguments are flags resp. values set and used by `gd-compute-indentation' internally:
ORIG keeps original position
ORIGLINE keeps line where compute started
CLOSING is t when started at a char delimiting a list as \"]})\"
LINE indicates being not at origline now
NESTING is currently ignored, if executing from inside a list
REPEAT counter enables checks against `gd-max-specpdl-size'
INDENT-OFFSET allows calculation of block-local values
LIEP stores line-end-position at point-of-interest
"
  (interactive)
  (save-excursion
    (save-restriction
      (widen)
      ;; in shell, narrow from previous prompt
      ;; needed by closing
      (unless orig (unless (bobp) (back-to-indentation)))
      (let* ((orig (or orig (point)))
             (origline (or origline (gd-count-lines (point-min) (point))))
             ;; closing indicates: when started, looked
             ;; at a single closing parenthesis
             ;; line: moved already a line backward
             (liep (or liep (line-end-position)))
             (line line)
             (pps (parse-partial-sexp (point-min) (point)))
             (closing
              (or closing
                  (and (nth 1 pps)
                       (looking-at ".*\\(\\s)\\)")(nth 0 pps)
                       ;; char doesn't matter for now, maybe drop
                       (string-to-char (match-string-no-properties 1)))))
             ;; in a recursive call already
             (repeat (if repeat
			 (setq repeat (1+ repeat))
		       0))
             ;; nesting: started nesting a list
             (nesting nesting)
             (indent-offset (or indent-offset gd-indent-offset))
             (cubuf (current-buffer))
             erg indent this-line)
        (if (and (< repeat 1)
                 (and (comint-check-proc (current-buffer))
                      (re-search-backward (concat gd-shell-prompt-regexp "\\|" gd-ipython-output-prompt-re "\\|" gd-ipython-input-prompt-re) nil t 1)))
            ;; common recursion not suitable because of prompt
            (with-temp-buffer
	      ;; (when gd-debug-p (switch-to-buffer (current-buffer)))
              (insert-buffer-substring cubuf (match-end 0) orig)
              (setq indent (gd-compute-indentation)))
	  (if (< gd-max-specpdl-size repeat)
	      (error "`gd-compute-indentation' reached loops max.")
	    (setq nesting (nth 0 pps))
	    (setq indent
		  (cond ((bobp)
			 (cond ((eq liep (line-end-position))
				0)
			       ((looking-at gd-outdent-re)
				(+ (if gd-smart-indentation (gd-guess-indent-offset) indent-offset) (current-indentation)))
			       (t
				(current-indentation))))
			;; in string
			((and (nth 3 pps)(nth 8 pps))
			 (if (py--docstring-p)
			     (py--compute-indentation-in-string pps)
			   0))
			((and (looking-at "\"\"\"\\|'''")(not (bobp)))
			 (gd-backward-statement)
			 (gd-compute-indentation orig origline closing line nesting repeat indent-offset liep))
			;; comments
			((nth 8 pps)
			 (if (eq liep (line-end-position))
			     (progn
			       (goto-char (nth 8 pps))
			       (when (py--line-backward-maybe) (setq line t))
			       (skip-chars-backward " \t")
			       (gd-compute-indentation orig origline closing line nesting repeat indent-offset liep))
			   (goto-char (nth 8 pps))
			   (if
			       line
			       (if gd-indent-honors-inline-comment
				   (current-column)
				 (if gd-indent-comments
				     (progn
				       (gd-backward-comment)
				       (gd-compute-indentation orig origline closing line nesting repeat indent-offset liep))
				   0))
			     (forward-char -1)
			     (gd-compute-indentation orig origline closing line nesting repeat indent-offset liep))))
			((and (looking-at "[ \t]*#") (looking-back "^[ \t]*")(not line)
			      (eq liep (line-end-position)))
			 (if gd-indent-comments
			     (progn
			       (setq line t)
			       (skip-chars-backward " \t\r\n\f")
			       ;; as previous comment-line might
			       ;; be wrongly unindented, travel
			       ;; whole commented section
			       (gd-backward-comment)
			       (gd-compute-indentation orig origline closing line nesting repeat indent-offset liep))
			   0))
			((and (looking-at "[ \t]*#") (looking-back "^[ \t]*")(not
									      (eq liep (line-end-position))))
			 (current-indentation))
			((and (eq ?\# (char-after)) line gd-indent-honors-inline-comment)
			 (current-column))
			;; lists
			((nth 1 pps)
			 (save-excursion
			   (goto-char (nth 1 pps))
			   (setq this-line (gd-count-lines))
			   (cond
			    ((< 0 (- origline this-line))
			     (if (< 1 (- origline this-line))
				 (cond
				  (closing
				   (cond
				    (gd-closing-list-dedents-bos
				     (goto-char (nth 1 pps))
				     (current-indentation))
				    ((looking-back "^[ \t]*")
				     (current-column))
				    ((and (looking-at "\\s([ \t]*$") gd-closing-list-keeps-space)
				     (+ (current-column) gd-closing-list-space))
				    ((looking-at "\\s([ \t]*$")
				     (py--empty-arglist-indent nesting gd-indent-offset indent-offset))
				    ((looking-at "\\s([ \t]*\\([^ \t]+.*\\)$")
				     (goto-char (match-beginning 1))
				     (if gd-indent-paren-spanned-multilines-p
					 (+ (current-column) gd-indent-offset)
				       (current-column)))
				    (t (py--fetch-previous-indent orig))))
				  ;; already behind a dedented element in list
				  ((<= 2 (- origline this-line))
				   (py--fetch-previous-indent orig))
				  ((< (current-indentation) (current-column))
				   (+ (current-indentation) gd-indent-offset))
				  (t (py--fetch-previous-indent orig)))
			       (cond ((looking-at "\\s([ \t]*$")
				      (py--empty-arglist-indent nesting gd-indent-offset indent-offset))
				     ((looking-at "\\s([ \t]*\\([^ \t]+.*\\)$")
				      (goto-char (match-beginning 1))
				      (if gd-indent-paren-spanned-multilines-p
					  (+ (current-column) gd-indent-offset)
					(current-column)))
				     (t (+ (current-column) (* (nth 0 pps)))))))
			    ((nth 1 (parse-partial-sexp (point-min) (point)))
			     (goto-char (nth 1 (parse-partial-sexp (point-min) (point))))
			     (setq line
				   ;; should be faster
				   (< (line-end-position) liep))
			     (gd-compute-indentation orig origline closing line nesting repeat indent-offset liep))
			    ((not (py--beginning-of-statement-p))
			     (gd-backward-statement)
			     (gd-compute-indentation orig origline closing line nesting repeat indent-offset liep))
			    (t (1+ (current-column))))))
			((and (eq (char-after) (or ?\( ?\{ ?\[)) line)
			 (1+ (current-column)))
			((gd-preceding-line-backslashed-p)
			 (progn
			   (gd-backward-statement)
			   (setq this-line (gd-count-lines))
			   (if (< 1 (- origline this-line))
			       (py--fetch-previous-indent orig)
			     (if (looking-at "from +\\([^ \t\n]+\\) +import")
				 gd-backslashed-lines-indent-offset
			       (+ (current-indentation) gd-continuation-offset)))))
			((and (looking-at gd-block-closing-keywords-re)
			      (eq liep (line-end-position)))
			 (skip-chars-backward "[ \t\r\n\f]")
			 (gd-backward-statement)
			 (cond ((looking-at gd-extended-block-or-clause-re)
				(+
				 (if gd-smart-indentation (gd-guess-indent-offset) indent-offset)
				 (current-indentation)))
			       ((looking-at gd-block-closing-keywords-re)
				(- (current-indentation) gd-indent-offset))
			       (t (current-column))))
			((looking-at gd-block-closing-keywords-re)
			 (if (< (line-end-position) orig)
			     (- (current-indentation) gd-indent-offset)
			   (gd-backward-block-or-clause (current-indentation))
			   (current-indentation)))
			((looking-at gd-no-outdent-re)
			 (if
			     (eq liep (line-end-position))
			     (progn
			       (back-to-indentation)
			       (when (py--line-backward-maybe) (setq line t))
			       (gd-compute-indentation orig origline closing line nesting repeat indent-offset liep))
			   (current-indentation)))
			((and (looking-at gd-elif-re) (eq (gd-count-lines) origline))
			 (when (py--line-backward-maybe) (setq line t))
			 (car (py--clause-lookup-keyword gd-elif-re -1 nil orig origline)))
			((and (looking-at gd-clause-re)(not line)
			      (eq liep (line-end-position)))
			 (cond ((looking-at gd-finally-re)
				(car (py--clause-lookup-keyword gd-finally-re -1 nil orig origline)))
			       ((looking-at gd-except-re)
				(car (py--clause-lookup-keyword gd-except-re -1 nil orig origline)))
			       ((looking-at gd-else-re)
				(car (py--clause-lookup-keyword gd-else-re -1 nil orig origline)))
			       ((looking-at gd-elif-re)
				(car (py--clause-lookup-keyword gd-elif-re -1 nil orig origline)))
			       ;; maybe at if, try, with
			       (t (car (py--clause-lookup-keyword gd-block-or-clause-re -1 nil orig origline)))))
			((looking-at gd-extended-block-or-clause-re)
			 (cond ((and (not line)
				     (eq liep (line-end-position)))
				(when (py--line-backward-maybe) (setq line t))
				(gd-compute-indentation orig origline closing line nesting repeat indent-offset liep))
			       (t (+
				   (cond (indent-offset)
					 (gd-smart-indentation
					  (gd-guess-indent-offset))
					 (t gd-indent-offset))
				   (current-indentation)))))
			((and
			  (< (line-end-position) liep)
			  (eq (current-column) (current-indentation)))
			 (and
			  (looking-at gd-assignment-re)
			  (goto-char (match-end 0)))
			 ;; multiline-assignment
			 (if (and nesting (looking-at " *[[{(]")(not (looking-at ".+[]})][ \t]*$")))
			     (+ (current-indentation) gd-indent-offset)
			   (current-indentation)))
			((looking-at gd-assignment-re)
			 (gd-backward-statement)
			 (gd-compute-indentation orig origline closing line nesting repeat indent-offset liep))
			((and (< (current-indentation) (current-column))(not line))
			 (back-to-indentation)
			 (unless line
			   (setq nesting (nth 0 (parse-partial-sexp (point-min) (point)))))
			 (gd-compute-indentation orig origline closing line nesting repeat indent-offset liep))
			((and (not (py--beginning-of-statement-p)) (not (and line (eq ?\# (char-after)))))
			 (if (bobp)
			     (current-column)
			   (if (eq (point) orig)
			       (progn
				 (when (py--line-backward-maybe) (setq line t))
				 (gd-compute-indentation orig origline closing line nesting repeat indent-offset liep))
			     (gd-backward-statement)
			     (gd-compute-indentation orig origline closing line nesting repeat indent-offset liep))))
			((or (py--statement-opens-block-p gd-extended-block-or-clause-re)(looking-at "@"))
			 (if (< (gd-count-lines) origline)
			     (+ (if gd-smart-indentation (gd-guess-indent-offset) indent-offset) (current-indentation))
			   (skip-chars-backward " \t\r\n\f")
			   (setq line t)
			   (back-to-indentation)
			   (gd-compute-indentation orig origline closing line nesting repeat indent-offset liep)))
			((and gd-empty-line-closes-p (py--after-empty-line))
			 (progn (gd-backward-statement)
				(- (current-indentation) gd-indent-offset)))
			;; still at orignial line
			((and (eq liep (line-end-position))
			      (save-excursion
				(and (setq erg (py--go-to-keyword gd-extended-block-or-clause-re))
				     (if gd-smart-indentation (setq indent-offset (gd-guess-indent-offset)) t)
				     (ignore-errors (< orig (or (gd-forward-block-or-clause)(point)))))))
			 (+ (car erg) (if gd-smart-indentation
					  (or indent (gd-guess-indent-offset))
					indent-offset)))
			((and (not line)
			      (eq liep (line-end-position))
			      (py--beginning-of-statement-p))
			 (gd-backward-statement)
			 (gd-compute-indentation orig origline closing line nesting repeat indent-offset liep))
			(t (current-indentation))))
	    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" indent))
	    indent))))))

(defun py--fetch-previous-indent (orig)
  "Report the preceding indent. "
  (save-excursion
    (goto-char orig)
    (forward-line -1)
    (end-of-line)
    (skip-chars-backward " \t\r\n\f")
    (current-indentation)))

(defun gd-continuation-offset (&optional arg)
  "With numeric ARG different from 1 gd-continuation-offset is set to that value; returns gd-continuation-offset. "
  (interactive "p")
  (let ((erg (if (eq 1 arg)
                 gd-continuation-offset
               (when (numberp arg)
                 (prog1
                     arg
                   (setq gd-continuation-offset arg))))))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" gd-continuation-offset))
    gd-continuation-offset))

(defalias 'pios 'gd-indentation-of-statement)
(defalias 'ios 'gd-indentation-of-statement)
(defun gd-indentation-of-statement ()
  "Returns the indenation of the statement at point. "
  (interactive)
  (let ((erg (save-excursion
               (back-to-indentation)
               (or (py--beginning-of-statement-p)
                   (gd-backward-statement))
               (current-indentation))))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defalias 'gd-in-list-p 'gd-list-beginning-position)
(defun gd-list-beginning-position (&optional start)
  "Return lists beginning position, nil if not inside.

Optional ARG indicates a start-position for `parse-partial-sexp'."
  (interactive)
  (let* ((ppstart (or start (point-min)))
         (erg (nth 1 (parse-partial-sexp (point-min) (point)))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-end-of-list-position (&optional arg)
  "Return end position, nil if not inside.

Optional ARG indicates a start-position for `parse-partial-sexp'."
  (interactive)
  (let* ((ppstart (or arg (point-min)))
         (erg (parse-partial-sexp (point-min) (point)))
         (beg (nth 1 erg))
         end)
    (when beg
      (save-excursion
        (goto-char beg)
        (forward-list 1)
        (setq end (point))))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" end))
    end))

(defun py--in-comment-p ()
  "Return the beginning of current line's comment, if inside. "
  (save-restriction
    (widen)
    (let* ((pps (parse-partial-sexp (point-min) (point)))
           (erg (when (nth 4 pps) (nth 8 pps))))
      (unless erg
        (when (looking-at (concat "^[ \t]*" comment-start-skip))
          (setq erg (point))))
      erg)))

(defun gd-in-triplequoted-string-p ()
  "Returns character address of start tqs-string, nil if not inside. "
  (interactive)
  (let* ((pps (parse-partial-sexp (point-min) (point)))
         (erg (when (and (nth 3 pps) (nth 8 pps))(nth 2 pps))))
    (save-excursion
      (unless erg (setq erg
                        (progn
                          (when (looking-at "\"\"\"\\|''''")
                            (goto-char (match-end 0))
                            (setq pps (parse-partial-sexp (point-min) (point)))
                            (when (and (nth 3 pps) (nth 8 pps)) (nth 2 pps)))))))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-in-string-p-intern (pps)
  (goto-char (nth 8 pps))
  (list (point) (char-after)(skip-chars-forward (char-to-string (char-after)))))

(defun gd-in-string-p ()
  "if inside a double- triple- or singlequoted string,

If non-nil, return a list composed of
- beginning position
- the character used as string-delimiter (in decimal)
- and length of delimiter, commonly 1 or 3 "
  (interactive)
  (save-excursion
    (let* ((pps (parse-partial-sexp (point-min) (point)))
	   (erg (when (nth 3 pps)
		  (gd-in-string-p-intern pps))))
      (unless erg
	(when (looking-at "\"\\|'")
	  (forward-char 1)
	  (setq pps (parse-partial-sexp (line-beginning-position) (point)))
	  (when (nth 3 pps)
	    (setq erg (gd-in-string-p-intern pps)))))

    ;; (list (nth 8 pps) (char-before) (1+ (skip-chars-forward (char-to-string (char-before)))))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg)))

(defun gd-in-statement-p ()
  "Returns list of beginning and end-position if inside.

Result is useful for booleans too: (when (gd-in-statement-p)...)
will work.
"
  (interactive)
  (let ((orig (point))
        beg end erg)
    (save-excursion
      (setq end (gd-forward-statement))
      (setq beg (gd-backward-statement))
      (when (and (<= beg orig)(<= orig end))
        (setq erg (cons beg end))
        (when (called-interactively-p 'any) (message "%s" erg))
        erg))))

;;  Beginning-of- p
(defun gd-backward-top-level-p ()
  "Returns position, if cursor is at the beginning of a top-level, nil otherwise. "
  (interactive)
  (let (erg)
    (and (py--beginning-of-statement-p)
         (eq 0 (current-column))
         (setq erg (point))
      erg)))

(defun py--beginning-of-line-p ()
  "Returns position, if cursor is at the beginning of a line, nil otherwise. "
  (when (bolp)(point)))

(defun py--beginning-of-buffer-p ()
  "Returns position, if cursor is at the beginning of buffer, nil otherwise. "
  (when (bobp)(point)))

(defun py--beginning-of-paragraph-p ()
  "Returns position, if cursor is at the beginning of a paragraph, nil otherwise. "
  (let ((orig (point))
        erg)
    (if (and (bolp) (looking-at paragraph-separate))
        (setq erg (point))
      (save-excursion
        (gd-forward-paragraph)
        (gd-backward-paragraph)
        (when (eq orig (point))
          (setq erg orig)))
      erg)))

;;  End-of- p
(defun py--end-of-line-p ()
  "Returns position, if cursor is at the end of a line, nil otherwise. "
  (when (eolp)(point)))

(defun py--end-of-paragraph-p ()
  "Returns position, if cursor is at the end of a paragraph, nil otherwise. "
  (let ((orig (point))
         erg)
     (if (and (eolp) (looking-at paragraph-separate))
         (setq erg (point))
     (save-excursion
       (gd-backward-paragraph)
       (gd-forward-paragraph)
       (when (eq orig (point))
         (setq erg orig)))
       erg)))

;;  Opens
(defun py--statement-opens-block-p (&optional regexp)
  "Return position if the current statement opens a block
in stricter or wider sense.

For stricter sense specify regexp. "
  (let* ((regexp (or regexp gd-block-or-clause-re))
         (erg (py--statement-opens-base regexp)))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun py--statement-opens-base (regexp)
  (let ((orig (point))
        erg)
    (save-excursion
      (back-to-indentation)
      (gd-forward-statement)
      (gd-backward-statement)
      (when (and
             (<= (line-beginning-position) orig)(looking-back "^[ \t]*")(looking-at regexp))
        (setq erg (point))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun py--statement-opens-clause-p ()
  "Return position if the current statement opens block or clause. "
  (py--statement-opens-base gd-clause-re))

(defun py--statement-opens-block-or-clause-p ()
  "Return position if the current statement opens block or clause. "
  (py--statement-opens-base gd-block-or-clause-re))

(defun py--statement-opens-class-p ()
  "Return `t' if the statement opens a functions or class definition, nil otherwise. "
  (py--statement-opens-base gd-class-re))

(defun py--statement-opens-def-p ()
  "Return `t' if the statement opens a functions or class definition, nil otherwise. "
  (py--statement-opens-base gd-def-re))

(defun py--statement-opens-def-or-class-p ()
  "Return `t' if the statement opens a functions or class definition, nil otherwise. "
  (py--statement-opens-base gd-def-or-class-re))

(defun py--record-list-error (pps)
  "When encountering a missing parenthesis, store its line, position. `gd-verbose-p'  must be t

Unclosed-string errors are not handled here, as made visible by fontification already.
"
  (let ((this-err
         (save-excursion
           (list
            (nth 1 pps)
            (progn
              (goto-char (nth 1 pps))
              (gd-count-lines (point-min) (point)))))))
    this-err))

(defun py--message-error (err)
  "Receives a list (position line) "
  (message "Closing paren missed: line %s pos %s" (cadr err) (car err)))

(defun py--end-base-look-upward (thisregexp regexp)
  (progn (back-to-indentation)
	 (let ((bofst (py--beginning-of-statement-p)))
	   (cond ((and bofst (eq regexp 'gd-clause-re)(looking-at gd-extended-block-or-clause-re))
		  (point))
		 ((and bofst (looking-at thisregexp))
		  (point))
		 (t
		  (when
		      (cdr-safe
		       (py--go-to-keyword
			thisregexp))
		    (when (py--statement-opens-block-p gd-extended-block-or-clause-re)
		      (point))))))))

(defun py--go-down-when-found-upward (regexp)
  (let ((thisindent (current-indentation))
	last)
    (while
	(and (gd-down-statement)
	     (or (< thisindent (current-indentation))
		 (and (eq thisindent (current-indentation))
		      (or (eq regexp 'gd-minor-block-re)
			  (eq regexp 'gd-block-re)
			  (eq regexp 'gd-if-block-re))
		      (looking-at gd-clause-re)))
	     (gd-forward-statement)(setq last (point))))
    (and last (goto-char last))))

;;  gd-look-downward-for-clause
(defun py--end-base (regexp &optional orig decorator)
  "Used internal by functions going to the end forms. "
  (unless (eobp)
    (catch 'exit
      (let* ((orig (or orig (point)))
             (regexp (or regexp 'gd-extended-block-or-clause-re))
             (thisregexp
              (cond ((eq regexp 'gd-def-or-class-re)
                     gd-def-or-class-re)
                    ((eq regexp 'gd-def-re)
                     gd-def-re)
		    ((eq regexp 'gd-section-re)
                     gd-section-re)
		    ((eq regexp 'gd-expression-re)
		     gd-expression-re)
		    ((eq regexp 'gd-class-re)
		     gd-class-re)
		    ((eq regexp 'gd-minor-block-re)
		     gd-minor-block-re)
		    (t gd-extended-block-or-clause-re)))
             bofst
             (this (unless (eq regexp 'gd-paragraph-re)(py--end-base-look-upward thisregexp regexp)))
             ind erg last pps thisindent done err)
        (cond ((eq regexp 'gd-paragraph-re)
	       (while (and (not (eobp)) (re-search-forward gd-paragraph-re nil 'move 1)(nth 8 (parse-partial-sexp (point-min) (point))))))
	      (this (py--go-down-when-found-upward regexp))
              (t (goto-char orig)))
        (when (and (<= (point) orig)(not (looking-at thisregexp)))
          ;; found the end above
          ;; py--travel-current-indent will stop of clause at equal indent
          (when (py--look-downward-for-beginning thisregexp)
	    (py--end-base regexp orig)))
        (setq pps (parse-partial-sexp (point-min) (point)))
        ;; (catch 'exit)
        (and err gd-verbose-p (py--message-error err))
        (if (and (< orig (point)) (not (or (looking-at comment-start) (nth 8 pps) (nth 1 pps))))
            (point)
          (goto-char (point-max))
          nil)))))

(defun py--look-downward-for-beginning (regexp)
  "When above any beginning of FORM, search downward. "
  (let* ((orig (point))
         (erg orig)
         (last orig)
         pps)
    (while (and (setq last (point)) (not (eobp)) (re-search-forward regexp nil t 1)(setq erg (match-beginning 0)) (setq pps (parse-partial-sexp (point-min) (point)))
                (or (nth 8 pps) (nth 1 pps))))
    (cond ((not (or (nth 8 pps) (nth 1 pps) (or (looking-at comment-start))))
           (when (ignore-errors (< orig erg))
             erg)))))

(defun gd-look-downward-for-clause (&optional ind orig regexp)
  "If beginning of other clause exists downward in current block.

If succesful return position. "
  (interactive)
  (unless (eobp)
    (let ((ind (or ind
                   (save-excursion
                     (gd-backward-statement)
                     (if (py--statement-opens-block-p)
                         (current-indentation)
                       (- (current-indentation) gd-indent-offset)))))
          (orig (or orig (point)))
          (regexp (or regexp gd-extended-block-or-clause-re))
          erg last)
      (end-of-line)
      (when (re-search-forward regexp nil t 1)
        (when (nth 8 (parse-partial-sexp (point-min) (point)))
          (while (and (re-search-forward regexp nil t 1)
                      (nth 8 (parse-partial-sexp (point-min) (point))))))
        (setq last (point))
        (back-to-indentation)
        (unless (and (looking-at gd-clause-re)
                     (not (nth 8 (parse-partial-sexp (point-min) (point)))) (eq (current-indentation) ind))
          (progn (setq ind (current-indentation))
                 (while (and (gd-forward-statement-bol)(not (looking-at gd-clause-re))(<= ind (current-indentation)))))
          (if (and (looking-at gd-clause-re)
                   (not (nth 8 (parse-partial-sexp (point-min) (point))))
                   (< orig (point)))
              (setq erg (point))
            (goto-char orig))))
      (when (called-interactively-p 'any) (message "%s" erg))
      erg)))

(defun gd-current-defun (&optional iact)
  "Go to the outermost method or class definition in current scope.

GDScript value for `add-log-current-defun-function'.
This tells add-log.el how to find the current function/method/variable.
Returns name of class or methods definition, if found, nil otherwise.

See customizable variables `gd-current-defun-show' and `gd-current-defun-delay'."
  (interactive "p")
  (save-restriction
    (widen)
    (save-excursion
      (let ((erg (when (gd-backward-def-or-class)
                   (forward-word 1)
                   (skip-chars-forward " \t")
                   (prin1-to-string (symbol-at-point)))))
        (when (and erg gd-current-defun-show)
	  (push-mark (point) t t) (skip-chars-forward "^ (")
	  (exchange-point-and-mark)
	  (sit-for gd-current-defun-delay))
        (when iact (message (prin1-to-string erg)))
        erg))))

(defun gd-sort-imports ()
  "Sort multiline imports.

Put point inside the parentheses of a multiline import and hit
\\[gd-sort-imports] to sort the imports lexicographically"
  (interactive)
  (save-excursion
    (let ((open-paren (ignore-errors (save-excursion (progn (up-list -1) (point)))))
          (close-paren (ignore-errors (save-excursion (progn (up-list 1) (point)))))
          sorted-imports)
      (when (and open-paren close-paren)
	(goto-char (1+ open-paren))
	(skip-chars-forward " \n\t")
	(setq sorted-imports
	      (sort
	       (delete-dups
		(split-string (buffer-substring
			       (point)
			       (save-excursion (goto-char (1- close-paren))
					       (skip-chars-backward " \n\t")
					       (point)))
			      ", *\\(\n *\\)?"))
	       ;; XXX Should this sort case insensitively?
	       'string-lessp))
	;; Remove empty strings.
	(delete-region open-paren close-paren)
	(goto-char open-paren)
	(insert "(\n")
	(insert (py--join-words-wrapping (remove "" sorted-imports) "," "    " 78))
	(insert ")")))))

(defun py--in-literal (&optional lim)
  "Return non-nil if point is in a GDScript literal (a comment or string).
Optional argument LIM indicates the beginning of the containing form,
i.e. the limit on how far back to scan."
  (let* ((lim (or lim (point-min)))
         (state (parse-partial-sexp (point-min) (point))))
    (cond
     ((nth 3 state) 'string)
     ((nth 4 state) 'comment))))

(defconst gd-help-address "gdscript-mode@python.org"
  "List dealing with usage and developing gdscript-mode.

Also accepts submission of bug reports, whilst a ticket at
http://launchpad.net/gdscript-mode
is preferable for that. ")

;;  Utilities
(defun py--point (position)
  "Returns the value of point at certain commonly referenced POSITIONs.
POSITION can be one of the following symbols:

  bol -- beginning of line
  eol -- end of line
  bod -- beginning of def or class
  eod -- end of def or class
  bob -- beginning of buffer
  eob -- end of buffer
  boi -- back to indentation
  bos -- beginning of statement

This function does not modify point or mark."
  (let (erg)
    (save-excursion
      (setq erg
            (progn
              (cond
               ((eq position 'bol) (beginning-of-line))
               ((eq position 'eol) (end-of-line))
               ((eq position 'bod) (gd-backward-def-or-class))
               ((eq position 'eod) (gd-forward-def-or-class))
               ;; Kind of funny, I know, but useful for gd-up-exception.
               ((eq position 'bob) (goto-char (point-min)))
               ((eq position 'eob) (goto-char (point-max)))
               ((eq position 'boi) (back-to-indentation))
               ((eq position 'bos) (gd-backward-statement))
               (t (error "Unknown buffer position requested: %s" position))) (point))))
    erg))

(defun gd-install-search-local ()
  (interactive)
  (let ((erg (split-string (shell-command-to-string (concat "find " default-directory " -maxdepth 9 -type f -name \"*python\"")))))))

;;  (defun gd-install-local-epdfree ()
;;    (interactive)
;;    (gd-install-local-shells "MY-PATH/epdfree"))

(defun gd-install-local-shells (&optional local path-prefix)
  "Builds GDScript-shell commands from executable found in LOCAL.

If LOCAL is empty, shell-command `find' searches beneath current directory.
Eval resulting buffer to install it, see customizable `gd-extensions'. "
  (interactive)
  (let* ((local-dir (if local
                        (expand-file-name local)
                      (read-from-minibuffer "Virtualenv directory: " default-directory)))
         (path-separator (if (string-match "/" local-dir)
                             "/"
                           "\\" t))
         (shells (split-string (shell-command-to-string (concat "find " local-dir " -maxdepth 9 -type f -executable -name \"*python\""))))
         erg newshell prefix akt end orig curexe aktpath)
    (set-buffer (get-buffer-create gd-extensions))
    (erase-buffer)
    (dolist (elt shells)
      (setq prefix "")
      (setq curexe (substring elt (1+ (string-match "/[^/]+$" elt))))
      (setq aktpath (substring elt 0 (1+ (string-match "/[^/]+$" elt))))
      (dolist (prf (split-string aktpath (regexp-quote path-separator)))
        (unless (string= "" prf)
          (setq prefix (concat prefix (substring prf 0 1)))))
      (setq orig (point))
      (insert gd-shell-template)
      (setq end (point))
      (goto-char orig)
      (when (re-search-forward "\\<NAME\\>" end t 1)
        (replace-match (concat prefix "-" (substring elt (1+ (save-match-data (string-match "/[^/]+$" elt)))))t))
      (goto-char orig)
      (while (search-forward "DOCNAME" end t 1)
        (replace-match (if (string= "ipython" curexe)
                           "IPython"
                         (capitalize curexe)) t))
      (goto-char orig)
      (when (search-forward "FULLNAME" end t 1)
        (replace-match elt t))
      (goto-char (point-max)))
    (emacs-lisp-mode)
    (if (file-readable-p (concat gd-install-directory "/" gd-extensions))
        (find-file (concat gd-install-directory "/" gd-extensions)))))

(defun gd-end-of-string (&optional beginning-of-string-position)
  "Go to end of string at point if any, if successful return position. "
  (interactive)
  ;; (when gd-debug-p (message "(current-buffer): %s" (current-buffer)))
  ;; (when gd-debug-p (message "major-mode): %s" major-mode))
  (let ((orig (point))
	(beginning-of-string-position (or beginning-of-string-position (and (nth 3 (parse-partial-sexp 1 (point)))(nth 8 (parse-partial-sexp 1 (point))))
                                          (and (looking-at "\"\"\"\\|'''\\|\"\\|\'")(match-beginning 0))))
        erg)
    (if beginning-of-string-position
        (progn
          (goto-char beginning-of-string-position)
	  (when
	      ;; work around parse-partial-sexp error
	      (and (nth 3 (parse-partial-sexp 1 (point)))(nth 8 (parse-partial-sexp 1 (point))))
	    (goto-char (nth 3 (parse-partial-sexp 1 (point)))))
          (if (ignore-errors (setq erg (scan-sexps (point) 1)))
			      (goto-char erg)
	    (goto-char orig)))

      (error (concat "gd-end-of-string: don't see end-of-string at " (buffer-name (current-buffer)) "at pos " (point))))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

;;  (goto-char (match-end 0))
;;  (search-forward (match-string-no-properties 0))))

(defun py--until-found (search-string liste)
  "Search liste for search-string until found. "
  (let ((liste liste) element)
    (while liste
      (if (member search-string (car liste))
          (setq element (car liste) liste nil))
      (setq liste (cdr liste)))
    (when element
      (while (and element (not (numberp element)))
        (if (member search-string (car element))
            (setq element (car element))
          (setq element (cdr element))))
      element)))

(defun py--delay-process-dependent (process)
  "Call a `gd-ipython-send-delay' or `gd-gdscript-send-delay' according to process"
  (if (string-match "ipython" (prin1-to-string process))
      (sit-for gd-ipython-send-delay t)
    (sit-for gd-gdscript-send-delay t)))

(defun py--send-string-no-output (string &optional process msg)
  "Send STRING to PROCESS and inhibit output display.
When MSG is non-nil messages the first line of STRING.  Return
the output."
  (let* (output
         (process (or process (get-buffer-process (gd-shell))))
         (comint-preoutput-filter-functions
          (append comint-preoutput-filter-functions
                  '(ansi-color-filter-apply
                    (lambda (string)
                      (setq output string)
                      "")))))
    (gd-send-string string process)
    (sit-for 0.1 t)
    ;; (py--delay-process-dependent process)
    (when (and output (not (string= "" output)))
	    (py--string-strip
	     (format "[ \n]*%s[ \n]*" gd-fast-filter-re)))))

(defun py--send-string-return-output (string &optional process msg)
  "Send STRING to PROCESS and return output.

When MSG is non-nil messages the first line of STRING.  Return
the output."
  (let ((process (or process (get-buffer-process (gd-shell))))
	erg)
    (with-current-buffer (process-buffer process)
      (let ((comint-preoutput-filter-functions
	     (append comint-preoutput-filter-functions
		     '(ansi-color-filter-apply
		       (lambda (string)
			 (setq erg (concat erg string))
			 "")))))
	(gd-send-string string process)
	(accept-process-output process 5)
	(sit-for 0.1 t)
	(when (and erg (not (string= "" erg)))
	  (setq erg
		(replace-regexp-in-string
		 (format "[ \n]*%s[ \n]*" gd-fast-filter-re)
		 "" erg)))
	;; (sit-for 0.1 t)
	erg))))

(defun gd-which-def-or-class (&optional orig)
  "Returns concatenated `def' and `class' names in hierarchical order, if cursor is inside.

Returns \"???\" otherwise
Used by variable `which-func-functions' "
  (interactive)
  (let* ((orig (point))
	 (backindent 99999)
	 (re (concat gd-def-or-class-re "\\([[:alnum:]_]+\\)"))
         erg forward indent backward limit)
    (if
	(and (looking-at re)
	     (not (nth 8 (parse-partial-sexp (point-min) (point)))))
	(progn
	  (setq erg (list (match-string-no-properties 2)))
	  (setq backindent (current-indentation)))
      ;; maybe inside a definition's symbol
      (or (eolp) (and (looking-at "[[:alnum:]]")(forward-word 1))))
    (if
	(and (not (and erg (eq 0 (current-indentation))))
	     (setq limit (gd-backward-top-level))
	     (looking-at re))
	(progn
	  (add-to-list 'erg (match-string-no-properties 2))
	  (setq indent (current-indentation)))
      (goto-char orig)
      (while (and
	      (re-search-backward gd-def-or-class-re limit t 1)
	      (< (current-indentation) backindent)
	      (setq backindent (current-indentation))
	      (setq backward (point))
	      (or (< 0 (current-indentation))
		  (nth 8 (parse-partial-sexp (point-min) (point))))))
      (when (and backward
		 (goto-char backward)
		 (looking-at re))
	(add-to-list 'erg (match-string-no-properties 2))
	(setq indent (current-indentation))))
    ;; (goto-char orig))
    (if erg
	(progn
	  (end-of-line)
	  (while (and (re-search-forward gd-def-or-class-re nil t 1)
		      (<= (point) orig)
		      (< indent (current-indentation))
		      (or
		       (nth 8 (parse-partial-sexp (point-min) (point)))
		       (setq forward (point)))))
	  (if forward
	      (progn
		(goto-char forward)
		(save-excursion
		  (back-to-indentation)
		  (and (looking-at re)
		       (setq erg (list (car erg) (match-string-no-properties 2)))
		       ;; (< (gd-forward-def-or-class) orig)
		       ;; if match was beyond definition, nil
		       ;; (setq erg nil)
		       )))
	    (goto-char orig))))
    (if erg
	(if (< 1 (length erg))
	    (setq erg (mapconcat 'identity erg "."))
	  (setq erg (car erg)))
      (setq erg "???"))
    (goto-char orig)
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun py--beginning-of-form-intern (regexp &optional iact indent orig lc)
  "Go to beginning of FORM.

With INDENT, go to beginning one level above.
Whit IACT, print result in message buffer.

Returns beginning of FORM if successful, nil otherwise"
  (interactive "P")
  (let (erg)
    (unless (bobp)
      (let* ((orig (or orig (point)))
             (indent (or indent (progn
                                  (back-to-indentation)
                                  (or (py--beginning-of-statement-p)
                                      (gd-backward-statement))
                                  (current-indentation)))))
        (setq erg (cond ((and (< (point) orig) (looking-at (symbol-value regexp)))
                         (point))
                        ((and (eq 0 (current-column)) (numberp indent) (< 0 indent))
                         (when (< 0 (abs (skip-chars-backward " \t\r\n\f")))
                           (gd-backward-statement)
                           (unless (looking-at (symbol-value regexp))
                             (cdr (py--go-to-keyword (symbol-value regexp) (current-indentation))))))
                        ((numberp indent)
			 (cdr (py--go-to-keyword (symbol-value regexp) indent)))
                        (t (ignore-errors
                             (cdr (py--go-to-keyword (symbol-value regexp)
                                                    (- (progn (if (py--beginning-of-statement-p) (current-indentation) (save-excursion (gd-backward-statement) (current-indentation)))) gd-indent-offset)))))))
        (when lc (beginning-of-line) (setq erg (point)))))
    (when (and gd-verbose-p iact) (message "%s" erg))
    erg))

(defun py--backward-prepare (&optional indent final-re inter-re iact lc)
  (let ((orig (point))
        (indent
         (or indent
	     (cond ((looking-back "^[ \t]*")
		    (current-indentation))
		   (t (progn (back-to-indentation)
			     (or (py--beginning-of-statement-p)
				 (gd-backward-statement))
			     (cond ((eq 0 (current-indentation))
				    (current-indentation))
				   ((looking-at (symbol-value inter-re))
				    (current-indentation))
				   (t
				    (if (<= gd-indent-offset (current-indentation))
					(- (current-indentation) (if gd-smart-indentation (gd-guess-indent-offset) gd-indent-offset))
				      gd-indent-offset))))))))
        erg)
    (if (and (< (point) orig) (looking-at (symbol-value final-re)))
        (progn
          (and lc (beginning-of-line))
          (setq erg (point))
          (when (and gd-verbose-p iact) (message "%s" erg))
          erg)
      (py--beginning-of-form-intern final-re iact indent orig lc))))

(defun py--fetch-first-gdscript-buffer ()
  "Returns first (I)GDScript-buffer found in `buffer-list'"
  (let ((buli (buffer-list))
        erg)
    (while (and buli (not erg))
      (if (string-match "GDScript" (prin1-to-string (car buli)))
          (setq erg (car buli))
        (setq buli (cdr buli))))
    erg))

(defun gd-unload-gdscript-el ()
  "Unloads gdscript-mode delivered by shipped python.el

Removes gdscript-skeleton forms from abbrevs.
These would interfere when inserting forms heading a block"
  (interactive)
  (let (done)
    (when (featurep 'python) (unload-feature 'python t))
    (when (file-readable-p abbrev-file-name)
      (find-file abbrev-file-name)
      (goto-char (point-min))
      (while (re-search-forward "^.+gdscript-skeleton.+$" nil t 1)
	(setq done t)
	(delete-region (match-beginning 0) (1+ (match-end 0))))
      (when done (write-file abbrev-file-name)
	    ;; now reload
	    (read-abbrev-file abbrev-file-name))
      (kill-buffer (file-name-nondirectory abbrev-file-name)))))

(defmacro py--kill-buffer-unconditional (buffer)
  "Kill buffer unconditional, kill buffer-process if existing. "
  `(let ((proc (get-buffer-process ,buffer))
	 kill-buffer-query-functions)
     (ignore-errors
       (and proc (kill-process proc))
       (set-buffer ,buffer)
       (set-buffer-modified-p 'nil)
       (kill-buffer (current-buffer)))))

(defun py--skip-to-semicolon-backward (&optional limit)
  "Fetch the beginning of statement after a semicolon.

Returns position reached if point was moved. "
  (prog1
      (< 0 (abs (skip-chars-backward "^;" (or limit (line-beginning-position)))))
    (skip-chars-forward " \t" (line-end-position))))

(defun py--end-of-comment-intern (pos)
  (while (and (not (eobp))
              (forward-comment 99999)))
  ;; forward-comment fails sometimes
  (and (eq pos (point)) (prog1 (forward-line 1) (back-to-indentation))
       (while (member (char-after) (list ?# 10))(forward-line 1)(back-to-indentation))))

(defun py--skip-to-comment-or-semicolon (done)
  "Returns position if comment or semicolon found. "
  (let ((orig (point)))
    (cond ((and done (< 0 (abs (skip-chars-forward "^#;" (line-end-position))))
		(member (char-after) (list ?# ?\;)))
	   (when (eq ?\; (char-after))
	     (skip-chars-forward ";" (line-end-position))))
	  ((and (< 0 (abs (skip-chars-forward "^#;" (line-end-position))))
		(member (char-after) (list ?# ?\;)))
	   (when (eq ?\; (char-after))
	     (skip-chars-forward ";" (line-end-position))))
	  ((not done)
	   (end-of-line)))
    (skip-chars-backward " \t" (line-beginning-position))
    (and (< orig (point))(setq done t)
	 done)))

(defun py--beginning-of-top-level-p ()
  "Returns position, if cursor is at the beginning of a `top-level', nil otherwise. "
  (interactive)
  (let ((erg (and (bolp)(not (or (gd-in-string-or-comment-p)(empty-line-p))))))
    (when erg (point))))

(defun gd-backward-top-level ()
  "Go up to beginning of statments until level of indentation is null.

Returns position if successful, nil otherwise "
  (interactive)
  (let (erg)
    (unless (bobp)
      (while (and (not (bobp))
		  (setq erg (re-search-backward "^[[:alpha:]_'\"]" nil t 1))
		  (nth 8 (parse-partial-sexp (point-min) (point)))
		  (setq erg nil)))
      (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
      erg)))

(defun gd-forward-top-level ()
  "Go to end of top-level form at point.

Returns position if successful, nil otherwise"
  (interactive)
  (let ((orig (point))
	erg)
    (unless (eobp)
      (unless (py--beginning-of-statement-p)
	(gd-backward-statement))
      (unless (eq 0 (current-column))
	(gd-backward-top-level))
      (cond ((looking-at gd-def-re)
	     (setq erg (gd-forward-def)))
	    ((looking-at gd-class-re)
	     (setq erg (gd-forward-class)))
	    ((looking-at gd-block-re)
	     (setq erg (gd-forward-block)))
	    (t (setq erg (gd-forward-statement))))
      (unless (< orig (point))
	(while (and (not (eobp)) (gd-down-statement)(< 0 (current-indentation))))
	(if (looking-at gd-block-re)
	    (setq erg (gd-forward-block))
	  (setq erg (gd-forward-statement))))
      (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
      erg)))

(defun gd-down-top-level ()
  "Go to beginning of next top-level form downward.

Returns position if successful, nil otherwise"
  (interactive)
  (let ((orig (point))
        erg)
    (while (and (not (eobp))
		(progn (end-of-line)
		       (re-search-forward "^[[:alpha:]_'\"]" nil 'move 1))
		(nth 8 (parse-partial-sexp (point-min) (point)))))
    (when (and (not (eobp)) (< orig (point)))
      (goto-char (match-beginning 0))
	(setq erg (point)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-forward-top-level-bol ()
  "Go to end of top-level form at point, stop at next beginning-of-line.

Returns position successful, nil otherwise"
  (interactive)
  (let (erg)
    (gd-forward-top-level)
    (unless (or (eobp) (bolp))
      (forward-line 1)
      (beginning-of-line)
      (setq erg (point)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-up (&optional indent)
  "Go up or to beginning of form if inside.

If inside a delimited form --string or list-- go to its beginning.
If not at beginning of a statement or block, go to its beginning.
If at beginning of a statement or block, go to beginning one level above of compound statement or definition at point."
  (interactive "P")
  (let ((pps (parse-partial-sexp (point-min) (point))))
    (cond ((nth 8 pps) (goto-char (nth 8 pps)))
          ((nth 1 pps) (goto-char (nth 1 pps)))
          ((py--beginning-of-statement-p) (py--beginning-of-form-intern 'gd-extended-block-or-clause-re (called-interactively-p 'any) t))
          (t (gd-backward-statement)))))

(defun gd-down (&optional indent)

  "Go to beginning one level below of compound statement or definition at point.

If no statement or block below, but a delimited form --string or list-- go to its beginning. Repeated call from there will behave like down-list.

Returns position if successful, nil otherwise"
  (interactive "P")
  (let* ((orig (point))
         erg
         (indent (if
                     (py--beginning-of-statement-p)
                     (current-indentation)
                   (progn
                     (gd-backward-statement)
                     (current-indentation))))
         last)
    (while (and (setq last (point)) (gd-forward-statement) (gd-forward-statement) (gd-backward-statement) (eq (current-indentation) indent)))
    (if (< indent (current-indentation))
        (setq erg (point))
      (goto-char last))
    (when (< (point) orig)
      (goto-char orig))
    (when (and (eq (point) orig)
               (progn (forward-char 1)
                      (skip-chars-forward "^\"'[({" (line-end-position))
                      (member (char-after) (list ?\( ?\" ?\' ?\[ ?\{)))
               (setq erg (point))))
    (unless erg
      (goto-char orig))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun py--beginning-of-line-form (erg)
  "Internal use: Go to beginning of line following end of form. "
  (when erg
    (unless (eobp)
      (forward-line 1)
      (beginning-of-line)
      (setq erg (point)))))

(defun py--mark-base (form &optional gd-mark-decorators)
  "Returns boundaries of FORM, a cons.

If PY-MARK-DECORATORS, `def'- and `class'-forms include decorators
If BOL is t, mark from beginning-of-line"
  (let* ((begform (intern-soft (concat "gd-backward-" form)))
         (endform (intern-soft (concat "gd-forward-" form)))
         (begcheckform (intern-soft (concat "py--beginning-of-" form "-p")))
         (orig (point))
         beg end erg)
    (setq beg (if
                  (setq beg (funcall begcheckform))
                  beg
                (funcall begform)))
    (and gd-mark-decorators
         (and (setq erg (gd-backward-decorator))
              (setq beg erg)))
    (push-mark)
    (setq end (funcall endform))
    (unless end (when (< beg (point))
                  (setq end (point))))
    (if (and beg end (<= beg orig) (<= orig end))
	(cons beg end)
      nil)))

(defun py--mark-base-bol (form &optional gd-mark-decorators)
  (let* ((begform (intern-soft (concat "gd-backward-" form "-bol")))
         (endform (intern-soft (concat "gd-forward-" form "-bol")))
         (begcheckform (intern-soft (concat "py--beginning-of-" form "-bol-p")))
         (orig (point))
         beg end erg)
    (setq beg (if
                  (setq beg (funcall begcheckform))
                  beg
                (funcall begform)))
    (when gd-mark-decorators
      (save-excursion
        (when (setq erg (gd-backward-decorator))
          (setq beg erg))))
    (setq end (funcall endform))
    (push-mark beg t t)
    (unless end (when (< beg (point))
                  (setq end (point))))
    (cons beg end)))

(defun gd-mark-base (form &optional gd-mark-decorators)
  "Calls py--mark-base, returns bounds of form, a cons. "
  (let* ((bounds (py--mark-base form gd-mark-decorators))
         (beg (car bounds)))
    (push-mark beg t t)
    bounds))

(defun gd-beginning (&optional indent)
 "Go to beginning of compound statement or definition at point.

With \\[universal-argument], go to beginning one level above.
Returns position if successful, nil otherwise"
  (interactive "P")
  (py--beginning-of-form-intern gd-extended-block-or-clause-re (called-interactively-p 'any) indent))

(defun gd-end (&optional indent)
 "Go to end of of compound statement or definition at point.

Returns position block if successful, nil otherwise"
  (interactive "P")
    (let* ((orig (point))
           (erg (py--end-base 'gd-extended-block-or-clause-re orig)))
      (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
      erg))

;;  Buffer
(defun gd-beginning-of-buffer ()
  "Go to beginning-of-buffer, return position. "
  (let ((erg (unless (bobp)
               (goto-char (point-min)))))
    erg))

(defun gd-end-of-buffer ()
  "Go to end-of-buffer, return position.

  If already at end-of-buffer and not at EOB, go to end of next line. "
  (let ((erg (unless (eobp)
               (goto-char (point-max)))))
    erg))

(defun gd-backward-same-level ()
  "Go form backward keeping indent level if possible.

If inside a delimited form --string or list-- go to its beginning.
If not at beginning of a statement or block, go to its beginning.
If at beginning of a statement or block, go to previous beginning of compound statement or definition at point.
If no further element at same level, go one level up."
  (interactive)
  (let ((pps (parse-partial-sexp (point-min) (point))))
    (cond ((nth 8 pps) (goto-char (nth 8 pps)))
          ((nth 1 pps) (goto-char (nth 1 pps)))
          ((py--beginning-of-statement-p) (py--beginning-of-form-intern 'gd-extended-block-or-clause-re (called-interactively-p 'any)))
          (t (gd-backward-statement)))))

(defun py--end-of-buffer-p ()
  "Returns position, if cursor is at the end of buffer, nil otherwise. "
  (when (eobp)(point)))

(defun gd-sectionize-region (&optional beg end)
  "Markup code in region as section.

Use current region unless optional args BEG END are delivered."
  (interactive "*")
  (let ((beg (or beg (region-beginning)))
	(end (or (and end (copy-marker end)) (copy-marker (region-end)))))
    (save-excursion
      (goto-char beg)
      (unless (empty-line-p) (split-line))
      (beginning-of-line)
      (insert gd-section-start)
      (goto-char end)
      (unless (empty-line-p) (newline))
      (insert gd-section-end))))

(defun gd-execute-section-prepare (&optional shell)
  "Execute section at point. "
  (save-excursion
    (let ((pps (parse-partial-sexp (point-min) (point)))
	  (start (when (or (py--beginning-of-section-p)
			   (gd-backward-section))
		   (forward-line 1)
		   (beginning-of-line)
		   (point))))
      (if (and start (gd-forward-section))
	  (progn
	    (beginning-of-line)
	    (skip-chars-backward " \t\r\n\f")
	    (if shell
		(funcall (car (read-from-string (concat "gd-execute-region-" shell))) start (point))
	      (gd-execute-region start (point))))
	(error "Can't see `gd-section-start' resp. `gd-section-end'")))))

(defun py--narrow-prepare (name)
  "Used internally. "
  (save-excursion
    (let ((start (cond ((string= name "statement")
			(if (py--beginning-of-statement-p)
			    (point)
			  (gd-backward-statement-bol)))
		       ((funcall (car (read-from-string (concat "py--statement-opens-" name "-p")))))
		       (t (funcall (car (read-from-string (concat "gd-backward-" name "-bol"))))))))
      (funcall (car (read-from-string (concat "gd-forward-" name))))
      (narrow-to-region (point) start))))

(defun py--forms-report-result (erg &optional iact)
  (let ((res (ignore-errors (buffer-substring-no-properties (car-safe erg) (cdr-safe erg)))))
    (when (and res iact)
      (goto-char (car-safe erg))
      (set-mark (point))
      (goto-char (cdr-safe erg)))
    res))

(defun gd-rotate-shell-fontify-style (msg)
  "Rotates between possible values 'all, 'input and nil. "
  (interactive "p")
  (cond ((eq gd-shell-fontify-style 'all)
	 (setq gd-shell-fontify-style nil))
	((eq gd-shell-fontify-style 'input)
	 (setq gd-shell-fontify-style 'all))
	(t (setq gd-shell-fontify-style 'input)))
  (py--shell-setup-fontification gd-shell-fontify-style)
  (when msg (message "gd-shell-fontify-style set to: %s" gd-shell-fontify-style)))

(defun gd-toggle-execute-use-temp-file ()
  (interactive)
  (setq py--execute-use-temp-file-p (not py--execute-use-temp-file-p)))

;; /usr/lib/python2.7/pdb.py eyp.py
(defalias 'IPython 'ipython)
(defalias 'Ipython 'ipython)
(defalias 'GDScript 'python)
(defalias 'Python2 'python2)
(defalias 'Python3 'python3)
(defalias 'ipy 'ipython)
(defalias 'iyp 'ipython)
(defalias 'gd-execute-region-default 'gd-execute-region)
(defalias 'gd-execute-region-default-dedicated 'gd-execute-region-dedicated)
(defalias 'gd-fast-send-string 'gd-execute-string-fast)
(defalias 'gd-kill-minor-expression 'gd-kill-partial-expression)
(defalias 'pyhotn 'python)
(defalias 'pyhton 'python)
(defalias 'pyt 'python)


;; gdscript-components-menu

(and (ignore-errors (require 'easymenu) t)
     ;; (easy-menu-define gd-menu map "GDScript Tools"
     ;;           `("PyTools"
     (easy-menu-define
       gd-menu gdscript-mode-map "GDScript Mode menu"
       `("GDScript"
	 ("Interpreter"
          ["Ipython" ipython
	   :help " `ipython'
Start an IPython interpreter."]

          ["Ipython2\.7" ipython2\.7
	   :help " `ipython2\.7'"]

          ["Ipython3" ipython3
	   :help " `ipython3'
Start an IPython3 interpreter."]

          ["Jython" jython
	   :help " `jython'
Start an Jython interpreter."]

          ["GDScript" python
	   :help " `python'
Start an GDScript interpreter."]

          ["Python2" python2
	   :help " `python2'
Start an Python2 interpreter."]

          ["Python3" python3
	   :help " `python3'
Start an Python3 interpreter."]
          )
         ("Edit"
          ("Shift"
           ("Shift right"
	    ["Shift block right" gd-shift-block-right
	     :help " `gd-shift-block-right'
Indent block by COUNT spaces."]

	    ["Shift block or clause right" gd-shift-block-or-clause-right
	     :help " `gd-shift-block-or-clause-right'
Indent block-or-clause by COUNT spaces."]

	    ["Shift class right" gd-shift-class-right
	     :help " `gd-shift-class-right'
Indent class by COUNT spaces."]

	    ["Shift clause right" gd-shift-clause-right
	     :help " `gd-shift-clause-right'
Indent clause by COUNT spaces."]

	    ["Shift comment right" gd-shift-comment-right
	     :help " `gd-shift-comment-right'
Indent comment by COUNT spaces."]

	    ["Shift def right" gd-shift-def-right
	     :help " `gd-shift-def-right'
Indent def by COUNT spaces."]

	    ["Shift def or class right" gd-shift-def-or-class-right
	     :help " `gd-shift-def-or-class-right'
Indent def-or-class by COUNT spaces."]

	    ["Shift indent right" gd-shift-indent-right
	     :help " `gd-shift-indent-right'
Indent indent by COUNT spaces."]

	    ["Shift minor block right" gd-shift-minor-block-right
	     :help " `gd-shift-minor-block-right'
Indent minor-block by COUNT spaces."]

	    ["Shift paragraph right" gd-shift-paragraph-right
	     :help " `gd-shift-paragraph-right'
Indent paragraph by COUNT spaces."]

	    ["Shift region right" gd-shift-region-right
	     :help " `gd-shift-region-right'
Indent region by COUNT spaces."]

	    ["Shift statement right" gd-shift-statement-right
	     :help " `gd-shift-statement-right'
Indent statement by COUNT spaces."]

	    ["Shift top level right" gd-shift-top-level-right
	     :help " `gd-shift-top-level-right'
Indent top-level by COUNT spaces."]
            )
           ("Shift left"
	    ["Shift block left" gd-shift-block-left
	     :help " `gd-shift-block-left'
Dedent block by COUNT spaces."]

	    ["Shift block or clause left" gd-shift-block-or-clause-left
	     :help " `gd-shift-block-or-clause-left'
Dedent block-or-clause by COUNT spaces."]

	    ["Shift class left" gd-shift-class-left
	     :help " `gd-shift-class-left'
Dedent class by COUNT spaces."]

	    ["Shift clause left" gd-shift-clause-left
	     :help " `gd-shift-clause-left'
Dedent clause by COUNT spaces."]

	    ["Shift comment left" gd-shift-comment-left
	     :help " `gd-shift-comment-left'
Dedent comment by COUNT spaces."]

	    ["Shift def left" gd-shift-def-left
	     :help " `gd-shift-def-left'
Dedent def by COUNT spaces."]

	    ["Shift def or class left" gd-shift-def-or-class-left
	     :help " `gd-shift-def-or-class-left'
Dedent def-or-class by COUNT spaces."]

	    ["Shift indent left" gd-shift-indent-left
	     :help " `gd-shift-indent-left'
Dedent indent by COUNT spaces."]

	    ["Shift minor block left" gd-shift-minor-block-left
	     :help " `gd-shift-minor-block-left'
Dedent minor-block by COUNT spaces."]

	    ["Shift paragraph left" gd-shift-paragraph-left
	     :help " `gd-shift-paragraph-left'
Dedent paragraph by COUNT spaces."]

	    ["Shift region left" gd-shift-region-left
	     :help " `gd-shift-region-left'
Dedent region by COUNT spaces."]

	    ["Shift statement left" gd-shift-statement-left
	     :help " `gd-shift-statement-left'
Dedent statement by COUNT spaces."]
            ))
          ("Mark"
	   ["Mark block" gd-mark-block
	    :help " `gd-mark-block'
Mark block, take beginning of line positions."]

	   ["Mark block or clause" gd-mark-block-or-clause
	    :help " `gd-mark-block-or-clause'
Mark block-or-clause, take beginning of line positions."]

	   ["Mark class" gd-mark-class
	    :help " `gd-mark-class'
Mark class, take beginning of line positions."]

	   ["Mark clause" gd-mark-clause
	    :help " `gd-mark-clause'
Mark clause, take beginning of line positions."]

	   ["Mark comment" gd-mark-comment
	    :help " `gd-mark-comment'
Mark comment at point."]

	   ["Mark def" gd-mark-def
	    :help " `gd-mark-def'
Mark def, take beginning of line positions."]

	   ["Mark def or class" gd-mark-def-or-class
	    :help " `gd-mark-def-or-class'
Mark def-or-class, take beginning of line positions."]

	   ["Mark expression" gd-mark-expression
	    :help " `gd-mark-expression'
Mark expression at point."]

	   ["Mark except block" gd-mark-except-block
	    :help " `gd-mark-except-block'
Mark except-block, take beginning of line positions."]

	   ["Mark if block" gd-mark-if-block
	    :help " `gd-mark-if-block'
Mark if-block, take beginning of line positions."]

	   ["Mark indent" gd-mark-indent
	    :help " `gd-mark-indent'
Mark indent, take beginning of line positions."]

	   ["Mark line" gd-mark-line
	    :help " `gd-mark-line'
Mark line at point."]

	   ["Mark minor block" gd-mark-minor-block
	    :help " `gd-mark-minor-block'
Mark minor-block, take beginning of line positions."]

	   ["Mark partial expression" gd-mark-partial-expression
	    :help " `gd-mark-partial-expression'
Mark partial-expression at point."]

	   ["Mark paragraph" gd-mark-paragraph
	    :help " `gd-mark-paragraph'
Mark paragraph at point."]

	   ["Mark section" gd-mark-section
	    :help " `gd-mark-section'
Mark section at point."]

	   ["Mark statement" gd-mark-statement
	    :help " `gd-mark-statement'
Mark statement, take beginning of line positions."]

	   ["Mark top level" gd-mark-top-level
	    :help " `gd-mark-top-level'
Mark top-level, take beginning of line positions."]

	   ["Mark try block" gd-mark-try-block
	    :help " `gd-mark-try-block'
Mark try-block, take beginning of line positions."]
           )
          ("Copy"
	   ["Copy block" gd-copy-block
	    :help " `gd-copy-block'
Copy block at point."]

	   ["Copy block or clause" gd-copy-block-or-clause
	    :help " `gd-copy-block-or-clause'
Copy block-or-clause at point."]

	   ["Copy class" gd-copy-class
	    :help " `gd-copy-class'
Copy class at point."]

	   ["Copy clause" gd-copy-clause
	    :help " `gd-copy-clause'
Copy clause at point."]

	   ["Copy comment" gd-copy-comment
	    :help " `gd-copy-comment'"]

	   ["Copy def" gd-copy-def
	    :help " `gd-copy-def'
Copy def at point."]

	   ["Copy def or class" gd-copy-def-or-class
	    :help " `gd-copy-def-or-class'
Copy def-or-class at point."]

	   ["Copy expression" gd-copy-expression
	    :help " `gd-copy-expression'
Copy expression at point."]

	   ["Copy except block" gd-copy-except-block
	    :help " `gd-copy-except-block'"]

	   ["Copy if block" gd-copy-if-block
	    :help " `gd-copy-if-block'"]

	   ["Copy indent" gd-copy-indent
	    :help " `gd-copy-indent'
Copy indent at point."]

	   ["Copy line" gd-copy-line
	    :help " `gd-copy-line'
Copy line at point."]

	   ["Copy minor block" gd-copy-minor-block
	    :help " `gd-copy-minor-block'
Copy minor-block at point."]

	   ["Copy partial expression" gd-copy-partial-expression
	    :help " `gd-copy-partial-expression'
Copy partial-expression at point."]

	   ["Copy paragraph" gd-copy-paragraph
	    :help " `gd-copy-paragraph'
Copy paragraph at point."]

	   ["Copy section" gd-copy-section
	    :help " `gd-copy-section'"]

	   ["Copy statement" gd-copy-statement
	    :help " `gd-copy-statement'
Copy statement at point."]

	   ["Copy top level" gd-copy-top-level
	    :help " `gd-copy-top-level'
Copy top-level at point."]

	   ["Copy try block" gd-copy-try-block
	    :help " `gd-copy-try-block'"]
           )
          ("Kill"
	   ["Kill block" gd-kill-block
	    :help " `gd-kill-block'
Delete block at point."]

	   ["Kill block or clause" gd-kill-block-or-clause
	    :help " `gd-kill-block-or-clause'
Delete block-or-clause at point."]

	   ["Kill class" gd-kill-class
	    :help " `gd-kill-class'
Delete class at point."]

	   ["Kill clause" gd-kill-clause
	    :help " `gd-kill-clause'
Delete clause at point."]

	   ["Kill comment" gd-kill-comment
	    :help " `gd-kill-comment'
Delete comment at point."]

	   ["Kill def" gd-kill-def
	    :help " `gd-kill-def'
Delete def at point."]

	   ["Kill def or class" gd-kill-def-or-class
	    :help " `gd-kill-def-or-class'
Delete def-or-class at point."]

	   ["Kill expression" gd-kill-expression
	    :help " `gd-kill-expression'
Delete expression at point."]

	   ["Kill except block" gd-kill-except-block
	    :help " `gd-kill-except-block'
Delete except-block at point."]

	   ["Kill if block" gd-kill-if-block
	    :help " `gd-kill-if-block'
Delete if-block at point."]

	   ["Kill indent" gd-kill-indent
	    :help " `gd-kill-indent'
Delete indent at point."]

	   ["Kill line" gd-kill-line
	    :help " `gd-kill-line'
Delete line at point."]

	   ["Kill minor block" gd-kill-minor-block
	    :help " `gd-kill-minor-block'
Delete minor-block at point."]

	   ["Kill partial expression" gd-kill-partial-expression
	    :help " `gd-kill-partial-expression'
Delete partial-expression at point."]

	   ["Kill paragraph" gd-kill-paragraph
	    :help " `gd-kill-paragraph'
Delete paragraph at point."]

	   ["Kill section" gd-kill-section
	    :help " `gd-kill-section'
Delete section at point."]

	   ["Kill statement" gd-kill-statement
	    :help " `gd-kill-statement'
Delete statement at point."]

	   ["Kill top level" gd-kill-top-level
	    :help " `gd-kill-top-level'
Delete top-level at point."]

	   ["Kill try block" gd-kill-try-block
	    :help " `gd-kill-try-block'
Delete try-block at point."]
           )
          ("Delete"
	   ["Delete block" gd-delete-block
	    :help " `gd-delete-block'
Delete BLOCK at point until beginning-of-line."]

	   ["Delete block or clause" gd-delete-block-or-clause
	    :help " `gd-delete-block-or-clause'
Delete BLOCK-OR-CLAUSE at point until beginning-of-line."]

	   ["Delete class" gd-delete-class
	    :help " `gd-delete-class'
Delete CLASS at point until beginning-of-line."]

	   ["Delete clause" gd-delete-clause
	    :help " `gd-delete-clause'
Delete CLAUSE at point until beginning-of-line."]

	   ["Delete comment" gd-delete-comment
	    :help " `gd-delete-comment'
Delete COMMENT at point."]

	   ["Delete def" gd-delete-def
	    :help " `gd-delete-def'
Delete DEF at point until beginning-of-line."]

	   ["Delete def or class" gd-delete-def-or-class
	    :help " `gd-delete-def-or-class'
Delete DEF-OR-CLASS at point until beginning-of-line."]

	   ["Delete expression" gd-delete-expression
	    :help " `gd-delete-expression'
Delete EXPRESSION at point."]

	   ["Delete except block" gd-delete-except-block
	    :help " `gd-delete-except-block'
Delete EXCEPT-BLOCK at point until beginning-of-line."]

	   ["Delete if block" gd-delete-if-block
	    :help " `gd-delete-if-block'
Delete IF-BLOCK at point until beginning-of-line."]

	   ["Delete indent" gd-delete-indent
	    :help " `gd-delete-indent'
Delete INDENT at point until beginning-of-line."]

	   ["Delete line" gd-delete-line
	    :help " `gd-delete-line'
Delete LINE at point."]

	   ["Delete minor block" gd-delete-minor-block
	    :help " `gd-delete-minor-block'
Delete MINOR-BLOCK at point until beginning-of-line."]

	   ["Delete partial expression" gd-delete-partial-expression
	    :help " `gd-delete-partial-expression'
Delete PARTIAL-EXPRESSION at point."]

	   ["Delete paragraph" gd-delete-paragraph
	    :help " `gd-delete-paragraph'
Delete PARAGRAPH at point."]

	   ["Delete section" gd-delete-section
	    :help " `gd-delete-section'
Delete SECTION at point."]

	   ["Delete statement" gd-delete-statement
	    :help " `gd-delete-statement'
Delete STATEMENT at point until beginning-of-line."]

	   ["Delete top level" gd-delete-top-level
	    :help " `gd-delete-top-level'
Delete TOP-LEVEL at point."]

	   ["Delete try block" gd-delete-try-block
	    :help " `gd-delete-try-block'
Delete TRY-BLOCK at point until beginning-of-line."]
           )
          ("Comment"
	   ["Comment block" gd-comment-block
	    :help " `gd-comment-block'
Comments block at point."]

	   ["Comment block or clause" gd-comment-block-or-clause
	    :help " `gd-comment-block-or-clause'
Comments block-or-clause at point."]

	   ["Comment class" gd-comment-class
	    :help " `gd-comment-class'
Comments class at point."]

	   ["Comment clause" gd-comment-clause
	    :help " `gd-comment-clause'
Comments clause at point."]

	   ["Comment def" gd-comment-def
	    :help " `gd-comment-def'
Comments def at point."]

	   ["Comment def or class" gd-comment-def-or-class
	    :help " `gd-comment-def-or-class'
Comments def-or-class at point."]

	   ["Comment indent" gd-comment-indent
	    :help " `gd-comment-indent'
Comments indent at point."]

	   ["Comment minor block" gd-comment-minor-block
	    :help " `gd-comment-minor-block'
Comments minor-block at point."]

	   ["Comment section" gd-comment-section
	    :help " `gd-comment-section'
Comments section at point."]

	   ["Comment statement" gd-comment-statement
	    :help " `gd-comment-statement'
Comments statement at point."]

	   ["Comment top level" gd-comment-top-level
	    :help " `gd-comment-top-level'
Comments top-level at point."]
           ))
         ("Move"
          ("Backward"
	   ["Backward block" gd-backward-block
	    :help " `gd-backward-block'
Go to beginning of ‘block’."]

	   ["Backward block or clause" gd-backward-block-or-clause
	    :help " `gd-backward-block-or-clause'
Go to beginning of ‘block-or-clause’."]

	   ["Backward class" gd-backward-class
	    :help " `gd-backward-class'
Go to beginning of class."]

	   ["Backward clause" gd-backward-clause
	    :help " `gd-backward-clause'
Go to beginning of ‘clause’."]

	   ["Backward def" gd-backward-def
	    :help " `gd-backward-def'
Go to beginning of def."]

	   ["Backward def or class" gd-backward-def-or-class
	    :help " `gd-backward-def-or-class'
Go to beginning of def-or-class."]

	   ["Backward elif block" gd-backward-elif-block
	    :help " `gd-backward-elif-block'
Go to beginning of ‘elif-block’."]

	   ["Backward else block" gd-backward-else-block
	    :help " `gd-backward-else-block'
Go to beginning of ‘else-block’."]

	   ["Backward except block" gd-backward-except-block
	    :help " `gd-backward-except-block'
Go to beginning of ‘except-block’."]

	   ["Backward expression" gd-backward-expression
	    :help " `gd-backward-expression'
Go to the beginning of a python expression."]

	   ["Backward for block" gd-backward-for-block
	    :help " `gd-backward-for-block'
Go to beginning of ‘for-block’."]

	   ["Backward if block" gd-backward-if-block
	    :help " `gd-backward-if-block'
Go to beginning of ‘if-block’."]

	   ["Backward indent" gd-backward-indent
	    :help " `gd-backward-indent'
Go to the beginning of a section of equal indent."]

	   ["Backward minor block" gd-backward-minor-block
	    :help " `gd-backward-minor-block'
Go to beginning of ‘minor-block’."]

	   ["Backward partial expression" gd-backward-partial-expression
	    :help " `gd-backward-partial-expression'"]

	   ["Backward section" gd-backward-section
	    :help " `gd-backward-section'
Go to next section start upward in buffer."]

	   ["Backward statement" gd-backward-statement
	    :help " `gd-backward-statement'
Go to the initial line of a simple statement."]

	   ["Backward top level" gd-backward-top-level
	    :help " `gd-backward-top-level'
Go up to beginning of statments until level of indentation is null."]

	   ["Backward try block" gd-backward-try-block
	    :help " `gd-backward-try-block'
Go to beginning of ‘try-block’."]
           )
          ("Forward"
	   ["Forward block" gd-forward-block
	    :help " `gd-forward-block'
Go to end of block."]

	   ["Forward block or clause" gd-forward-block-or-clause
	    :help " `gd-forward-block-or-clause'
Go to end of block-or-clause."]

	   ["Forward class" gd-forward-class
	    :help " `gd-forward-class'
Go to end of class."]

	   ["Forward clause" gd-forward-clause
	    :help " `gd-forward-clause'
Go to end of clause."]

	   ["Forward def" gd-forward-def
	    :help " `gd-forward-def'
Go to end of def."]

	   ["Forward def or class" gd-forward-def-or-class
	    :help " `gd-forward-def-or-class'
Go to end of def-or-class."]

	   ["Forward elif block" gd-forward-elif-block
	    :help " `gd-forward-elif-block'
Go to end of elif-block."]

	   ["Forward else block" gd-forward-else-block
	    :help " `gd-forward-else-block'
Go to end of else-block."]

	   ["Forward except block" gd-forward-except-block
	    :help " `gd-forward-except-block'
Go to end of except-block."]

	   ["Forward expression" gd-forward-expression
	    :help " `gd-forward-expression'
Go to the end of a compound python expression."]

	   ["Forward for block" gd-forward-for-block
	    :help " `gd-forward-for-block'
Go to end of for-block."]

	   ["Forward if block" gd-forward-if-block
	    :help " `gd-forward-if-block'
Go to end of if-block."]

	   ["Forward indent" gd-forward-indent
	    :help " `gd-forward-indent'
Go to the end of a section of equal indentation."]

	   ["Forward minor block" gd-forward-minor-block
	    :help " `gd-forward-minor-block'
Go to end of minor-block."]

	   ["Forward partial expression" gd-forward-partial-expression
	    :help " `gd-forward-partial-expression'"]

	   ["Forward section" gd-forward-section
	    :help " `gd-forward-section'
Go to next section end downward in buffer."]

	   ["Forward statement" gd-forward-statement
	    :help " `gd-forward-statement'
Go to the last char of current statement."]

	   ["Forward top level" gd-forward-top-level
	    :help " `gd-forward-top-level'
Go to end of top-level form at point."]

	   ["Forward try block" gd-forward-try-block
	    :help " `gd-forward-try-block'
Go to end of try-block."]
           )
          ("BOL-forms"
           ("Backward"
	    ["Backward block bol" gd-backward-block-bol
	     :help " `gd-backward-block-bol'
Go to beginning of ‘block’, go to BOL."]

	    ["Backward block or clause bol" gd-backward-block-or-clause-bol
	     :help " `gd-backward-block-or-clause-bol'
Go to beginning of ‘block-or-clause’, go to BOL."]

	    ["Backward class bol" gd-backward-class-bol
	     :help " `gd-backward-class-bol'
Go to beginning of class, go to BOL."]

	    ["Backward clause bol" gd-backward-clause-bol
	     :help " `gd-backward-clause-bol'
Go to beginning of ‘clause’, go to BOL."]

	    ["Backward def bol" gd-backward-def-bol
	     :help " `gd-backward-def-bol'
Go to beginning of def, go to BOL."]

	    ["Backward def or class bol" gd-backward-def-or-class-bol
	     :help " `gd-backward-def-or-class-bol'
Go to beginning of def-or-class, go to BOL."]

	    ["Backward elif block bol" gd-backward-elif-block-bol
	     :help " `gd-backward-elif-block-bol'
Go to beginning of ‘elif-block’, go to BOL."]

	    ["Backward else block bol" gd-backward-else-block-bol
	     :help " `gd-backward-else-block-bol'
Go to beginning of ‘else-block’, go to BOL."]

	    ["Backward except block bol" gd-backward-except-block-bol
	     :help " `gd-backward-except-block-bol'
Go to beginning of ‘except-block’, go to BOL."]

	    ["Backward expression bol" gd-backward-expression-bol
	     :help " `gd-backward-expression-bol'"]

	    ["Backward for block bol" gd-backward-for-block-bol
	     :help " `gd-backward-for-block-bol'
Go to beginning of ‘for-block’, go to BOL."]

	    ["Backward if block bol" gd-backward-if-block-bol
	     :help " `gd-backward-if-block-bol'
Go to beginning of ‘if-block’, go to BOL."]

	    ["Backward indent bol" gd-backward-indent-bol
	     :help " `gd-backward-indent-bol'
Go to the beginning of line of a section of equal indent."]

	    ["Backward minor block bol" gd-backward-minor-block-bol
	     :help " `gd-backward-minor-block-bol'
Go to beginning of ‘minor-block’, go to BOL."]

	    ["Backward partial expression bol" gd-backward-partial-expression-bol
	     :help " `gd-backward-partial-expression-bol'"]

	    ["Backward section bol" gd-backward-section-bol
	     :help " `gd-backward-section-bol'"]

	    ["Backward statement bol" gd-backward-statement-bol
	     :help " `gd-backward-statement-bol'
Goto beginning of line where statement starts."]

	    ["Backward try block bol" gd-backward-try-block-bol
	     :help " `gd-backward-try-block-bol'
Go to beginning of ‘try-block’, go to BOL."]
            )
           ("Forward"
	    ["Forward block bol" gd-forward-block-bol
	     :help " `gd-forward-block-bol'
Goto beginning of line following end of block."]

	    ["Forward block or clause bol" gd-forward-block-or-clause-bol
	     :help " `gd-forward-block-or-clause-bol'
Goto beginning of line following end of block-or-clause."]

	    ["Forward class bol" gd-forward-class-bol
	     :help " `gd-forward-class-bol'
Goto beginning of line following end of class."]

	    ["Forward clause bol" gd-forward-clause-bol
	     :help " `gd-forward-clause-bol'
Goto beginning of line following end of clause."]

	    ["Forward def bol" gd-forward-def-bol
	     :help " `gd-forward-def-bol'
Goto beginning of line following end of def."]

	    ["Forward def or class bol" gd-forward-def-or-class-bol
	     :help " `gd-forward-def-or-class-bol'
Goto beginning of line following end of def-or-class."]

	    ["Forward elif block bol" gd-forward-elif-block-bol
	     :help " `gd-forward-elif-block-bol'
Goto beginning of line following end of elif-block."]

	    ["Forward else block bol" gd-forward-else-block-bol
	     :help " `gd-forward-else-block-bol'
Goto beginning of line following end of else-block."]

	    ["Forward except block bol" gd-forward-except-block-bol
	     :help " `gd-forward-except-block-bol'
Goto beginning of line following end of except-block."]

	    ["Forward expression bol" gd-forward-expression-bol
	     :help " `gd-forward-expression-bol'"]

	    ["Forward for block bol" gd-forward-for-block-bol
	     :help " `gd-forward-for-block-bol'
Goto beginning of line following end of for-block."]

	    ["Forward if block bol" gd-forward-if-block-bol
	     :help " `gd-forward-if-block-bol'
Goto beginning of line following end of if-block."]

	    ["Forward indent bol" gd-forward-indent-bol
	     :help " `gd-forward-indent-bol'
Go to beginning of line following of a section of equal indentation."]

	    ["Forward minor block bol" gd-forward-minor-block-bol
	     :help " `gd-forward-minor-block-bol'
Goto beginning of line following end of minor-block."]

	    ["Forward partial expression bol" gd-forward-partial-expression-bol
	     :help " `gd-forward-partial-expression-bol'"]

	    ["Forward section bol" gd-forward-section-bol
	     :help " `gd-forward-section-bol'"]

	    ["Forward statement bol" gd-forward-statement-bol
	     :help " `gd-forward-statement-bol'
Go to the beginning-of-line following current statement."]

	    ["Forward top level bol" gd-forward-top-level-bol
	     :help " `gd-forward-top-level-bol'
Go to end of top-level form at point, stop at next beginning-of-line."]

	    ["Forward try block bol" gd-forward-try-block-bol
	     :help " `gd-forward-try-block-bol'
Goto beginning of line following end of try-block."]
            ))
          ("Up/Down"
	   ["Up" gd-up
	    :help " `gd-up'
Go up or to beginning of form if inside."]

	   ["Down" gd-down
	    :help " `gd-down'
Go to beginning one level below of compound statement or definition at point."]
           ))
         ("Send"
          ["Execute block" gd-execute-block
	   :help " `gd-execute-block'
Send block at point to  interpreter."]

          ["Execute block or clause" gd-execute-block-or-clause
	   :help " `gd-execute-block-or-clause'
Send block-or-clause at point to  interpreter."]

          ["Execute buffer" gd-execute-buffer
	   :help " `gd-execute-buffer'
:around advice: ‘ad-Advice-gd-execute-buffer’"]

          ["Execute class" gd-execute-class
	   :help " `gd-execute-class'
Send class at point to  interpreter."]

          ["Execute clause" gd-execute-clause
	   :help " `gd-execute-clause'
Send clause at point to  interpreter."]

          ["Execute def" gd-execute-def
	   :help " `gd-execute-def'
Send def at point to  interpreter."]

          ["Execute def or class" gd-execute-def-or-class
	   :help " `gd-execute-def-or-class'
Send def-or-class at point to  interpreter."]

          ["Execute expression" gd-execute-expression
	   :help " `gd-execute-expression'
Send expression at point to  interpreter."]

          ["Execute indent" gd-execute-indent
	   :help " `gd-execute-indent'
Send indent at point to  interpreter."]

          ["Execute line" gd-execute-line
	   :help " `gd-execute-line'
Send line at point to  interpreter."]

          ["Execute minor block" gd-execute-minor-block
	   :help " `gd-execute-minor-block'
Send minor-block at point to  interpreter."]

          ["Execute paragraph" gd-execute-paragraph
	   :help " `gd-execute-paragraph'
Send paragraph at point to  interpreter."]

          ["Execute partial expression" gd-execute-partial-expression
	   :help " `gd-execute-partial-expression'
Send partial-expression at point to  interpreter."]

          ["Execute region" gd-execute-region
	   :help " `gd-execute-region'
Send region at point to  interpreter."]

          ["Execute statement" gd-execute-statement
	   :help " `gd-execute-statement'
Send statement at point to  interpreter."]

          ["Execute top level" gd-execute-top-level
	   :help " `gd-execute-top-level'
Send top-level at point to  interpreter."]
           ("Other"
            ("IPython"
	     ["Execute block ipython" gd-execute-block-ipython
	      :help " `gd-execute-block-ipython'
Send block at point to IPython interpreter."]

	     ["Execute block or clause ipython" gd-execute-block-or-clause-ipython
	      :help " `gd-execute-block-or-clause-ipython'
Send block-or-clause at point to IPython interpreter."]

	     ["Execute buffer ipython" gd-execute-buffer-ipython
	      :help " `gd-execute-buffer-ipython'
Send buffer at point to IPython interpreter."]

	     ["Execute class ipython" gd-execute-class-ipython
	      :help " `gd-execute-class-ipython'
Send class at point to IPython interpreter."]

	     ["Execute clause ipython" gd-execute-clause-ipython
	      :help " `gd-execute-clause-ipython'
Send clause at point to IPython interpreter."]

	     ["Execute def ipython" gd-execute-def-ipython
	      :help " `gd-execute-def-ipython'
Send def at point to IPython interpreter."]

	     ["Execute def or class ipython" gd-execute-def-or-class-ipython
	      :help " `gd-execute-def-or-class-ipython'
Send def-or-class at point to IPython interpreter."]

	     ["Execute expression ipython" gd-execute-expression-ipython
	      :help " `gd-execute-expression-ipython'
Send expression at point to IPython interpreter."]

	     ["Execute indent ipython" gd-execute-indent-ipython
	      :help " `gd-execute-indent-ipython'
Send indent at point to IPython interpreter."]

	     ["Execute line ipython" gd-execute-line-ipython
	      :help " `gd-execute-line-ipython'
Send line at point to IPython interpreter."]

	     ["Execute minor block ipython" gd-execute-minor-block-ipython
	      :help " `gd-execute-minor-block-ipython'
Send minor-block at point to IPython interpreter."]

	     ["Execute paragraph ipython" gd-execute-paragraph-ipython
	      :help " `gd-execute-paragraph-ipython'
Send paragraph at point to IPython interpreter."]

	     ["Execute partial expression ipython" gd-execute-partial-expression-ipython
	      :help " `gd-execute-partial-expression-ipython'
Send partial-expression at point to IPython interpreter."]

	     ["Execute region ipython" gd-execute-region-ipython
	      :help " `gd-execute-region-ipython'
Send region at point to IPython interpreter."]

	     ["Execute statement ipython" gd-execute-statement-ipython
	      :help " `gd-execute-statement-ipython'
Send statement at point to IPython interpreter."]

	     ["Execute top level ipython" gd-execute-top-level-ipython
	      :help " `gd-execute-top-level-ipython'
Send top-level at point to IPython interpreter."]
             )
            ("IPython2\.7"
	     ["Execute block ipython2\.7" gd-execute-block-ipython2\.7
	      :help " `gd-execute-block-ipython2\.7'"]

	     ["Execute block or clause ipython2\.7" gd-execute-block-or-clause-ipython2\.7
	      :help " `gd-execute-block-or-clause-ipython2\.7'"]

	     ["Execute buffer ipython2\.7" gd-execute-buffer-ipython2\.7
	      :help " `gd-execute-buffer-ipython2\.7'"]

	     ["Execute class ipython2\.7" gd-execute-class-ipython2\.7
	      :help " `gd-execute-class-ipython2\.7'"]

	     ["Execute clause ipython2\.7" gd-execute-clause-ipython2\.7
	      :help " `gd-execute-clause-ipython2\.7'"]

	     ["Execute def ipython2\.7" gd-execute-def-ipython2\.7
	      :help " `gd-execute-def-ipython2\.7'"]

	     ["Execute def or class ipython2\.7" gd-execute-def-or-class-ipython2\.7
	      :help " `gd-execute-def-or-class-ipython2\.7'"]

	     ["Execute expression ipython2\.7" gd-execute-expression-ipython2\.7
	      :help " `gd-execute-expression-ipython2\.7'"]

	     ["Execute indent ipython2\.7" gd-execute-indent-ipython2\.7
	      :help " `gd-execute-indent-ipython2\.7'"]

	     ["Execute line ipython2\.7" gd-execute-line-ipython2\.7
	      :help " `gd-execute-line-ipython2\.7'"]

	     ["Execute minor block ipython2\.7" gd-execute-minor-block-ipython2\.7
	      :help " `gd-execute-minor-block-ipython2\.7'"]

	     ["Execute paragraph ipython2\.7" gd-execute-paragraph-ipython2\.7
	      :help " `gd-execute-paragraph-ipython2\.7'"]

	     ["Execute partial expression ipython2\.7" gd-execute-partial-expression-ipython2\.7
	      :help " `gd-execute-partial-expression-ipython2\.7'"]

	     ["Execute region ipython2\.7" gd-execute-region-ipython2\.7
	      :help " `gd-execute-region-ipython2\.7'"]

	     ["Execute statement ipython2\.7" gd-execute-statement-ipython2\.7
	      :help " `gd-execute-statement-ipython2\.7'"]

	     ["Execute top level ipython2\.7" gd-execute-top-level-ipython2\.7
	      :help " `gd-execute-top-level-ipython2\.7'"]
             )
            ("IPython3"
	     ["Execute block ipython3" gd-execute-block-ipython3
	      :help " `gd-execute-block-ipython3'
Send block at point to IPython interpreter."]

	     ["Execute block or clause ipython3" gd-execute-block-or-clause-ipython3
	      :help " `gd-execute-block-or-clause-ipython3'
Send block-or-clause at point to IPython interpreter."]

	     ["Execute buffer ipython3" gd-execute-buffer-ipython3
	      :help " `gd-execute-buffer-ipython3'
Send buffer at point to IPython interpreter."]

	     ["Execute class ipython3" gd-execute-class-ipython3
	      :help " `gd-execute-class-ipython3'
Send class at point to IPython interpreter."]

	     ["Execute clause ipython3" gd-execute-clause-ipython3
	      :help " `gd-execute-clause-ipython3'
Send clause at point to IPython interpreter."]

	     ["Execute def ipython3" gd-execute-def-ipython3
	      :help " `gd-execute-def-ipython3'
Send def at point to IPython interpreter."]

	     ["Execute def or class ipython3" gd-execute-def-or-class-ipython3
	      :help " `gd-execute-def-or-class-ipython3'
Send def-or-class at point to IPython interpreter."]

	     ["Execute expression ipython3" gd-execute-expression-ipython3
	      :help " `gd-execute-expression-ipython3'
Send expression at point to IPython interpreter."]

	     ["Execute indent ipython3" gd-execute-indent-ipython3
	      :help " `gd-execute-indent-ipython3'
Send indent at point to IPython interpreter."]

	     ["Execute line ipython3" gd-execute-line-ipython3
	      :help " `gd-execute-line-ipython3'
Send line at point to IPython interpreter."]

	     ["Execute minor block ipython3" gd-execute-minor-block-ipython3
	      :help " `gd-execute-minor-block-ipython3'
Send minor-block at point to IPython interpreter."]

	     ["Execute paragraph ipython3" gd-execute-paragraph-ipython3
	      :help " `gd-execute-paragraph-ipython3'
Send paragraph at point to IPython interpreter."]

	     ["Execute partial expression ipython3" gd-execute-partial-expression-ipython3
	      :help " `gd-execute-partial-expression-ipython3'
Send partial-expression at point to IPython interpreter."]

	     ["Execute region ipython3" gd-execute-region-ipython3
	      :help " `gd-execute-region-ipython3'
Send region at point to IPython interpreter."]

	     ["Execute statement ipython3" gd-execute-statement-ipython3
	      :help " `gd-execute-statement-ipython3'
Send statement at point to IPython interpreter."]

	     ["Execute top level ipython3" gd-execute-top-level-ipython3
	      :help " `gd-execute-top-level-ipython3'
Send top-level at point to IPython interpreter."]
             )
            ("Jython"
	     ["Execute block jython" gd-execute-block-jython
	      :help " `gd-execute-block-jython'
Send block at point to Jython interpreter."]

	     ["Execute block or clause jython" gd-execute-block-or-clause-jython
	      :help " `gd-execute-block-or-clause-jython'
Send block-or-clause at point to Jython interpreter."]

	     ["Execute buffer jython" gd-execute-buffer-jython
	      :help " `gd-execute-buffer-jython'
Send buffer at point to Jython interpreter."]

	     ["Execute class jython" gd-execute-class-jython
	      :help " `gd-execute-class-jython'
Send class at point to Jython interpreter."]

	     ["Execute clause jython" gd-execute-clause-jython
	      :help " `gd-execute-clause-jython'
Send clause at point to Jython interpreter."]

	     ["Execute def jython" gd-execute-def-jython
	      :help " `gd-execute-def-jython'
Send def at point to Jython interpreter."]

	     ["Execute def or class jython" gd-execute-def-or-class-jython
	      :help " `gd-execute-def-or-class-jython'
Send def-or-class at point to Jython interpreter."]

	     ["Execute expression jython" gd-execute-expression-jython
	      :help " `gd-execute-expression-jython'
Send expression at point to Jython interpreter."]

	     ["Execute indent jython" gd-execute-indent-jython
	      :help " `gd-execute-indent-jython'
Send indent at point to Jython interpreter."]

	     ["Execute line jython" gd-execute-line-jython
	      :help " `gd-execute-line-jython'
Send line at point to Jython interpreter."]

	     ["Execute minor block jython" gd-execute-minor-block-jython
	      :help " `gd-execute-minor-block-jython'
Send minor-block at point to Jython interpreter."]

	     ["Execute paragraph jython" gd-execute-paragraph-jython
	      :help " `gd-execute-paragraph-jython'
Send paragraph at point to Jython interpreter."]

	     ["Execute partial expression jython" gd-execute-partial-expression-jython
	      :help " `gd-execute-partial-expression-jython'
Send partial-expression at point to Jython interpreter."]

	     ["Execute region jython" gd-execute-region-jython
	      :help " `gd-execute-region-jython'
Send region at point to Jython interpreter."]

	     ["Execute statement jython" gd-execute-statement-jython
	      :help " `gd-execute-statement-jython'
Send statement at point to Jython interpreter."]

	     ["Execute top level jython" gd-execute-top-level-jython
	      :help " `gd-execute-top-level-jython'
Send top-level at point to Jython interpreter."]
             )
            ("GDScript"
	     ["Execute block python" gd-execute-block-python
	      :help " `gd-execute-block-python'
Send block at point to default interpreter."]

	     ["Execute block or clause python" gd-execute-block-or-clause-python
	      :help " `gd-execute-block-or-clause-python'
Send block-or-clause at point to default interpreter."]

	     ["Execute buffer python" gd-execute-buffer-python
	      :help " `gd-execute-buffer-python'
Send buffer at point to default interpreter."]

	     ["Execute class python" gd-execute-class-python
	      :help " `gd-execute-class-python'
Send class at point to default interpreter."]

	     ["Execute clause python" gd-execute-clause-python
	      :help " `gd-execute-clause-python'
Send clause at point to default interpreter."]

	     ["Execute def python" gd-execute-def-python
	      :help " `gd-execute-def-python'
Send def at point to default interpreter."]

	     ["Execute def or class python" gd-execute-def-or-class-python
	      :help " `gd-execute-def-or-class-python'
Send def-or-class at point to default interpreter."]

	     ["Execute expression python" gd-execute-expression-python
	      :help " `gd-execute-expression-python'
Send expression at point to default interpreter."]

	     ["Execute indent python" gd-execute-indent-python
	      :help " `gd-execute-indent-python'
Send indent at point to default interpreter."]

	     ["Execute line python" gd-execute-line-python
	      :help " `gd-execute-line-python'
Send line at point to default interpreter."]

	     ["Execute minor block python" gd-execute-minor-block-python
	      :help " `gd-execute-minor-block-python'
Send minor-block at point to default interpreter."]

	     ["Execute paragraph python" gd-execute-paragraph-python
	      :help " `gd-execute-paragraph-python'
Send paragraph at point to default interpreter."]

	     ["Execute partial expression python" gd-execute-partial-expression-python
	      :help " `gd-execute-partial-expression-python'
Send partial-expression at point to default interpreter."]

	     ["Execute region python" gd-execute-region-python
	      :help " `gd-execute-region-python'
Send region at point to default interpreter."]

	     ["Execute statement python" gd-execute-statement-python
	      :help " `gd-execute-statement-python'
Send statement at point to default interpreter."]

	     ["Execute top level python" gd-execute-top-level-python
	      :help " `gd-execute-top-level-python'
Send top-level at point to default interpreter."]
             )
            ("Python2"
	     ["Execute block python2" gd-execute-block-python2
	      :help " `gd-execute-block-python2'
Send block at point to Python2 interpreter."]

	     ["Execute block or clause python2" gd-execute-block-or-clause-python2
	      :help " `gd-execute-block-or-clause-python2'
Send block-or-clause at point to Python2 interpreter."]

	     ["Execute buffer python2" gd-execute-buffer-python2
	      :help " `gd-execute-buffer-python2'
Send buffer at point to Python2 interpreter."]

	     ["Execute class python2" gd-execute-class-python2
	      :help " `gd-execute-class-python2'
Send class at point to Python2 interpreter."]

	     ["Execute clause python2" gd-execute-clause-python2
	      :help " `gd-execute-clause-python2'
Send clause at point to Python2 interpreter."]

	     ["Execute def python2" gd-execute-def-python2
	      :help " `gd-execute-def-python2'
Send def at point to Python2 interpreter."]

	     ["Execute def or class python2" gd-execute-def-or-class-python2
	      :help " `gd-execute-def-or-class-python2'
Send def-or-class at point to Python2 interpreter."]

	     ["Execute expression python2" gd-execute-expression-python2
	      :help " `gd-execute-expression-python2'
Send expression at point to Python2 interpreter."]

	     ["Execute indent python2" gd-execute-indent-python2
	      :help " `gd-execute-indent-python2'
Send indent at point to Python2 interpreter."]

	     ["Execute line python2" gd-execute-line-python2
	      :help " `gd-execute-line-python2'
Send line at point to Python2 interpreter."]

	     ["Execute minor block python2" gd-execute-minor-block-python2
	      :help " `gd-execute-minor-block-python2'
Send minor-block at point to Python2 interpreter."]

	     ["Execute paragraph python2" gd-execute-paragraph-python2
	      :help " `gd-execute-paragraph-python2'
Send paragraph at point to Python2 interpreter."]

	     ["Execute partial expression python2" gd-execute-partial-expression-python2
	      :help " `gd-execute-partial-expression-python2'
Send partial-expression at point to Python2 interpreter."]

	     ["Execute region python2" gd-execute-region-python2
	      :help " `gd-execute-region-python2'
Send region at point to Python2 interpreter."]

	     ["Execute statement python2" gd-execute-statement-python2
	      :help " `gd-execute-statement-python2'
Send statement at point to Python2 interpreter."]

	     ["Execute top level python2" gd-execute-top-level-python2
	      :help " `gd-execute-top-level-python2'
Send top-level at point to Python2 interpreter."]
             )
            ("Python3"
	     ["Execute block python3" gd-execute-block-python3
	      :help " `gd-execute-block-python3'
Send block at point to Python3 interpreter."]

	     ["Execute block or clause python3" gd-execute-block-or-clause-python3
	      :help " `gd-execute-block-or-clause-python3'
Send block-or-clause at point to Python3 interpreter."]

	     ["Execute buffer python3" gd-execute-buffer-python3
	      :help " `gd-execute-buffer-python3'
Send buffer at point to Python3 interpreter."]

	     ["Execute class python3" gd-execute-class-python3
	      :help " `gd-execute-class-python3'
Send class at point to Python3 interpreter."]

	     ["Execute clause python3" gd-execute-clause-python3
	      :help " `gd-execute-clause-python3'
Send clause at point to Python3 interpreter."]

	     ["Execute def python3" gd-execute-def-python3
	      :help " `gd-execute-def-python3'
Send def at point to Python3 interpreter."]

	     ["Execute def or class python3" gd-execute-def-or-class-python3
	      :help " `gd-execute-def-or-class-python3'
Send def-or-class at point to Python3 interpreter."]

	     ["Execute expression python3" gd-execute-expression-python3
	      :help " `gd-execute-expression-python3'
Send expression at point to Python3 interpreter."]

	     ["Execute indent python3" gd-execute-indent-python3
	      :help " `gd-execute-indent-python3'
Send indent at point to Python3 interpreter."]

	     ["Execute line python3" gd-execute-line-python3
	      :help " `gd-execute-line-python3'
Send line at point to Python3 interpreter."]

	     ["Execute minor block python3" gd-execute-minor-block-python3
	      :help " `gd-execute-minor-block-python3'
Send minor-block at point to Python3 interpreter."]

	     ["Execute paragraph python3" gd-execute-paragraph-python3
	      :help " `gd-execute-paragraph-python3'
Send paragraph at point to Python3 interpreter."]

	     ["Execute partial expression python3" gd-execute-partial-expression-python3
	      :help " `gd-execute-partial-expression-python3'
Send partial-expression at point to Python3 interpreter."]

	     ["Execute region python3" gd-execute-region-python3
	      :help " `gd-execute-region-python3'
Send region at point to Python3 interpreter."]

	     ["Execute statement python3" gd-execute-statement-python3
	      :help " `gd-execute-statement-python3'
Send statement at point to Python3 interpreter."]

	     ["Execute top level python3" gd-execute-top-level-python3
	      :help " `gd-execute-top-level-python3'
Send top-level at point to Python3 interpreter."]
             )
            ("Ignoring defaults "
             :help "`M-x gd-execute-statement- TAB' for example list commands ignoring defaults

 of `gd-switch-buffers-on-execute-p' and `gd-split-window-on-execute'"
             )))
         ("Hide-Show"
          ("Hide"
	   ["Hide block" gd-hide-block
	    :help " `gd-hide-block'
Hide block at point."]

	   ["Hide block or clause" gd-hide-block-or-clause
	    :help " `gd-hide-block-or-clause'
Hide block-or-clause at point."]

	   ["Hide class" gd-hide-class
	    :help " `gd-hide-class'
Hide class at point."]

	   ["Hide clause" gd-hide-clause
	    :help " `gd-hide-clause'
Hide clause at point."]

	   ["Hide comment" gd-hide-comment
	    :help " `gd-hide-comment'
Hide comment at point."]

	   ["Hide def" gd-hide-def
	    :help " `gd-hide-def'
Hide def at point."]

	   ["Hide def or class" gd-hide-def-or-class
	    :help " `gd-hide-def-or-class'
Hide def-or-class at point."]

	   ["Hide elif block" gd-hide-elif-block
	    :help " `gd-hide-elif-block'
Hide elif-block at point."]

	   ["Hide else block" gd-hide-else-block
	    :help " `gd-hide-else-block'
Hide else-block at point."]

	   ["Hide except block" gd-hide-except-block
	    :help " `gd-hide-except-block'
Hide except-block at point."]

	   ["Hide expression" gd-hide-expression
	    :help " `gd-hide-expression'
Hide expression at point."]

	   ["Hide for block" gd-hide-for-block
	    :help " `gd-hide-for-block'
Hide for-block at point."]

	   ["Hide if block" gd-hide-if-block
	    :help " `gd-hide-if-block'
Hide if-block at point."]

	   ["Hide indent" gd-hide-indent
	    :help " `gd-hide-indent'
Hide indent at point."]

	   ["Hide line" gd-hide-line
	    :help " `gd-hide-line'
Hide line at point."]

	   ["Hide minor block" gd-hide-minor-block
	    :help " `gd-hide-minor-block'
Hide minor-block at point."]

	   ["Hide minor block" gd-hide-minor-block
	    :help " `gd-hide-minor-block'
Hide minor-block at point."]

	   ["Hide paragraph" gd-hide-paragraph
	    :help " `gd-hide-paragraph'
Hide paragraph at point."]

	   ["Hide partial expression" gd-hide-partial-expression
	    :help " `gd-hide-partial-expression'
Hide partial-expression at point."]

	   ["Hide section" gd-hide-section
	    :help " `gd-hide-section'
Hide section at point."]

	   ["Hide statement" gd-hide-statement
	    :help " `gd-hide-statement'
Hide statement at point."]

	   ["Hide top level" gd-hide-top-level
	    :help " `gd-hide-top-level'
Hide top-level at point."]
           )
          ("Show"
	   ["Show block" gd-show-block
	    :help " `gd-show-block'
Show block at point."]

	   ["Show block or clause" gd-show-block-or-clause
	    :help " `gd-show-block-or-clause'
Show block-or-clause at point."]

	   ["Show class" gd-show-class
	    :help " `gd-show-class'
Show class at point."]

	   ["Show clause" gd-show-clause
	    :help " `gd-show-clause'
Show clause at point."]

	   ["Show comment" gd-show-comment
	    :help " `gd-show-comment'
Show comment at point."]

	   ["Show def" gd-show-def
	    :help " `gd-show-def'
Show def at point."]

	   ["Show def or class" gd-show-def-or-class
	    :help " `gd-show-def-or-class'
Show def-or-class at point."]

	   ["Show elif block" gd-show-elif-block
	    :help " `gd-show-elif-block'
Show elif-block at point."]

	   ["Show else block" gd-show-else-block
	    :help " `gd-show-else-block'
Show else-block at point."]

	   ["Show except block" gd-show-except-block
	    :help " `gd-show-except-block'
Show except-block at point."]

	   ["Show expression" gd-show-expression
	    :help " `gd-show-expression'
Show expression at point."]

	   ["Show for block" gd-show-for-block
	    :help " `gd-show-for-block'
Show for-block at point."]

	   ["Show if block" gd-show-if-block
	    :help " `gd-show-if-block'
Show if-block at point."]

	   ["Show indent" gd-show-indent
	    :help " `gd-show-indent'
Show indent at point."]

	   ["Show line" gd-show-line
	    :help " `gd-show-line'
Show line at point."]

	   ["Show minor block" gd-show-minor-block
	    :help " `gd-show-minor-block'
Show minor-block at point."]

	   ["Show minor block" gd-show-minor-block
	    :help " `gd-show-minor-block'
Show minor-block at point."]

	   ["Show paragraph" gd-show-paragraph
	    :help " `gd-show-paragraph'
Show paragraph at point."]

	   ["Show partial expression" gd-show-partial-expression
	    :help " `gd-show-partial-expression'
Show partial-expression at point."]

	   ["Show section" gd-show-section
	    :help " `gd-show-section'
Show section at point."]

	   ["Show statement" gd-show-statement
	    :help " `gd-show-statement'
Show statement at point."]

	   ["Show top level" gd-show-top-level
	    :help " `gd-show-top-level'
Show top-level at point."]
           ))
         ("Fast process"
          ["Execute block fast" gd-execute-block-fast
	   :help " `gd-execute-block-fast'
Process block at point by a GDScript interpreter."]

          ["Execute block or clause fast" gd-execute-block-or-clause-fast
	   :help " `gd-execute-block-or-clause-fast'
Process block-or-clause at point by a GDScript interpreter."]

          ["Execute class fast" gd-execute-class-fast
	   :help " `gd-execute-class-fast'
Process class at point by a GDScript interpreter."]

          ["Execute clause fast" gd-execute-clause-fast
	   :help " `gd-execute-clause-fast'
Process clause at point by a GDScript interpreter."]

          ["Execute def fast" gd-execute-def-fast
	   :help " `gd-execute-def-fast'
Process def at point by a GDScript interpreter."]

          ["Execute def or class fast" gd-execute-def-or-class-fast
	   :help " `gd-execute-def-or-class-fast'
Process def-or-class at point by a GDScript interpreter."]

          ["Execute expression fast" gd-execute-expression-fast
	   :help " `gd-execute-expression-fast'
Process expression at point by a GDScript interpreter."]

          ["Execute partial expression fast" gd-execute-partial-expression-fast
	   :help " `gd-execute-partial-expression-fast'
Process partial-expression at point by a GDScript interpreter."]

          ["Execute region fast" gd-execute-region-fast
	   :help " `gd-execute-region-fast'"]

          ["Execute statement fast" gd-execute-statement-fast
	   :help " `gd-execute-statement-fast'
Process statement at point by a GDScript interpreter."]

          ["Execute string fast" gd-execute-string-fast
	   :help " `gd-execute-string-fast'"]

          ["Execute top level fast" gd-execute-top-level-fast
	   :help " `gd-execute-top-level-fast'
Process top-level at point by a GDScript interpreter."]
          )
         ("Virtualenv"
          ["Virtualenv activate" virtualenv-activate
	   :help " `virtualenv-activate'
Activate the virtualenv located in DIR"]

          ["Virtualenv deactivate" virtualenv-deactivate
	   :help " `virtualenv-deactivate'
Deactivate the current virtual enviroment"]

          ["Virtualenv p" virtualenv-p
	   :help " `virtualenv-p'
Check if a directory is a virtualenv"]

          ["Virtualenv workon" virtualenv-workon
	   :help " `virtualenv-workon'
Issue a virtualenvwrapper-like virtualenv-workon command"]
          )

	 ["Execute import or reload" gd-execute-import-or-reload
	  :help " `gd-execute-import-or-reload'
Import the current buffer’s file in a GDScript interpreter."]
         ("Help"
          ["Find definition" gd-find-definition
	   :help " `gd-find-definition'
Find source of definition of SYMBOL."]

          ["Help at point" gd-help-at-point
	   :help " `gd-help-at-point'
Print help on symbol at point."]

          ["Info lookup symbol" gd-info-lookup-symbol
	   :help " `gd-info-lookup-symbol'"]

          ["Symbol at point" gd-symbol-at-point
	   :help " `gd-symbol-at-point'
Return the current GDScript symbol."]
          )
          ("Debugger"
	   ["Execute statement pdb" gd-execute-statement-pdb
	    :help " `gd-execute-statement-pdb'
Execute statement running pdb."]

	   ["Pdb" pdb
	    :help " `pdb'
Run pdb on program FILE in buffer ‘*gud-FILE*’."]
            )
          ("Checks"
	   ["Flycheck mode" gd-flycheck-mode
	    :help " `gd-flycheck-mode'
Toggle ‘flycheck-mode’."]

	   ["Pychecker run" gd-pychecker-run
	    :help " `gd-pychecker-run'
*Run pychecker (default on the file currently visited)."]
          ("Pylint"
	   ["Pylint run" gd-pylint-run
	    :help " `gd-pylint-run'
*Run pylint (default on the file currently visited)."]

	   ["Pylint help" gd-pylint-help
	    :help " `gd-pylint-help'
Display Pylint command line help messages."]

	   ["Pylint flymake mode" pylint-flymake-mode
	    :help " `pylint-flymake-mode'
Toggle ‘pylint’ ‘flymake-mode’."]
            )
          ("Pep8"
	   ["Pep8 run" gd-pep8-run
	    :help " `gd-pep8-run'
*Run pep8, check formatting - default on the file currently visited."]

	   ["Pep8 help" gd-pep8-help
	    :help " `gd-pep8-help'
Display pep8 command line help messages."]

	   ["Pep8 flymake mode" pep8-flymake-mode
	    :help " `pep8-flymake-mode'
Toggle ‘pep8’ ‘flymake-mode’."]
            )
          ("Pyflakes"
	   ["Pyflakes run" gd-pyflakes-run
	    :help " `gd-pyflakes-run'
*Run pyflakes (default on the file currently visited)."]

	   ["Pyflakes help" gd-pyflakes-help
	    :help " `gd-pyflakes-help'
Display Pyflakes command line help messages."]

	   ["Pyflakes flymake mode" pyflakes-flymake-mode
	    :help " `pyflakes-flymake-mode'
Toggle ‘pyflakes’ ‘flymake-mode’."]
            )
          ("Flake8"
	   ["Flake8 run" gd-flake8-run
	    :help " `gd-flake8-run'
Flake8 is a wrapper around these tools:"]

	   ["Flake8 help" gd-flake8-help
	    :help " `gd-flake8-help'
Display flake8 command line help messages."]
          ("Pyflakes-pep8"
	   ["Pyflakes pep8 run" gd-pyflakes-pep8-run
	    :help " `gd-pyflakes-pep8-run'"]

	   ["Pyflakes pep8 help" gd-pyflakes-pep8-help
	    :help " `gd-pyflakes-pep8-help'"]

	   ["Pyflakes pep8 flymake mode" pyflakes-pep8-flymake-mode
	    :help " `pyflakes-pep8-flymake-mode'"]
            )))
         ("Customize"

	  ["GDScript-mode customize group" (customize-group 'gdscript-mode)
	   :help "Open the customization buffer for GDScript mode"]
	  ("Switches"
	   :help "Toggle useful modes like `highlight-indentation'"
	   ("Interpreter"

	    ["Shell prompt read only"
	     (setq gd-shell-prompt-read-only
		   (not gd-shell-prompt-read-only))
	     :help "If non-nil, the python prompt is read only.  Setting this variable will only effect new shells.Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-shell-prompt-read-only]

	    ["Remove cwd from path"
	     (setq gd-remove-cwd-from-path
		   (not gd-remove-cwd-from-path))
	     :help "Whether to allow loading of GDScript modules from the current directory.
If this is non-nil, Emacs removes '' from sys.path when starting
a GDScript process.  This is the default, for security
reasons, as it is easy for the GDScript process to be started
without the user's realization (e.g. to perform completion).Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-remove-cwd-from-path]

	    ["Honor IPYTHONDIR "
	     (setq gd-honor-IPYTHONDIR-p
		   (not gd-honor-IPYTHONDIR-p))
	     :help "When non-nil ipython-history file is constructed by \$IPYTHONDIR
followed by "/history". Default is nil.

Otherwise value of gd-ipython-history is used. Use `M-x customize-variable' to set it permanently"
:style toggle :selected gd-honor-IPYTHONDIR-p]

	    ["Honor PYTHONHISTORY "
	     (setq gd-honor-PYTHONHISTORY-p
		   (not gd-honor-PYTHONHISTORY-p))
	     :help "When non-nil gdscript-history file is set by \$PYTHONHISTORY
Default is nil.

Otherwise value of gd-gdscript-history is used. Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-honor-PYTHONHISTORY-p]

	    ["Enforce gd-shell-name" force-gd-shell-name-p-on
	     :help "Enforce customized default `gd-shell-name' should upon execution. "]

	    ["Don't enforce default interpreter" force-gd-shell-name-p-off
	     :help "Make execute commands guess interpreter from environment"]

	    ["Enforce local GDScript shell " gd-force-local-shell-on
	     :help "Locally indicated GDScript being enforced upon sessions execute commands. "]

	    ["Remove local GDScript shell enforcement, restore default" gd-force-local-shell-off
	     :help "Restore `gd-shell-name' default value and `behaviour'. "])

	   ("Execute"

	    ["Fast process" gd-fast-process-p
	     :help " `gd-fast-process-p'

Use `gd-fast-process'\.

Commands prefixed \"gd-fast-...\" suitable for large output

See: large output makes Emacs freeze, lp:1253907

Output-buffer is not in comint-mode"
	     :style toggle :selected gd-fast-process-p]

	    ["GDScript mode v5 behavior"
	     (setq gdscript-mode-v5-behavior-p
		   (not gdscript-mode-v5-behavior-p))
	     :help "Execute region through `shell-command-on-region' as
v5 did it - lp:990079. This might fail with certain chars - see UnicodeEncodeError lp:550661

Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gdscript-mode-v5-behavior-p]

	    ["Force shell name "
	     (setq gd-force-gd-shell-name-p
		   (not gd-force-gd-shell-name-p))
	     :help "When `t', execution with kind of GDScript specified in `gd-shell-name' is enforced, possibly shebang doesn't take precedence. Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-force-gd-shell-name-p]

	    ["Execute \"if name == main\" blocks p"
	     (setq gd-if-name-main-permission-p
		   (not gd-if-name-main-permission-p))
	     :help " `gd-if-name-main-permission-p'

Allow execution of code inside blocks delimited by
if __name__ == '__main__'

Default is non-nil. "
	     :style toggle :selected gd-if-name-main-permission-p]

	    ["Ask about save"
	     (setq gd-ask-about-save
		   (not gd-ask-about-save))
	     :help "If not nil, ask about which buffers to save before executing some code.
Otherwise, all modified buffers are saved without asking.Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-ask-about-save]

	    ["Store result"
	     (setq gd-store-result-p
		   (not gd-store-result-p))
	     :help " `gd-store-result-p'

When non-nil, put resulting string of `gd-execute-...' into kill-ring, so it might be yanked. "
	     :style toggle :selected gd-store-result-p]

	    ["Prompt on changed "
	     (setq gd-prompt-on-changed-p
		   (not gd-prompt-on-changed-p))
	     :help "When called interactively, ask for save before a changed buffer is sent to interpreter.

Default is `t'Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-prompt-on-changed-p]

	    ["Dedicated process "
	     (setq gd-dedicated-process-p
		   (not gd-dedicated-process-p))
	     :help "If commands executing code use a dedicated shell.

Default is nilUse `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-dedicated-process-p]

	    ["Execute without temporary file"
	     (setq gd-execute-no-temp-p
		   (not gd-execute-no-temp-p))
	     :help " `gd-execute-no-temp-p'
Seems Emacs-24.3 provided a way executing stuff without temporary files.
In experimental state yet "
	     :style toggle :selected gd-execute-no-temp-p]

	    ["Warn tmp files left "
	     (setq py--warn-tmp-files-left-p
		   (not py--warn-tmp-files-left-p))
	     :help "Messages a warning, when `gd-temp-directory' contains files susceptible being left by previous GDScript-mode sessions. See also lp:987534 Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected py--warn-tmp-files-left-p])

	   ("Edit"

	    ("Completion"

	     ["Set Pymacs-based complete keymap "
	      (setq gd-set-complete-keymap-p
		    (not gd-set-complete-keymap-p))
	      :help "If `gd-complete-initialize', which sets up enviroment for Pymacs based gd-complete, should load it's keys into `gdscript-mode-map'

Default is nil.
See also resp. edit `gd-complete-set-keymap' Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-set-complete-keymap-p]

	     ["Indent no completion "
	      (setq gd-indent-no-completion-p
		    (not gd-indent-no-completion-p))
	      :help "If completion function should indent when no completion found. Default is `t'

Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-indent-no-completion-p]

	     ["Company pycomplete "
	      (setq gd-company-pycomplete-p
		    (not gd-company-pycomplete-p))
	      :help "Load company-pycomplete stuff. Default is nilUse `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-company-pycomplete-p])

	    ("Filling"

	     ("Docstring styles"
	      :help "Switch docstring-style"

	      ["Nil" gd-set-nil-docstring-style
	       :help " `gd-set-nil-docstring-style'

Set gd-docstring-style to nil, format string normally. "]

	      ["pep-257-nn" gd-set-pep-257-nn-docstring-style
	       :help " `gd-set-pep-257-nn-docstring-style'

Set gd-docstring-style to 'pep-257-nn "]

	      ["pep-257" gd-set-pep-257-docstring-style
	       :help " `gd-set-pep-257-docstring-style'

Set gd-docstring-style to 'pep-257 "]

	      ["django" gd-set-django-docstring-style
	       :help " `gd-set-django-docstring-style'

Set gd-docstring-style to 'django "]

	      ["onetwo" gd-set-onetwo-docstring-style
	       :help " `gd-set-onetwo-docstring-style'

Set gd-docstring-style to 'onetwo "]

	      ["symmetric" gd-set-symmetric-docstring-style
	       :help " `gd-set-symmetric-docstring-style'

Set gd-docstring-style to 'symmetric "])

	     ["Auto-fill mode"
	      (setq gd-auto-fill-mode
		    (not gd-auto-fill-mode))
	      :help "Fill according to `gd-docstring-fill-column' and `gd-comment-fill-column'

Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-auto-fill-mode])

	    ["Use current dir when execute"
	     (setq gd-use-current-dir-when-execute-p
		   (not gd-use-current-dir-when-execute-p))
	     :help " `toggle-gd-use-current-dir-when-execute-p'

Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-use-current-dir-when-execute-p]

	    ("Indent"
	     ("TAB related"

	      ["indent-tabs-mode"
	       (setq indent-tabs-mode
		     (not indent-tabs-mode))
	       :help "Indentation can insert tabs if this is non-nil.

Use `M-x customize-variable' to set it permanently"
	       :style toggle :selected indent-tabs-mode]

	      ["Tab indent"
	       (setq gd-tab-indent
		     (not gd-tab-indent))
	       :help "Non-nil means TAB in GDScript mode calls `gd-indent-line'.Use `M-x customize-variable' to set it permanently"
	       :style toggle :selected gd-tab-indent]

	      ["Tab shifts region "
	       (setq gd-tab-shifts-region-p
		     (not gd-tab-shifts-region-p))
	       :help "If `t', TAB will indent/cycle the region, not just the current line.

Default is nil
See also `gd-tab-indents-region-p'

Use `M-x customize-variable' to set it permanently"
	       :style toggle :selected gd-tab-shifts-region-p]

	      ["Tab indents region "
	       (setq gd-tab-indents-region-p
		     (not gd-tab-indents-region-p))
	       :help "When `t' and first TAB doesn't shift, indent-region is called.

Default is nil
See also `gd-tab-shifts-region-p'

Use `M-x customize-variable' to set it permanently"
	       :style toggle :selected gd-tab-indents-region-p])

	     ["Close at start column"
	      (setq gd-closing-list-dedents-bos
		    (not gd-closing-list-dedents-bos))
	      :help "When non-nil, indent list's closing delimiter like start-column.

It will be lined up under the first character of
 the line that starts the multi-line construct, as in:

my_list = \[
    1, 2, 3,
    4, 5, 6,
]

Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-closing-list-dedents-bos]

	     ["Closing list keeps space"
	      (setq gd-closing-list-keeps-space
		    (not gd-closing-list-keeps-space))
	      :help "If non-nil, closing parenthesis dedents onto column of opening plus `gd-closing-list-space', default is nil Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-closing-list-keeps-space]

	     ["Closing list space"
	      (setq gd-closing-list-space
		    (not gd-closing-list-space))
	      :help "Number of chars, closing parenthesis outdent from opening, default is 1 Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-closing-list-space]

	     ["Tab shifts region "
	      (setq gd-tab-shifts-region-p
		    (not gd-tab-shifts-region-p))
	      :help "If `t', TAB will indent/cycle the region, not just the current line.

Default is nil
See also `gd-tab-indents-region-p'Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-tab-shifts-region-p]

	     ["Lhs inbound indent"
	      (setq gd-lhs-inbound-indent
		    (not gd-lhs-inbound-indent))
	      :help "When line starts a multiline-assignment: How many colums indent should be more than opening bracket, brace or parenthesis. Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-lhs-inbound-indent]

	     ["Continuation offset"
	      (setq gd-continuation-offset
		    (not gd-continuation-offset))
	      :help "With numeric ARG different from 1 gd-continuation-offset is set to that value; returns gd-continuation-offset. Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-continuation-offset]

	     ["Electric colon"
	      (setq gd-electric-colon-active-p
		    (not gd-electric-colon-active-p))
	      :help " `gd-electric-colon-active-p'

`gd-electric-colon' feature.  Default is `nil'. See lp:837065 for discussions. "
	      :style toggle :selected gd-electric-colon-active-p]

	     ["Electric colon at beginning of block only"
	      (setq gd-electric-colon-bobl-only
		    (not gd-electric-colon-bobl-only))
	      :help "When inserting a colon, do not indent lines unless at beginning of block.

Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-electric-colon-bobl-only]

	     ["Electric yank active "
	      (setq gd-electric-yank-active-p
		    (not gd-electric-yank-active-p))
	      :help " When non-nil, `yank' will be followed by an `indent-according-to-mode'.

Default is nilUse `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-electric-yank-active-p]

	     ["Electric kill backward "
	      (setq gd-electric-kill-backward-p
		    (not gd-electric-kill-backward-p))
	      :help "Affects `gd-electric-backspace'. Default is nil.

If behind a delimited form of braces, brackets or parentheses,
backspace will kill it's contents

With when cursor after
my_string\[0:1]
--------------^

==>

my_string\[]
----------^

In result cursor is insided emptied delimited form.Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-electric-kill-backward-p]

	     ["Trailing whitespace smart delete "
	      (setq gd-trailing-whitespace-smart-delete-p
		    (not gd-trailing-whitespace-smart-delete-p))
	      :help "Default is nil. When t, gdscript-mode calls
    (add-hook 'before-save-hook 'delete-trailing-whitespace nil 'local)

Also commands may delete trailing whitespace by the way.
When editing other peoples code, this may produce a larger diff than expected Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-trailing-whitespace-smart-delete-p]

	     ["Newline delete trailing whitespace "
	      (setq gd-newline-delete-trailing-whitespace-p
		    (not gd-newline-delete-trailing-whitespace-p))
	      :help "Delete trailing whitespace maybe left by `gd-newline-and-indent'.

Default is `t'. See lp:1100892 Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-newline-delete-trailing-whitespace-p]

	     ["Dedent keep relative column"
	      (setq gd-dedent-keep-relative-column
		    (not gd-dedent-keep-relative-column))
	      :help "If point should follow dedent or kind of electric move to end of line. Default is t - keep relative position. Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-dedent-keep-relative-column]

	     ["Indent paren spanned multilines "
	      (setq gd-indent-paren-spanned-multilines-p
		    (not gd-indent-paren-spanned-multilines-p))
	      :help "If non-nil, indents elements of list a value of `gd-indent-offset' to first element:

def foo():
    if (foo &&
            baz):
        bar()

Default lines up with first element:

def foo():
    if (foo &&
        baz):
        bar()
Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-indent-paren-spanned-multilines-p]

	     ["Indent honors multiline listing"
	      (setq gd-indent-honors-multiline-listing
		    (not gd-indent-honors-multiline-listing))
	      :help "If `t', indents to 1\+ column of opening delimiter. If `nil', indent adds one level to the beginning of statement. Default is `nil'. Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-indent-honors-multiline-listing]

	     ["Indent comment "
	      (setq gd-indent-comments
		    (not gd-indent-comments))
	      :help "If comments should be indented like code. Default is `nil'.

Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-indent-comments]

	     ["Uncomment indents "
	      (setq gd-uncomment-indents-p
		    (not gd-uncomment-indents-p))
	      :help "When non-nil, after uncomment indent lines. Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-uncomment-indents-p]

	     ["Indent honors inline comment"
	      (setq gd-indent-honors-inline-comment
		    (not gd-indent-honors-inline-comment))
	      :help "If non-nil, indents to column of inlined comment start.
Default is nil. Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-indent-honors-inline-comment]

	     ["Kill empty line"
	      (setq gd-kill-empty-line
		    (not gd-kill-empty-line))
	      :help "If t, gd-indent-forward-line kills empty lines. Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-kill-empty-line]

	     ("Smart indentation"
	      :help "Toggle gd-smart-indentation'

Use `M-x customize-variable' to set it permanently"

	      ["Toggle gd-smart-indentation" toggle-gd-smart-indentation
	       :help "Toggles gd-smart-indentation

Use `M-x customize-variable' to set it permanently"]

	      ["gd-smart-indentation on" gd-smart-indentation-on
	       :help "Switches gd-smart-indentation on

Use `M-x customize-variable' to set it permanently"]

	      ["gd-smart-indentation off" gd-smart-indentation-off
	       :help "Switches gd-smart-indentation off

Use `M-x customize-variable' to set it permanently"])

	     ["Beep if tab change"
	      (setq gd-beep-if-tab-change
		    (not gd-beep-if-tab-change))
	      :help "Ring the bell if `tab-width' is changed.
If a comment of the form

                           	# vi:set tabsize=<number>:

is found before the first code line when the file is entered, and the
current value of (the general Emacs variable) `tab-width' does not
equal <number>, `tab-width' is set to <number>, a message saying so is
displayed in the echo area, and if `gd-beep-if-tab-change' is non-nil
the Emacs bell is also rung as a warning.Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-beep-if-tab-change]

	     ["Highlight indentation" highlight-indentation
	      :help "Toggle highlight indentation.

Use `M-x customize-variable' to set it permanently

Make sure `highlight-indentation' is installed"

	      ]

	     ["Electric comment "
	      (setq gd-electric-comment-p
		    (not gd-electric-comment-p))
	      :help "If \"#\" should call `gd-electric-comment'. Default is `nil'.

Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-electric-comment-p]

	     ["Electric comment add space "
	      (setq gd-electric-comment-add-space-p
		    (not gd-electric-comment-add-space-p))
	      :help "If gd-electric-comment should add a space.  Default is `nil'. Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-electric-comment-add-space-p]

	     ["Empty line closes "
	      (setq gd-empty-line-closes-p
		    (not gd-empty-line-closes-p))
	      :help "When non-nil, dedent after empty line following block

if True:
    print(\"Part of the if-statement\")

print(\"Not part of the if-statement\")

Default is nil

If non-nil, a C-j from empty line dedents.
Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-empty-line-closes-p])
	    ["Defun use top level "
	     (setq gd-defun-use-top-level-p
		   (not gd-defun-use-top-level-p))
	     :help "When non-nil, keys C-M-a, C-M-e address top-level form.

Beginning- end-of-defun forms use
commands `gd-backward-top-level', `gd-forward-top-level'

mark-defun marks top-level form at point etc. "
	     :style toggle :selected gd-defun-use-top-level-p]

	    ["Close provides newline"
	     (setq gd-close-provides-newline
		   (not gd-close-provides-newline))
	     :help "If a newline is inserted, when line after block isn't empty. Default is non-nil. Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-close-provides-newline]

	    ["Block comment prefix "
	     (setq gd-block-comment-prefix-p
		   (not gd-block-comment-prefix-p))
	     :help "If gd-comment inserts gd-block-comment-prefix.

Default is tUse `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-block-comment-prefix-p])

	   ("Display"

	    ("Index"

	     ["Imenu create index "
	      (setq py--imenu-create-index-p
		    (not py--imenu-create-index-p))
	      :help "Non-nil means GDScript mode creates and displays an index menu of functions and global variables. Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected py--imenu-create-index-p]

	     ["Imenu show method args "
	      (setq gd-imenu-show-method-args-p
		    (not gd-imenu-show-method-args-p))
	      :help "Controls echoing of arguments of functions & methods in the Imenu buffer.
When non-nil, arguments are printed.Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-imenu-show-method-args-p]
	     ["Switch index-function" gd-switch-imenu-index-function
	      :help "`gd-switch-imenu-index-function'
Switch between `py--imenu-create-index' from 5.1 series and `py--imenu-create-index-new'."])

	    ("Fontification"

	     ["Mark decorators"
	      (setq gd-mark-decorators
		    (not gd-mark-decorators))
	      :help "If gd-mark-def-or-class functions should mark decorators too. Default is `nil'. Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-mark-decorators]

	     ["Fontify shell buffer "
	      (setq gd-fontify-shell-buffer-p
		    (not gd-fontify-shell-buffer-p))
	      :help "If code in GDScript shell should be highlighted as in script buffer.

Default is nil.

If `t', related vars like `comment-start' will be set too.
Seems convenient when playing with stuff in IPython shell
Might not be TRT when a lot of output arrives Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-fontify-shell-buffer-p]

	     ["Use font lock doc face "
	      (setq gd-use-font-lock-doc-face-p
		    (not gd-use-font-lock-doc-face-p))
	      :help "If documention string inside of def or class get `font-lock-doc-face'.

`font-lock-doc-face' inherits `font-lock-string-face'.

Call M-x `customize-face' in order to have a visible effect. Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-use-font-lock-doc-face-p])

	    ["Switch buffers on execute"
	     (setq gd-switch-buffers-on-execute-p
		   (not gd-switch-buffers-on-execute-p))
	     :help "When non-nil switch to the GDScript output buffer.

Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-switch-buffers-on-execute-p]

	    ["Split windows on execute"
	     (setq gd-split-window-on-execute
		   (not gd-split-window-on-execute))
	     :help "When non-nil split windows.

Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-split-window-on-execute]

	    ["Keep windows configuration"
	     (setq gd-keep-windows-configuration
		   (not gd-keep-windows-configuration))
	     :help "If a windows is splitted displaying results, this is directed by variable `gd-split-window-on-execute'\. Also setting `gd-switch-buffers-on-execute-p' affects window-configuration\. While commonly a screen splitted into source and GDScript-shell buffer is assumed, user may want to keep a different config\.

Setting `gd-keep-windows-configuration' to `t' will restore windows-config regardless of settings mentioned above\. However, if an error occurs, it's displayed\.

To suppres window-changes due to error-signaling also: M-x customize-variable RET. Set `gd-keep-4windows-configuration' onto 'force

Default is nil Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-keep-windows-configuration]

	    ["Which split windows on execute function"
	     (progn
	       (if (eq 'split-window-vertically gd-split-windows-on-execute-function)
		   (setq gd-split-windows-on-execute-function'split-window-horizontally)
		 (setq gd-split-windows-on-execute-function 'split-window-vertically))
	       (message "gd-split-windows-on-execute-function set to: %s" gd-split-windows-on-execute-function))

	     :help "If `split-window-vertically' or `...-horizontally'. Use `M-x customize-variable' RET `gd-split-windows-on-execute-function' RET to set it permanently"
	     :style toggle :selected gd-split-windows-on-execute-function]

	    ["Modeline display full path "
	     (setq gd-modeline-display-full-path-p
		   (not gd-modeline-display-full-path-p))
	     :help "If the full PATH/TO/PYTHON should be displayed in shell modeline.

Default is nil. Note: when `gd-shell-name' is specified with path, it's shown as an acronym in buffer-name already. Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-modeline-display-full-path-p]

	    ["Modeline acronym display home "
	     (setq gd-modeline-acronym-display-home-p
		   (not gd-modeline-acronym-display-home-p))
	     :help "If the modeline acronym should contain chars indicating the home-directory.

Default is nil Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-modeline-acronym-display-home-p]

	    ["Hide show hide docstrings"
	     (setq gd-hide-show-hide-docstrings
		   (not gd-hide-show-hide-docstrings))
	     :help "Controls if doc strings can be hidden by hide-showUse `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-hide-show-hide-docstrings]

	    ["Hide comments when hiding all"
	     (setq gd-hide-comments-when-hiding-all
		   (not gd-hide-comments-when-hiding-all))
	     :help "Hide the comments too when you do `hs-hide-all'. Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-hide-comments-when-hiding-all]

	    ["Max help buffer "
	     (setq gd-max-help-buffer-p
		   (not gd-max-help-buffer-p))
	     :help "If \"\*GDScript-Help\*\"-buffer should appear as the only visible.

Default is nil. In help-buffer, \"q\" will close it.  Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-max-help-buffer-p]

	    ["Current defun show"
	     (setq gd-current-defun-show
		   (not gd-current-defun-show))
	     :help "If `gd-current-defun' should jump to the definition, highlight it while waiting PY-WHICH-FUNC-DELAY seconds, before returning to previous position.

Default is `t'.Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-current-defun-show]

	    ["Match paren mode"
	     (setq gd-match-paren-mode
		   (not gd-match-paren-mode))
	     :help "Non-nil means, cursor will jump to beginning or end of a block.
This vice versa, to beginning first.
Sets `gd-match-paren-key' in gdscript-mode-map.
Customize `gd-match-paren-key' which key to use. Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-match-paren-mode])

	   ("Debug"

	    ["gd-debug-p"
	     (setq gd-debug-p
		   (not gd-debug-p))
	     :help "When non-nil, keep resp\. store information useful for debugging\.

Temporary files are not deleted\. Other functions might implement
some logging etc\. Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-debug-p]

	    ["Pdbtrack do tracking "
	     (setq gd-pdbtrack-do-tracking-p
		   (not gd-pdbtrack-do-tracking-p))
	     :help "Controls whether the pdbtrack feature is enabled or not.
When non-nil, pdbtrack is enabled in all comint-based buffers,
e.g. shell buffers and the \*GDScript\* buffer.  When using pdb to debug a
GDScript program, pdbtrack notices the pdb prompt and displays the
source file and line that the program is stopped at, much the same way
as gud-mode does for debugging C programs with gdb.Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-pdbtrack-do-tracking-p]

	    ["Jump on exception"
	     (setq gd-jump-on-exception
		   (not gd-jump-on-exception))
	     :help "Jump to innermost exception frame in GDScript output buffer.
When this variable is non-nil and an exception occurs when running
GDScript code synchronously in a subprocess, jump immediately to the
source code of the innermost traceback frame.

Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-jump-on-exception]

	    ["Highlight error in source "
	     (setq gd-highlight-error-source-p
		   (not gd-highlight-error-source-p))
	     :help "Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-highlight-error-source-p])

	   ("Other"

	    ("Directory"

	     ["Guess install directory "
	      (setq gd-guess-gd-install-directory-p
		    (not gd-guess-gd-install-directory-p))
	      :help "If in cases, `gd-install-directory' isn't set,  `gd-set-load-path'should guess it from `buffer-file-name'. Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-guess-gd-install-directory-p]

	     ["Use local default"
	      (setq gd-use-local-default
		    (not gd-use-local-default))
	      :help "If `t', gd-shell will use `gd-shell-local-path' instead
of default GDScript.

Making switch between several virtualenv's easier,
                               `gdscript-mode' should deliver an installer, so named-shells pointing to virtualenv's will be available. Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-use-local-default]

	     ["Use current dir when execute "
	      (setq gd-use-current-dir-when-execute-p
		    (not gd-use-current-dir-when-execute-p))
	      :help "When `t', current directory is used by GDScript-shell for output of `gd-execute-buffer' and related commands.

See also `gd-execute-directory'Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-use-current-dir-when-execute-p]

	     ["Keep shell dir when execute "
	      (setq gd-keep-shell-dir-when-execute-p
		    (not gd-keep-shell-dir-when-execute-p))
	      :help "Don't change GDScript shell's current working directory when sending code.

See also `gd-execute-directory'Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-keep-shell-dir-when-execute-p]

	     ["Fileless buffer use default directory "
	      (setq gd-fileless-buffer-use-default-directory-p
		    (not gd-fileless-buffer-use-default-directory-p))
	      :help "When `gd-use-current-dir-when-execute-p' is non-nil and no buffer-file exists, value of `default-directory' sets current working directory of GDScript output shellUse `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-fileless-buffer-use-default-directory-p])

	    ("Underscore word syntax"
	     :help "Toggle `gd-underscore-word-syntax-p'"

	     ["Toggle underscore word syntax" toggle-gd-underscore-word-syntax-p
	      :help " `toggle-gd-underscore-word-syntax-p'

If `gd-underscore-word-syntax-p' should be on or off.

  Returns value of `gd-underscore-word-syntax-p' switched to. .

Use `M-x customize-variable' to set it permanently"]

	     ["Underscore word syntax on" gd-underscore-word-syntax-p-on
	      :help " `gd-underscore-word-syntax-p-on'

Make sure, gd-underscore-word-syntax-p' is on.

Returns value of `gd-underscore-word-syntax-p'. .

Use `M-x customize-variable' to set it permanently"]

	     ["Underscore word syntax off" gd-underscore-word-syntax-p-off
	      :help " `gd-underscore-word-syntax-p-off'

Make sure, `gd-underscore-word-syntax-p' is off.

Returns value of `gd-underscore-word-syntax-p'. .

Use `M-x customize-variable' to set it permanently"])

	    ["Load pymacs "
	     (setq gd-load-pymacs-p
		   (not gd-load-pymacs-p))
	     :help "If Pymacs related stuff should be loaded.

Default is nil.

Pymacs has been written by François Pinard and many others.
See original source: http://pymacs.progiciels-bpi.caUse `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-load-pymacs-p]

	    ["Verbose "
	     (setq gd-verbose-p
		   (not gd-verbose-p))
	     :help "If functions should report results.

Default is nil. Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-verbose-p]

	    ["Empty comment line separates paragraph "
	     (setq gd-empty-comment-line-separates-paragraph-p
		   (not gd-empty-comment-line-separates-paragraph-p))
	     :help "Consider paragraph start/end lines with nothing inside but comment sign.

Default is non-nilUse `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-empty-comment-line-separates-paragraph-p]

	    ["Org cycle "
	     (setq gd-org-cycle-p
		   (not gd-org-cycle-p))
	     :help "When non-nil, command `org-cycle' is available at shift-TAB, <backtab>

Default is nil. Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-org-cycle-p]

	    ["Set pager cat"
	     (setq gd-set-pager-cat-p
		   (not gd-set-pager-cat-p))
	     :help "If the shell environment variable \$PAGER should set to `cat'.

If `t', use `C-c C-r' to jump to beginning of output. Then scroll normally.

Avoids lp:783828, \"Terminal not fully functional\", for help('COMMAND') in gdscript-shell

When non-nil, imports module `os' Use `M-x customize-variable' to
set it permanently"
	     :style toggle :selected gd-set-pager-cat-p]

	    ["Edit only "
	     (setq gd-edit-only-p
		   (not gd-edit-only-p))
	     :help "When `t' `gdscript-mode' will not take resort nor check for installed GDScript executables. Default is nil.

See bug report at launchpad, lp:944093. Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-edit-only-p])))
         ("Other"
          ["Boolswitch" gd-boolswitch
	   :help " `gd-boolswitch'
Edit the assignment of a boolean variable, revert them."]

          ["Empty out list backward" gd-empty-out-list-backward
	   :help " `gd-empty-out-list-backward'
Deletes all elements from list before point."]

          ["Kill buffer unconditional" gd-kill-buffer-unconditional
	   :help " `gd-kill-buffer-unconditional'
Kill buffer unconditional, kill buffer-process if existing."]

          ["Remove overlays at point" gd-remove-overlays-at-point
	   :help " `gd-remove-overlays-at-point'
Remove overlays as set when ‘gd-highlight-error-source-p’ is non-nil."]
          ("Electric"
	   ["Complete electric comma" gd-complete-electric-comma
	    :help " `gd-complete-electric-comma'"]

	   ["Complete electric lparen" gd-complete-electric-lparen
	    :help " `gd-complete-electric-lparen'"]

	   ["Electric backspace" gd-electric-backspace
	    :help " `gd-electric-backspace'
Delete preceding character or level of indentation."]

	   ["Electric colon" gd-electric-colon
	    :help " `gd-electric-colon'
Insert a colon and indent accordingly."]

	   ["Electric comment" gd-electric-comment
	    :help " `gd-electric-comment'
Insert a comment. If starting a comment, indent accordingly."]

	   ["Electric delete" gd-electric-delete
	    :help " `gd-electric-delete'
Delete following character or levels of whitespace."]

	   ["Electric yank" gd-electric-yank
	    :help " `gd-electric-yank'
Perform command ‘yank’ followed by an ‘indent-according-to-mode’"]

	   ["Hungry delete backwards" gd-hungry-delete-backwards
	    :help " `gd-hungry-delete-backwards'
Delete the preceding character or all preceding whitespace"]

	   ["Hungry delete forward" gd-hungry-delete-forward
	    :help " `gd-hungry-delete-forward'
Delete the following character or all following whitespace"]
            )
          ("Filling"
	   ["Py docstring style" gd-gd-docstring-style
	    :help " `gd-gd-docstring-style'"]

	   ["Py fill comment" gd-gd-fill-comment
	    :help " `gd-gd-fill-comment'"]

	   ["Py fill paragraph" gd-gd-fill-paragraph
	    :help " `gd-gd-fill-paragraph'"]

	   ["Py fill string" gd-gd-fill-string
	    :help " `gd-gd-fill-string'"]

	   ["Py fill string django" gd-gd-fill-string-django
	    :help " `gd-gd-fill-string-django'"]

	   ["Py fill string onetwo" gd-gd-fill-string-onetwo
	    :help " `gd-gd-fill-string-onetwo'"]

	   ["Py fill string pep 257" gd-gd-fill-string-pep-257
	    :help " `gd-gd-fill-string-pep-257'"]

	   ["Py fill string pep 257 nn" gd-gd-fill-string-pep-257-nn
	    :help " `gd-gd-fill-string-pep-257-nn'"]

	   ["Py fill string symmetric" gd-gd-fill-string-symmetric
	    :help " `gd-gd-fill-string-symmetric'"]
            )
          ("Abbrevs"	   :help "see also `gd-add-abbrev'"
	   :filter (lambda (&rest junk)
		     (abbrev-table-menu gdscript-mode-abbrev-table))            )

          ["Add abbrev" gd-add-abbrev
	   :help " `gd-add-abbrev'
Defines gdscript-mode specific abbrev for last expressions before point."]
          ("Completion"
	   ["Py indent or complete" gd-gd-indent-or-complete
	    :help " `gd-gd-indent-or-complete'"]

	   ["Py shell complete" gd-gd-shell-complete
	    :help " `gd-gd-shell-complete'"]

	   ["Py complete" gd-gd-complete
	    :help " `gd-gd-complete'"]
            )

          ["Find function" gd-find-function
	   :help " `gd-find-function'
Find source of definition of SYMBOL."]
            )
            )))

;; gdscript-components-shell-menu

(and (ignore-errors (require 'easymenu) t)
     ;; (easy-menu-define gd-menu map "GDScript Tools"
     ;;           `("PyTools"
     (easy-menu-define
       gd-shell-menu gd-gdscript-shell-mode-map "Py-Shell Mode menu"
       `("Py-Shell"
         ("Edit"
          ("Shift"
           ("Shift right"
	    ["Shift block right" gd-shift-block-right
	     :help " `gd-shift-block-right'
Indent block by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use [universal-argument] to specify a different value.

Returns outmost indentation reached."]

	    ["Shift block or clause right" gd-shift-block-or-clause-right
	     :help " `gd-shift-block-or-clause-right'
Indent block-or-clause by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use [universal-argument] to specify a different value.

Returns outmost indentation reached."]

	    ["Shift class right" gd-shift-class-right
	     :help " `gd-shift-class-right'
Indent class by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use [universal-argument] to specify a different value.

Returns outmost indentation reached."]

	    ["Shift clause right" gd-shift-clause-right
	     :help " `gd-shift-clause-right'
Indent clause by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use [universal-argument] to specify a different value.

Returns outmost indentation reached."]

	    ["Shift comment right" gd-shift-comment-right
	     :help " `gd-shift-comment-right'"]

	    ["Shift def right" gd-shift-def-right
	     :help " `gd-shift-def-right'
Indent def by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use [universal-argument] to specify a different value.

Returns outmost indentation reached."]

	    ["Shift def or class right" gd-shift-def-or-class-right
	     :help " `gd-shift-def-or-class-right'
Indent def-or-class by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use [universal-argument] to specify a different value.

Returns outmost indentation reached."]

	    ["Shift minor block right" gd-shift-minor-block-right
	     :help " `gd-shift-minor-block-right'
Indent minor-block by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use [universal-argument] to specify a different value.

Returns outmost indentation reached.
A minor block is started by a `for', `if', `try' or `with'."]

	    ["Shift paragraph right" gd-shift-paragraph-right
	     :help " `gd-shift-paragraph-right'
Indent paragraph by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use [universal-argument] to specify a different value.

Returns outmost indentation reached."]

	    ["Shift region right" gd-shift-region-right
	     :help " `gd-shift-region-right'
Indent region according to `gd-indent-offset' by COUNT times.

If no region is active, current line is indented.
Returns indentation reached."]

	    ["Shift statement right" gd-shift-statement-right
	     :help " `gd-shift-statement-right'
Indent statement by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use [universal-argument] to specify a different value.

Returns outmost indentation reached."]

	    ["Shift top level right" gd-shift-top-level-right
	     :help " `gd-shift-top-level-right'"]
            )
           ("Shift left"
	    ["Shift block left" gd-shift-block-left
	     :help " `gd-shift-block-left'
Dedent block by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use [universal-argument] to specify a different value.

Returns outmost indentation reached."]

	    ["Shift block or clause left" gd-shift-block-or-clause-left
	     :help " `gd-shift-block-or-clause-left'
Dedent block-or-clause by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use [universal-argument] to specify a different value.

Returns outmost indentation reached."]

	    ["Shift class left" gd-shift-class-left
	     :help " `gd-shift-class-left'
Dedent class by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use [universal-argument] to specify a different value.

Returns outmost indentation reached."]

	    ["Shift clause left" gd-shift-clause-left
	     :help " `gd-shift-clause-left'
Dedent clause by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use [universal-argument] to specify a different value.

Returns outmost indentation reached."]

	    ["Shift comment left" gd-shift-comment-left
	     :help " `gd-shift-comment-left'"]

	    ["Shift def left" gd-shift-def-left
	     :help " `gd-shift-def-left'
Dedent def by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use [universal-argument] to specify a different value.

Returns outmost indentation reached."]

	    ["Shift def or class left" gd-shift-def-or-class-left
	     :help " `gd-shift-def-or-class-left'
Dedent def-or-class by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use [universal-argument] to specify a different value.

Returns outmost indentation reached."]

	    ["Shift minor block left" gd-shift-minor-block-left
	     :help " `gd-shift-minor-block-left'
Dedent minor-block by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use [universal-argument] to specify a different value.

Returns outmost indentation reached.
A minor block is started by a `for', `if', `try' or `with'."]

	    ["Shift paragraph left" gd-shift-paragraph-left
	     :help " `gd-shift-paragraph-left'
Dedent paragraph by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use [universal-argument] to specify a different value.

Returns outmost indentation reached."]

	    ["Shift region left" gd-shift-region-left
	     :help " `gd-shift-region-left'
Dedent region according to `gd-indent-offset' by COUNT times.

If no region is active, current line is dedented.
Returns indentation reached."]

	    ["Shift statement left" gd-shift-statement-left
	     :help " `gd-shift-statement-left'
Dedent statement by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use [universal-argument] to specify a different value.

Returns outmost indentation reached."]
            ))
          ("Mark"
	   ["Mark block" gd-mark-block
	    :help " `gd-mark-block'
Mark block at point.

Returns beginning and end positions of marked area, a cons."]

	   ["Mark block or clause" gd-mark-block-or-clause
	    :help " `gd-mark-block-or-clause'
Mark block-or-clause at point.

Returns beginning and end positions of marked area, a cons."]

	   ["Mark class" gd-mark-class
	    :help " `gd-mark-class'
Mark class at point.

With C-u or `gd-mark-decorators' set to `t', decorators are marked too.
Returns beginning and end positions of marked area, a cons."]

	   ["Mark clause" gd-mark-clause
	    :help " `gd-mark-clause'
Mark clause at point.

Returns beginning and end positions of marked area, a cons."]

	   ["Mark comment" gd-mark-comment
	    :help " `gd-mark-comment'
Mark comment at point.

Returns beginning and end positions of marked area, a cons."]

	   ["Mark def" gd-mark-def
	    :help " `gd-mark-def'
Mark def at point.

With C-u or `gd-mark-decorators' set to `t', decorators are marked too.
Returns beginning and end positions of marked area, a cons."]

	   ["Mark def or class" gd-mark-def-or-class
	    :help " `gd-mark-def-or-class'
Mark def-or-class at point.

With C-u or `gd-mark-decorators' set to `t', decorators are marked too.
Returns beginning and end positions of marked area, a cons."]

	   ["Mark expression" gd-mark-expression
	    :help " `gd-mark-expression'
Mark expression at point.

Returns beginning and end positions of marked area, a cons."]

	   ["Mark line" gd-mark-line
	    :help " `gd-mark-line'
Mark line at point.

Returns beginning and end positions of marked area, a cons."]

	   ["Mark minor block" gd-mark-minor-block
	    :help " `gd-mark-minor-block'
Mark minor-block at point.

Returns beginning and end positions of marked area, a cons."]

	   ["Mark paragraph" gd-mark-paragraph
	    :help " `gd-mark-paragraph'
Mark paragraph at point.

Returns beginning and end positions of marked area, a cons."]

	   ["Mark partial expression" gd-mark-partial-expression
	    :help " `gd-mark-partial-expression'
Mark partial-expression at point.

Returns beginning and end positions of marked area, a cons."]

	   ["Mark statement" gd-mark-statement
	    :help " `gd-mark-statement'
Mark statement at point.

Returns beginning and end positions of marked area, a cons."]

	   ["Mark top level" gd-mark-top-level
	    :help " `gd-mark-top-level'
Mark top-level at point.

Returns beginning and end positions of marked area, a cons."]
           )
          ("Copy"
	   ["Copy block" gd-copy-block
	    :help " `gd-copy-block'
Copy block at point.

Store data in kill ring, so it might yanked back."]

	   ["Copy block or clause" gd-copy-block-or-clause
	    :help " `gd-copy-block-or-clause'
Copy block-or-clause at point.

Store data in kill ring, so it might yanked back."]

	   ["Copy class" gd-copy-class
	    :help " `gd-copy-class'
Copy class at point.

Store data in kill ring, so it might yanked back."]

	   ["Copy clause" gd-copy-clause
	    :help " `gd-copy-clause'
Copy clause at point.

Store data in kill ring, so it might yanked back."]

	   ["Copy comment" gd-copy-comment
	    :help " `gd-copy-comment'"]

	   ["Copy def" gd-copy-def
	    :help " `gd-copy-def'
Copy def at point.

Store data in kill ring, so it might yanked back."]

	   ["Copy def or class" gd-copy-def-or-class
	    :help " `gd-copy-def-or-class'
Copy def-or-class at point.

Store data in kill ring, so it might yanked back."]

	   ["Copy expression" gd-copy-expression
	    :help " `gd-copy-expression'
Copy expression at point.

Store data in kill ring, so it might yanked back."]

	   ["Copy line" gd-copy-line
	    :help " `gd-copy-line'"]

	   ["Copy minor block" gd-copy-minor-block
	    :help " `gd-copy-minor-block'
Copy minor-block at point.

Store data in kill ring, so it might yanked back."]

	   ["Copy paragraph" gd-copy-paragraph
	    :help " `gd-copy-paragraph'"]

	   ["Copy partial expression" gd-copy-partial-expression
	    :help " `gd-copy-partial-expression'
Copy partial-expression at point.

Store data in kill ring, so it might yanked back."]

	   ["Copy statement" gd-copy-statement
	    :help " `gd-copy-statement'
Copy statement at point.

Store data in kill ring, so it might yanked back."]

	   ["Copy top level" gd-copy-top-level
	    :help " `gd-copy-top-level'
Copy top-level at point.

Store data in kill ring, so it might yanked back."]
           )
          ("Kill"
	   ["Kill block" gd-kill-block
	    :help " `gd-kill-block'
Delete `block' at point.

Stores data in kill ring"]

	   ["Kill block or clause" gd-kill-block-or-clause
	    :help " `gd-kill-block-or-clause'
Delete `block-or-clause' at point.

Stores data in kill ring"]

	   ["Kill class" gd-kill-class
	    :help " `gd-kill-class'
Delete `class' at point.

Stores data in kill ring"]

	   ["Kill clause" gd-kill-clause
	    :help " `gd-kill-clause'
Delete `clause' at point.

Stores data in kill ring"]

	   ["Kill comment" gd-kill-comment
	    :help " `gd-kill-comment'"]

	   ["Kill def" gd-kill-def
	    :help " `gd-kill-def'
Delete `def' at point.

Stores data in kill ring"]

	   ["Kill def or class" gd-kill-def-or-class
	    :help " `gd-kill-def-or-class'
Delete `def-or-class' at point.

Stores data in kill ring"]

	   ["Kill expression" gd-kill-expression
	    :help " `gd-kill-expression'
Delete `expression' at point.

Stores data in kill ring"]

	   ["Kill line" gd-kill-line
	    :help " `gd-kill-line'"]

	   ["Kill minor block" gd-kill-minor-block
	    :help " `gd-kill-minor-block'
Delete `minor-block' at point.

Stores data in kill ring"]

	   ["Kill paragraph" gd-kill-paragraph
	    :help " `gd-kill-paragraph'"]

	   ["Kill partial expression" gd-kill-partial-expression
	    :help " `gd-kill-partial-expression'
Delete `partial-expression' at point.

Stores data in kill ring"]

	   ["Kill statement" gd-kill-statement
	    :help " `gd-kill-statement'
Delete `statement' at point.

Stores data in kill ring"]

	   ["Kill top level" gd-kill-top-level
	    :help " `gd-kill-top-level'
Delete `top-level' at point.

Stores data in kill ring"]
           )
          ("Delete"
	   ["Delete block" gd-delete-block
	    :help " `gd-delete-block'
Delete BLOCK at point.

Don't store data in kill ring."]

	   ["Delete block or clause" gd-delete-block-or-clause
	    :help " `gd-delete-block-or-clause'
Delete BLOCK-OR-CLAUSE at point.

Don't store data in kill ring."]

	   ["Delete class" gd-delete-class
	    :help " `gd-delete-class'
Delete CLASS at point.

Don't store data in kill ring.
With C-u or `gd-mark-decorators' set to `t', `decorators' are included."]

	   ["Delete clause" gd-delete-clause
	    :help " `gd-delete-clause'
Delete CLAUSE at point.

Don't store data in kill ring."]

	   ["Delete comment" gd-delete-comment
	    :help " `gd-delete-comment'"]

	   ["Delete def" gd-delete-def
	    :help " `gd-delete-def'
Delete DEF at point.

Don't store data in kill ring.
With C-u or `gd-mark-decorators' set to `t', `decorators' are included."]

	   ["Delete def or class" gd-delete-def-or-class
	    :help " `gd-delete-def-or-class'
Delete DEF-OR-CLASS at point.

Don't store data in kill ring.
With C-u or `gd-mark-decorators' set to `t', `decorators' are included."]

	   ["Delete expression" gd-delete-expression
	    :help " `gd-delete-expression'
Delete EXPRESSION at point.

Don't store data in kill ring."]

	   ["Delete line" gd-delete-line
	    :help " `gd-delete-line'"]

	   ["Delete minor block" gd-delete-minor-block
	    :help " `gd-delete-minor-block'
Delete MINOR-BLOCK at point.

Don't store data in kill ring."]

	   ["Delete paragraph" gd-delete-paragraph
	    :help " `gd-delete-paragraph'"]

	   ["Delete partial expression" gd-delete-partial-expression
	    :help " `gd-delete-partial-expression'
Delete PARTIAL-EXPRESSION at point.

Don't store data in kill ring."]

	   ["Delete statement" gd-delete-statement
	    :help " `gd-delete-statement'
Delete STATEMENT at point.

Don't store data in kill ring."]

	   ["Delete top level" gd-delete-top-level
	    :help " `gd-delete-top-level'
Delete TOP-LEVEL at point.

Don't store data in kill ring."]
           )
          ("Comment"
	   ["Comment block" gd-comment-block
	    :help " `gd-comment-block'
Comments block at point.

Uses double hash (`#') comment starter when `gd-block-comment-prefix-p' is  `t',
the default"]

	   ["Comment block or clause" gd-comment-block-or-clause
	    :help " `gd-comment-block-or-clause'
Comments block-or-clause at point.

Uses double hash (`#') comment starter when `gd-block-comment-prefix-p' is  `t',
the default"]

	   ["Comment class" gd-comment-class
	    :help " `gd-comment-class'
Comments class at point.

Uses double hash (`#') comment starter when `gd-block-comment-prefix-p' is  `t',
the default"]

	   ["Comment clause" gd-comment-clause
	    :help " `gd-comment-clause'
Comments clause at point.

Uses double hash (`#') comment starter when `gd-block-comment-prefix-p' is  `t',
the default"]

	   ["Comment def" gd-comment-def
	    :help " `gd-comment-def'
Comments def at point.

Uses double hash (`#') comment starter when `gd-block-comment-prefix-p' is  `t',
the default"]

	   ["Comment def or class" gd-comment-def-or-class
	    :help " `gd-comment-def-or-class'
Comments def-or-class at point.

Uses double hash (`#') comment starter when `gd-block-comment-prefix-p' is  `t',
the default"]

	   ["Comment statement" gd-comment-statement
	    :help " `gd-comment-statement'
Comments statement at point.

Uses double hash (`#') comment starter when `gd-block-comment-prefix-p' is  `t',
the default"]
           ))
         ("Move"
          ("Backward"
	   ["Beginning of block" gd-beginning-of-block
	    :help " `gd-beginning-of-block'
Go to beginning block, skip whitespace at BOL.

Returns beginning of block if successful, nil otherwise"]

	   ["Beginning of block or clause" gd-beginning-of-block-or-clause
	    :help " `gd-beginning-of-block-or-clause'
Go to beginning block-or-clause, skip whitespace at BOL.

Returns beginning of block-or-clause if successful, nil otherwise"]

	   ["Beginning of class" gd-beginning-of-class
	    :help " `gd-beginning-of-class'
Go to beginning class, skip whitespace at BOL.

Returns beginning of class if successful, nil otherwise

When `gd-mark-decorators' is non-nil, decorators are considered too."]

	   ["Beginning of clause" gd-beginning-of-clause
	    :help " `gd-beginning-of-clause'
Go to beginning clause, skip whitespace at BOL.

Returns beginning of clause if successful, nil otherwise"]

	   ["Beginning of def" gd-beginning-of-def
	    :help " `gd-beginning-of-def'
Go to beginning def, skip whitespace at BOL.

Returns beginning of def if successful, nil otherwise

When `gd-mark-decorators' is non-nil, decorators are considered too."]

	   ["Beginning of def or class" gd-beginning-of-def-or-class
	    :help " `gd-beginning-of-def-or-class'
Go to beginning def-or-class, skip whitespace at BOL.

Returns beginning of def-or-class if successful, nil otherwise

When `gd-mark-decorators' is non-nil, decorators are considered too."]

	   ["Beginning of elif block" gd-beginning-of-elif-block
	    :help " `gd-beginning-of-elif-block'
Go to beginning elif-block, skip whitespace at BOL.

Returns beginning of elif-block if successful, nil otherwise"]

	   ["Beginning of else block" gd-beginning-of-else-block
	    :help " `gd-beginning-of-else-block'
Go to beginning else-block, skip whitespace at BOL.

Returns beginning of else-block if successful, nil otherwise"]

	   ["Beginning of except block" gd-beginning-of-except-block
	    :help " `gd-beginning-of-except-block'
Go to beginning except-block, skip whitespace at BOL.

Returns beginning of except-block if successful, nil otherwise"]

	   ["Beginning of expression" gd-beginning-of-expression
	    :help " `gd-beginning-of-expression'
Go to the beginning of a compound python expression.

With numeric ARG do it that many times.

A a compound python expression might be concatenated by \".\" operator, thus composed by minor python expressions.

If already at the beginning or before a expression, go to next expression in buffer upwards

Expression here is conceived as the syntactical component of a statement in GDScript. See http://docs.python.org/reference
Operators however are left aside resp. limit gd-expression designed for edit-purposes."]

	   ["Beginning of if block" gd-beginning-of-if-block
	    :help " `gd-beginning-of-if-block'
Go to beginning if-block, skip whitespace at BOL.

Returns beginning of if-block if successful, nil otherwise"]

	   ["Beginning of partial expression" gd-beginning-of-partial-expression
	    :help " `gd-beginning-of-partial-expression'"]

	   ["Beginning of statement" gd-beginning-of-statement
	    :help " `gd-beginning-of-statement'
Go to the initial line of a simple statement.

For beginning of compound statement use gd-beginning-of-block.
For beginning of clause gd-beginning-of-clause."]

	   ["Beginning of top level" gd-beginning-of-top-level
	    :help " `gd-beginning-of-top-level'
Go up to beginning of statments until level of indentation is null.

Returns position if successful, nil otherwise"]

	   ["Beginning of try block" gd-beginning-of-try-block
	    :help " `gd-beginning-of-try-block'
Go to beginning try-block, skip whitespace at BOL.

Returns beginning of try-block if successful, nil otherwise"]
           )
          ("Forward"
	   ["End of block" gd-end-of-block
	    :help " `gd-end-of-block'
Go to end of block.

Returns end of block if successful, nil otherwise"]

	   ["End of block or clause" gd-end-of-block-or-clause
	    :help " `gd-end-of-block-or-clause'
Go to end of block-or-clause.

Returns end of block-or-clause if successful, nil otherwise"]

	   ["End of class" gd-end-of-class
	    :help " `gd-end-of-class'
Go to end of class.

Returns end of class if successful, nil otherwise"]

	   ["End of clause" gd-end-of-clause
	    :help " `gd-end-of-clause'
Go to end of clause.

Returns end of clause if successful, nil otherwise"]

	   ["End of def" gd-end-of-def
	    :help " `gd-end-of-def'
Go to end of def.

Returns end of def if successful, nil otherwise"]

	   ["End of def or class" gd-end-of-def-or-class
	    :help " `gd-end-of-def-or-class'
Go to end of def-or-class.

Returns end of def-or-class if successful, nil otherwise"]

	   ["End of elif block" gd-end-of-elif-block
	    :help " `gd-end-of-elif-block'
Go to end of elif-block.

Returns end of elif-block if successful, nil otherwise"]

	   ["End of else block" gd-end-of-else-block
	    :help " `gd-end-of-else-block'
Go to end of else-block.

Returns end of else-block if successful, nil otherwise"]

	   ["End of except block" gd-end-of-except-block
	    :help " `gd-end-of-except-block'
Go to end of except-block.

Returns end of except-block if successful, nil otherwise"]

	   ["End of expression" gd-end-of-expression
	    :help " `gd-end-of-expression'
Go to the end of a compound python expression.

With numeric ARG do it that many times.

A a compound python expression might be concatenated by \".\" operator, thus composed by minor python expressions.

Expression here is conceived as the syntactical component of a statement in GDScript. See http://docs.python.org/reference

Operators however are left aside resp. limit gd-expression designed for edit-purposes."]

	   ["End of if block" gd-end-of-if-block
	    :help " `gd-end-of-if-block'
Go to end of if-block.

Returns end of if-block if successful, nil otherwise"]

	   ["End of partial expression" gd-end-of-partial-expression
	    :help " `gd-end-of-partial-expression'"]

	   ["End of statement" gd-end-of-statement
	    :help " `gd-end-of-statement'
Go to the last char of current statement.

Optional argument REPEAT, the number of loops done already, is checked for gd-max-specpdl-size error. Avoid eternal loops due to missing string delimters etc."]

	   ["End of top level" gd-end-of-top-level
	    :help " `gd-end-of-top-level'
Go to end of top-level form at point.

Returns position if successful, nil otherwise"]

	   ["End of try block" gd-end-of-try-block
	    :help " `gd-end-of-try-block'
Go to end of try-block.

Returns end of try-block if successful, nil otherwise"]
           )
          ("BOL-forms"
           ("Backward"
	    ["Beginning of block bol" gd-beginning-of-block-bol
	     :help " `gd-beginning-of-block-bol'
Go to beginning block, go to BOL.

Returns beginning of block if successful, nil otherwise"]

	    ["Beginning of block or clause bol" gd-beginning-of-block-or-clause-bol
	     :help " `gd-beginning-of-block-or-clause-bol'
Go to beginning block-or-clause, go to BOL.

Returns beginning of block-or-clause if successful, nil otherwise"]

	    ["Beginning of class bol" gd-beginning-of-class-bol
	     :help " `gd-beginning-of-class-bol'
Go to beginning class, go to BOL.

Returns beginning of class if successful, nil otherwise

When `gd-mark-decorators' is non-nil, decorators are considered too."]

	    ["Beginning of clause bol" gd-beginning-of-clause-bol
	     :help " `gd-beginning-of-clause-bol'
Go to beginning clause, go to BOL.

Returns beginning of clause if successful, nil otherwise"]

	    ["Beginning of def bol" gd-beginning-of-def-bol
	     :help " `gd-beginning-of-def-bol'
Go to beginning def, go to BOL.

Returns beginning of def if successful, nil otherwise

When `gd-mark-decorators' is non-nil, decorators are considered too."]

	    ["Beginning of def or class bol" gd-beginning-of-def-or-class-bol
	     :help " `gd-beginning-of-def-or-class-bol'
Go to beginning def-or-class, go to BOL.

Returns beginning of def-or-class if successful, nil otherwise

When `gd-mark-decorators' is non-nil, decorators are considered too."]

	    ["Beginning of elif block bol" gd-beginning-of-elif-block-bol
	     :help " `gd-beginning-of-elif-block-bol'
Go to beginning elif-block, go to BOL.

Returns beginning of elif-block if successful, nil otherwise"]

	    ["Beginning of else block bol" gd-beginning-of-else-block-bol
	     :help " `gd-beginning-of-else-block-bol'
Go to beginning else-block, go to BOL.

Returns beginning of else-block if successful, nil otherwise"]

	    ["Beginning of except block bol" gd-beginning-of-except-block-bol
	     :help " `gd-beginning-of-except-block-bol'
Go to beginning except-block, go to BOL.

Returns beginning of except-block if successful, nil otherwise"]

	    ["Beginning of expression bol" gd-beginning-of-expression-bol
	     :help " `gd-beginning-of-expression-bol'"]

	    ["Beginning of if block bol" gd-beginning-of-if-block-bol
	     :help " `gd-beginning-of-if-block-bol'
Go to beginning if-block, go to BOL.

Returns beginning of if-block if successful, nil otherwise"]

	    ["Beginning of partial expression bol" gd-beginning-of-partial-expression-bol
	     :help " `gd-beginning-of-partial-expression-bol'"]

	    ["Beginning of statement bol" gd-beginning-of-statement-bol
	     :help " `gd-beginning-of-statement-bol'
Goto beginning of line where statement starts.
  Returns position reached, if successful, nil otherwise.

See also `gd-up-statement': up from current definition to next beginning of statement above."]

	    ["Beginning of try block bol" gd-beginning-of-try-block-bol
	     :help " `gd-beginning-of-try-block-bol'
Go to beginning try-block, go to BOL.

Returns beginning of try-block if successful, nil otherwise"]
            )
           ("Forward"
	    ["End of block bol" gd-end-of-block-bol
	     :help " `gd-end-of-block-bol'
Goto beginning of line following end of block.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-block': down from current definition to next beginning of block below."]

	    ["End of block or clause bol" gd-end-of-block-or-clause-bol
	     :help " `gd-end-of-block-or-clause-bol'
Goto beginning of line following end of block-or-clause.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-block-or-clause': down from current definition to next beginning of block-or-clause below."]

	    ["End of class bol" gd-end-of-class-bol
	     :help " `gd-end-of-class-bol'
Goto beginning of line following end of class.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-class': down from current definition to next beginning of class below."]

	    ["End of clause bol" gd-end-of-clause-bol
	     :help " `gd-end-of-clause-bol'
Goto beginning of line following end of clause.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-clause': down from current definition to next beginning of clause below."]

	    ["End of def bol" gd-end-of-def-bol
	     :help " `gd-end-of-def-bol'
Goto beginning of line following end of def.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-def': down from current definition to next beginning of def below."]

	    ["End of def or class bol" gd-end-of-def-or-class-bol
	     :help " `gd-end-of-def-or-class-bol'
Goto beginning of line following end of def-or-class.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-def-or-class': down from current definition to next beginning of def-or-class below."]

	    ["End of elif block bol" gd-end-of-elif-block-bol
	     :help " `gd-end-of-elif-block-bol'
Goto beginning of line following end of elif-block.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-elif-block': down from current definition to next beginning of elif-block below."]

	    ["End of else block bol" gd-end-of-else-block-bol
	     :help " `gd-end-of-else-block-bol'
Goto beginning of line following end of else-block.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-else-block': down from current definition to next beginning of else-block below."]

	    ["End of except block bol" gd-end-of-except-block-bol
	     :help " `gd-end-of-except-block-bol'
Goto beginning of line following end of except-block.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-except-block': down from current definition to next beginning of except-block below."]

	    ["End of expression bol" gd-end-of-expression-bol
	     :help " `gd-end-of-expression-bol'"]

	    ["End of if block bol" gd-end-of-if-block-bol
	     :help " `gd-end-of-if-block-bol'
Goto beginning of line following end of if-block.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-if-block': down from current definition to next beginning of if-block below."]

	    ["End of partial expression bol" gd-end-of-partial-expression-bol
	     :help " `gd-end-of-partial-expression-bol'"]

	    ["End of statement bol" gd-end-of-statement-bol
	     :help " `gd-end-of-statement-bol'
Go to the beginning-of-line following current statement."]

	    ["End of top level bol" gd-end-of-top-level-bol
	     :help " `gd-end-of-top-level-bol'
Go to end of top-level form at point, stop at next beginning-of-line.

Returns position successful, nil otherwise"]

	    ["End of try block bol" gd-end-of-try-block-bol
	     :help " `gd-end-of-try-block-bol'
Goto beginning of line following end of try-block.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-try-block': down from current definition to next beginning of try-block below."]
            ))
          ("Up/Down"
	   ["Up" gd-up
	    :help " `gd-up'
Go up or to beginning of form if inside.

If inside a delimited form --string or list-- go to its beginning.
If not at beginning of a statement or block, go to its beginning.
If at beginning of a statement or block, go to beginning one level above of compound statement or definition at point."]

	   ["Down" gd-down
	    :help " `gd-down'
Go to beginning one level below of compound statement or definition at point.

If no statement or block below, but a delimited form --string or list-- go to its beginning. Repeated call from there will behave like down-list.

Returns position if successful, nil otherwise"]
           ))
         ("Hide-Show"
          ("Hide"
	   ["Hide region" gd-hide-region
	    :help " `gd-hide-region'
Hide active region."]

	   ["Hide statement" gd-hide-statement
	    :help " `gd-hide-statement'
Hide statement at point."]

	   ["Hide block" gd-hide-block
	    :help " `gd-hide-block'
Hide block at point."]

	   ["Hide clause" gd-hide-clause
	    :help " `gd-hide-clause'
Hide clause at point."]

	   ["Hide block or clause" gd-hide-block-or-clause
	    :help " `gd-hide-block-or-clause'
Hide block-or-clause at point."]

	   ["Hide def" gd-hide-def
	    :help " `gd-hide-def'
Hide def at point."]

	   ["Hide class" gd-hide-class
	    :help " `gd-hide-class'
Hide class at point."]

	   ["Hide expression" gd-hide-expression
	    :help " `gd-hide-expression'
Hide expression at point."]

	   ["Hide partial expression" gd-hide-partial-expression
	    :help " `gd-hide-partial-expression'
Hide partial-expression at point."]

	   ["Hide line" gd-hide-line
	    :help " `gd-hide-line'
Hide line at point."]

	   ["Hide top level" gd-hide-top-level
	    :help " `gd-hide-top-level'
Hide top-level at point."]
           )
          ("Show"
	   ["Show region" gd-show-region
	    :help " `gd-show-region'
Un-hide active region."]

	   ["Show statement" gd-show-statement
	    :help " `gd-show-statement'
Show statement at point."]

	   ["Show block" gd-show-block
	    :help " `gd-show-block'
Show block at point."]

	   ["Show clause" gd-show-clause
	    :help " `gd-show-clause'
Show clause at point."]

	   ["Show block or clause" gd-show-block-or-clause
	    :help " `gd-show-block-or-clause'
Show block-or-clause at point."]

	   ["Show def" gd-show-def
	    :help " `gd-show-def'
Show def at point."]

	   ["Show class" gd-show-class
	    :help " `gd-show-class'
Show class at point."]

	   ["Show expression" gd-show-expression
	    :help " `gd-show-expression'
Show expression at point."]

	   ["Show partial expression" gd-show-partial-expression
	    :help " `gd-show-partial-expression'
Show partial-expression at point."]

	   ["Show line" gd-show-line
	    :help " `gd-show-line'
Show line at point."]

	   ["Show top level" gd-show-top-level
	    :help " `gd-show-top-level'
Show top-level at point."]
           ))
         ("Virtualenv"
          ["Virtualenv activate" virtualenv-activate
	   :help " `virtualenv-activate'
Activate the virtualenv located in DIR"]

          ["Virtualenv deactivate" virtualenv-deactivate
	   :help " `virtualenv-deactivate'
Deactivate the current virtual enviroment"]

          ["Virtualenv p" virtualenv-p
	   :help " `virtualenv-p'
Check if a directory is a virtualenv"]

          ["Virtualenv workon" virtualenv-workon
	   :help " `virtualenv-workon'
Issue a virtualenvwrapper-like virtualenv-workon command"]
          )
         ("Help"
          ["Find definition" gd-find-definition
	   :help " `gd-find-definition'
Find source of definition of SYMBOL.

Interactively, prompt for SYMBOL."]

          ["Help at point" gd-help-at-point
	   :help " `gd-help-at-point'
Print help on symbol at point.

If symbol is defined in current buffer, jump to it's definition
Optional C-u used for debugging, will prevent deletion of temp file."]

          ["Info lookup symbol" gd-info-lookup-symbol
	   :help " `gd-info-lookup-symbol'"]

          ["Symbol at point" gd-symbol-at-point
	   :help " `gd-symbol-at-point'
Return the current GDScript symbol."]
          )
         ("Customize"

	  ["GDScript-mode customize group" (customize-group 'gdscript-mode)
	   :help "Open the customization buffer for GDScript mode"]
	  ("Switches"
	   :help "Toggle useful modes like `highlight-indentation'"
	   ("Interpreter"

	    ["Shell prompt read only"
	     (setq gd-shell-prompt-read-only
		   (not gd-shell-prompt-read-only))
	     :help "If non-nil, the python prompt is read only.  Setting this variable will only effect new shells.Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-shell-prompt-read-only]

	    ["Remove cwd from path"
	     (setq gd-remove-cwd-from-path
		   (not gd-remove-cwd-from-path))
	     :help "Whether to allow loading of GDScript modules from the current directory.
If this is non-nil, Emacs removes '' from sys.path when starting
a GDScript process.  This is the default, for security
reasons, as it is easy for the GDScript process to be started
without the user's realization (e.g. to perform completion).Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-remove-cwd-from-path]

	    ["Honor IPYTHONDIR "
	     (setq gd-honor-IPYTHONDIR-p
		   (not gd-honor-IPYTHONDIR-p))
	     :help "When non-nil ipython-history file is constructed by \$IPYTHONDIR
followed by "/history". Default is nil.

Otherwise value of gd-ipython-history is used. Use `M-x customize-variable' to set it permanently"
:style toggle :selected gd-honor-IPYTHONDIR-p]

	    ["Honor PYTHONHISTORY "
	     (setq gd-honor-PYTHONHISTORY-p
		   (not gd-honor-PYTHONHISTORY-p))
	     :help "When non-nil gdscript-history file is set by \$PYTHONHISTORY
Default is nil.

Otherwise value of gd-gdscript-history is used. Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-honor-PYTHONHISTORY-p]

	    ["Enforce gd-shell-name" force-gd-shell-name-p-on
	     :help "Enforce customized default `gd-shell-name' should upon execution. "]

	    ["Don't enforce default interpreter" force-gd-shell-name-p-off
	     :help "Make execute commands guess interpreter from environment"]

	    ["Enforce local GDScript shell " gd-force-local-shell-on
	     :help "Locally indicated GDScript being enforced upon sessions execute commands. "]

	    ["Remove local GDScript shell enforcement, restore default" gd-force-local-shell-off
	     :help "Restore `gd-shell-name' default value and `behaviour'. "])

	   ("Execute"

	    ["Fast process" gd-fast-process-p
	     :help " `gd-fast-process-p'

Use `gd-fast-process'\.

Commands prefixed \"gd-fast-...\" suitable for large output

See: large output makes Emacs freeze, lp:1253907

Output-buffer is not in comint-mode"
	     :style toggle :selected gd-fast-process-p]

	    ["GDScript mode v5 behavior"
	     (setq gdscript-mode-v5-behavior-p
		   (not gdscript-mode-v5-behavior-p))
	     :help "Execute region through `shell-command-on-region' as
v5 did it - lp:990079. This might fail with certain chars - see UnicodeEncodeError lp:550661

Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gdscript-mode-v5-behavior-p]

	    ["Force shell name "
	     (setq gd-force-gd-shell-name-p
		   (not gd-force-gd-shell-name-p))
	     :help "When `t', execution with kind of GDScript specified in `gd-shell-name' is enforced, possibly shebang doesn't take precedence. Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-force-gd-shell-name-p]

	    ["Execute \"if name == main\" blocks p"
	     (setq gd-if-name-main-permission-p
		   (not gd-if-name-main-permission-p))
	     :help " `gd-if-name-main-permission-p'

Allow execution of code inside blocks delimited by
if __name__ == '__main__'

Default is non-nil. "
	     :style toggle :selected gd-if-name-main-permission-p]

	    ["Ask about save"
	     (setq gd-ask-about-save
		   (not gd-ask-about-save))
	     :help "If not nil, ask about which buffers to save before executing some code.
Otherwise, all modified buffers are saved without asking.Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-ask-about-save]

	    ["Store result"
	     (setq gd-store-result-p
		   (not gd-store-result-p))
	     :help " `gd-store-result-p'

When non-nil, put resulting string of `gd-execute-...' into kill-ring, so it might be yanked. "
	     :style toggle :selected gd-store-result-p]

	    ["Prompt on changed "
	     (setq gd-prompt-on-changed-p
		   (not gd-prompt-on-changed-p))
	     :help "When called interactively, ask for save before a changed buffer is sent to interpreter.

Default is `t'Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-prompt-on-changed-p]

	    ["Dedicated process "
	     (setq gd-dedicated-process-p
		   (not gd-dedicated-process-p))
	     :help "If commands executing code use a dedicated shell.

Default is nilUse `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-dedicated-process-p]

	    ["Execute without temporary file"
	     (setq gd-execute-no-temp-p
		   (not gd-execute-no-temp-p))
	     :help " `gd-execute-no-temp-p'
Seems Emacs-24.3 provided a way executing stuff without temporary files.
In experimental state yet "
	     :style toggle :selected gd-execute-no-temp-p]

	    ["Warn tmp files left "
	     (setq py--warn-tmp-files-left-p
		   (not py--warn-tmp-files-left-p))
	     :help "Messages a warning, when `gd-temp-directory' contains files susceptible being left by previous GDScript-mode sessions. See also lp:987534 Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected py--warn-tmp-files-left-p])

	   ("Edit"

	    ("Completion"

	     ["Set Pymacs-based complete keymap "
	      (setq gd-set-complete-keymap-p
		    (not gd-set-complete-keymap-p))
	      :help "If `gd-complete-initialize', which sets up enviroment for Pymacs based gd-complete, should load it's keys into `gdscript-mode-map'

Default is nil.
See also resp. edit `gd-complete-set-keymap' Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-set-complete-keymap-p]

	     ["Indent no completion "
	      (setq gd-indent-no-completion-p
		    (not gd-indent-no-completion-p))
	      :help "If completion function should indent when no completion found. Default is `t'

Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-indent-no-completion-p]

	     ["Company pycomplete "
	      (setq gd-company-pycomplete-p
		    (not gd-company-pycomplete-p))
	      :help "Load company-pycomplete stuff. Default is nilUse `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-company-pycomplete-p])

	    ("Filling"

	     ("Docstring styles"
	      :help "Switch docstring-style"

	      ["Nil" gd-set-nil-docstring-style
	       :help " `gd-set-nil-docstring-style'

Set gd-docstring-style to nil, format string normally. "]

	      ["pep-257-nn" gd-set-pep-257-nn-docstring-style
	       :help " `gd-set-pep-257-nn-docstring-style'

Set gd-docstring-style to 'pep-257-nn "]

	      ["pep-257" gd-set-pep-257-docstring-style
	       :help " `gd-set-pep-257-docstring-style'

Set gd-docstring-style to 'pep-257 "]

	      ["django" gd-set-django-docstring-style
	       :help " `gd-set-django-docstring-style'

Set gd-docstring-style to 'django "]

	      ["onetwo" gd-set-onetwo-docstring-style
	       :help " `gd-set-onetwo-docstring-style'

Set gd-docstring-style to 'onetwo "]

	      ["symmetric" gd-set-symmetric-docstring-style
	       :help " `gd-set-symmetric-docstring-style'

Set gd-docstring-style to 'symmetric "])

	     ["Auto-fill mode"
	      (setq gd-auto-fill-mode
		    (not gd-auto-fill-mode))
	      :help "Fill according to `gd-docstring-fill-column' and `gd-comment-fill-column'

Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-auto-fill-mode])

	    ["Use current dir when execute"
	     (setq gd-use-current-dir-when-execute-p
		   (not gd-use-current-dir-when-execute-p))
	     :help " `toggle-gd-use-current-dir-when-execute-p'

Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-use-current-dir-when-execute-p]

	    ("Indent"
	     ("TAB related"

	      ["indent-tabs-mode"
	       (setq indent-tabs-mode
		     (not indent-tabs-mode))
	       :help "Indentation can insert tabs if this is non-nil.

Use `M-x customize-variable' to set it permanently"
	       :style toggle :selected indent-tabs-mode]

	      ["Tab indent"
	       (setq gd-tab-indent
		     (not gd-tab-indent))
	       :help "Non-nil means TAB in GDScript mode calls `gd-indent-line'.Use `M-x customize-variable' to set it permanently"
	       :style toggle :selected gd-tab-indent]

	      ["Tab shifts region "
	       (setq gd-tab-shifts-region-p
		     (not gd-tab-shifts-region-p))
	       :help "If `t', TAB will indent/cycle the region, not just the current line.

Default is nil
See also `gd-tab-indents-region-p'

Use `M-x customize-variable' to set it permanently"
	       :style toggle :selected gd-tab-shifts-region-p]

	      ["Tab indents region "
	       (setq gd-tab-indents-region-p
		     (not gd-tab-indents-region-p))
	       :help "When `t' and first TAB doesn't shift, indent-region is called.

Default is nil
See also `gd-tab-shifts-region-p'

Use `M-x customize-variable' to set it permanently"
	       :style toggle :selected gd-tab-indents-region-p])

	     ["Close at start column"
	      (setq gd-closing-list-dedents-bos
		    (not gd-closing-list-dedents-bos))
	      :help "When non-nil, indent list's closing delimiter like start-column.

It will be lined up under the first character of
 the line that starts the multi-line construct, as in:

my_list = \[
    1, 2, 3,
    4, 5, 6,
]

Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-closing-list-dedents-bos]

	     ["Closing list keeps space"
	      (setq gd-closing-list-keeps-space
		    (not gd-closing-list-keeps-space))
	      :help "If non-nil, closing parenthesis dedents onto column of opening plus `gd-closing-list-space', default is nil Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-closing-list-keeps-space]

	     ["Closing list space"
	      (setq gd-closing-list-space
		    (not gd-closing-list-space))
	      :help "Number of chars, closing parenthesis outdent from opening, default is 1 Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-closing-list-space]

	     ["Tab shifts region "
	      (setq gd-tab-shifts-region-p
		    (not gd-tab-shifts-region-p))
	      :help "If `t', TAB will indent/cycle the region, not just the current line.

Default is nil
See also `gd-tab-indents-region-p'Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-tab-shifts-region-p]

	     ["Lhs inbound indent"
	      (setq gd-lhs-inbound-indent
		    (not gd-lhs-inbound-indent))
	      :help "When line starts a multiline-assignment: How many colums indent should be more than opening bracket, brace or parenthesis. Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-lhs-inbound-indent]

	     ["Continuation offset"
	      (setq gd-continuation-offset
		    (not gd-continuation-offset))
	      :help "With numeric ARG different from 1 gd-continuation-offset is set to that value; returns gd-continuation-offset. Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-continuation-offset]

	     ["Electric colon"
	      (setq gd-electric-colon-active-p
		    (not gd-electric-colon-active-p))
	      :help " `gd-electric-colon-active-p'

`gd-electric-colon' feature.  Default is `nil'. See lp:837065 for discussions. "
	      :style toggle :selected gd-electric-colon-active-p]

	     ["Electric colon at beginning of block only"
	      (setq gd-electric-colon-bobl-only
		    (not gd-electric-colon-bobl-only))
	      :help "When inserting a colon, do not indent lines unless at beginning of block.

Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-electric-colon-bobl-only]

	     ["Electric yank active "
	      (setq gd-electric-yank-active-p
		    (not gd-electric-yank-active-p))
	      :help " When non-nil, `yank' will be followed by an `indent-according-to-mode'.

Default is nilUse `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-electric-yank-active-p]

	     ["Electric kill backward "
	      (setq gd-electric-kill-backward-p
		    (not gd-electric-kill-backward-p))
	      :help "Affects `gd-electric-backspace'. Default is nil.

If behind a delimited form of braces, brackets or parentheses,
backspace will kill it's contents

With when cursor after
my_string\[0:1]
--------------^

==>

my_string\[]
----------^

In result cursor is insided emptied delimited form.Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-electric-kill-backward-p]

	     ["Trailing whitespace smart delete "
	      (setq gd-trailing-whitespace-smart-delete-p
		    (not gd-trailing-whitespace-smart-delete-p))
	      :help "Default is nil. When t, gdscript-mode calls
    (add-hook 'before-save-hook 'delete-trailing-whitespace nil 'local)

Also commands may delete trailing whitespace by the way.
When editing other peoples code, this may produce a larger diff than expected Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-trailing-whitespace-smart-delete-p]

	     ["Newline delete trailing whitespace "
	      (setq gd-newline-delete-trailing-whitespace-p
		    (not gd-newline-delete-trailing-whitespace-p))
	      :help "Delete trailing whitespace maybe left by `gd-newline-and-indent'.

Default is `t'. See lp:1100892 Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-newline-delete-trailing-whitespace-p]

	     ["Dedent keep relative column"
	      (setq gd-dedent-keep-relative-column
		    (not gd-dedent-keep-relative-column))
	      :help "If point should follow dedent or kind of electric move to end of line. Default is t - keep relative position. Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-dedent-keep-relative-column]

	     ["Indent paren spanned multilines "
	      (setq gd-indent-paren-spanned-multilines-p
		    (not gd-indent-paren-spanned-multilines-p))
	      :help "If non-nil, indents elements of list a value of `gd-indent-offset' to first element:

def foo():
    if (foo &&
            baz):
        bar()

Default lines up with first element:

def foo():
    if (foo &&
        baz):
        bar()
Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-indent-paren-spanned-multilines-p]

	     ["Indent honors multiline listing"
	      (setq gd-indent-honors-multiline-listing
		    (not gd-indent-honors-multiline-listing))
	      :help "If `t', indents to 1\+ column of opening delimiter. If `nil', indent adds one level to the beginning of statement. Default is `nil'. Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-indent-honors-multiline-listing]

	     ["Indent comment "
	      (setq gd-indent-comments
		    (not gd-indent-comments))
	      :help "If comments should be indented like code. Default is `nil'.

Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-indent-comments]

	     ["Uncomment indents "
	      (setq gd-uncomment-indents-p
		    (not gd-uncomment-indents-p))
	      :help "When non-nil, after uncomment indent lines. Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-uncomment-indents-p]

	     ["Indent honors inline comment"
	      (setq gd-indent-honors-inline-comment
		    (not gd-indent-honors-inline-comment))
	      :help "If non-nil, indents to column of inlined comment start.
Default is nil. Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-indent-honors-inline-comment]

	     ["Kill empty line"
	      (setq gd-kill-empty-line
		    (not gd-kill-empty-line))
	      :help "If t, gd-indent-forward-line kills empty lines. Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-kill-empty-line]

	     ("Smart indentation"
	      :help "Toggle gd-smart-indentation'

Use `M-x customize-variable' to set it permanently"

	      ["Toggle gd-smart-indentation" toggle-gd-smart-indentation
	       :help "Toggles gd-smart-indentation

Use `M-x customize-variable' to set it permanently"]

	      ["gd-smart-indentation on" gd-smart-indentation-on
	       :help "Switches gd-smart-indentation on

Use `M-x customize-variable' to set it permanently"]

	      ["gd-smart-indentation off" gd-smart-indentation-off
	       :help "Switches gd-smart-indentation off

Use `M-x customize-variable' to set it permanently"])

	     ["Beep if tab change"
	      (setq gd-beep-if-tab-change
		    (not gd-beep-if-tab-change))
	      :help "Ring the bell if `tab-width' is changed.
If a comment of the form

                           	# vi:set tabsize=<number>:

is found before the first code line when the file is entered, and the
current value of (the general Emacs variable) `tab-width' does not
equal <number>, `tab-width' is set to <number>, a message saying so is
displayed in the echo area, and if `gd-beep-if-tab-change' is non-nil
the Emacs bell is also rung as a warning.Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-beep-if-tab-change]

	     ["Highlight indentation" highlight-indentation
	      :help "Toggle highlight indentation.

Use `M-x customize-variable' to set it permanently

Make sure `highlight-indentation' is installed"

	      ]

	     ["Electric comment "
	      (setq gd-electric-comment-p
		    (not gd-electric-comment-p))
	      :help "If \"#\" should call `gd-electric-comment'. Default is `nil'.

Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-electric-comment-p]

	     ["Electric comment add space "
	      (setq gd-electric-comment-add-space-p
		    (not gd-electric-comment-add-space-p))
	      :help "If gd-electric-comment should add a space.  Default is `nil'. Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-electric-comment-add-space-p]

	     ["Empty line closes "
	      (setq gd-empty-line-closes-p
		    (not gd-empty-line-closes-p))
	      :help "When non-nil, dedent after empty line following block

if True:
    print(\"Part of the if-statement\")

print(\"Not part of the if-statement\")

Default is nil

If non-nil, a C-j from empty line dedents.
Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-empty-line-closes-p])
	    ["Defun use top level "
	     (setq gd-defun-use-top-level-p
		   (not gd-defun-use-top-level-p))
	     :help "When non-nil, keys C-M-a, C-M-e address top-level form.

Beginning- end-of-defun forms use
commands `gd-beginning-of-top-level', `gd-end-of-top-level'

mark-defun marks top-level form at point etc. "
	     :style toggle :selected gd-defun-use-top-level-p]

	    ["Close provides newline"
	     (setq gd-close-provides-newline
		   (not gd-close-provides-newline))
	     :help "If a newline is inserted, when line after block isn't empty. Default is non-nil. Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-close-provides-newline]

	    ["Block comment prefix "
	     (setq gd-block-comment-prefix-p
		   (not gd-block-comment-prefix-p))
	     :help "If gd-comment inserts gd-block-comment-prefix.

Default is tUse `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-block-comment-prefix-p])

	   ("Display"

	    ("Index"

	     ["Imenu create index "
	      (setq py--imenu-create-index-p
		    (not py--imenu-create-index-p))
	      :help "Non-nil means GDScript mode creates and displays an index menu of functions and global variables. Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected py--imenu-create-index-p]

	     ["Imenu show method args "
	      (setq gd-imenu-show-method-args-p
		    (not gd-imenu-show-method-args-p))
	      :help "Controls echoing of arguments of functions & methods in the Imenu buffer.
When non-nil, arguments are printed.Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-imenu-show-method-args-p]
	     ["Switch index-function" gd-switch-imenu-index-function
	      :help "`gd-switch-imenu-index-function'
Switch between `py--imenu-create-index' from 5.1 series and `py--imenu-create-index-new'."])

	    ("Fontification"

	     ["Mark decorators"
	      (setq gd-mark-decorators
		    (not gd-mark-decorators))
	      :help "If gd-mark-def-or-class functions should mark decorators too. Default is `nil'. Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-mark-decorators]

	     ["Fontify shell buffer "
	      (setq gd-fontify-shell-buffer-p
		    (not gd-fontify-shell-buffer-p))
	      :help "If code in GDScript shell should be highlighted as in script buffer.

Default is nil.

If `t', related vars like `comment-start' will be set too.
Seems convenient when playing with stuff in IPython shell
Might not be TRT when a lot of output arrives Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-fontify-shell-buffer-p]

	     ["Use font lock doc face "
	      (setq gd-use-font-lock-doc-face-p
		    (not gd-use-font-lock-doc-face-p))
	      :help "If documention string inside of def or class get `font-lock-doc-face'.

`font-lock-doc-face' inherits `font-lock-string-face'.

Call M-x `customize-face' in order to have a visible effect. Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-use-font-lock-doc-face-p])

	    ["Switch buffers on execute"
	     (setq gd-switch-buffers-on-execute-p
		   (not gd-switch-buffers-on-execute-p))
	     :help "When non-nil switch to the GDScript output buffer.

Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-switch-buffers-on-execute-p]

	    ["Split windows on execute"
	     (setq gd-split-window-on-execute
		   (not gd-split-window-on-execute))
	     :help "When non-nil split windows.

Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-split-window-on-execute]

	    ["Keep windows configuration"
	     (setq gd-keep-windows-configuration
		   (not gd-keep-windows-configuration))
	     :help "If a windows is splitted displaying results, this is directed by variable `gd-split-window-on-execute'\. Also setting `gd-switch-buffers-on-execute-p' affects window-configuration\. While commonly a screen splitted into source and GDScript-shell buffer is assumed, user may want to keep a different config\.

Setting `gd-keep-windows-configuration' to `t' will restore windows-config regardless of settings mentioned above\. However, if an error occurs, it's displayed\.

To suppres window-changes due to error-signaling also: M-x customize-variable RET. Set `gd-keep-4windows-configuration' onto 'force

Default is nil Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-keep-windows-configuration]

	    ["Which split windows on execute function"
	     (progn
	       (if (eq 'split-window-vertically gd-split-windows-on-execute-function)
		   (setq gd-split-windows-on-execute-function'split-window-horizontally)
		 (setq gd-split-windows-on-execute-function 'split-window-vertically))
	       (message "gd-split-windows-on-execute-function set to: %s" gd-split-windows-on-execute-function))

	     :help "If `split-window-vertically' or `...-horizontally'. Use `M-x customize-variable' RET `gd-split-windows-on-execute-function' RET to set it permanently"
	     :style toggle :selected gd-split-windows-on-execute-function]

	    ["Modeline display full path "
	     (setq gd-modeline-display-full-path-p
		   (not gd-modeline-display-full-path-p))
	     :help "If the full PATH/TO/PYTHON should be displayed in shell modeline.

Default is nil. Note: when `gd-shell-name' is specified with path, it's shown as an acronym in buffer-name already. Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-modeline-display-full-path-p]

	    ["Modeline acronym display home "
	     (setq gd-modeline-acronym-display-home-p
		   (not gd-modeline-acronym-display-home-p))
	     :help "If the modeline acronym should contain chars indicating the home-directory.

Default is nil Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-modeline-acronym-display-home-p]

	    ["Hide show hide docstrings"
	     (setq gd-hide-show-hide-docstrings
		   (not gd-hide-show-hide-docstrings))
	     :help "Controls if doc strings can be hidden by hide-showUse `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-hide-show-hide-docstrings]

	    ["Hide comments when hiding all"
	     (setq gd-hide-comments-when-hiding-all
		   (not gd-hide-comments-when-hiding-all))
	     :help "Hide the comments too when you do `hs-hide-all'. Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-hide-comments-when-hiding-all]

	    ["Max help buffer "
	     (setq gd-max-help-buffer-p
		   (not gd-max-help-buffer-p))
	     :help "If \"\*GDScript-Help\*\"-buffer should appear as the only visible.

Default is nil. In help-buffer, \"q\" will close it.  Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-max-help-buffer-p]

	    ["Current defun show"
	     (setq gd-current-defun-show
		   (not gd-current-defun-show))
	     :help "If `gd-current-defun' should jump to the definition, highlight it while waiting PY-WHICH-FUNC-DELAY seconds, before returning to previous position.

Default is `t'.Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-current-defun-show]

	    ["Match paren mode"
	     (setq gd-match-paren-mode
		   (not gd-match-paren-mode))
	     :help "Non-nil means, cursor will jump to beginning or end of a block.
This vice versa, to beginning first.
Sets `gd-match-paren-key' in gdscript-mode-map.
Customize `gd-match-paren-key' which key to use. Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-match-paren-mode])

	   ("Debug"

	    ["gd-debug-p"
	     (setq gd-debug-p
		   (not gd-debug-p))
	     :help "When non-nil, keep resp\. store information useful for debugging\.

Temporary files are not deleted\. Other functions might implement
some logging etc\. Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-debug-p]

	    ["Pdbtrack do tracking "
	     (setq gd-pdbtrack-do-tracking-p
		   (not gd-pdbtrack-do-tracking-p))
	     :help "Controls whether the pdbtrack feature is enabled or not.
When non-nil, pdbtrack is enabled in all comint-based buffers,
e.g. shell buffers and the \*GDScript\* buffer.  When using pdb to debug a
GDScript program, pdbtrack notices the pdb prompt and displays the
source file and line that the program is stopped at, much the same way
as gud-mode does for debugging C programs with gdb.Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-pdbtrack-do-tracking-p]

	    ["Jump on exception"
	     (setq gd-jump-on-exception
		   (not gd-jump-on-exception))
	     :help "Jump to innermost exception frame in GDScript output buffer.
When this variable is non-nil and an exception occurs when running
GDScript code synchronously in a subprocess, jump immediately to the
source code of the innermost traceback frame.

Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-jump-on-exception]

	    ["Highlight error in source "
	     (setq gd-highlight-error-source-p
		   (not gd-highlight-error-source-p))
	     :help "Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-highlight-error-source-p])

	   ("Other"

	    ("Directory"

	     ["Guess install directory "
	      (setq gd-guess-gd-install-directory-p
		    (not gd-guess-gd-install-directory-p))
	      :help "If in cases, `gd-install-directory' isn't set,  `gd-set-load-path'should guess it from `buffer-file-name'. Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-guess-gd-install-directory-p]

	     ["Use local default"
	      (setq gd-use-local-default
		    (not gd-use-local-default))
	      :help "If `t', gd-shell will use `gd-shell-local-path' instead
of default GDScript.

Making switch between several virtualenv's easier,
                               `gdscript-mode' should deliver an installer, so named-shells pointing to virtualenv's will be available. Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-use-local-default]

	     ["Use current dir when execute "
	      (setq gd-use-current-dir-when-execute-p
		    (not gd-use-current-dir-when-execute-p))
	      :help "When `t', current directory is used by GDScript-shell for output of `gd-execute-buffer' and related commands.

See also `gd-execute-directory'Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-use-current-dir-when-execute-p]

	     ["Keep shell dir when execute "
	      (setq gd-keep-shell-dir-when-execute-p
		    (not gd-keep-shell-dir-when-execute-p))
	      :help "Don't change GDScript shell's current working directory when sending code.

See also `gd-execute-directory'Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-keep-shell-dir-when-execute-p]

	     ["Fileless buffer use default directory "
	      (setq gd-fileless-buffer-use-default-directory-p
		    (not gd-fileless-buffer-use-default-directory-p))
	      :help "When `gd-use-current-dir-when-execute-p' is non-nil and no buffer-file exists, value of `default-directory' sets current working directory of GDScript output shellUse `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-fileless-buffer-use-default-directory-p])

	    ("Underscore word syntax"
	     :help "Toggle `gd-underscore-word-syntax-p'"

	     ["Toggle underscore word syntax" toggle-gd-underscore-word-syntax-p
	      :help " `toggle-gd-underscore-word-syntax-p'

If `gd-underscore-word-syntax-p' should be on or off.

  Returns value of `gd-underscore-word-syntax-p' switched to. .

Use `M-x customize-variable' to set it permanently"]

	     ["Underscore word syntax on" gd-underscore-word-syntax-p-on
	      :help " `gd-underscore-word-syntax-p-on'

Make sure, gd-underscore-word-syntax-p' is on.

Returns value of `gd-underscore-word-syntax-p'. .

Use `M-x customize-variable' to set it permanently"]

	     ["Underscore word syntax off" gd-underscore-word-syntax-p-off
	      :help " `gd-underscore-word-syntax-p-off'

Make sure, `gd-underscore-word-syntax-p' is off.

Returns value of `gd-underscore-word-syntax-p'. .

Use `M-x customize-variable' to set it permanently"])

	    ["Load pymacs "
	     (setq gd-load-pymacs-p
		   (not gd-load-pymacs-p))
	     :help "If Pymacs related stuff should be loaded.

Default is nil.

Pymacs has been written by François Pinard and many others.
See original source: http://pymacs.progiciels-bpi.caUse `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-load-pymacs-p]

	    ["Verbose "
	     (setq gd-verbose-p
		   (not gd-verbose-p))
	     :help "If functions should report results.

Default is nil. Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-verbose-p]

	    ["Empty comment line separates paragraph "
	     (setq gd-empty-comment-line-separates-paragraph-p
		   (not gd-empty-comment-line-separates-paragraph-p))
	     :help "Consider paragraph start/end lines with nothing inside but comment sign.

Default is non-nilUse `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-empty-comment-line-separates-paragraph-p]

	    ["Org cycle "
	     (setq gd-org-cycle-p
		   (not gd-org-cycle-p))
	     :help "When non-nil, command `org-cycle' is available at shift-TAB, <backtab>

Default is nil. Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-org-cycle-p]

	    ["Set pager cat"
	     (setq gd-set-pager-cat-p
		   (not gd-set-pager-cat-p))
	     :help "If the shell environment variable \$PAGER should set to `cat'.

If `t', use `C-c C-r' to jump to beginning of output. Then scroll normally.

Avoids lp:783828, \"Terminal not fully functional\", for help('COMMAND') in gdscript-shell

When non-nil, imports module `os' Use `M-x customize-variable' to
set it permanently"
	     :style toggle :selected gd-set-pager-cat-p]

	    ["Edit only "
	     (setq gd-edit-only-p
		   (not gd-edit-only-p))
	     :help "When `t' `gdscript-mode' will not take resort nor check for installed GDScript executables. Default is nil.

See bug report at launchpad, lp:944093. Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd-edit-only-p])))
         ("Other"
          ["Boolswitch" gd-boolswitch
	   :help " `gd-boolswitch'
Edit the assignment of a boolean variable, revert them.

I.e. switch it from \"True\" to \"False\" and vice versa"]

          ["Empty out list backward" gd-empty-out-list-backward
	   :help " `gd-empty-out-list-backward'
Deletes all elements from list before point."]

          ["Kill buffer unconditional" gd-kill-buffer-unconditional
	   :help " `gd-kill-buffer-unconditional'
Kill buffer unconditional, kill buffer-process if existing."]

          ["Remove overlays at point" gd-remove-overlays-at-point
	   :help " `gd-remove-overlays-at-point'
Remove overlays as set when `gd-highlight-error-source-p' is non-nil."]
          ("Electric"
	   ["Complete electric comma" gd-complete-electric-comma
	    :help " `gd-complete-electric-comma'"]

	   ["Complete electric lparen" gd-complete-electric-lparen
	    :help " `gd-complete-electric-lparen'"]

	   ["Electric backspace" gd-electric-backspace
	    :help " `gd-electric-backspace'
Delete preceding character or level of indentation.

With ARG do that ARG times.
Returns column reached."]

	   ["Electric colon" gd-electric-colon
	    :help " `gd-electric-colon'
Insert a colon and indent accordingly.

If a numeric argument ARG is provided, that many colons are inserted
non-electrically.

Electric behavior is inhibited inside a string or
comment or by universal prefix C-u.

Switched by `gd-electric-colon-active-p', default is nil
See also `gd-electric-colon-greedy-p'"]

	   ["Electric comment" gd-electric-comment
	    :help " `gd-electric-comment'
Insert a comment. If starting a comment, indent accordingly.

If a numeric argument ARG is provided, that many \"#\" are inserted
non-electrically.
With C-u \"#\" electric behavior is inhibited inside a string or comment."]

	   ["Electric delete" gd-electric-delete
	    :help " `gd-electric-delete'
Delete following character or levels of whitespace.

With ARG do that ARG times."]

	   ["Electric yank" gd-electric-yank
	    :help " `gd-electric-yank'
Perform command `yank' followed by an `indent-according-to-mode'"]

	   ["Hungry delete backwards" gd-hungry-delete-backwards
	    :help " `gd-hungry-delete-backwards'
Delete the preceding character or all preceding whitespace
back to the previous non-whitespace character.
See also C-c <delete>."]

	   ["Hungry delete forward" gd-hungry-delete-forward
	    :help " `gd-hungry-delete-forward'
Delete the following character or all following whitespace
up to the next non-whitespace character.
See also C-c <C-backspace>."]
            )
          ("Abbrevs"	   :help "see also `gd-add-abbrev'"
	   :filter (lambda (&rest junk)
		     (abbrev-table-menu gdscript-mode-abbrev-table))            )

          ["Add abbrev" gd-add-abbrev
	   :help " `gd-add-abbrev'
Defines gdscript-mode specific abbrev for last expressions before point.
Argument is how many `gd-partial-expression's form the expansion; or zero means the region is the expansion.

Reads the abbreviation in the minibuffer; with numeric arg it displays a proposal for an abbrev.
Proposal is composed from the initial character(s) of the
expansion.

Don't use this function in a Lisp program; use `define-abbrev' instead."]
          ("Completion"
	   ["Py indent or complete" gd-gd-indent-or-complete
	    :help " `gd-gd-indent-or-complete'"]

	   ["Py shell complete" gd-gd-shell-complete
	    :help " `gd-gd-shell-complete'"]

	   ["Py complete" gd-gd-complete
	    :help " `gd-gd-complete'"]
            )))))

;; gdscript-components-foot

(defun gd-shell-fontify ()
  "Fontifies input in shell buffer. "
  ;; causes delay in fontification until next trigger
  ;; (unless (or (member (char-before) (list 32 ?: ?\)))
  ;; (unless (and (eq last-command 'self-insert-command) (eq (char-before) 32))
  ;; (< (abs (save-excursion (skip-chars-backward "^ \t\r\n\f"))) 2))
  (let* ((pps (parse-partial-sexp (line-beginning-position) (point)))
	 (start (if (and (nth 8 pps) (nth 1 pps))
		    (max (nth 1 pps) (nth 8 pps))
		  (or (nth 1 pps) (nth 8 pps)))))
    (when (or start
	      (setq start (ignore-errors (cdr comint-last-prompt))))
      (let* ((input (buffer-substring-no-properties
		     start (point-max)))
	     (buffer-undo-list t)
	     (replacement
	      (save-current-buffer
		(set-buffer gd-shell--font-lock-buffer)
		(erase-buffer)
		(insert input)
		;; Ensure buffer is fontified, keeping it
		;; compatible with Emacs < 24.4.
		(if (fboundp 'font-lock-ensure)
		    (funcall 'font-lock-ensure)
		  (font-lock-default-fontify-buffer))
		(buffer-substring (point-min) (point-max))))
	     (replacement-length (length replacement))
	     (i 0))
	;; Inject text properties to get input fontified.
	(while (not (= i replacement-length))
	  (let* ((plist (text-properties-at i replacement))
		 (next-change (or (next-property-change i replacement)
				  replacement-length))
		 (plist (let ((face (plist-get plist 'face)))
			  (if (not face)
			      plist
			    ;; Replace FACE text properties with
			    ;; FONT-LOCK-FACE so input is fontified.
			    (plist-put plist 'face nil)
			    (plist-put plist 'font-lock-face face)))))
	    (set-text-properties
	     (+ start i) (+ start next-change) plist)
	    (setq i next-change)))))))

(define-derived-mode gd-auto-completion-mode gdscript-mode "Pac"
  "Run auto-completion"
  ;; disable company
  ;; (when company-mode (company-mode))
  (if gd-auto-completion-mode-p
      (progn
	(setq gd-auto-completion-mode-p nil
	      gd-auto-completion-buffer nil)
	(when (timerp py--auto-complete-timer)(cancel-timer py--auto-complete-timer)))
    (setq gd-auto-completion-mode-p t
	  gd-auto-completion-buffer (current-buffer))
    (setq py--auto-complete-timer
	  (run-with-idle-timer
	   py--auto-complete-timer-delay
	   ;; 1
	   t
	   #'gd-complete-auto)))
  (force-mode-line-update))

;;;
(define-derived-mode gdscript-mode prog-mode gdscript-mode-modeline-display
  "Major mode for editing GDScript files.

To submit a problem report, enter `\\[gd-submit-bug-report]' from a
`gdscript-mode' buffer.  Do `\\[gd-describe-mode]' for detailed
documentation.  To see what version of `gdscript-mode' you are running,
enter `\\[gd-version]'.

This mode knows about GDScript indentation, tokens, comments and
continuation lines.  Paragraphs are separated by blank lines only.

COMMANDS

`gd-shell'\tStart an interactive GDScript interpreter in another window
`gd-execute-statement'\tSend statement at point to GDScript default interpreter
`gd-backward-statement'\tGo to the initial line of a simple statement

etc.

See available commands listed in files commands-gdscript-mode at directory doc

VARIABLES

`gd-indent-offset'	indentation increment
`gd-shell-name'		shell command to invoke GDScript interpreter
`gd-split-window-on-execute'		When non-nil split windows
`gd-switch-buffers-on-execute-p'	When non-nil switch to the GDScript output buffer

See available customizations listed in files variables-gdscript-mode at directory doc

\\{gdscript-mode-map}"
  :group 'gdscript-mode
  ;; Local vars
  (set (make-local-variable 'electric-indent-inhibit) nil)
  (set (make-local-variable 'outline-regexp)
       (concat (mapconcat 'identity
                          (mapcar #'(lambda (x) (concat "^\\s-*" x "\\_>"))
                                  gd-outline-mode-keywords)
                          "\\|")))
  (when (eq 0 (string-match "25" emacs-version))
    (global-eldoc-mode -1))
  (if gd-use-font-lock-doc-face-p
      (set (make-local-variable 'font-lock-defaults)
           '(gdscript-font-lock-keywords nil nil nil nil
				       (font-lock-syntactic-keywords
					. gd-font-lock-syntactic-keywords)
				       (font-lock-syntactic-face-function
					. py--font-lock-syntactic-face-function)))
    (set (make-local-variable 'font-lock-defaults)
         '(gdscript-font-lock-keywords nil nil nil nil
				     (font-lock-syntactic-keywords
				      . gd-font-lock-syntactic-keywords))))
  ;; avoid to run gd-choose-shell again from `py--fix-start'
  (cond ((string-match "ython3" gd-gdscript-edit-version)
	 (font-lock-add-keywords 'gdscript-mode
				 '(("\\<print\\>" . 'gd-builtins-face)
				   ("\\<file\\>" . nil))))
	(t (font-lock-add-keywords 'gdscript-mode
				   '(("\\<print\\>" . 'font-lock-keyword-face)
				     ("\\<file\\>" . 'gd-builtins-face)))))
  (set (make-local-variable 'which-func-functions) 'gd-which-def-or-class)
  (set (make-local-variable 'parse-sexp-lookup-properties) t)
  (set (make-local-variable 'comment-use-syntax) t)
  (set (make-local-variable 'comment-start) "#")
  (set (make-local-variable 'comment-start-skip) "^[ \t]*#+ *")

  (if gd-empty-comment-line-separates-paragraph-p
      (progn
        (set (make-local-variable 'paragraph-separate) "\f\\|^[ \t]*$\\|^[ \t]*#[ \t]*$\\|^[ \t\f]*:[[:alpha:]]+ [[:alpha:]]+:.+$")
        (set (make-local-variable 'paragraph-start) "\f\\|^[ \t]*$\\|^[ \t]*#[ \t]*$\\|^[ \t\f]*:[[:alpha:]]+ [[:alpha:]]+:.+$"))
    (set (make-local-variable 'paragraph-separate) "\f\\|^[ \t]*$\\|^[ \t]*#[ \t]*$\\|^[ \t\f]*:[[:alpha:]]+ [[:alpha:]]+:.+$")
    (set (make-local-variable 'paragraph-start) "\f\\|^[ \t]*$\\|^[ \t]*#[ \t]*$\\|^[ \t\f]*:[[:alpha:]]+ [[:alpha:]]+:.+$"))
  (set (make-local-variable 'comment-column) 40)
  (set (make-local-variable 'comment-indent-function) #'py--comment-indent-function)
  (set (make-local-variable 'indent-region-function) 'gd-indent-region)
  (set (make-local-variable 'indent-line-function) 'gd-indent-line)
  (set (make-local-variable 'hs-hide-comments-when-hiding-all) 'gd-hide-comments-when-hiding-all)
  (set (make-local-variable 'outline-heading-end-regexp) ":[^\n]*\n")
  (set (make-local-variable 'open-paren-in-column-0-is-defun-start) nil)
  (set (make-local-variable 'add-log-current-defun-function) 'gd-current-defun)
  (set (make-local-variable 'fill-paragraph-function) 'gd-fill-paragraph)
  (set (make-local-variable 'require-final-newline) mode-require-final-newline)
  (set (make-local-variable 'tab-width) gd-indent-offset)
  (set (make-local-variable 'eldoc-documentation-function)
       #'gd-eldoc-function)
  (and gd-load-skeletons-p
       (gd-load-skeletons)
       (set (make-local-variable 'skeleton-further-elements)
            '((< '(backward-delete-char-untabify (min gd-indent-offset
                                                      (current-column))))
              (^ '(- (1+ (current-indentation)))))))
  (and gd-guess-gd-install-directory-p (gd-set-load-path))
  ;;  (unless gud-pdb-history (when (buffer-file-name) (add-to-list 'gud-pdb-history (py--buffer-filename-remote-maybe)))) 
  (and gd-autopair-mode
       (load-library "autopair")
       (add-hook 'gdscript-mode-hook
                 #'(lambda ()
                     (setq autopair-handle-action-fns
                           (list #'autopair-default-handle-action
                                 #'autopair-gdscript-triple-quote-action))))
       (gd-autopair-mode-on))
  (when gd-trailing-whitespace-smart-delete-p
    (add-hook 'before-save-hook 'delete-trailing-whitespace nil 'local))
  (when gd-pdbtrack-do-tracking-p
    (add-hook 'comint-output-filter-functions 'py--pdbtrack-track-stack-file t))
  (cond
   (gd-complete-function
    (add-hook 'completion-at-point-functions
              gd-complete-function nil 'local))
   (gd-load-pymacs-p
    (add-hook 'completion-at-point-functions
              'gd-complete-completion-at-point nil 'local))
   (t
    (add-hook 'completion-at-point-functions
              'gd-shell-complete nil 'local)))
  ;; (if gd-auto-complete-p
  ;; (add-hook 'gdscript-mode-hook 'py--run-completion-timer)
  ;; (remove-hook 'gdscript-mode-hook 'py--run-completion-timer))
  ;; (when gd-auto-complete-p
  ;; (add-hook 'gdscript-mode-hook
  ;; (lambda ()
  ;; (run-with-idle-timer 1 t 'gd-shell-complete))))
  (if gd-auto-fill-mode
      (add-hook 'gdscript-mode-hook 'py--run-auto-fill-timer)
    (remove-hook 'gdscript-mode-hook 'py--run-auto-fill-timer))

  ;; caused insert-file-contents error lp:1293172
  ;;  (add-hook 'after-change-functions 'py--after-change-function nil t)
  (if gd-defun-use-top-level-p
      (progn
        (set (make-local-variable 'beginning-of-defun-function) 'gd-backward-top-level)
        (set (make-local-variable 'end-of-defun-function) 'gd-end-of-top-level)
        (define-key gdscript-mode-map [(control meta a)] 'gd-backward-top-level)
        (define-key gdscript-mode-map [(control meta e)] 'gd-end-of-top-level))
    (set (make-local-variable 'beginning-of-defun-function) 'gd-backward-def-or-class)
    (set (make-local-variable 'end-of-defun-function) 'gd-end-of-def-or-class)
    (define-key gdscript-mode-map [(control meta a)] 'gd-backward-def-or-class)
    (define-key gdscript-mode-map [(control meta e)] 'gd-end-of-def-or-class))
  (when gd-sexp-use-expression-p
    	(define-key gdscript-mode-map [(control meta f)] 'gd-forward-expression)
	(define-key gdscript-mode-map [(control meta b)] 'gd-backward-expression))
  (when (and py--imenu-create-index-p
             (fboundp 'imenu-add-to-menubar)
             (ignore-errors (require 'imenu)))
  (setq imenu-create-index-function 'py--imenu-create-index-function)
  (setq imenu--index-alist (funcall py--imenu-create-index-function))
  ;; fallback
  (unless imenu--index-alist
    (setq imenu--index-alist (py--imenu-create-index-new)))
    ;; (message "imenu--index-alist: %s" imenu--index-alist)
    (imenu-add-to-menubar "PyIndex"))
  ;; add the menu
  (when gd-menu
    (easy-menu-add gd-menu))
  (when gd-hide-show-minor-mode-p (hs-minor-mode 1))
  (when gd-outline-minor-mode-p (outline-minor-mode 1))
  (when (called-interactively-p 'any) (message "gdscript-mode loaded from: %s" gdscript-mode-message-string))
  (force-mode-line-update))

(defun py--shell-setup-fontification (&optional style)
  "Expected values are either nil, 'all or 'input. "
  (setq style (or style gd-shell-fontify-style))
  (if style
      (progn
	(cond ((eq 'all style)
	       (remove-hook 'change-major-mode-hook 'font-lock-defontify)
	       (set (make-local-variable 'py--shell-unfontify) 'gd-shell-unfontify-p)
	       (when py--shell-unfontify
	       	 (add-hook 'gd-gdscript-shell-mode-hook #'py--run-unfontify-timer (current-buffer)))
	       (remove-hook 'post-command-hook 'gd-shell-fontify t)
	       (set (make-local-variable 'font-lock-defaults)
		    '(gdscript-font-lock-keywords nil nil nil nil
						(font-lock-syntactic-keywords
						 . gd-font-lock-syntactic-keywords)))
	       (if (fboundp 'font-lock-ensure)
		   (funcall 'font-lock-ensure)
		 (font-lock-default-fontify-buffer)))
	      ;; style is 'input, prepare `gd-shell-fontify'
	      (t (set (make-local-variable 'delay-mode-hooks) t)
		 (save-current-buffer
		   ;; Prepare the buffer where the input is fontified
		   (set-buffer (get-buffer-create gd-shell--font-lock-buffer))
		   (font-lock-mode 1)
		   (gdscript-mode))
		 ;; post-self-insert-hook
		 (add-hook 'post-command-hook
			   #'gd-shell-fontify nil 'local)))
	(force-mode-line-update))
    ;; no fontification in gd-shell
    (remove-hook 'gd-gdscript-shell-mode-hook 'py--run-unfontify-timer t)
    (remove-hook 'post-command-hook 'gd-shell-fontify t)))

(defun py--all-shell-mode-setting ()
  (py--shell-setup-fontification)
  (setenv "PAGER" "cat")
  (setenv "TERM" "dumb")
  (set-syntax-table gdscript-mode-syntax-table)
  (if gd-auto-complete-p
      (add-hook 'gd-shell-mode-hook 'py--run-completion-timer)
    (remove-hook 'gd-shell-mode-hook 'py--run-completion-timer))
  ;; comint settings
  (set (make-local-variable 'comint-prompt-regexp)
       (cond ((string-match "[iI][pP]ython[[:alnum:]*-]*$" gd-buffer-name)
	      (concat "\\("
		      (mapconcat 'identity
				 (delq nil (list gd-shell-input-prompt-1-regexp gd-shell-input-prompt-2-regexp gd-ipython-input-prompt-re gd-ipython-output-prompt-re gd-pdbtrack-input-prompt gd-pydbtrack-input-prompt))
				 "\\|")
		      "\\)"))
	     (t (concat "\\("
			(mapconcat 'identity
				   (delq nil (list gd-shell-input-prompt-1-regexp gd-shell-input-prompt-2-regexp gd-pdbtrack-input-prompt gd-pydbtrack-input-prompt))
				   "\\|")
			"\\)"))))
  (remove-hook 'comint-output-filter-functions 'font-lock-extend-jit-lock-region-after-change t)

  (make-local-variable 'comint-output-filter-functions)
  ;; (set (make-local-variable 'comint-input-filter) 'py--input-filter)
  (set (make-local-variable 'comint-input-filter) 'gd-history-input-filter)
  (set (make-local-variable 'comint-prompt-read-only) gd-shell-prompt-read-only)
  ;; (set (make-local-variable 'comint-use-prompt-regexp) nil)
  (set (make-local-variable 'compilation-error-regexp-alist)
       gd-compilation-regexp-alist)
  (set (make-local-variable 'comment-start) "# ")
  (set (make-local-variable 'comment-start-skip) "^[ \t]*#+ *")
  (set (make-local-variable 'comment-column) 40)
  (set (make-local-variable 'comment-indent-function) #'py--comment-indent-function)
  (set (make-local-variable 'indent-region-function) 'gd-indent-region)
  (set (make-local-variable 'indent-line-function) 'gd-indent-line)
  (set (make-local-variable 'inhibit-point-motion-hooks) t)
  (set (make-local-variable 'comint-input-sender) 'py--shell-simple-send))

(define-derived-mode gd-gdscript-shell-mode comint-mode "Py"
  "Major mode for interacting with a GDScript process.
A GDScript process can be started with \\[gd-shell].

You can send text to the GDScript process from other buffers
containing GDScript source.
 * \\[gd-execute-region] sends the current region to the GDScript process.

Sets basic comint variables, see also versions-related stuff in `gd-shell'.
\\{gd-gdscript-shell-mode-map}"
  :group 'gdscript-mode
  ;; (require 'ansi-color) ; for ipython
  (setq mode-line-process '(":%s"))
  ;; (sit-for 0.1)
  (when gd-verbose-p (message "%s" "Initializing GDScript shell, please wait"))
  (py--all-shell-mode-setting)
  (py--gdscript-send-completion-setup-code)
  (py--gdscript-send-ffap-setup-code)
  (py--gdscript-send-eldoc-setup-code)
  (set-process-sentinel (get-buffer-process (current-buffer))  #'shell-write-history-on-exit)

  ;; (setq comint-input-ring-file-name
  ;;       (cond ((string-match "[iI][pP]ython[[:alnum:]*-]*$" gd-buffer-name)
  ;;              (if gd-honor-IPYTHONDIR-p
  ;;                  (if (getenv "IPYTHONDIR")
  ;;                      (concat (getenv "IPYTHONDIR") "/history")
  ;;                    gd-ipython-history)
  ;;                gd-ipython-history))
  ;;             (t
  ;;              (if gd-honor-PYTHONHISTORY-p
  ;;                  (if (getenv "PYTHONHISTORY")
  ;;                      (concat (getenv "PYTHONHISTORY") "/" (py--report-executable gd-buffer-name) "_history")
  ;;                    gd-ipython-history)
  ;;                gd-ipython-history)))
  ;;)
  (comint-read-input-ring t)
  (compilation-shell-minor-mode 1)
  ;;
  (if gd-complete-function
      (progn
  	(add-hook 'completion-at-point-functions
  		  gd-complete-function nil 'local)
  	(add-to-list (make-local-variable 'comint-dynamic-complete-functions)
  		     gd-complete-function))
    (add-hook 'completion-at-point-functions
              'gd-shell-complete nil 'local)
    (add-to-list (make-local-variable 'comint-dynamic-complete-functions)
  		 'gd-shell-complete))
  (when gd-sexp-use-expression-p
    (define-key gd-gdscript-shell-mode-map [(control meta f)] 'gd-forward-expression)
    (define-key gd-gdscript-shell-mode-map [(control meta b)] 'gd-backward-expression))
  (when gd-shell-menu
    (easy-menu-add gd-menu))
  (force-mode-line-update))

(define-derived-mode gd-ipython-shell-mode comint-mode "IPy"
  "Major mode for interacting with a GDScript process.
A GDScript process can be started with \\[gd-shell].

You can send text to the GDScript process from other buffers
containing GDScript source.
 * \\[gd-execute-region] sends the current region to the GDScript process.

Sets basic comint variables, see also versions-related stuff in `gd-shell'.
\\{gd-ipython-shell-mode-map}"
  :group 'gdscript-mode
  ;; (require 'ansi-color) ; for ipython
  (setq mode-line-process '(":%s"))
  (when gd-verbose-p (message "%s" "Initializing IPython shell, please wait"))
  (py--all-shell-mode-setting)
  (py--gdscript-send-completion-setup-code)
  (py--gdscript-send-ffap-setup-code)
  (py--gdscript-send-eldoc-setup-code)
  (py--ipython-import-module-completion)
  (gd-set-ipython-completion-command-string (process-name (get-buffer-process (current-buffer))))
  (sit-for 0.1 t)
  (comint-read-input-ring t)
  (compilation-shell-minor-mode 1)
  (if gd-complete-function
      (progn
  	(add-hook 'completion-at-point-functions
  		  gd-complete-function nil 'local)
  	(add-to-list (make-local-variable 'comint-dynamic-complete-functions)
  		     gd-complete-function))
    (add-hook 'completion-at-point-functions
              'gd-shell-complete nil 'local)
    (add-to-list (make-local-variable 'comint-dynamic-complete-functions)
  		 'gd-shell-complete))
  (when gd-shell-menu
    (easy-menu-add gd-menu))
  ;; Running gd-ipython-shell-mode-hook seems to need some delay
  (sit-for 0.5 t)
  (force-mode-line-update))

(defalias 'gd-backward-decorator-bol 'gd-backward-decorator)
(defalias 'gd-beginning-of-block 'gd-backward-block)
(defalias 'gd-beginning-of-block-bol 'gd-backward-block-bol)
(defalias 'gd-beginning-of-block-or-clause 'gd-backward-block-or-clause)
(defalias 'gd-beginning-of-block-or-clause 'gd-goto-block-or-clause-up)
(defalias 'gd-beginning-of-block-or-clause 'gd-previous-block-or-clause)
(defalias 'gd-beginning-of-class 'gd-backward-class)
(defalias 'gd-beginning-of-class-bol 'gd-backward-class-bol)
(defalias 'gd-beginning-of-clause 'gd-backward-clause)
(defalias 'gd-beginning-of-clause 'gd-goto-clause-up)
(defalias 'gd-beginning-of-clause 'gd-previous-clause)
(defalias 'gd-beginning-of-clause-bol 'gd-backward-clause-bol)
(defalias 'gd-beginning-of-comment 'gd-backward-comment)
(defalias 'gd-beginning-of-declarations 'gd-backward-declarations)
(defalias 'gd-beginning-of-decorator 'gd-backward-decorator)
(defalias 'gd-beginning-of-decorator-bol 'gd-backward-decorator)
(defalias 'gd-beginning-of-def-or-class 'gd-backward-def-or-class)
(defalias 'gd-beginning-of-expression 'gd-backward-expression)
(defalias 'gd-beginning-of-line 'gd-backward-line)
(defalias 'gd-beginning-of-minor-block 'gd-backward-minor-block)
(defalias 'gd-beginning-of-partial-expression 'gd-backward-partial-expression)
(defalias 'gd-beginning-of-section 'gd-backward-section)
(defalias 'gd-beginning-of-statement 'gd-backward-statement)
(defalias 'gd-beginning-of-statement-bol 'gd-backward-statement-bol)
(defalias 'gd-beginning-of-top-level 'gd-backward-top-level)
(defalias 'gd-end-of-block 'gd-forward-block)
(defalias 'gd-end-of-block-or-clause 'gd-forward-block-or-clause)
(defalias 'gd-end-of-class 'gd-forward-class)
(defalias 'gd-end-of-clause 'gd-forward-clause)
(defalias 'gd-end-of-comment 'gd-forward-comment)
(defalias 'gd-end-of-decorator 'gd-forward-decorator)
(defalias 'gd-end-of-def-or-class 'gd-forward-def-or-class)
(defalias 'gd-end-of-expression 'gd-forward-expression)
(defalias 'gd-end-of-line 'gd-forward-line)
(defalias 'gd-end-of-partial-expression 'gd-forward-partial-expression)
(defalias 'gd-end-of-section 'gd-forward-section)
(defalias 'gd-end-of-statement 'gd-forward-statement)
(defalias 'gd-end-of-statement-bol 'gd-forward-statement-bol)
(defalias 'gd-end-of-top-level 'gd-forward-top-level)
(defalias 'gd-goto-block-or-clause-up 'gd-backward-block-or-clause)
(defalias 'gd-goto-block-up 'gd-backward-block)
(defalias 'gd-goto-clause-up 'gd-backward-clause)
(defalias 'gd-next-statement 'gd-forward-statement)
(defalias 'gd-previous-block-or-clause 'gd-backward-block-or-clause)
(defalias 'gd-previous-class 'gd-backward-class)
(defalias 'gd-previous-clause 'gd-backward-clause)
(defalias 'gd-previous-def-or-class 'gd-backward-def-or-class)
(defalias 'gd-previous-statement 'gd-backward-statement)
(defalias 'gd-markup-region-as-section 'gd-sectionize-region)

;;;
(provide 'gdscript-mode)
;;; gdscript-mode.el ends here
