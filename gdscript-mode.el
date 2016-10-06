;; TODO HEADER LICENSE COPYRIGHT
;; THIS IS PYTHON-MODE.el below with a lot of replacements and cuts
;; EXPECT TO FIND GARBAGE UNTI WORK IS DONE
;; IT`S A 20k-line file after all

(defgroup gdscript-mode nil
  "Support for the GDScript programming language, <http://www.godotengine.org/>"
  :group 'languages
  :prefix "gd-")

(defconst gd-version "0.0.1")

(defcustom gdscript-mode-modeline-display "GDScript"
  "String to display in Emacs modeline "

  :type 'string
  :tag "gdscript-mode-modeline-display"
  :group 'gdscript-mode)


(defcustom info-lookup-mode "GDScript"
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

(defcustom gd--execute-use-temp-file-p nil
 "Assume execution at a remote machine.

 where write-access is not given. "

 :type 'boolean
 :group 'gdscript-mode)

(defvar gd--match-paren-forward-p nil
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
  "Used by gd--fast-send-string-intern. "

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

(defvar gd--auto-complete-timer nil
  "Internally used by `gd-auto-completion-mode'")

(defvar gd-auto-completion-buffer nil
  "Internally used by `gd-auto-completion-mode'")

(defvar gd--auto-complete-timer-delay 1
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

(defcustom gd--delete-temp-file-delay 1
  "Used by `gd--delete-temp-file'"

  :type 'number
  :tag "gd--delete-temp-file-delay"
  :group 'gdscript-mode)

(defcustom gd-gdscript-send-delay 5
  "Seconds to wait for output, used by `gd--send-...' functions.

See also gd-ipython-send-delay"

  :type 'number
  :tag "gd-gdscript-send-delay"
  :group 'gdscript-mode)

(defcustom gd-ipython-send-delay 9
  "Seconds to wait for output, used by `gd--send-...' functions.

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



(defcustom gd-shell-prompt-read-only t
  "If non-nil, the python prompt is read only.  Setting this
variable will only effect new shells."
  :type 'boolean
  :tag "gd-shell-prompt-read-only"
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
  '("class"    "func"    "elif"    "else"    "except"
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
  '("class"    "func"    "elif"    "else"    "except"
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

(defcustom gd--imenu-create-index-p nil
  "Non-nil means GDScript mode creates and displays an index menu of functions and global variables. "
  :type 'boolean
  :tag "gd--imenu-create-index-p"
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

(defcustom gd--warn-tmp-files-left-p nil
  "Messages a warning, when `gd-temp-directory' contains files susceptible being left by previous GDScript-mode sessions. See also lp:987534 "
  :type 'boolean
  :tag "gd--warn-tmp-files-left-p"
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

(defcustom gd--imenu-create-index-function 'gd--imenu-create-index-new
  "Switch between `gd--imenu-create-index-new', which also lists modules variables,  and series 5. index-machine"
  :type '(choice (const :tag "'gd--imenu-create-index-new, also lists modules variables " gd--imenu-create-index-new)

                 (const :tag "gd--imenu-create-index, series 5. index-machine" gd-imenu-create-index))
  :tag "gd--imenu-create-index-function"
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

(defun gd--set-ffap-form ()
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
         (gd--set-ffap-form))
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
	  (ignore-errors (string-match "gdscript-mode.el" (gd--buffer-filename-remote-maybe))))
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
set in gd-execute-region and used in gd--jump-to-exception.")

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
   "static func"
   "class"
   "func"
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

(defconst gd-block-re "[ \t]*\\_<\\(class\\|func\\|static func\\|async for\\|for\\|if\\|try\\|while\\|with\\|async with\\)\\_>[:( \n\t]*"
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

(defconst gd-def-or-class-re "[ \t]*\\_<\\(static func\\|class\\|func\\)\\_>[ \n\t]"
  "Matches the beginning of a class- or functions definition. ")

;; (setq gd-def-or-class-re "[ \t]*\\_<\\(static func\\|class\\|func\\)\\_>[ \n\t]")

;; (defconst gd-def-re "[ \t]*\\_<\\(static func\\|func\\)\\_>[ \n\t]"
(defconst gd-def-re "[ \t]*\\_<\\(func\\|static func\\)\\_>[ \n\t]"
  "Matches the beginning of a functions definition. ")

(defcustom gd-block-or-clause-re-raw
  (list
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
   "static func"
   "class"
   "func"
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

(defun gd--quote-syntax (n)
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
     (1 (gd--quote-syntax 1) t t)
     (2 (gd--quote-syntax 2) t t)
     (3 (gd--quote-syntax 3) t t)
     (6 (gd--quote-syntax 1) t t))))

(defconst gd-windows-config-register 313465889
  "Internal used")

(defvar gd-windows-config nil
  "Completion stores gd-windows-config-register here")

(put 'gd-indent-offset 'safe-local-variable 'integerp)

;; testing
(defvar gd--shell-unfontify nil
  "Internally used by `gd--run-unfontify-timer'. ")


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

(defun gd--delete-all-but-first-prompt ()
  "Don't let prompts from setup-codes sent clutter buffer. "
  (let (last erg)
    (when (re-search-backward gd-fast-filter-re nil t 1)
      (setq erg (match-end 0))
      (while (and (re-search-backward gd-fast-filter-re nil t 1) (setq erg (match-end 0))))
      (delete-region erg (point-max))))
  (goto-char (point-max)))

(defun gd--gdscript-send-setup-code-intern (name &optional msg)
  (let ((setup-file (concat (gd--normalize-directory gd-temp-directory) "py-" name "-setup-code.py"))
	(gd-ignore-result-p t)
	(buf (current-buffer)))
    (unless (file-readable-p setup-file)
      (with-temp-buffer
	(insert (eval (car (read-from-string (concat "py-" name "-setup-code")))))
	(write-file setup-file)))
    (gd--execute-file-base nil setup-file nil buf)
    (when msg (message "%s" (concat name " setup-code sent to " (process-name (get-buffer-process buf)))))))

(defun gd--gdscript-send-completion-setup-code ()
  "For GDScript see gd--gdscript-send-setup-code "
  (gd--gdscript-send-setup-code-intern "shell-completion" gd-verbose-p))

(defun gd--gdscript-send-ffap-setup-code ()
  "For GDScript see gd--gdscript-send-setup-code "
  (gd--gdscript-send-setup-code-intern "ffap" gd-verbose-p))

(defun gd--gdscript-send-eldoc-setup-code ()
  "For GDScript see gd--gdscript-send-setup-code "
  (gd--gdscript-send-setup-code-intern "eldoc" gd-verbose-p))

(defun gd--ipython-import-module-completion ()
  "Setup IPython v0.11 or greater.

Used by `gd-ipython-module-completion-string'"
  (let ((setup-file (concat (gd--normalize-directory gd-temp-directory) "gd-ipython-module-completion.py"))
	(gd-ignore-result-p t))
    (unless (file-readable-p setup-file)
      (with-temp-buffer
	(insert gd-ipython-module-completion-code)
	(write-file setup-file)))
    (gd--execute-file-base nil setup-file nil (current-buffer))))

(defun gd--at-raw-string ()
  "If at beginning of a raw-string. "
  (looking-at "\"\"\"\\|'''") (member (char-before) (list ?u ?U ?r ?R)))

(defun gd--docstring-p (&optional beginning-of-string-position)
  "Check to see if there is a docstring at POS."
  (let* (pps
	 (pos (or beginning-of-string-position
		  (and (nth 3 (setq pps (parse-partial-sexp (point-min) (point)))) (nth 8 pps)))))
    (save-restriction
      (widen)
      (save-excursion
	(goto-char pos)
	(when (gd--at-raw-string)
	  (forward-char -1)
	  (setq pos (point)))
	(when (gd-backward-statement)
	  (when (looking-at gd-def-or-class-re)
	    pos))))))

(defun gd--font-lock-syntactic-face-function (state)
  (if (nth 3 state)
      (if (gd--docstring-p (nth 8 state))
          font-lock-doc-face
        font-lock-string-face)
    font-lock-comment-face))

(and (fboundp 'make-obsolete-variable)
     (make-obsolete-variable 'gd-mode-hook 'gdscript-mode-hook nil))


(defun gd--normalize-directory (directory)
  "Make sure DIRECTORY ends with a file-path separator char.

Returns DIRECTORY"
  (let ((erg (cond ((string-match (concat gd-separator-char "$") directory)
                    directory)
                   ((not (string= "" directory))
                    (concat directory gd-separator-char)))))
    (unless erg (when gd-verbose-p (message "Warning: directory is empty")))
    erg))



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

(defun gd--escape-doublequotes (start end)
  (let ((end (copy-marker end)))
    (save-excursion
      (goto-char start)
      (while (and (not (eobp)) (< 0 (abs (skip-chars-forward "^\"" end))))
	(when (eq (char-after) ?\")
	  (unless (gd-escaped)
	    (insert "\\")
	    (forward-char 1)))))))

(defun gd--escape-open-paren-col1 (start end)
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

        ;; (define-key map [(meta i)] 'gd-indent-forward-line)
        (define-key map [(control j)] 'gd-newline-and-indent)
        ;; Most Pythoneers expect RET `gd-newline-and-indent'
        ;; (define-key map (kbd "RET") 'gd-newline-and-dedent)
        ;; (define-key map (kbd "RET") gd-return-key)
        (define-key map (kbd "RET") 'gd-newline-and-indent)
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
        ;; Miscellaneous
        ;; (define-key map [(super q)] 'gd-copy-statement)
        (define-key map [(control c)(\#)] 'gd-comment-region)
        (define-key map [(control x) (n) (d)] 'gd-narrow-to-defun)
        ;; information
        (define-key map [(control c)(control v)] 'gd-version)
        (define-key map (kbd "TAB") 'gd-indent-line)
	;; (if gd-complete-function
        ;;     (progn
        ;;       (define-key map [(meta tab)] gd-complete-function)
        ;;       (define-key map [(esc) (tab)] gd-complete-function))
        ;;   (define-key map [(meta tab)] 'gd-shell-complete)
        ;;   (define-key map [(esc) (tab)] 'gd-shell-complete))
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

;;Syntax highlighting
;;  Font-lock and syntax

(setq gdscript-font-lock-keywords
      ;; Keywords
      `(,(rx symbol-start
             (or
			"if" "elif" "else" "for" "do" "while" "switch" "case" "break" "continue" "pass" 
			"return" "class" "extends" "tool" "signal" "func" "static" "const" "enum" "var" 
			"onready" "export" "setget" "breakpoint" "and" "or" "not")
             symbol-end)
        (,(rx symbol-start (or "static func" "func" "class") symbol-end) . gd-def-class-face)
        (,(rx symbol-start (or "if") symbol-end) . gd-try-if-face)
        ;; functions
        (,(rx symbol-start "func" (1+ space) (group (1+ (or word ?_))))
         (1 font-lock-function-name-face))
        (,(rx symbol-start "static func" (1+ space) (group (1+ (or word ?_))))
         (1 font-lock-function-name-face))
        ;; classes
        (,(rx symbol-start (group "class") (1+ space) (group (1+ (or word ?_))))
         (1 gd-def-class-face) (2 gd-class-name-face))
        (,(rx symbol-start
              (or "true" "false" "null")
			  symbol-end) . gd-pseudo-keyword-face)
        ;; Decorators.
        (,(rx line-start (* (any " \t")) (group "@" (1+ (or word ?_))
                                               (0+ "." (1+ (or word ?_)))))
         (1 gd-decorators-face))
	(,(rx symbol-start (or "self")
	      symbol-end) . gd-object-reference-face)
        ;; Builtins
        (,(rx
        (or space line-start (not (any ".(")))
        symbol-start
        (group (or "_" "__doc__" "__import__" "__name__" "__package__" "abs" "all"
            "Vector2" "Rect2" "Vector3" "Matrix32" "Plane" "Quat" "AABB" "Matrix3" "Transform"
            "String" "int" "float" "bool" "Color" "RID" "Object"
            "InputEvent" "Array" "Dictionary" 
            "Color8" "abs" "acos" "asin" "assert" "atan" "atan2" "bytes2var"
            "ceil" "clamp" "convert" "cos" "cosh" "db2linear" "decimals"
            "dectime" "deg2rad" "dict2inst" "ease" "exp" "floor" "fmod"
            "fposmod" "funcref" "hash" "inst2dict" "instance_from_id" "is_inf"
            "is_nan" "lerp" "linear2db" "load" "log" "max" "min" "nearest_po2"
            "pow" "preload" "print" "print_stack" "printerr" "printraw"
            "prints" "printt" "rad2deg" "rand_range" "rand_seed" "randf"
            "randi" "randomize" "range" "round" "seed" "sign" "sin" "sinh"
            "sqrt" "stepify" "str" "str2var" "tan" "tanh" "type_exists"
            "typeof" "var2bytes" "var2str" "weakref" "yield"))
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
(require 'custom)
(require 'hippie-exp)
(require 'thingatpt)
(require 'which-func)


(defun gd-toggle-sexp-function ()
  "Opens customization "
  (interactive)
  (customize-variable 'gd-sexp-function))


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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;; INDENTATION ;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun gd--top-level-form-p ()
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

(defun gd--indent-fix-region-intern (beg end)
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

(defun gd--indent-line-intern (need cui gd-indent-offset col &optional beg end region)
  (let (erg)
    (if gd-tab-indent
	(progn
	  (and gd-tab-indents-region-p region
	       (gd--indent-fix-region-intern beg end))
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

(defun gd--indent-line-base (beg end region cui need arg this-indent-offset col)
  (cond ((eq 4 (prefix-numeric-value arg))
	 (if (and (eq cui (current-indentation))
		  (<= need cui))
	     (if indent-tabs-mode (insert "\t")(insert (make-string gd-indent-offset 32)))
	   (beginning-of-line)
	   (delete-horizontal-space)
	   (indent-to (+ need gd-indent-offset))))
	((not (eq 1 (prefix-numeric-value arg)))
	 (gd-smart-indentation-off)
	 (gd--indent-line-intern need cui this-indent-offset col beg end region))
	(t (gd--indent-line-intern need cui this-indent-offset col beg end region))))

(defun gd--calculate-indent-backwards (cui indent-offset)
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
		       (gd--calculate-indent-backwards cui this-indent-offset)))
		 (if (bolp)
		     (gd-compute-indentation orig)
		   (gd--calculate-indent-backwards cui this-indent-offset)))
		(t
		 outmost
		 ;; (gd-compute-indentation orig)
		 )))
    (when (and (called-interactively-p 'any) gd-verbose-p) (message "gd-indent-line, need: %s" need))
    ;; if at outmost
    ;; and not (eq this-command last-command), need remains nil
    (when need
      (gd--indent-line-base beg end region cui need arg this-indent-offset col)
      (and region (or gd-tab-shifts-region-p
		      gd-tab-indents-region-p)
	   (not (eq (point) orig))
	   (exchange-point-and-mark))
      (when (and (called-interactively-p 'any) gd-verbose-p)(message "%s" (current-indentation)))
      (current-indentation))))

(defun gd--delete-trailing-whitespace (orig)
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
    (gd--delete-trailing-whitespace orig)
    (setq erg
	  (cond (this-dedent
		 (indent-to-column this-dedent))
		((and gd-empty-line-closes-p (or (eq this-command last-command)(gd--after-empty-line)))
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

(defun gd--guess-indent-final (indents orig)
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

(defun gd--guess-indent-forward ()
  "Called when moving to end of a form and `gd-smart-indentation' is on. "
  (let* ((first (if
                    (gd--beginning-of-statement-p)
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

(defun gd--guess-indent-backward ()
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
                       (gd--guess-indent-forward)
                     (gd--guess-indent-backward)))
                  ;; guess some usable indent is above current position
                  ((eq 0 (current-indentation))
                   (gd--guess-indent-forward))
                  (t (gd--guess-indent-backward))))
           (erg (gd--guess-indent-final indents orig)))
      (if erg (setq gd-indent-offset erg)
        (setq gd-indent-offset
              (default-value 'gd-indent-offset)))
      (when (called-interactively-p 'any) (message "%s" gd-indent-offset))
      gd-indent-offset)))

(defun gd--comment-indent-function ()
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

(defun gd--indent-line-by-line (beg end)
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
    (gd--indent-line-by-line beg end)
    ;; (if (eq 4 (prefix-numeric-value line-by-line))
    ;; 	(gd--indent-line-by-line beg end)
    ;;   (setq need (gd-compute-indentation))
    ;;   (if (< 0 (abs need))
    ;; 	  (indent-region beg end need)
    ;; 	(gd--indent-line-by-line beg end))
    ;;   (goto-char orig))
    )
  )

(defun gd--beginning-of-buffer-position ()
  (point-min))

(defun gd--end-of-buffer-position ()
  (point-max))

;;  Declarations start
(defun gd--bounds-of-declarations ()
  "Bounds of consecutive multitude of assigments resp. statements around point.

Indented same level, which don't open blocks.
Typically declarations resp. initialisations of variables following
a class or function definition.
See also gd--bounds-of-statements "
  (let* ((orig-indent (progn
                        (back-to-indentation)
                        (unless (gd--beginning-of-statement-p)
                          (gd-backward-statement))
                        (unless (gd--beginning-of-block-p)
                          (current-indentation))))
         (orig (point))
         last beg end)
    (when orig-indent
      (setq beg (line-beginning-position))
      ;; look upward first
      (while (and
              (progn
                (unless (gd--beginning-of-statement-p)
                  (gd-backward-statement))
                (line-beginning-position))
              (gd-backward-statement)
              (not (gd--beginning-of-block-p))
              (eq (current-indentation) orig-indent))
        (setq beg (line-beginning-position)))
      (goto-char orig)
      (while (and (setq last (line-end-position))
                  (setq end (gd-down-statement))
                  (not (gd--beginning-of-block-p))
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
  (let* ((bounds (gd--bounds-of-declarations))
         (erg (car bounds)))
    (when erg (goto-char erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-forward-declarations ()
  "Got to the end of assigments resp. statements in current level which don't open blocks. "
  (interactive)
  (let* ((bounds (gd--bounds-of-declarations))
         (erg (cdr bounds)))
    (when erg (goto-char erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defalias 'gd-copy-declarations 'gd-declarations)
(defun gd-declarations ()
  "Copy and mark assigments resp. statements in current level which don't open blocks or start with a keyword.

See also `gd-statements', which is more general, taking also simple statements starting with a keyword. "
  (interactive)
  (let* ((bounds (gd--bounds-of-declarations))
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
  (let* ((bounds (gd--bounds-of-declarations))
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
(defun gd--bounds-of-statements ()
  "Bounds of consecutive multitude of statements around point.

Indented same level, which don't open blocks. "
  (interactive)
  (let* ((orig-indent (progn
                        (back-to-indentation)
                        (unless (gd--beginning-of-statement-p)
                          (gd-backward-statement))
                        (unless (gd--beginning-of-block-p)
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
                  (not (gd--beginning-of-block-p))
                  (eq (current-indentation) orig-indent)))
      (setq beg last)
      (goto-char orig)
      (setq end (line-end-position))
      (while (and (setq last (gd--end-of-statement-position))
                  (setq end (gd-down-statement))
                  (not (gd--beginning-of-block-p))
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
  (let* ((bounds (gd--bounds-of-statements))
         (erg (car bounds)))
    (when erg (goto-char erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-forward-statements ()
  "Got to the end of statements in current level which don't open blocks. "
  (interactive)
  (let* ((bounds (gd--bounds-of-statements))
         (erg (cdr bounds)))
    (when erg (goto-char erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defalias 'gd-copy-statements 'gd-statements)
(defun gd-statements ()
  "Copy and mark simple statements in current level which don't open blocks.

More general than gd-declarations, which would stop at keywords like a print-statement. "
  (interactive)
  (let* ((bounds (gd--bounds-of-statements))
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
  (let* ((bounds (gd--bounds-of-statements))
         (beg (car bounds))
         (end (cdr bounds)))
    (when (and beg end)
      (kill-new (buffer-substring-no-properties beg end))
      (delete-region beg end))))

(defun gd--join-words-wrapping (words separator line-prefix line-length)
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

;; Comments
(defun gd-delete-comments-in-def-or-class ()
  "Delete all commented lines in def-or-class at point"
  (interactive "*")
  (save-excursion
    (let ((beg (gd--beginning-of-def-or-class-position))
          (end (gd--end-of-def-or-class-position)))
      (and beg end (gd--delete-comments-intern beg end)))))

(defun gd-delete-comments-in-class ()
  "Delete all commented lines in class at point"
  (interactive "*")
  (save-excursion
    (let ((beg (gd--beginning-of-class-position))
          (end (gd--end-of-class-position)))
      (and beg end (gd--delete-comments-intern beg end)))))

(defun gd-delete-comments-in-block ()
  "Delete all commented lines in block at point"
  (interactive "*")
  (save-excursion
    (let ((beg (gd--beginning-of-block-position))
          (end (gd--end-of-block-position)))
      (and beg end (gd--delete-comments-intern beg end)))))

(defun gd-delete-comments-in-region (beg end)
  "Delete all commented lines in region. "
  (interactive "r*")
  (save-excursion
    (gd--delete-comments-intern beg end)))

(defun gd--delete-comments-intern (beg end)
  (save-restriction
    (narrow-to-region beg end)
    (goto-char beg)
    (while (and (< (line-end-position) end) (not (eobp)))
      (beginning-of-line)
      (if (looking-at (concat "[ \t]*" comment-start))
          (delete-region (point) (1+ (line-end-position)))
        (forward-line 1)))))

(defun gd--edit-docstring-set-vars ()
  (save-excursion
    (setq gd--docbeg (when (use-region-p) (region-beginning)))
    (setq gd--docend (when (use-region-p) (region-end)))
    (let ((pps (parse-partial-sexp (point-min) (point))))
      (when (nth 3 pps)
	(setq gd--docbeg (or gd--docbeg (progn (goto-char (nth 8 pps))
					       (skip-chars-forward (char-to-string (char-after)))(push-mark)(point))))
	(setq gd--docend (or gd--docend
			     (progn (goto-char (nth 8 pps))
				    (forward-sexp)
				    (skip-chars-backward (char-to-string (char-before)))
				    (point)))))
      (setq gd--docbeg (copy-marker gd--docbeg))
      (setq gd--docend (copy-marker gd--docend)))))

;; Edit docstring
(defvar gd--docbeg nil
  "Internally used by `gd-edit-docstring'")

(defvar gd--docend nil
  "Internally used by `gd-edit-docstring'")

(defvar gd--oldbuf nil
  "Internally used by `gd-edit-docstring'")

(defvar gd-edit-docstring-buffer "Edit docstring"
  "Name of the temporary buffer to use when editing. ")

(defvar gd--edit-docstring-register nil)

(defun gd--write-back-docstring ()
  (interactive)
  (unless (eq (current-buffer) (get-buffer gd-edit-docstring-buffer))
    (set-buffer gd-edit-docstring-buffer))
  (goto-char (point-min))
  (while (re-search-forward "[\"']" nil t 1)
    (or (gd-escaped)
	(replace-match (concat "\\\\" (match-string-no-properties 0)))))
  (jump-to-register gd--edit-docstring-register)
  ;; (gd-restore-window-configuration)
  (delete-region gd--docbeg gd--docend)
  (insert-buffer gd-edit-docstring-buffer))

(defun gd-edit-docstring ()
  "Edit docstring or active region in gdscript-mode. "
  (interactive "*")
  (save-excursion
    (save-restriction
      (window-configuration-to-register gd--edit-docstring-register)
      (setq gd--oldbuf (current-buffer))
      (let ((orig (point))
	     pps)
	(gd--edit-docstring-set-vars)
	;; store relative position in docstring
	(setq relpos (1+ (- orig gd--docbeg)))
	(setq docstring (buffer-substring gd--docbeg gd--docend))
	(set (make-variable-buffer-local 'gd-edit-docstring-orig-pos) orig)
	(set-buffer (get-buffer-create gd-edit-docstring-buffer))
	(erase-buffer)
	(switch-to-buffer (current-buffer))
	(insert docstring)
	(gdscript-mode)
	(local-set-key [(control c)(control c)] 'gd--write-back-docstring)
	(goto-char relpos)
	(message "%s" "Type C-c C-c writes contents back")
	))))

;; gdscript-components-backward-forms


(defun gd-backward-block (&optional indent)
  "Go to beginning of `block'.

If already at beginning, go one `block' backward.
Returns beginning of `block' if successful, nil otherwise"
  (interactive)
  (gd--backward-prepare indent 'gd-block-re 'gd-clause-re (called-interactively-p 'any)))

(defun gd-backward-block-or-clause (&optional indent)
  "Go to beginning of `block-or-clause'.

If already at beginning, go one `block-or-clause' backward.
Returns beginning of `block-or-clause' if successful, nil otherwise"
  (interactive)
  (gd--backward-prepare indent 'gd-extended-block-or-clause-re 'gd-extended-block-or-clause-re (called-interactively-p 'any)))

(defun gd-backward-clause (&optional indent)
  "Go to beginning of `clause'.

If already at beginning, go one `clause' backward.
Returns beginning of `clause' if successful, nil otherwise"
  (interactive)
  (gd--backward-prepare indent 'gd-extended-block-or-clause-re 'gd-extended-block-or-clause-re (called-interactively-p 'any)))

(defun gd-backward-elif-block (&optional indent)
  "Go to beginning of `elif-block'.

If already at beginning, go one `elif-block' backward.
Returns beginning of `elif-block' if successful, nil otherwise"
  (interactive)
  (gd--backward-prepare indent 'gd-elif-block-re 'gd-clause-re (called-interactively-p 'any)))

(defun gd-backward-else-block (&optional indent)
  "Go to beginning of `else-block'.

If already at beginning, go one `else-block' backward.
Returns beginning of `else-block' if successful, nil otherwise"
  (interactive)
  (gd--backward-prepare indent 'gd-else-block-re 'gd-clause-re (called-interactively-p 'any)))

(defun gd-backward-except-block (&optional indent)
  "Go to beginning of `except-block'.

If already at beginning, go one `except-block' backward.
Returns beginning of `except-block' if successful, nil otherwise"
  (interactive)
  (gd--backward-prepare indent 'gd-except-block-re 'gd-clause-re (called-interactively-p 'any)))

(defun gd-backward-for-block (&optional indent)
  "Go to beginning of `for-block'.

If already at beginning, go one `for-block' backward.
Returns beginning of `for-block' if successful, nil otherwise"
  (interactive)
  (gd--backward-prepare indent 'gd-for-block-re 'gd-clause-re (called-interactively-p 'any)))

(defun gd-backward-if-block (&optional indent)
  "Go to beginning of `if-block'.

If already at beginning, go one `if-block' backward.
Returns beginning of `if-block' if successful, nil otherwise"
  (interactive)
  (gd--backward-prepare indent 'gd-if-block-re 'gd-clause-re (called-interactively-p 'any)))

(defun gd-backward-minor-block (&optional indent)
  "Go to beginning of `minor-block'.

If already at beginning, go one `minor-block' backward.
Returns beginning of `minor-block' if successful, nil otherwise"
  (interactive)
  (gd--backward-prepare indent 'gd-minor-block-re 'gd-clause-re (called-interactively-p 'any)))

(defun gd-backward-try-block (&optional indent)
  "Go to beginning of `try-block'.

If already at beginning, go one `try-block' backward.
Returns beginning of `try-block' if successful, nil otherwise"
  (interactive)
  (gd--backward-prepare indent 'gd-try-block-re 'gd-clause-re (called-interactively-p 'any)))

(defun gd-backward-block-bol (&optional indent)
  "Go to beginning of `block', go to BOL.

If already at beginning, go one `block' backward.
Returns beginning of `block' if successful, nil otherwise"
  (interactive)
  (gd--backward-prepare indent 'gd-block-re 'gd-clause-re (called-interactively-p 'any) t))

(defun gd-backward-block-or-clause-bol (&optional indent)
  "Go to beginning of `block-or-clause', go to BOL.

If already at beginning, go one `block-or-clause' backward.
Returns beginning of `block-or-clause' if successful, nil otherwise"
  (interactive)
  (gd--backward-prepare indent 'gd-extended-block-or-clause-re 'gd-extended-block-or-clause-re (called-interactively-p 'any) t))

(defun gd-backward-clause-bol (&optional indent)
  "Go to beginning of `clause', go to BOL.

If already at beginning, go one `clause' backward.
Returns beginning of `clause' if successful, nil otherwise"
  (interactive)
  (gd--backward-prepare indent 'gd-extended-block-or-clause-re 'gd-extended-block-or-clause-re (called-interactively-p 'any) t))

(defun gd-backward-elif-block-bol (&optional indent)
  "Go to beginning of `elif-block', go to BOL.

If already at beginning, go one `elif-block' backward.
Returns beginning of `elif-block' if successful, nil otherwise"
  (interactive)
  (gd--backward-prepare indent 'gd-elif-block-re 'gd-clause-re (called-interactively-p 'any) t))

(defun gd-backward-else-block-bol (&optional indent)
  "Go to beginning of `else-block', go to BOL.

If already at beginning, go one `else-block' backward.
Returns beginning of `else-block' if successful, nil otherwise"
  (interactive)
  (gd--backward-prepare indent 'gd-else-block-re 'gd-clause-re (called-interactively-p 'any) t))

(defun gd-backward-except-block-bol (&optional indent)
  "Go to beginning of `except-block', go to BOL.

If already at beginning, go one `except-block' backward.
Returns beginning of `except-block' if successful, nil otherwise"
  (interactive)
  (gd--backward-prepare indent 'gd-except-block-re 'gd-clause-re (called-interactively-p 'any) t))

(defun gd-backward-for-block-bol (&optional indent)
  "Go to beginning of `for-block', go to BOL.

If already at beginning, go one `for-block' backward.
Returns beginning of `for-block' if successful, nil otherwise"
  (interactive)
  (gd--backward-prepare indent 'gd-for-block-re 'gd-clause-re (called-interactively-p 'any) t))

(defun gd-backward-if-block-bol (&optional indent)
  "Go to beginning of `if-block', go to BOL.

If already at beginning, go one `if-block' backward.
Returns beginning of `if-block' if successful, nil otherwise"
  (interactive)
  (gd--backward-prepare indent 'gd-if-block-re 'gd-clause-re (called-interactively-p 'any) t))

(defun gd-backward-minor-block-bol (&optional indent)
  "Go to beginning of `minor-block', go to BOL.

If already at beginning, go one `minor-block' backward.
Returns beginning of `minor-block' if successful, nil otherwise"
  (interactive)
  (gd--backward-prepare indent 'gd-minor-block-re 'gd-clause-re (called-interactively-p 'any) t))

(defun gd-backward-try-block-bol (&optional indent)
  "Go to beginning of `try-block', go to BOL.

If already at beginning, go one `try-block' backward.
Returns beginning of `try-block' if successful, nil otherwise"
  (interactive)
  (gd--backward-prepare indent 'gd-try-block-re 'gd-clause-re (called-interactively-p 'any) t))

;; gdscript-components-forward-forms


(defun gd-forward-block (&optional indent)
  "Go to end of block.

Returns end of block if successful, nil otherwise"
  (interactive "P")
  (let* ((orig (point))
         (erg (gd--end-base 'gd-block-re orig)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-forward-block-bol (&optional indent)
  "Goto beginning of line following end of block.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-block': down from current definition to next beginning of block below. "
  (interactive)
  (let ((erg (gd-forward-block indent)))
    (setq erg (gd--beginning-of-line-form erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-forward-block-or-clause (&optional indent)
  "Go to end of block-or-clause.

Returns end of block-or-clause if successful, nil otherwise"
  (interactive "P")
  (let* ((orig (point))
         (erg (gd--end-base 'gd-block-or-clause-re orig)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-forward-block-or-clause-bol (&optional indent)
  "Goto beginning of line following end of block-or-clause.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-block-or-clause': down from current definition to next beginning of block-or-clause below. "
  (interactive)
  (let ((erg (gd-forward-block-or-clause indent)))
    (setq erg (gd--beginning-of-line-form erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-forward-class (&optional indent)
  "Go to end of class.

Returns end of class if successful, nil otherwise"
  (interactive "P")
  (let* ((orig (point))
         (erg (gd--end-base 'gd-class-re orig)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-forward-class-bol (&optional indent)
  "Goto beginning of line following end of class.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-class': down from current definition to next beginning of class below. "
  (interactive)
  (let ((erg (gd-forward-class indent)))
    (setq erg (gd--beginning-of-line-form erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-forward-clause (&optional indent)
  "Go to end of clause.

Returns end of clause if successful, nil otherwise"
  (interactive "P")
  (let* ((orig (point))
         (erg (gd--end-base 'gd-clause-re orig)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-forward-clause-bol (&optional indent)
  "Goto beginning of line following end of clause.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-clause': down from current definition to next beginning of clause below. "
  (interactive)
  (let ((erg (gd-forward-clause indent)))
    (setq erg (gd--beginning-of-line-form erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-forward-def-or-class (&optional indent)
  "Go to end of def-or-class.

Returns end of def-or-class if successful, nil otherwise"
  (interactive "P")
  (let* ((orig (point))
         (erg (gd--end-base 'gd-def-or-class-re orig)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-forward-def-or-class-bol (&optional indent)
  "Goto beginning of line following end of def-or-class.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-def-or-class': down from current definition to next beginning of def-or-class below. "
  (interactive)
  (let ((erg (gd-forward-def-or-class indent)))
    (setq erg (gd--beginning-of-line-form erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-forward-def (&optional indent)
  "Go to end of def.

Returns end of def if successful, nil otherwise"
  (interactive "P")
  (let* ((orig (point))
         (erg (gd--end-base 'gd-def-re orig)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-forward-def-bol (&optional indent)
  "Goto beginning of line following end of def.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-def': down from current definition to next beginning of def below. "
  (interactive)
  (let ((erg (gd-forward-def indent)))
    (setq erg (gd--beginning-of-line-form erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-forward-if-block (&optional indent)
  "Go to end of if-block.

Returns end of if-block if successful, nil otherwise"
  (interactive "P")
  (let* ((orig (point))
         (erg (gd--end-base 'gd-if-block-re orig)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-forward-if-block-bol (&optional indent)
  "Goto beginning of line following end of if-block.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-if-block': down from current definition to next beginning of if-block below. "
  (interactive)
  (let ((erg (gd-forward-if-block indent)))
    (setq erg (gd--beginning-of-line-form erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-forward-elif-block (&optional indent)
  "Go to end of elif-block.

Returns end of elif-block if successful, nil otherwise"
  (interactive "P")
  (let* ((orig (point))
         (erg (gd--end-base 'gd-elif-block-re orig)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-forward-elif-block-bol (&optional indent)
  "Goto beginning of line following end of elif-block.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-elif-block': down from current definition to next beginning of elif-block below. "
  (interactive)
  (let ((erg (gd-forward-elif-block indent)))
    (setq erg (gd--beginning-of-line-form erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-forward-else-block (&optional indent)
  "Go to end of else-block.

Returns end of else-block if successful, nil otherwise"
  (interactive "P")
  (let* ((orig (point))
         (erg (gd--end-base 'gd-else-block-re orig)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-forward-else-block-bol (&optional indent)
  "Goto beginning of line following end of else-block.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-else-block': down from current definition to next beginning of else-block below. "
  (interactive)
  (let ((erg (gd-forward-else-block indent)))
    (setq erg (gd--beginning-of-line-form erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-forward-for-block (&optional indent)
  "Go to end of for-block.

Returns end of for-block if successful, nil otherwise"
  (interactive "P")
  (let* ((orig (point))
         (erg (gd--end-base 'gd-for-block-re orig)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-forward-for-block-bol (&optional indent)
  "Goto beginning of line following end of for-block.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-for-block': down from current definition to next beginning of for-block below. "
  (interactive)
  (let ((erg (gd-forward-for-block indent)))
    (setq erg (gd--beginning-of-line-form erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-forward-except-block (&optional indent)
  "Go to end of except-block.

Returns end of except-block if successful, nil otherwise"
  (interactive "P")
  (let* ((orig (point))
         (erg (gd--end-base 'gd-except-block-re orig)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))


(defun gd-forward-minor-block (&optional indent)
  "Go to end of minor-block.

Returns end of minor-block if successful, nil otherwise"
  (interactive "P")
  (let* ((orig (point))
         (erg (gd--end-base 'gd-minor-block-re orig)))
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-forward-minor-block-bol (&optional indent)
  "Goto beginning of line following end of minor-block.
  Returns position reached, if successful, nil otherwise.

See also `gd-down-minor-block': down from current definition to next beginning of minor-block below. "
  (interactive)
  (let ((erg (gd-forward-minor-block indent)))
    (setq erg (gd--beginning-of-line-form erg))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

;; gdscript-components-forward-forms.el ends here
;; gdscript-components-move

;; Indentation
;; Travel current level of indentation
(defun gd--travel-this-indent-backward ()
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
      (gd--travel-this-indent-backward)
      (when erg (goto-char erg))
      (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
      erg)))

(defun gd--travel-this-indent-backward-bol ()
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
      (gd--travel-this-indent-backward-bol)
      ;; (when erg (goto-char erg)
      ;; (beginning-of-line)
      ;; (setq erg (point)))
      (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
      erg)))

(defun gd--travel-this-indent-forward ()
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
      (gd--travel-this-indent-forward)
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
      (gd--travel-this-indent-forward)
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
    (when (gd--in-comment-p)
      (gd-backward-comment)
      (skip-chars-backward " \t\r\n\f"))
    ;; part of gd-partial-expression-forward-chars
    (when (member (char-after) (list ?\ ?\" ?' ?\) ?} ?\] ?: ?#))
      (forward-char -1))
    (skip-chars-backward gd-partial-expression-forward-chars)
    (when (< 0 (abs (skip-chars-backward gd-partial-expression-backward-chars)))
      (while (and (not (bobp)) (gd--in-comment-p)(< 0 (abs (skip-chars-backward gd-partial-expression-backward-chars))))))
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
	  (when (gd--skip-to-semicolon-backward (save-excursion (back-to-indentation)(point)))
	    (setq done t))
          (gd-backward-statement orig done limit ignore-in-string-p))
         ((gd-preceding-line-backslashed-p)
          (forward-line -1)
          (back-to-indentation)
          (setq done t)
          (gd-backward-statement orig done limit ignore-in-string-p))
	 ;; at raw-string
	 ;; (and (looking-at "\"\"\"\\|'''") (member (char-before) (list ?u ?U ?r ?R)))
	 ((gd--at-raw-string)
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
	  (when (gd--skip-to-semicolon-backward (save-excursion (back-to-indentation)(point)))
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
	 ((and (not done) (gd--skip-to-semicolon-backward (save-excursion (back-to-indentation)(point))))
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
      (unless done (gd--skip-to-comment-or-semicolon done))
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
		(setq err (gd--record-list-error pps))
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
	(gd--end-of-comment-intern (point))
	(gd--skip-to-comment-or-semicolon done)
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
	(gd--skip-to-comment-or-semicolon done)
	(gd-forward-statement orig done repeat))
       ((eq (current-indentation) (current-column))
	(gd--skip-to-comment-or-semicolon done)
	;; (setq pps (parse-partial-sexp (point-min) (point)))
	(unless done
	  (gd-forward-statement orig done repeat)))

       ((and (looking-at "[[:print:]]+$") (not done) (gd--skip-to-comment-or-semicolon done))
	(gd-forward-statement orig done repeat)))
      (unless
	  (or
	   (eq (point) orig)
	   (member (char-before) (list 10 32 9 ?#)))
	(setq erg (point)))
      (if (and gd-verbose-p err)
	  (gd--message-error err)
        (and gd-verbose-p (called-interactively-p 'any) (message "%s" erg)))
      erg)))

(defun gd-forward-statement-bol ()
  "Go to the beginning-of-line following current statement."
  (interactive)
  (let ((erg (gd-forward-statement)))
    (setq erg (gd--beginning-of-line-form erg))
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
		 (when (gd--in-comment-p)
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

(defun gd--go-to-keyword (regexp &optional maxindent)
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

(defun gd--clause-lookup-keyword (regexp arg &optional indent orig origline)
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
          (cond
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
         ((and (looking-at "\\<else\\>[: \n\t]")(save-match-data (string-match "else" regexp)))
          (setq indent (current-indentation))
          (setq count (1+ count))
          (while
              (and
               (not (eval stop))
               (funcall function)
               (setq done t)
               (not (and (eq indent (current-indentation)) (looking-at "if"))))))
         ((and (looking-at "\\_<else\\>[: \n\t]")(save-match-data (string-match "else" regexp)))
          (setq indent (current-indentation))
          (setq count (1+ count))
          (while
              (and
               (not (eval stop))
               (funcall function)
               (setq done t)
               (not (and (eq indent (current-indentation)) (looking-at "if"))))))
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

(defun gd--travel-current-indent (indent &optional orig)
  "Moves down until clause is closed, i.e. current indentation is reached.

Takes a list, INDENT and START position. "
  (unless (eobp)
    (let ((orig (or orig (point)))
          last)
      (while (and (setq last (point))(not (eobp))(gd-forward-statement)
                  (save-excursion (or (<= indent (progn  (gd-backward-statement)(current-indentation)))(eq last (line-beginning-position))))
                  ;; (gd--end-of-statement-p)
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

(defun gd--backward-def-or-class-decorator-maybe (&optional bol)
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

(defun gd--backward-def-or-class-matcher (regexp indent origline)
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

(defun gd--backward-def-or-class-intern (regexp &optional bol)
  (let ((origline (gd-count-lines))
	(indent (if (empty-line-p)
		    (current-indentation)
		  (save-excursion
		    (if (gd--beginning-of-statement-p)
			(current-indentation)
		      (gd-backward-statement)
		      (current-indentation)))))
	erg)
    ;; (if (and (< (current-column) origindent) (looking-at regexp))
    ;; (setq erg (point))
    (setq erg (gd--backward-def-or-class-matcher regexp indent origline))
    (and erg (looking-back "static ")
	 (goto-char (match-beginning 0))
	 (setq erg (point)))
    ;; bol-forms at not at bol yet
    (and bol erg (beginning-of-line) (setq erg (point)))
    (and erg gd-mark-decorators (setq erg (gd--backward-def-or-class-decorator-maybe bol)))
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
	   (gd--backward-def-or-class-intern gd-class-re))))
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
	       (gd--backward-def-or-class-intern gd-def-re))))
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
	       (gd--backward-def-or-class-intern gd-def-or-class-re))))
    (when (and gd-verbose-p (called-interactively-p 'any))
      (message "%s" erg))
    erg))

(defun gd-backward-class-bol ()
  "Go to beginning of class, go to BOL.

If already at beginning, go one class backward.
Returns beginning of class if successful, nil otherwise

When `gd-mark-decorators' is non-nil, decorators are considered too. "
  (interactive)
  (let ((erg (gd--backward-def-or-class-intern gd-class-re t)))
    (when (and gd-verbose-p (called-interactively-p 'any))
      (message "%s" erg))
    erg))

(defun gd-backward-def-bol ()
  "Go to beginning of def, go to BOL.

If already at beginning, go one def backward.
Returns beginning of def if successful, nil otherwise

When `gd-mark-decorators' is non-nil, decorators are considered too. "
  (interactive)
  (let ((erg (gd--backward-def-or-class-intern gd-def-re t)))
    (when (and gd-verbose-p (called-interactively-p 'any))
      (message "%s" erg))
    erg))

(defun gd-backward-def-or-class-bol ()
  "Go to beginning of def-or-class, go to BOL.

If already at beginning, go one def-or-class backward.
Returns beginning of def-or-class if successful, nil otherwise

When `gd-mark-decorators' is non-nil, decorators are considered too. "
  (interactive)
  (let ((erg (gd--backward-def-or-class-intern gd-def-or-class-re t)))
    (when (and gd-verbose-p (called-interactively-p 'any))
      (message "%s" erg))
    erg))

;; gdscript-components-kill-forms


(defun gd-kill-comment ()
  "Delete comment at point.

Stores data in kill ring"
  (interactive "*")
  (let ((erg (gd--mark-base "comment")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-line ()
  "Delete line at point.

Stores data in kill ring"
  (interactive "*")
  (let ((erg (gd--mark-base "line")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-paragraph ()
  "Delete paragraph at point.

Stores data in kill ring"
  (interactive "*")
  (let ((erg (gd--mark-base "paragraph")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-expression ()
  "Delete expression at point.

Stores data in kill ring"
  (interactive "*")
  (let ((erg (gd--mark-base "expression")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-partial-expression ()
  "Delete partial-expression at point.

Stores data in kill ring"
  (interactive "*")
  (let ((erg (gd--mark-base "partial-expression")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-section ()
  "Delete section at point.

Stores data in kill ring"
  (interactive "*")
  (let ((erg (gd--mark-base "section")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-top-level ()
  "Delete top-level at point.

Stores data in kill ring"
  (interactive "*")
  (let ((erg (gd--mark-base "top-level")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-block ()
  "Delete block at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (gd--mark-base-bol "block")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-block-or-clause ()
  "Delete block-or-clause at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (gd--mark-base-bol "block-or-clause")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-class ()
  "Delete class at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (gd--mark-base-bol "class")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-clause ()
  "Delete clause at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (gd--mark-base-bol "clause")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-def ()
  "Delete def at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (gd--mark-base-bol "def")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-def-or-class ()
  "Delete def-or-class at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (gd--mark-base-bol "def-or-class")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-elif-block ()
  "Delete elif-block at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (gd--mark-base-bol "elif-block")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-else-block ()
  "Delete else-block at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (gd--mark-base-bol "else-block")))
    (kill-region (car erg) (cdr erg))))


(defun gd-kill-for-block ()
  "Delete for-block at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (gd--mark-base-bol "for-block")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-if-block ()
  "Delete if-block at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (gd--mark-base-bol "if-block")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-indent ()
  "Delete indent at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (gd--mark-base-bol "indent")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-minor-block ()
  "Delete minor-block at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (gd--mark-base-bol "minor-block")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-statement ()
  "Delete statement at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (gd--mark-base-bol "statement")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-top-level ()
  "Delete top-level at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (gd--mark-base-bol "top-level")))
    (kill-region (car erg) (cdr erg))))

(defun gd-kill-try-block ()
  "Delete try-block at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (let ((erg (gd--mark-base-bol "try-block")))
    (kill-region (car erg) (cdr erg))))

;; gdscript-components-mark-forms


(defun gd-mark-comment ()
  "Mark comment at point.

Returns beginning and end positions of marked area, a cons. "
  (interactive)
  (let (erg)
    (setq erg (gd--mark-base "comment"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-line ()
  "Mark line at point.

Returns beginning and end positions of marked area, a cons. "
  (interactive)
  (let (erg)
    (setq erg (gd--mark-base "line"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-paragraph ()
  "Mark paragraph at point.

Returns beginning and end positions of marked area, a cons. "
  (interactive)
  (let (erg)
    (setq erg (gd--mark-base "paragraph"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-expression ()
  "Mark expression at point.

Returns beginning and end positions of marked area, a cons. "
  (interactive)
  (let (erg)
    (setq erg (gd--mark-base "expression"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-partial-expression ()
  "Mark partial-expression at point.

Returns beginning and end positions of marked area, a cons. "
  (interactive)
  (let (erg)
    (setq erg (gd--mark-base "partial-expression"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-section ()
  "Mark section at point.

Returns beginning and end positions of marked area, a cons. "
  (interactive)
  (let (erg)
    (setq erg (gd--mark-base "section"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-top-level ()
  "Mark top-level at point.

Returns beginning and end positions of marked area, a cons. "
  (interactive)
  (let (erg)
    (setq erg (gd--mark-base "top-level"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-block ()
  "Mark block, take beginning of line positions. 

Returns beginning and end positions of region, a cons. "
  (interactive)
  (let (erg)
    (setq erg (gd--mark-base-bol "block"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-block-or-clause ()
  "Mark block-or-clause, take beginning of line positions. 

Returns beginning and end positions of region, a cons. "
  (interactive)
  (let (erg)
    (setq erg (gd--mark-base-bol "block-or-clause"))
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
    (gd--mark-base-bol "class" gd-mark-decorators)
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-clause ()
  "Mark clause, take beginning of line positions. 

Returns beginning and end positions of region, a cons. "
  (interactive)
  (let (erg)
    (setq erg (gd--mark-base-bol "clause"))
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
    (gd--mark-base-bol "def" gd-mark-decorators)
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
    (gd--mark-base-bol "def-or-class" gd-mark-decorators)
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-elif-block ()
  "Mark elif-block, take beginning of line positions. 

Returns beginning and end positions of region, a cons. "
  (interactive)
  (let (erg)
    (setq erg (gd--mark-base-bol "elif-block"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-else-block ()
  "Mark else-block, take beginning of line positions. 

Returns beginning and end positions of region, a cons. "
  (interactive)
  (let (erg)
    (setq erg (gd--mark-base-bol "else-block"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))


(defun gd-mark-for-block ()
  "Mark for-block, take beginning of line positions. 

Returns beginning and end positions of region, a cons. "
  (interactive)
  (let (erg)
    (setq erg (gd--mark-base-bol "for-block"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-if-block ()
  "Mark if-block, take beginning of line positions. 

Returns beginning and end positions of region, a cons. "
  (interactive)
  (let (erg)
    (setq erg (gd--mark-base-bol "if-block"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-indent ()
  "Mark indent, take beginning of line positions. 

Returns beginning and end positions of region, a cons. "
  (interactive)
  (let (erg)
    (setq erg (gd--mark-base-bol "indent"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-minor-block ()
  "Mark minor-block, take beginning of line positions. 

Returns beginning and end positions of region, a cons. "
  (interactive)
  (let (erg)
    (setq erg (gd--mark-base-bol "minor-block"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-statement ()
  "Mark statement, take beginning of line positions. 

Returns beginning and end positions of region, a cons. "
  (interactive)
  (let (erg)
    (setq erg (gd--mark-base-bol "statement"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))

(defun gd-mark-top-level ()
  "Mark top-level, take beginning of line positions. 

Returns beginning and end positions of region, a cons. "
  (interactive)
  (let (erg)
    (setq erg (gd--mark-base-bol "top-level"))
    (exchange-point-and-mark)
    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" erg))
    erg))


;; gdscript-components-copy-forms


(defun gd-copy-block ()
  "Copy block at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "block")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-block-or-clause ()
  "Copy block-or-clause at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "block-or-clause")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-buffer ()
  "Copy buffer at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "buffer")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-class ()
  "Copy class at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "class")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-clause ()
  "Copy clause at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "clause")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-def ()
  "Copy def at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "def")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-def-or-class ()
  "Copy def-or-class at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "def-or-class")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-expression ()
  "Copy expression at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "expression")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-indent ()
  "Copy indent at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "indent")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-line ()
  "Copy line at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "line")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-minor-block ()
  "Copy minor-block at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "minor-block")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-paragraph ()
  "Copy paragraph at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "paragraph")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-partial-expression ()
  "Copy partial-expression at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "partial-expression")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-region ()
  "Copy region at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "region")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-statement ()
  "Copy statement at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "statement")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-top-level ()
  "Copy top-level at point.

Store data in kill ring, so it might yanked back. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "top-level")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-block-bol ()
  "Delete block bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "block")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-block-or-clause-bol ()
  "Delete block-or-clause bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "block-or-clause")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-buffer-bol ()
  "Delete buffer bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "buffer")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-class-bol ()
  "Delete class bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "class")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-clause-bol ()
  "Delete clause bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "clause")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-def-bol ()
  "Delete def bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "def")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-def-or-class-bol ()
  "Delete def-or-class bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "def-or-class")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-expression-bol ()
  "Delete expression bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "expression")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-indent-bol ()
  "Delete indent bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "indent")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-line-bol ()
  "Delete line bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "line")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-minor-block-bol ()
  "Delete minor-block bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "minor-block")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-paragraph-bol ()
  "Delete paragraph bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "paragraph")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-partial-expression-bol ()
  "Delete partial-expression bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "partial-expression")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-region-bol ()
  "Delete region bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "region")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-statement-bol ()
  "Delete statement bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "statement")))
      (copy-region-as-kill (car erg) (cdr erg)))))

(defun gd-copy-top-level-bol ()
  "Delete top-level bol at point.

Stores data in kill ring. Might be yanked back using `C-y'. "
  (interactive "*")
  (save-excursion
    (let ((erg (gd--mark-base-bol "top-level")))
      (copy-region-as-kill (car erg) (cdr erg)))))

;; gdscript-components-delete-forms


(defun gd-delete-block ()
  "Delete BLOCK at point until beginning-of-line.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (gd--mark-base-bol "block")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-block-or-clause ()
  "Delete BLOCK-OR-CLAUSE at point until beginning-of-line.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (gd--mark-base-bol "block-or-clause")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-class (&optional arg)
  "Delete CLASS at point until beginning-of-line.

Don't store data in kill ring. 
With \\[universal-argument] or `gd-mark-decorators' set to `t', `decorators' are included."
  (interactive "P")
 (let* ((gd-mark-decorators (or arg gd-mark-decorators))
        (erg (gd--mark-base "class" gd-mark-decorators)))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-clause ()
  "Delete CLAUSE at point until beginning-of-line.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (gd--mark-base-bol "clause")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-def (&optional arg)
  "Delete DEF at point until beginning-of-line.

Don't store data in kill ring. 
With \\[universal-argument] or `gd-mark-decorators' set to `t', `decorators' are included."
  (interactive "P")
 (let* ((gd-mark-decorators (or arg gd-mark-decorators))
        (erg (gd--mark-base "def" gd-mark-decorators)))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-def-or-class (&optional arg)
  "Delete DEF-OR-CLASS at point until beginning-of-line.

Don't store data in kill ring. 
With \\[universal-argument] or `gd-mark-decorators' set to `t', `decorators' are included."
  (interactive "P")
 (let* ((gd-mark-decorators (or arg gd-mark-decorators))
        (erg (gd--mark-base "def-or-class" gd-mark-decorators)))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-elif-block ()
  "Delete ELIF-BLOCK at point until beginning-of-line.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (gd--mark-base-bol "elif-block")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-else-block ()
  "Delete ELSE-BLOCK at point until beginning-of-line.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (gd--mark-base-bol "else-block")))
    (delete-region (car erg) (cdr erg))))


(defun gd-delete-for-block ()
  "Delete FOR-BLOCK at point until beginning-of-line.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (gd--mark-base-bol "for-block")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-if-block ()
  "Delete IF-BLOCK at point until beginning-of-line.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (gd--mark-base-bol "if-block")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-indent ()
  "Delete INDENT at point until beginning-of-line.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (gd--mark-base-bol "indent")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-minor-block ()
  "Delete MINOR-BLOCK at point until beginning-of-line.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (gd--mark-base-bol "minor-block")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-statement ()
  "Delete STATEMENT at point until beginning-of-line.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (gd--mark-base-bol "statement")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-top-level ()
  "Delete TOP-LEVEL at point until beginning-of-line.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (gd--mark-base-bol "top-level")))
    (delete-region (car erg) (cdr erg))))


(defun gd-delete-comment ()
  "Delete COMMENT at point.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (gd--mark-base "comment")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-line ()
  "Delete LINE at point.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (gd--mark-base "line")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-paragraph ()
  "Delete PARAGRAPH at point.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (gd--mark-base "paragraph")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-expression ()
  "Delete EXPRESSION at point.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (gd--mark-base "expression")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-partial-expression ()
  "Delete PARTIAL-EXPRESSION at point.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (gd--mark-base "partial-expression")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-section ()
  "Delete SECTION at point.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (gd--mark-base "section")))
    (delete-region (car erg) (cdr erg))))

(defun gd-delete-top-level ()
  "Delete TOP-LEVEL at point.

Don't store data in kill ring. "
  (interactive)
  (let ((erg (gd--mark-base "top-level")))
    (delete-region (car erg) (cdr erg))))

;; gdscript-components-execute
;; I AM HERE
;; gdscript  documentation

;;  Documentation functions
;;  dump the long form of the mode blurb; does the usual doc escapes,
;;  plus lines of the form ^[vc]:name\$ to suck variable & command docs
;;  out of the right places, along with the keys they're on & current
;;  values

(defun gd--dump-help-string (str)
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
          (error "Error in gd--dump-help-string, tag `%s'" funckind)))
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
  (gd--dump-help-string "Major mode for editing GDScript files.
Knows about GDScript indentation, tokens, comments and continuation lines.
Paragraphs are separated by blank lines only.

Major sections below begin with the string `@'; specific function and
variable docs begin with `->'.


@VARIABLES

gd-indent-offset\tindentation increment
gd-block-comment-prefix\tcomment string used by comment-region
gd-temp-directory\tdirectory used for temp files (if needed)

gd-beep-if-tab-change\tring the bell if tab-width is changed
%v:gd-indent-offset
%v:gd-block-comment-prefix
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
;; WAYPOINT 2

(defvar gd-chars-before " \t\n\r\f"
  "Used by `gd--string-strip'")

(defvar gd-chars-after " \t\n\r\f"
    "Used by `gd--string-strip'")

;;  (setq strip-chars-before  "[ \t\r\n]*")
(defun gd--string-strip (str &optional chars-before chars-after)
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
      (if (and (gd--in-comment-p)(not gd-indent-comments))
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

(defun gd--close-intern (regexp)
  "Core function, internal used only. "
  (let ((cui (car (gd--go-to-keyword (symbol-value regexp)))))
    (message "%s" cui)
    (gd--end-base regexp (point))
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
  (let ((erg (gd--close-intern 'gd-def-re)))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-close-class ()
  "Set indent level to that of beginning of class definition.

If final line isn't empty and `gd-close-block-provides-newline' non-nil, insert a newline. "
  (interactive "*")
  (let ((erg (gd--close-intern 'gd-class-re)))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-close-def-or-class ()
  "Set indent level to that of beginning of def-or-class definition.

If final line isn't empty and `gd-close-block-provides-newline' non-nil, insert a newline. "
  (interactive "*")
  (let ((erg (gd--close-intern 'gd-def-or-class-re)))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-close-clause ()
  "Set indent level to that of beginning of clause definition.

If final line isn't empty and `gd-close-block-provides-newline' non-nil, insert a newline. "
  (interactive "*")
  (let ((erg (gd--close-intern 'gd-block-or-clause-re)))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-close-block ()
  "Set indent level to that of beginning of block definition.

If final line isn't empty and `gd-close-block-provides-newline' non-nil, insert a newline. "
  (interactive "*")
  (let ((erg (gd--close-intern 'gd-block-re)))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-close-block-or-clause ()
  "Set indent level to that of beginning of block-or-clause definition.

If final line isn't empty and `gd-close-block-or-clause-provides-newline' non-nil, insert a newline. "
  (interactive "*")
  (let ((erg (gd--close-intern 'gd-block-or-clause-re)))
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

(defun gd--match-end-finish (cui)
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

(defun gd--match-paren-forward ()
  (setq gd--match-paren-forward-p t)
  (let ((cui (current-indentation)))
    (cond
     ((gd--beginning-of-top-level-p)
      (gd-forward-top-level-bol)
      (gd--match-end-finish cui))
     ((gd--beginning-of-class-p)
      (gd-forward-class-bol cui)
      (gd--match-end-finish cui))
     ((gd--beginning-of-def-p)
      (gd-forward-def-bol cui)
      (gd--match-end-finish cui))
     ((gd--beginning-of-if-block-p)
      (gd-forward-if-block-bol cui)
      (gd--match-end-finish cui))
     ((gd--beginning-of-try-block-p)
      (gd-forward-try-block-bol cui)
      (gd--match-end-finish cui))
     ((gd--beginning-of-for-block-p)
      (gd-forward-for-block-bol cui)
      (gd--match-end-finish cui))
     ((gd--beginning-of-block-p)
      (gd-forward-block-bol)
      (gd--match-end-finish cui))
     ((gd--beginning-of-clause-p)
      (gd-forward-clause-bol)
      (gd--match-end-finish cui))
     ((gd--beginning-of-statement-p)
      (gd-forward-statement-bol)
      (gd--match-end-finish cui))
     (t (gd-forward-statement)
	(gd--match-end-finish cui)))))

(defun gd--match-paren-backward ()
  (setq gd--match-paren-forward-p nil)
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

(defun gd--match-paren-blocks ()
  (cond
   ((and (looking-back "^[ \t]*")(if (eq last-command 'gd-match-paren)(not gd--match-paren-forward-p)t)
	 ;; (looking-at gd-extended-block-or-clause-re)
	 (looking-at "[[:alpha:]_]"))
    ;; from beginning of top-level, block, clause, statement
    (gd--match-paren-forward))
   (t
    (gd--match-paren-backward))))

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
       (not gd--match-paren-forward-p)
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
      (gd--match-paren-blocks)))))

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


(defun gd-move-breakpoint ()
  "Kill previous \"pdb.set_trace()\" and insert it at point. "
  (interactive "*")
  (let ((orig (copy-marker (point))))
    (search-backward "breakpoint")
    (replace-match "")
    (when (empty-line-p)
      (delete-region (line-beginning-position) (line-end-position)))
    (goto-char orig)
    (insert "breakpoint")))


(defun gd-printform-insert (&optional arg string)
  "Inserts a print statement out of current `(car kill-ring)' by default, inserts STRING if delivered.

With optional \\[universal-argument] print as string"
  (interactive "*P")
  (let* ((name (gd--string-strip (or arg (car kill-ring))))
         ;; guess if doublequotes or parentheses are needed
         (numbered (not (eq 4 (prefix-numeric-value arg))))
         (form (cond ((or (eq major-mode 'gdscript-mode)(eq major-mode 'gd-shell-mode))
                      (if numbered
                          (concat "print(\"" name ": %s \" % (" name "))")
                        (concat "print(\"" name ": %s \" % \"" name "\")"))))))
    (insert form)))


(defun gd-line-to-printform (&optional arg)
  "Transforms the item on current line in a print statement. "
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
    (unless (gd--end-of-statement-p)
      (gd-forward-statement))
    (backward-word)
    (cond ((looking-at "true")
           (replace-match "false"))
          ((looking-at "false")
           (replace-match "true"))
          (t (message "%s" "Can't see \"true or false\" here")))))

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

;; WAYPOINT 3
;; TODO MAYBE DELETE ALL OF ELECTRIC
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
        ((and gd-electric-colon-bobl-only (save-excursion (gd-backward-statement) (not (gd--beginning-of-block-p))))
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
                           (and (gd--top-level-form-p)(< (current-indentation) indent)))
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

;; gdscript-components-booleans-beginning-forms


(defun gd--beginning-of-comment-p ()
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

(defun gd--beginning-of-line-p ()
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

(defun gd--beginning-of-paragraph-p ()
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

(defun gd--beginning-of-expression-p ()
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

(defun gd--beginning-of-partial-expression-p ()
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

(defun gd--beginning-of-section-p ()
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

(defun gd--beginning-of-top-level-p ()
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

(defun gd--beginning-of-block-bol-p ()
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

(defun gd--beginning-of-block-or-clause-bol-p ()
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

(defun gd--beginning-of-class-bol-p ()
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

(defun gd--beginning-of-clause-bol-p ()
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

(defun gd--beginning-of-def-bol-p ()
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

(defun gd--beginning-of-def-or-class-bol-p ()
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

(defun gd--beginning-of-elif-block-bol-p ()
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

(defun gd--beginning-of-else-block-bol-p ()
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

(defun gd--beginning-of-except-block-bol-p ()
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

(defun gd--beginning-of-for-block-bol-p ()
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

(defun gd--beginning-of-if-block-bol-p ()
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

(defun gd--beginning-of-indent-bol-p ()
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

(defun gd--beginning-of-minor-block-bol-p ()
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

(defun gd--beginning-of-statement-bol-p ()
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

(defun gd--beginning-of-top-level-bol-p ()
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

(defun gd--beginning-of-try-block-bol-p ()
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

(defun gd--beginning-of-block-p ()
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

(defun gd--beginning-of-block-or-clause-p ()
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

(defun gd--beginning-of-class-p ()
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

(defun gd--beginning-of-clause-p ()
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

(defun gd--beginning-of-def-p ()
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

(defun gd--beginning-of-def-or-class-p ()
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

(defun gd--beginning-of-elif-block-p ()
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

(defun gd--beginning-of-else-block-p ()
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

(defun gd--beginning-of-except-block-p ()
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

(defun gd--beginning-of-for-block-p ()
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

(defun gd--beginning-of-if-block-p ()
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

(defun gd--beginning-of-indent-p ()
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

(defun gd--beginning-of-minor-block-p ()
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

(defun gd--beginning-of-statement-p ()
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

(defun gd--beginning-of-top-level-p ()
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

(defun gd--beginning-of-try-block-p ()
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


(defun gd--end-of-comment-p ()
  "Returns position, if cursor is at the end of a comment, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-comment)
      (gd-forward-comment)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-line-p ()
  "Returns position, if cursor is at the end of a line, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-line)
      (gd-forward-line)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-paragraph-p ()
  "Returns position, if cursor is at the end of a paragraph, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-paragraph)
      (gd-forward-paragraph)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-expression-p ()
  "Returns position, if cursor is at the end of a expression, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-expression)
      (gd-forward-expression)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-partial-expression-p ()
  "Returns position, if cursor is at the end of a partial-expression, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-partial-expression)
      (gd-forward-partial-expression)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-section-p ()
  "Returns position, if cursor is at the end of a section, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-section)
      (gd-forward-section)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-top-level-p ()
  "Returns position, if cursor is at the end of a top-level, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-top-level)
      (gd-forward-top-level)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-block-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-block-bol)
      (gd-forward-block-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-block-or-clause-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a block-or-clause, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-block-or-clause-bol)
      (gd-forward-block-or-clause-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-class-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a class, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-class-bol)
      (gd-forward-class-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-clause-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a clause, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-clause-bol)
      (gd-forward-clause-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-def-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a def, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-def-bol)
      (gd-forward-def-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-def-or-class-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a def-or-class, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-def-or-class-bol)
      (gd-forward-def-or-class-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-elif-block-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a elif-block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-elif-block-bol)
      (gd-forward-elif-block-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-else-block-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a else-block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-else-block-bol)
      (gd-forward-else-block-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-except-block-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a except-block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-except-block-bol)
      (gd-forward-except-block-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-for-block-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a for-block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-for-block-bol)
      (gd-forward-for-block-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-if-block-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a if-block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-if-block-bol)
      (gd-forward-if-block-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-indent-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a indent, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-indent-bol)
      (gd-forward-indent-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-minor-block-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a minor-block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-minor-block-bol)
      (gd-forward-minor-block-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-statement-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a statement, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-statement-bol)
      (gd-forward-statement-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-top-level-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a top-level, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-top-level-bol)
      (gd-forward-top-level-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-try-block-bol-p ()
  "Returns position, if cursor is at beginning-of-line at the end of a try-block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-try-block-bol)
      (gd-forward-try-block-bol)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-block-p ()
  "Returns position, if cursor is at the end of a block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-block)
      (gd-forward-block)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-block-or-clause-p ()
  "Returns position, if cursor is at the end of a block-or-clause, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-block-or-clause)
      (gd-forward-block-or-clause)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-class-p ()
  "Returns position, if cursor is at the end of a class, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-class)
      (gd-forward-class)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-clause-p ()
  "Returns position, if cursor is at the end of a clause, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-clause)
      (gd-forward-clause)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-def-p ()
  "Returns position, if cursor is at the end of a def, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-def)
      (gd-forward-def)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-def-or-class-p ()
  "Returns position, if cursor is at the end of a def-or-class, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-def-or-class)
      (gd-forward-def-or-class)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-elif-block-p ()
  "Returns position, if cursor is at the end of a elif-block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-elif-block)
      (gd-forward-elif-block)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-else-block-p ()
  "Returns position, if cursor is at the end of a else-block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-else-block)
      (gd-forward-else-block)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-except-block-p ()
  "Returns position, if cursor is at the end of a except-block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-except-block)
      (gd-forward-except-block)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-for-block-p ()
  "Returns position, if cursor is at the end of a for-block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-for-block)
      (gd-forward-for-block)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-if-block-p ()
  "Returns position, if cursor is at the end of a if-block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-if-block)
      (gd-forward-if-block)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-indent-p ()
  "Returns position, if cursor is at the end of a indent, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-indent)
      (gd-forward-indent)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-minor-block-p ()
  "Returns position, if cursor is at the end of a minor-block, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-minor-block)
      (gd-forward-minor-block)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-statement-p ()
  "Returns position, if cursor is at the end of a statement, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-statement)
      (gd-forward-statement)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-top-level-p ()
  "Returns position, if cursor is at the end of a top-level, nil otherwise. "
  (let ((orig (point))
	erg)
    (save-excursion
      (gd-backward-top-level)
      (gd-forward-top-level)
      (when (eq orig (point))
	(setq erg orig))
      erg)))

(defun gd--end-of-try-block-p ()
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


(defun gd--beginning-of-block-position ()
  "Returns beginning of block position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-block)))
      erg)))

(defun gd--beginning-of-block-or-clause-position ()
  "Returns beginning of block-or-clause position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-block-or-clause)))
      erg)))

(defun gd--beginning-of-class-position ()
  "Returns beginning of class position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-class)))
      erg)))

(defun gd--beginning-of-clause-position ()
  "Returns beginning of clause position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-clause)))
      erg)))

(defun gd--beginning-of-comment-position ()
  "Returns beginning of comment position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-comment)))
      erg)))

(defun gd--beginning-of-def-position ()
  "Returns beginning of def position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-def)))
      erg)))

(defun gd--beginning-of-def-or-class-position ()
  "Returns beginning of def-or-class position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-def-or-class)))
      erg)))

(defun gd--beginning-of-expression-position ()
  "Returns beginning of expression position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-expression)))
      erg)))

(defun gd--beginning-of-except-block-position ()
  "Returns beginning of except-block position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-except-block)))
      erg)))

(defun gd--beginning-of-if-block-position ()
  "Returns beginning of if-block position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-if-block)))
      erg)))

(defun gd--beginning-of-indent-position ()
  "Returns beginning of indent position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-indent)))
      erg)))

(defun gd--beginning-of-line-position ()
  "Returns beginning of line position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-line)))
      erg)))

(defun gd--beginning-of-minor-block-position ()
  "Returns beginning of minor-block position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-minor-block)))
      erg)))

(defun gd--beginning-of-partial-expression-position ()
  "Returns beginning of partial-expression position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-partial-expression)))
      erg)))

(defun gd--beginning-of-paragraph-position ()
  "Returns beginning of paragraph position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-paragraph)))
      erg)))

(defun gd--beginning-of-section-position ()
  "Returns beginning of section position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-section)))
      erg)))

(defun gd--beginning-of-statement-position ()
  "Returns beginning of statement position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-statement)))
      erg)))

(defun gd--beginning-of-top-level-position ()
  "Returns beginning of top-level position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-top-level)))
      erg)))

(defun gd--beginning-of-try-block-position ()
  "Returns beginning of try-block position at beginning-of-line. "
  (save-excursion
    (let ((erg (gd-backward-try-block)))
      erg)))

(defun gd--beginning-of-block-position-bol ()
  "Returns beginning of block position. "
  (save-excursion
    (let ((erg (gd-backward-block-bol)))
      erg)))

(defun gd--beginning-of-block-or-clause-position-bol ()
  "Returns beginning of block-or-clause position. "
  (save-excursion
    (let ((erg (gd-backward-block-or-clause-bol)))
      erg)))

(defun gd--beginning-of-class-position-bol ()
  "Returns beginning of class position. "
  (save-excursion
    (let ((erg (gd-backward-class-bol)))
      erg)))

(defun gd--beginning-of-clause-position-bol ()
  "Returns beginning of clause position. "
  (save-excursion
    (let ((erg (gd-backward-clause-bol)))
      erg)))

(defun gd--beginning-of-def-position-bol ()
  "Returns beginning of def position. "
  (save-excursion
    (let ((erg (gd-backward-def-bol)))
      erg)))

(defun gd--beginning-of-def-or-class-position-bol ()
  "Returns beginning of def-or-class position. "
  (save-excursion
    (let ((erg (gd-backward-def-or-class-bol)))
      erg)))

(defun gd--beginning-of-elif-block-position-bol ()
  "Returns beginning of elif-block position. "
  (save-excursion
    (let ((erg (gd-backward-elif-block-bol)))
      erg)))

(defun gd--beginning-of-else-block-position-bol ()
  "Returns beginning of else-block position. "
  (save-excursion
    (let ((erg (gd-backward-else-block-bol)))
      erg)))

(defun gd--beginning-of-except-block-position-bol ()
  "Returns beginning of except-block position. "
  (save-excursion
    (let ((erg (gd-backward-except-block-bol)))
      erg)))

(defun gd--beginning-of-for-block-position-bol ()
  "Returns beginning of for-block position. "
  (save-excursion
    (let ((erg (gd-backward-for-block-bol)))
      erg)))

(defun gd--beginning-of-if-block-position-bol ()
  "Returns beginning of if-block position. "
  (save-excursion
    (let ((erg (gd-backward-if-block-bol)))
      erg)))

(defun gd--beginning-of-indent-position-bol ()
  "Returns beginning of indent position. "
  (save-excursion
    (let ((erg (gd-backward-indent-bol)))
      erg)))

(defun gd--beginning-of-minor-block-position-bol ()
  "Returns beginning of minor-block position. "
  (save-excursion
    (let ((erg (gd-backward-minor-block-bol)))
      erg)))

(defun gd--beginning-of-statement-position-bol ()
  "Returns beginning of statement position. "
  (save-excursion
    (let ((erg (gd-backward-statement-bol)))
      erg)))

(defun gd--beginning-of-try-block-position-bol ()
  "Returns beginning of try-block position. "
  (save-excursion
    (let ((erg (gd-backward-try-block-bol)))
      erg)))

;; gdscript-components-end-position-forms


(defun gd--end-of-block-position ()
  "Returns end of block position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-block))))
      erg)))

(defun gd--end-of-block-or-clause-position ()
  "Returns end of block-or-clause position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-block-or-clause))))
      erg)))

(defun gd--end-of-class-position ()
  "Returns end of class position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-class))))
      erg)))

(defun gd--end-of-clause-position ()
  "Returns end of clause position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-clause))))
      erg)))

(defun gd--end-of-comment-position ()
  "Returns end of comment position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-comment))))
      erg)))

(defun gd--end-of-def-position ()
  "Returns end of def position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-def))))
      erg)))

(defun gd--end-of-def-or-class-position ()
  "Returns end of def-or-class position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-def-or-class))))
      erg)))

(defun gd--end-of-expression-position ()
  "Returns end of expression position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-expression))))
      erg)))

(defun gd--end-of-except-block-position ()
  "Returns end of except-block position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-except-block))))
      erg)))

(defun gd--end-of-if-block-position ()
  "Returns end of if-block position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-if-block))))
      erg)))

(defun gd--end-of-indent-position ()
  "Returns end of indent position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-indent))))
      erg)))

(defun gd--end-of-line-position ()
  "Returns end of line position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-line))))
      erg)))

(defun gd--end-of-minor-block-position ()
  "Returns end of minor-block position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-minor-block))))
      erg)))

(defun gd--end-of-partial-expression-position ()
  "Returns end of partial-expression position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-partial-expression))))
      erg)))

(defun gd--end-of-paragraph-position ()
  "Returns end of paragraph position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-paragraph))))
      erg)))

(defun gd--end-of-section-position ()
  "Returns end of section position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-section))))
      erg)))

(defun gd--end-of-statement-position ()
  "Returns end of statement position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-statement))))
      erg)))

(defun gd--end-of-top-level-position ()
  "Returns end of top-level position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-top-level))))
      erg)))

(defun gd--end-of-try-block-position ()
  "Returns end of try-block position. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-try-block))))
      erg)))

(defun gd--end-of-block-position-bol ()
  "Returns end of block position at beginning-of-line. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-block-bol))))
      erg)))

(defun gd--end-of-block-or-clause-position-bol ()
  "Returns end of block-or-clause position at beginning-of-line. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-block-or-clause-bol))))
      erg)))

(defun gd--end-of-class-position-bol ()
  "Returns end of class position at beginning-of-line. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-class-bol))))
      erg)))

(defun gd--end-of-clause-position-bol ()
  "Returns end of clause position at beginning-of-line. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-clause-bol))))
      erg)))

(defun gd--end-of-def-position-bol ()
  "Returns end of def position at beginning-of-line. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-def-bol))))
      erg)))

(defun gd--end-of-def-or-class-position-bol ()
  "Returns end of def-or-class position at beginning-of-line. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-def-or-class-bol))))
      erg)))

(defun gd--end-of-elif-block-position-bol ()
  "Returns end of elif-block position at beginning-of-line. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-elif-block-bol))))
      erg)))

(defun gd--end-of-else-block-position-bol ()
  "Returns end of else-block position at beginning-of-line. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-else-block-bol))))
      erg)))

(defun gd--end-of-except-block-position-bol ()
  "Returns end of except-block position at beginning-of-line. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-except-block-bol))))
      erg)))

(defun gd--end-of-for-block-position-bol ()
  "Returns end of for-block position at beginning-of-line. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-for-block-bol))))
      erg)))

(defun gd--end-of-if-block-position-bol ()
  "Returns end of if-block position at beginning-of-line. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-if-block-bol))))
      erg)))

(defun gd--end-of-indent-position-bol ()
  "Returns end of indent position at beginning-of-line. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-indent-bol))))
      erg)))

(defun gd--end-of-minor-block-position-bol ()
  "Returns end of minor-block position at beginning-of-line. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-minor-block-bol))))
      erg)))

(defun gd--end-of-statement-position-bol ()
  "Returns end of statement position at beginning-of-line. "
  (save-excursion
    (let ((erg (progn
                 (when (looking-at "[ \\t\\r\\n\\f]*$")
                   (skip-chars-backward " \t\r\n\f")
                   (forward-char -1))
                 (gd-forward-statement-bol))))
      erg)))

(defun gd--end-of-try-block-position-bol ()
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
    (if (gd--beginning-of-statement-p)
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
	   (cond ((gd--end-of-statement-p)
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
                 (or (gd--beginning-of-try-block-p)
                     (save-excursion
                       (gd-backward-try-block)))))
        (end (save-excursion
               (gd-forward-try-block))))
    (gd-execute-region beg end)))

(defun gd-execute-if-block ()
  "Send if-block at point to GDScript default interpreter. "
  (interactive)
  (let ((beg (prog1
                 (or (gd--beginning-of-if-block-p)
                     (save-excursion
                       (gd-backward-if-block)))))
        (end (save-excursion
               (gd-forward-if-block))))
    (gd-execute-region beg end)))

(defun gd-execute-for-block ()
  "Send for-block at point to GDScript default interpreter. "
  (interactive)
  (let ((beg (prog1
                 (or (gd--beginning-of-for-block-p)
                     (save-excursion
                       (gd-backward-for-block)))))
        (end (save-excursion
               (gd-forward-for-block))))
    (gd-execute-region beg end)))

;; gdscript-extended-executes


(defun gd-execute-block ()
  "Send block at point to  interpreter. "
  (interactive)
  (gd--execute-prepare 'block nil  nil nil))

(defun gd-execute-block-switch ()
  "Send block at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'block nil  nil 'switch))

(defun gd-execute-block-no-switch ()
  "Send block at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'block nil  nil 'no-switch))

(defun gd-execute-block-dedicated ()
  "Send block at point to  unique interpreter. "
  (interactive)
  (gd--execute-prepare 'block nil  t nil))

(defun gd-execute-block-dedicated-switch ()
  "Send block at point to  unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'block nil  t 'switch))

(defun gd-execute-block-ipython ()
  "Send block at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'block 'ipython nil nil))

(defun gd-execute-block-ipython-switch ()
  "Send block at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'block 'ipython nil 'switch))

(defun gd-execute-block-ipython-no-switch ()
  "Send block at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'block 'ipython nil 'no-switch))

(defun gd-execute-block-ipython-dedicated ()
  "Send block at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'block 'ipython t nil))

(defun gd-execute-block-ipython-dedicated-switch ()
  "Send block at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'block 'ipython t 'switch))

(defun gd-execute-block-ipython2.7 ()
  "Send block at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'block 'ipython2.7 nil nil))

(defun gd-execute-block-ipython2.7-switch ()
  "Send block at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'block 'ipython2.7 nil 'switch))

(defun gd-execute-block-ipython2.7-no-switch ()
  "Send block at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'block 'ipython2.7 nil 'no-switch))

(defun gd-execute-block-ipython2.7-dedicated ()
  "Send block at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'block 'ipython2.7 t nil))

(defun gd-execute-block-ipython2.7-dedicated-switch ()
  "Send block at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'block 'ipython2.7 t 'switch))

(defun gd-execute-block-ipython3 ()
  "Send block at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'block 'ipython3 nil nil))

(defun gd-execute-block-ipython3-switch ()
  "Send block at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'block 'ipython3 nil 'switch))

(defun gd-execute-block-ipython3-no-switch ()
  "Send block at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'block 'ipython3 nil 'no-switch))

(defun gd-execute-block-ipython3-dedicated ()
  "Send block at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'block 'ipython3 t nil))

(defun gd-execute-block-ipython3-dedicated-switch ()
  "Send block at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'block 'ipython3 t 'switch))

(defun gd-execute-block-jython ()
  "Send block at point to Jython interpreter. "
  (interactive)
  (gd--execute-prepare 'block 'jython nil nil))

(defun gd-execute-block-jython-switch ()
  "Send block at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'block 'jython nil 'switch))

(defun gd-execute-block-jython-no-switch ()
  "Send block at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'block 'jython nil 'no-switch))

(defun gd-execute-block-jython-dedicated ()
  "Send block at point to Jython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'block 'jython t nil))

(defun gd-execute-block-jython-dedicated-switch ()
  "Send block at point to Jython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'block 'jython t 'switch))

(defun gd-execute-block-python ()
  "Send block at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'block 'python nil nil))

(defun gd-execute-block-gdscript-switch ()
  "Send block at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'block 'python nil 'switch))

(defun gd-execute-block-gdscript-no-switch ()
  "Send block at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'block 'python nil 'no-switch))

(defun gd-execute-block-gdscript-dedicated ()
  "Send block at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'block 'python t nil))

(defun gd-execute-block-gdscript-dedicated-switch ()
  "Send block at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'block 'python t 'switch))

(defun gd-execute-block-python2 ()
  "Send block at point to Python2 interpreter. "
  (interactive)
  (gd--execute-prepare 'block 'python2 nil nil))

(defun gd-execute-block-python2-switch ()
  "Send block at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'block 'python2 nil 'switch))

(defun gd-execute-block-python2-no-switch ()
  "Send block at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'block 'python2 nil 'no-switch))

(defun gd-execute-block-python2-dedicated ()
  "Send block at point to Python2 unique interpreter. "
  (interactive)
  (gd--execute-prepare 'block 'python2 t nil))

(defun gd-execute-block-python2-dedicated-switch ()
  "Send block at point to Python2 unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'block 'python2 t 'switch))

(defun gd-execute-block-python3 ()
  "Send block at point to Python3 interpreter. "
  (interactive)
  (gd--execute-prepare 'block 'python3 nil nil))

(defun gd-execute-block-python3-switch ()
  "Send block at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'block 'python3 nil 'switch))

(defun gd-execute-block-python3-no-switch ()
  "Send block at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'block 'python3 nil 'no-switch))

(defun gd-execute-block-python3-dedicated ()
  "Send block at point to Python3 unique interpreter. "
  (interactive)
  (gd--execute-prepare 'block 'python3 t nil))

(defun gd-execute-block-python3-dedicated-switch ()
  "Send block at point to Python3 unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'block 'python3 t 'switch))

(defun gd-execute-block-or-clause ()
  "Send block-or-clause at point to  interpreter. "
  (interactive)
  (gd--execute-prepare 'block-or-clause nil  nil nil))

(defun gd-execute-block-or-clause-switch ()
  "Send block-or-clause at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'block-or-clause nil  nil 'switch))

(defun gd-execute-block-or-clause-no-switch ()
  "Send block-or-clause at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'block-or-clause nil  nil 'no-switch))

(defun gd-execute-block-or-clause-dedicated ()
  "Send block-or-clause at point to  unique interpreter. "
  (interactive)
  (gd--execute-prepare 'block-or-clause nil  t nil))

(defun gd-execute-block-or-clause-dedicated-switch ()
  "Send block-or-clause at point to  unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'block-or-clause nil  t 'switch))

(defun gd-execute-block-or-clause-ipython ()
  "Send block-or-clause at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'ipython nil nil))

(defun gd-execute-block-or-clause-ipython-switch ()
  "Send block-or-clause at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'ipython nil 'switch))

(defun gd-execute-block-or-clause-ipython-no-switch ()
  "Send block-or-clause at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'ipython nil 'no-switch))

(defun gd-execute-block-or-clause-ipython-dedicated ()
  "Send block-or-clause at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'ipython t nil))

(defun gd-execute-block-or-clause-ipython-dedicated-switch ()
  "Send block-or-clause at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'ipython t 'switch))

(defun gd-execute-block-or-clause-ipython2.7 ()
  "Send block-or-clause at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'ipython2.7 nil nil))

(defun gd-execute-block-or-clause-ipython2.7-switch ()
  "Send block-or-clause at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'ipython2.7 nil 'switch))

(defun gd-execute-block-or-clause-ipython2.7-no-switch ()
  "Send block-or-clause at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'ipython2.7 nil 'no-switch))

(defun gd-execute-block-or-clause-ipython2.7-dedicated ()
  "Send block-or-clause at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'ipython2.7 t nil))

(defun gd-execute-block-or-clause-ipython2.7-dedicated-switch ()
  "Send block-or-clause at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'ipython2.7 t 'switch))

(defun gd-execute-block-or-clause-ipython3 ()
  "Send block-or-clause at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'ipython3 nil nil))

(defun gd-execute-block-or-clause-ipython3-switch ()
  "Send block-or-clause at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'ipython3 nil 'switch))

(defun gd-execute-block-or-clause-ipython3-no-switch ()
  "Send block-or-clause at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'ipython3 nil 'no-switch))

(defun gd-execute-block-or-clause-ipython3-dedicated ()
  "Send block-or-clause at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'ipython3 t nil))

(defun gd-execute-block-or-clause-ipython3-dedicated-switch ()
  "Send block-or-clause at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'ipython3 t 'switch))

(defun gd-execute-block-or-clause-jython ()
  "Send block-or-clause at point to Jython interpreter. "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'jython nil nil))

(defun gd-execute-block-or-clause-jython-switch ()
  "Send block-or-clause at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'jython nil 'switch))

(defun gd-execute-block-or-clause-jython-no-switch ()
  "Send block-or-clause at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'jython nil 'no-switch))

(defun gd-execute-block-or-clause-jython-dedicated ()
  "Send block-or-clause at point to Jython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'jython t nil))

(defun gd-execute-block-or-clause-jython-dedicated-switch ()
  "Send block-or-clause at point to Jython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'jython t 'switch))

(defun gd-execute-block-or-clause-python ()
  "Send block-or-clause at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'block-or-clause 'python nil nil))

(defun gd-execute-block-or-clause-gdscript-switch ()
  "Send block-or-clause at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'block-or-clause 'python nil 'switch))

(defun gd-execute-block-or-clause-gdscript-no-switch ()
  "Send block-or-clause at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'block-or-clause 'python nil 'no-switch))

(defun gd-execute-block-or-clause-gdscript-dedicated ()
  "Send block-or-clause at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'block-or-clause 'python t nil))

(defun gd-execute-block-or-clause-gdscript-dedicated-switch ()
  "Send block-or-clause at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'block-or-clause 'python t 'switch))

(defun gd-execute-block-or-clause-python2 ()
  "Send block-or-clause at point to Python2 interpreter. "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'python2 nil nil))

(defun gd-execute-block-or-clause-python2-switch ()
  "Send block-or-clause at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'python2 nil 'switch))

(defun gd-execute-block-or-clause-python2-no-switch ()
  "Send block-or-clause at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'python2 nil 'no-switch))

(defun gd-execute-block-or-clause-python2-dedicated ()
  "Send block-or-clause at point to Python2 unique interpreter. "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'python2 t nil))

(defun gd-execute-block-or-clause-python2-dedicated-switch ()
  "Send block-or-clause at point to Python2 unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'python2 t 'switch))

(defun gd-execute-block-or-clause-python3 ()
  "Send block-or-clause at point to Python3 interpreter. "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'python3 nil nil))

(defun gd-execute-block-or-clause-python3-switch ()
  "Send block-or-clause at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'python3 nil 'switch))

(defun gd-execute-block-or-clause-python3-no-switch ()
  "Send block-or-clause at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'python3 nil 'no-switch))

(defun gd-execute-block-or-clause-python3-dedicated ()
  "Send block-or-clause at point to Python3 unique interpreter. "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'python3 t nil))

(defun gd-execute-block-or-clause-python3-dedicated-switch ()
  "Send block-or-clause at point to Python3 unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'block-or-clause 'python3 t 'switch))

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
  (gd--execute-prepare 'buffer nil  nil nil (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer nil  nil 'switch (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer nil  nil 'no-switch (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer nil  t nil (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer nil  t 'switch (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'ipython nil nil (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'ipython nil 'switch (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'ipython nil 'no-switch (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'ipython t nil (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'ipython t 'switch (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'ipython2.7 nil nil (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'ipython2.7 nil 'switch (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'ipython2.7 nil 'no-switch (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'ipython2.7 t nil (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'ipython2.7 t 'switch (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'ipython3 nil nil (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'ipython3 nil 'switch (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'ipython3 nil 'no-switch (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'ipython3 t nil (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'ipython3 t 'switch (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'jython nil nil (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'jython nil 'switch (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'jython nil 'no-switch (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'jython t nil (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'jython t 'switch (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'python nil nil (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'python nil 'switch (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'python nil 'no-switch (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'python t nil (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'python t 'switch (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'python2 nil nil (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'python2 nil 'switch (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'python2 nil 'no-switch (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'python2 t nil (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'python2 t 'switch (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'python3 nil nil (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'python3 nil 'switch (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'python3 nil 'no-switch (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'python3 t nil (point-min) (point-max)))

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
  (gd--execute-prepare 'buffer 'python3 t 'switch (point-min) (point-max)))

(defun gd-execute-class ()
  "Send class at point to  interpreter. "
  (interactive)
  (gd--execute-prepare 'class nil  nil nil))

(defun gd-execute-class-switch ()
  "Send class at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'class nil  nil 'switch))

(defun gd-execute-class-no-switch ()
  "Send class at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'class nil  nil 'no-switch))

(defun gd-execute-class-dedicated ()
  "Send class at point to  unique interpreter. "
  (interactive)
  (gd--execute-prepare 'class nil  t nil))

(defun gd-execute-class-dedicated-switch ()
  "Send class at point to  unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'class nil  t 'switch))

(defun gd-execute-class-ipython ()
  "Send class at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'class 'ipython nil nil))

(defun gd-execute-class-ipython-switch ()
  "Send class at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'class 'ipython nil 'switch))

(defun gd-execute-class-ipython-no-switch ()
  "Send class at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'class 'ipython nil 'no-switch))

(defun gd-execute-class-ipython-dedicated ()
  "Send class at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'class 'ipython t nil))

(defun gd-execute-class-ipython-dedicated-switch ()
  "Send class at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'class 'ipython t 'switch))

(defun gd-execute-class-ipython2.7 ()
  "Send class at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'class 'ipython2.7 nil nil))

(defun gd-execute-class-ipython2.7-switch ()
  "Send class at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'class 'ipython2.7 nil 'switch))

(defun gd-execute-class-ipython2.7-no-switch ()
  "Send class at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'class 'ipython2.7 nil 'no-switch))

(defun gd-execute-class-ipython2.7-dedicated ()
  "Send class at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'class 'ipython2.7 t nil))

(defun gd-execute-class-ipython2.7-dedicated-switch ()
  "Send class at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'class 'ipython2.7 t 'switch))

(defun gd-execute-class-ipython3 ()
  "Send class at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'class 'ipython3 nil nil))

(defun gd-execute-class-ipython3-switch ()
  "Send class at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'class 'ipython3 nil 'switch))

(defun gd-execute-class-ipython3-no-switch ()
  "Send class at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'class 'ipython3 nil 'no-switch))

(defun gd-execute-class-ipython3-dedicated ()
  "Send class at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'class 'ipython3 t nil))

(defun gd-execute-class-ipython3-dedicated-switch ()
  "Send class at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'class 'ipython3 t 'switch))

(defun gd-execute-class-jython ()
  "Send class at point to Jython interpreter. "
  (interactive)
  (gd--execute-prepare 'class 'jython nil nil))

(defun gd-execute-class-jython-switch ()
  "Send class at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'class 'jython nil 'switch))

(defun gd-execute-class-jython-no-switch ()
  "Send class at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'class 'jython nil 'no-switch))

(defun gd-execute-class-jython-dedicated ()
  "Send class at point to Jython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'class 'jython t nil))

(defun gd-execute-class-jython-dedicated-switch ()
  "Send class at point to Jython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'class 'jython t 'switch))

(defun gd-execute-class-python ()
  "Send class at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'class 'python nil nil))

(defun gd-execute-class-gdscript-switch ()
  "Send class at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'class 'python nil 'switch))

(defun gd-execute-class-gdscript-no-switch ()
  "Send class at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'class 'python nil 'no-switch))

(defun gd-execute-class-gdscript-dedicated ()
  "Send class at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'class 'python t nil))

(defun gd-execute-class-gdscript-dedicated-switch ()
  "Send class at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'class 'python t 'switch))

(defun gd-execute-class-python2 ()
  "Send class at point to Python2 interpreter. "
  (interactive)
  (gd--execute-prepare 'class 'python2 nil nil))

(defun gd-execute-class-python2-switch ()
  "Send class at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'class 'python2 nil 'switch))

(defun gd-execute-class-python2-no-switch ()
  "Send class at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'class 'python2 nil 'no-switch))

(defun gd-execute-class-python2-dedicated ()
  "Send class at point to Python2 unique interpreter. "
  (interactive)
  (gd--execute-prepare 'class 'python2 t nil))

(defun gd-execute-class-python2-dedicated-switch ()
  "Send class at point to Python2 unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'class 'python2 t 'switch))

(defun gd-execute-class-python3 ()
  "Send class at point to Python3 interpreter. "
  (interactive)
  (gd--execute-prepare 'class 'python3 nil nil))

(defun gd-execute-class-python3-switch ()
  "Send class at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'class 'python3 nil 'switch))

(defun gd-execute-class-python3-no-switch ()
  "Send class at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'class 'python3 nil 'no-switch))

(defun gd-execute-class-python3-dedicated ()
  "Send class at point to Python3 unique interpreter. "
  (interactive)
  (gd--execute-prepare 'class 'python3 t nil))

(defun gd-execute-class-python3-dedicated-switch ()
  "Send class at point to Python3 unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'class 'python3 t 'switch))

(defun gd-execute-clause ()
  "Send clause at point to  interpreter. "
  (interactive)
  (gd--execute-prepare 'clause nil  nil nil))

(defun gd-execute-clause-switch ()
  "Send clause at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'clause nil  nil 'switch))

(defun gd-execute-clause-no-switch ()
  "Send clause at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'clause nil  nil 'no-switch))

(defun gd-execute-clause-dedicated ()
  "Send clause at point to  unique interpreter. "
  (interactive)
  (gd--execute-prepare 'clause nil  t nil))

(defun gd-execute-clause-dedicated-switch ()
  "Send clause at point to  unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'clause nil  t 'switch))

(defun gd-execute-clause-ipython ()
  "Send clause at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'clause 'ipython nil nil))

(defun gd-execute-clause-ipython-switch ()
  "Send clause at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'clause 'ipython nil 'switch))

(defun gd-execute-clause-ipython-no-switch ()
  "Send clause at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'clause 'ipython nil 'no-switch))

(defun gd-execute-clause-ipython-dedicated ()
  "Send clause at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'clause 'ipython t nil))

(defun gd-execute-clause-ipython-dedicated-switch ()
  "Send clause at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'clause 'ipython t 'switch))

(defun gd-execute-clause-ipython2.7 ()
  "Send clause at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'clause 'ipython2.7 nil nil))

(defun gd-execute-clause-ipython2.7-switch ()
  "Send clause at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'clause 'ipython2.7 nil 'switch))

(defun gd-execute-clause-ipython2.7-no-switch ()
  "Send clause at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'clause 'ipython2.7 nil 'no-switch))

(defun gd-execute-clause-ipython2.7-dedicated ()
  "Send clause at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'clause 'ipython2.7 t nil))

(defun gd-execute-clause-ipython2.7-dedicated-switch ()
  "Send clause at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'clause 'ipython2.7 t 'switch))

(defun gd-execute-clause-ipython3 ()
  "Send clause at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'clause 'ipython3 nil nil))

(defun gd-execute-clause-ipython3-switch ()
  "Send clause at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'clause 'ipython3 nil 'switch))

(defun gd-execute-clause-ipython3-no-switch ()
  "Send clause at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'clause 'ipython3 nil 'no-switch))

(defun gd-execute-clause-ipython3-dedicated ()
  "Send clause at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'clause 'ipython3 t nil))

(defun gd-execute-clause-ipython3-dedicated-switch ()
  "Send clause at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'clause 'ipython3 t 'switch))

(defun gd-execute-clause-jython ()
  "Send clause at point to Jython interpreter. "
  (interactive)
  (gd--execute-prepare 'clause 'jython nil nil))

(defun gd-execute-clause-jython-switch ()
  "Send clause at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'clause 'jython nil 'switch))

(defun gd-execute-clause-jython-no-switch ()
  "Send clause at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'clause 'jython nil 'no-switch))

(defun gd-execute-clause-jython-dedicated ()
  "Send clause at point to Jython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'clause 'jython t nil))

(defun gd-execute-clause-jython-dedicated-switch ()
  "Send clause at point to Jython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'clause 'jython t 'switch))

(defun gd-execute-clause-python ()
  "Send clause at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'clause 'python nil nil))

(defun gd-execute-clause-gdscript-switch ()
  "Send clause at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'clause 'python nil 'switch))

(defun gd-execute-clause-gdscript-no-switch ()
  "Send clause at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'clause 'python nil 'no-switch))

(defun gd-execute-clause-gdscript-dedicated ()
  "Send clause at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'clause 'python t nil))

(defun gd-execute-clause-gdscript-dedicated-switch ()
  "Send clause at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'clause 'python t 'switch))

(defun gd-execute-clause-python2 ()
  "Send clause at point to Python2 interpreter. "
  (interactive)
  (gd--execute-prepare 'clause 'python2 nil nil))

(defun gd-execute-clause-python2-switch ()
  "Send clause at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'clause 'python2 nil 'switch))

(defun gd-execute-clause-python2-no-switch ()
  "Send clause at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'clause 'python2 nil 'no-switch))

(defun gd-execute-clause-python2-dedicated ()
  "Send clause at point to Python2 unique interpreter. "
  (interactive)
  (gd--execute-prepare 'clause 'python2 t nil))

(defun gd-execute-clause-python2-dedicated-switch ()
  "Send clause at point to Python2 unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'clause 'python2 t 'switch))

(defun gd-execute-clause-python3 ()
  "Send clause at point to Python3 interpreter. "
  (interactive)
  (gd--execute-prepare 'clause 'python3 nil nil))

(defun gd-execute-clause-python3-switch ()
  "Send clause at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'clause 'python3 nil 'switch))

(defun gd-execute-clause-python3-no-switch ()
  "Send clause at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'clause 'python3 nil 'no-switch))

(defun gd-execute-clause-python3-dedicated ()
  "Send clause at point to Python3 unique interpreter. "
  (interactive)
  (gd--execute-prepare 'clause 'python3 t nil))

(defun gd-execute-clause-python3-dedicated-switch ()
  "Send clause at point to Python3 unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'clause 'python3 t 'switch))

(defun gd-execute-def ()
  "Send def at point to  interpreter. "
  (interactive)
  (gd--execute-prepare 'def nil  nil nil))

(defun gd-execute-def-switch ()
  "Send def at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'def nil  nil 'switch))

(defun gd-execute-def-no-switch ()
  "Send def at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'def nil  nil 'no-switch))

(defun gd-execute-def-dedicated ()
  "Send def at point to  unique interpreter. "
  (interactive)
  (gd--execute-prepare 'def nil  t nil))

(defun gd-execute-def-dedicated-switch ()
  "Send def at point to  unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'def nil  t 'switch))

(defun gd-execute-def-ipython ()
  "Send def at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'def 'ipython nil nil))

(defun gd-execute-def-ipython-switch ()
  "Send def at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'def 'ipython nil 'switch))

(defun gd-execute-def-ipython-no-switch ()
  "Send def at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'def 'ipython nil 'no-switch))

(defun gd-execute-def-ipython-dedicated ()
  "Send def at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'def 'ipython t nil))

(defun gd-execute-def-ipython-dedicated-switch ()
  "Send def at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'def 'ipython t 'switch))

(defun gd-execute-def-ipython2.7 ()
  "Send def at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'def 'ipython2.7 nil nil))

(defun gd-execute-def-ipython2.7-switch ()
  "Send def at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'def 'ipython2.7 nil 'switch))

(defun gd-execute-def-ipython2.7-no-switch ()
  "Send def at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'def 'ipython2.7 nil 'no-switch))

(defun gd-execute-def-ipython2.7-dedicated ()
  "Send def at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'def 'ipython2.7 t nil))

(defun gd-execute-def-ipython2.7-dedicated-switch ()
  "Send def at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'def 'ipython2.7 t 'switch))

(defun gd-execute-def-ipython3 ()
  "Send def at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'def 'ipython3 nil nil))

(defun gd-execute-def-ipython3-switch ()
  "Send def at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'def 'ipython3 nil 'switch))

(defun gd-execute-def-ipython3-no-switch ()
  "Send def at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'def 'ipython3 nil 'no-switch))

(defun gd-execute-def-ipython3-dedicated ()
  "Send def at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'def 'ipython3 t nil))

(defun gd-execute-def-ipython3-dedicated-switch ()
  "Send def at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'def 'ipython3 t 'switch))

(defun gd-execute-def-jython ()
  "Send def at point to Jython interpreter. "
  (interactive)
  (gd--execute-prepare 'def 'jython nil nil))

(defun gd-execute-def-jython-switch ()
  "Send def at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'def 'jython nil 'switch))

(defun gd-execute-def-jython-no-switch ()
  "Send def at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'def 'jython nil 'no-switch))

(defun gd-execute-def-jython-dedicated ()
  "Send def at point to Jython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'def 'jython t nil))

(defun gd-execute-def-jython-dedicated-switch ()
  "Send def at point to Jython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'def 'jython t 'switch))

(defun gd-execute-def-python ()
  "Send def at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'def 'python nil nil))

(defun gd-execute-def-gdscript-switch ()
  "Send def at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'def 'python nil 'switch))

(defun gd-execute-def-gdscript-no-switch ()
  "Send def at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'def 'python nil 'no-switch))

(defun gd-execute-def-gdscript-dedicated ()
  "Send def at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'def 'python t nil))

(defun gd-execute-def-gdscript-dedicated-switch ()
  "Send def at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'def 'python t 'switch))

(defun gd-execute-def-python2 ()
  "Send def at point to Python2 interpreter. "
  (interactive)
  (gd--execute-prepare 'def 'python2 nil nil))

(defun gd-execute-def-python2-switch ()
  "Send def at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'def 'python2 nil 'switch))

(defun gd-execute-def-python2-no-switch ()
  "Send def at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'def 'python2 nil 'no-switch))

(defun gd-execute-def-python2-dedicated ()
  "Send def at point to Python2 unique interpreter. "
  (interactive)
  (gd--execute-prepare 'def 'python2 t nil))

(defun gd-execute-def-python2-dedicated-switch ()
  "Send def at point to Python2 unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'def 'python2 t 'switch))

(defun gd-execute-def-python3 ()
  "Send def at point to Python3 interpreter. "
  (interactive)
  (gd--execute-prepare 'def 'python3 nil nil))

(defun gd-execute-def-python3-switch ()
  "Send def at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'def 'python3 nil 'switch))

(defun gd-execute-def-python3-no-switch ()
  "Send def at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'def 'python3 nil 'no-switch))

(defun gd-execute-def-python3-dedicated ()
  "Send def at point to Python3 unique interpreter. "
  (interactive)
  (gd--execute-prepare 'def 'python3 t nil))

(defun gd-execute-def-python3-dedicated-switch ()
  "Send def at point to Python3 unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'def 'python3 t 'switch))

(defun gd-execute-def-or-class ()
  "Send def-or-class at point to  interpreter. "
  (interactive)
  (gd--execute-prepare 'def-or-class nil  nil nil))

(defun gd-execute-def-or-class-switch ()
  "Send def-or-class at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'def-or-class nil  nil 'switch))

(defun gd-execute-def-or-class-no-switch ()
  "Send def-or-class at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'def-or-class nil  nil 'no-switch))

(defun gd-execute-def-or-class-dedicated ()
  "Send def-or-class at point to  unique interpreter. "
  (interactive)
  (gd--execute-prepare 'def-or-class nil  t nil))

(defun gd-execute-def-or-class-dedicated-switch ()
  "Send def-or-class at point to  unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'def-or-class nil  t 'switch))

(defun gd-execute-def-or-class-ipython ()
  "Send def-or-class at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'def-or-class 'ipython nil nil))

(defun gd-execute-def-or-class-ipython-switch ()
  "Send def-or-class at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'def-or-class 'ipython nil 'switch))

(defun gd-execute-def-or-class-ipython-no-switch ()
  "Send def-or-class at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'def-or-class 'ipython nil 'no-switch))

(defun gd-execute-def-or-class-ipython-dedicated ()
  "Send def-or-class at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'def-or-class 'ipython t nil))

(defun gd-execute-def-or-class-ipython-dedicated-switch ()
  "Send def-or-class at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'def-or-class 'ipython t 'switch))

(defun gd-execute-def-or-class-ipython2.7 ()
  "Send def-or-class at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'def-or-class 'ipython2.7 nil nil))

(defun gd-execute-def-or-class-ipython2.7-switch ()
  "Send def-or-class at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'def-or-class 'ipython2.7 nil 'switch))

(defun gd-execute-def-or-class-ipython2.7-no-switch ()
  "Send def-or-class at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'def-or-class 'ipython2.7 nil 'no-switch))

(defun gd-execute-def-or-class-ipython2.7-dedicated ()
  "Send def-or-class at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'def-or-class 'ipython2.7 t nil))

(defun gd-execute-def-or-class-ipython2.7-dedicated-switch ()
  "Send def-or-class at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'def-or-class 'ipython2.7 t 'switch))

(defun gd-execute-def-or-class-ipython3 ()
  "Send def-or-class at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'def-or-class 'ipython3 nil nil))

(defun gd-execute-def-or-class-ipython3-switch ()
  "Send def-or-class at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'def-or-class 'ipython3 nil 'switch))

(defun gd-execute-def-or-class-ipython3-no-switch ()
  "Send def-or-class at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'def-or-class 'ipython3 nil 'no-switch))

(defun gd-execute-def-or-class-ipython3-dedicated ()
  "Send def-or-class at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'def-or-class 'ipython3 t nil))

(defun gd-execute-def-or-class-ipython3-dedicated-switch ()
  "Send def-or-class at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'def-or-class 'ipython3 t 'switch))

(defun gd-execute-def-or-class-jython ()
  "Send def-or-class at point to Jython interpreter. "
  (interactive)
  (gd--execute-prepare 'def-or-class 'jython nil nil))

(defun gd-execute-def-or-class-jython-switch ()
  "Send def-or-class at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'def-or-class 'jython nil 'switch))

(defun gd-execute-def-or-class-jython-no-switch ()
  "Send def-or-class at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'def-or-class 'jython nil 'no-switch))

(defun gd-execute-def-or-class-jython-dedicated ()
  "Send def-or-class at point to Jython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'def-or-class 'jython t nil))

(defun gd-execute-def-or-class-jython-dedicated-switch ()
  "Send def-or-class at point to Jython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'def-or-class 'jython t 'switch))

(defun gd-execute-def-or-class-python ()
  "Send def-or-class at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'def-or-class 'python nil nil))

(defun gd-execute-def-or-class-gdscript-switch ()
  "Send def-or-class at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'def-or-class 'python nil 'switch))

(defun gd-execute-def-or-class-gdscript-no-switch ()
  "Send def-or-class at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'def-or-class 'python nil 'no-switch))

(defun gd-execute-def-or-class-gdscript-dedicated ()
  "Send def-or-class at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'def-or-class 'python t nil))

(defun gd-execute-def-or-class-gdscript-dedicated-switch ()
  "Send def-or-class at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'def-or-class 'python t 'switch))

(defun gd-execute-def-or-class-python2 ()
  "Send def-or-class at point to Python2 interpreter. "
  (interactive)
  (gd--execute-prepare 'def-or-class 'python2 nil nil))

(defun gd-execute-def-or-class-python2-switch ()
  "Send def-or-class at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'def-or-class 'python2 nil 'switch))

(defun gd-execute-def-or-class-python2-no-switch ()
  "Send def-or-class at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'def-or-class 'python2 nil 'no-switch))

(defun gd-execute-def-or-class-python2-dedicated ()
  "Send def-or-class at point to Python2 unique interpreter. "
  (interactive)
  (gd--execute-prepare 'def-or-class 'python2 t nil))

(defun gd-execute-def-or-class-python2-dedicated-switch ()
  "Send def-or-class at point to Python2 unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'def-or-class 'python2 t 'switch))

(defun gd-execute-def-or-class-python3 ()
  "Send def-or-class at point to Python3 interpreter. "
  (interactive)
  (gd--execute-prepare 'def-or-class 'python3 nil nil))

(defun gd-execute-def-or-class-python3-switch ()
  "Send def-or-class at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'def-or-class 'python3 nil 'switch))

(defun gd-execute-def-or-class-python3-no-switch ()
  "Send def-or-class at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'def-or-class 'python3 nil 'no-switch))

(defun gd-execute-def-or-class-python3-dedicated ()
  "Send def-or-class at point to Python3 unique interpreter. "
  (interactive)
  (gd--execute-prepare 'def-or-class 'python3 t nil))

(defun gd-execute-def-or-class-python3-dedicated-switch ()
  "Send def-or-class at point to Python3 unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'def-or-class 'python3 t 'switch))

(defun gd-execute-expression ()
  "Send expression at point to  interpreter. "
  (interactive)
  (gd--execute-prepare 'expression nil  nil nil))

(defun gd-execute-expression-switch ()
  "Send expression at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'expression nil  nil 'switch))

(defun gd-execute-expression-no-switch ()
  "Send expression at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'expression nil  nil 'no-switch))

(defun gd-execute-expression-dedicated ()
  "Send expression at point to  unique interpreter. "
  (interactive)
  (gd--execute-prepare 'expression nil  t nil))

(defun gd-execute-expression-dedicated-switch ()
  "Send expression at point to  unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'expression nil  t 'switch))

(defun gd-execute-expression-ipython ()
  "Send expression at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'expression 'ipython nil nil))

(defun gd-execute-expression-ipython-switch ()
  "Send expression at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'expression 'ipython nil 'switch))

(defun gd-execute-expression-ipython-no-switch ()
  "Send expression at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'expression 'ipython nil 'no-switch))

(defun gd-execute-expression-ipython-dedicated ()
  "Send expression at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'expression 'ipython t nil))

(defun gd-execute-expression-ipython-dedicated-switch ()
  "Send expression at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'expression 'ipython t 'switch))

(defun gd-execute-expression-ipython2.7 ()
  "Send expression at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'expression 'ipython2.7 nil nil))

(defun gd-execute-expression-ipython2.7-switch ()
  "Send expression at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'expression 'ipython2.7 nil 'switch))

(defun gd-execute-expression-ipython2.7-no-switch ()
  "Send expression at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'expression 'ipython2.7 nil 'no-switch))

(defun gd-execute-expression-ipython2.7-dedicated ()
  "Send expression at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'expression 'ipython2.7 t nil))

(defun gd-execute-expression-ipython2.7-dedicated-switch ()
  "Send expression at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'expression 'ipython2.7 t 'switch))

(defun gd-execute-expression-ipython3 ()
  "Send expression at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'expression 'ipython3 nil nil))

(defun gd-execute-expression-ipython3-switch ()
  "Send expression at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'expression 'ipython3 nil 'switch))

(defun gd-execute-expression-ipython3-no-switch ()
  "Send expression at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'expression 'ipython3 nil 'no-switch))

(defun gd-execute-expression-ipython3-dedicated ()
  "Send expression at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'expression 'ipython3 t nil))

(defun gd-execute-expression-ipython3-dedicated-switch ()
  "Send expression at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'expression 'ipython3 t 'switch))

(defun gd-execute-expression-jython ()
  "Send expression at point to Jython interpreter. "
  (interactive)
  (gd--execute-prepare 'expression 'jython nil nil))

(defun gd-execute-expression-jython-switch ()
  "Send expression at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'expression 'jython nil 'switch))

(defun gd-execute-expression-jython-no-switch ()
  "Send expression at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'expression 'jython nil 'no-switch))

(defun gd-execute-expression-jython-dedicated ()
  "Send expression at point to Jython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'expression 'jython t nil))

(defun gd-execute-expression-jython-dedicated-switch ()
  "Send expression at point to Jython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'expression 'jython t 'switch))

(defun gd-execute-expression-python ()
  "Send expression at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'expression 'python nil nil))

(defun gd-execute-expression-gdscript-switch ()
  "Send expression at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'expression 'python nil 'switch))

(defun gd-execute-expression-gdscript-no-switch ()
  "Send expression at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'expression 'python nil 'no-switch))

(defun gd-execute-expression-gdscript-dedicated ()
  "Send expression at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'expression 'python t nil))

(defun gd-execute-expression-gdscript-dedicated-switch ()
  "Send expression at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'expression 'python t 'switch))

(defun gd-execute-expression-python2 ()
  "Send expression at point to Python2 interpreter. "
  (interactive)
  (gd--execute-prepare 'expression 'python2 nil nil))

(defun gd-execute-expression-python2-switch ()
  "Send expression at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'expression 'python2 nil 'switch))

(defun gd-execute-expression-python2-no-switch ()
  "Send expression at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'expression 'python2 nil 'no-switch))

(defun gd-execute-expression-python2-dedicated ()
  "Send expression at point to Python2 unique interpreter. "
  (interactive)
  (gd--execute-prepare 'expression 'python2 t nil))

(defun gd-execute-expression-python2-dedicated-switch ()
  "Send expression at point to Python2 unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'expression 'python2 t 'switch))

(defun gd-execute-expression-python3 ()
  "Send expression at point to Python3 interpreter. "
  (interactive)
  (gd--execute-prepare 'expression 'python3 nil nil))

(defun gd-execute-expression-python3-switch ()
  "Send expression at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'expression 'python3 nil 'switch))

(defun gd-execute-expression-python3-no-switch ()
  "Send expression at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'expression 'python3 nil 'no-switch))

(defun gd-execute-expression-python3-dedicated ()
  "Send expression at point to Python3 unique interpreter. "
  (interactive)
  (gd--execute-prepare 'expression 'python3 t nil))

(defun gd-execute-expression-python3-dedicated-switch ()
  "Send expression at point to Python3 unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'expression 'python3 t 'switch))

(defun gd-execute-indent ()
  "Send indent at point to  interpreter. "
  (interactive)
  (gd--execute-prepare 'indent nil  nil nil))

(defun gd-execute-indent-switch ()
  "Send indent at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'indent nil  nil 'switch))

(defun gd-execute-indent-no-switch ()
  "Send indent at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'indent nil  nil 'no-switch))

(defun gd-execute-indent-dedicated ()
  "Send indent at point to  unique interpreter. "
  (interactive)
  (gd--execute-prepare 'indent nil  t nil))

(defun gd-execute-indent-dedicated-switch ()
  "Send indent at point to  unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'indent nil  t 'switch))

(defun gd-execute-indent-ipython ()
  "Send indent at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'indent 'ipython nil nil))

(defun gd-execute-indent-ipython-switch ()
  "Send indent at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'indent 'ipython nil 'switch))

(defun gd-execute-indent-ipython-no-switch ()
  "Send indent at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'indent 'ipython nil 'no-switch))

(defun gd-execute-indent-ipython-dedicated ()
  "Send indent at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'indent 'ipython t nil))

(defun gd-execute-indent-ipython-dedicated-switch ()
  "Send indent at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'indent 'ipython t 'switch))

(defun gd-execute-indent-ipython2.7 ()
  "Send indent at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'indent 'ipython2.7 nil nil))

(defun gd-execute-indent-ipython2.7-switch ()
  "Send indent at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'indent 'ipython2.7 nil 'switch))

(defun gd-execute-indent-ipython2.7-no-switch ()
  "Send indent at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'indent 'ipython2.7 nil 'no-switch))

(defun gd-execute-indent-ipython2.7-dedicated ()
  "Send indent at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'indent 'ipython2.7 t nil))

(defun gd-execute-indent-ipython2.7-dedicated-switch ()
  "Send indent at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'indent 'ipython2.7 t 'switch))

(defun gd-execute-indent-ipython3 ()
  "Send indent at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'indent 'ipython3 nil nil))

(defun gd-execute-indent-ipython3-switch ()
  "Send indent at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'indent 'ipython3 nil 'switch))

(defun gd-execute-indent-ipython3-no-switch ()
  "Send indent at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'indent 'ipython3 nil 'no-switch))

(defun gd-execute-indent-ipython3-dedicated ()
  "Send indent at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'indent 'ipython3 t nil))

(defun gd-execute-indent-ipython3-dedicated-switch ()
  "Send indent at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'indent 'ipython3 t 'switch))

(defun gd-execute-indent-jython ()
  "Send indent at point to Jython interpreter. "
  (interactive)
  (gd--execute-prepare 'indent 'jython nil nil))

(defun gd-execute-indent-jython-switch ()
  "Send indent at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'indent 'jython nil 'switch))

(defun gd-execute-indent-jython-no-switch ()
  "Send indent at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'indent 'jython nil 'no-switch))

(defun gd-execute-indent-jython-dedicated ()
  "Send indent at point to Jython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'indent 'jython t nil))

(defun gd-execute-indent-jython-dedicated-switch ()
  "Send indent at point to Jython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'indent 'jython t 'switch))

(defun gd-execute-indent-python ()
  "Send indent at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'indent 'python nil nil))

(defun gd-execute-indent-gdscript-switch ()
  "Send indent at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'indent 'python nil 'switch))

(defun gd-execute-indent-gdscript-no-switch ()
  "Send indent at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'indent 'python nil 'no-switch))

(defun gd-execute-indent-gdscript-dedicated ()
  "Send indent at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'indent 'python t nil))

(defun gd-execute-indent-gdscript-dedicated-switch ()
  "Send indent at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'indent 'python t 'switch))

(defun gd-execute-indent-python2 ()
  "Send indent at point to Python2 interpreter. "
  (interactive)
  (gd--execute-prepare 'indent 'python2 nil nil))

(defun gd-execute-indent-python2-switch ()
  "Send indent at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'indent 'python2 nil 'switch))

(defun gd-execute-indent-python2-no-switch ()
  "Send indent at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'indent 'python2 nil 'no-switch))

(defun gd-execute-indent-python2-dedicated ()
  "Send indent at point to Python2 unique interpreter. "
  (interactive)
  (gd--execute-prepare 'indent 'python2 t nil))

(defun gd-execute-indent-python2-dedicated-switch ()
  "Send indent at point to Python2 unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'indent 'python2 t 'switch))

(defun gd-execute-indent-python3 ()
  "Send indent at point to Python3 interpreter. "
  (interactive)
  (gd--execute-prepare 'indent 'python3 nil nil))

(defun gd-execute-indent-python3-switch ()
  "Send indent at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'indent 'python3 nil 'switch))

(defun gd-execute-indent-python3-no-switch ()
  "Send indent at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'indent 'python3 nil 'no-switch))

(defun gd-execute-indent-python3-dedicated ()
  "Send indent at point to Python3 unique interpreter. "
  (interactive)
  (gd--execute-prepare 'indent 'python3 t nil))

(defun gd-execute-indent-python3-dedicated-switch ()
  "Send indent at point to Python3 unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'indent 'python3 t 'switch))

(defun gd-execute-line ()
  "Send line at point to  interpreter. "
  (interactive)
  (gd--execute-prepare 'line nil  nil nil))

(defun gd-execute-line-switch ()
  "Send line at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'line nil  nil 'switch))

(defun gd-execute-line-no-switch ()
  "Send line at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'line nil  nil 'no-switch))

(defun gd-execute-line-dedicated ()
  "Send line at point to  unique interpreter. "
  (interactive)
  (gd--execute-prepare 'line nil  t nil))

(defun gd-execute-line-dedicated-switch ()
  "Send line at point to  unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'line nil  t 'switch))

(defun gd-execute-line-ipython ()
  "Send line at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'line 'ipython nil nil))

(defun gd-execute-line-ipython-switch ()
  "Send line at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'line 'ipython nil 'switch))

(defun gd-execute-line-ipython-no-switch ()
  "Send line at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'line 'ipython nil 'no-switch))

(defun gd-execute-line-ipython-dedicated ()
  "Send line at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'line 'ipython t nil))

(defun gd-execute-line-ipython-dedicated-switch ()
  "Send line at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'line 'ipython t 'switch))

(defun gd-execute-line-ipython2.7 ()
  "Send line at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'line 'ipython2.7 nil nil))

(defun gd-execute-line-ipython2.7-switch ()
  "Send line at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'line 'ipython2.7 nil 'switch))

(defun gd-execute-line-ipython2.7-no-switch ()
  "Send line at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'line 'ipython2.7 nil 'no-switch))

(defun gd-execute-line-ipython2.7-dedicated ()
  "Send line at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'line 'ipython2.7 t nil))

(defun gd-execute-line-ipython2.7-dedicated-switch ()
  "Send line at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'line 'ipython2.7 t 'switch))

(defun gd-execute-line-ipython3 ()
  "Send line at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'line 'ipython3 nil nil))

(defun gd-execute-line-ipython3-switch ()
  "Send line at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'line 'ipython3 nil 'switch))

(defun gd-execute-line-ipython3-no-switch ()
  "Send line at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'line 'ipython3 nil 'no-switch))

(defun gd-execute-line-ipython3-dedicated ()
  "Send line at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'line 'ipython3 t nil))

(defun gd-execute-line-ipython3-dedicated-switch ()
  "Send line at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'line 'ipython3 t 'switch))

(defun gd-execute-line-jython ()
  "Send line at point to Jython interpreter. "
  (interactive)
  (gd--execute-prepare 'line 'jython nil nil))

(defun gd-execute-line-jython-switch ()
  "Send line at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'line 'jython nil 'switch))

(defun gd-execute-line-jython-no-switch ()
  "Send line at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'line 'jython nil 'no-switch))

(defun gd-execute-line-jython-dedicated ()
  "Send line at point to Jython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'line 'jython t nil))

(defun gd-execute-line-jython-dedicated-switch ()
  "Send line at point to Jython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'line 'jython t 'switch))

(defun gd-execute-line-python ()
  "Send line at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'line 'python nil nil))

(defun gd-execute-line-gdscript-switch ()
  "Send line at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'line 'python nil 'switch))

(defun gd-execute-line-gdscript-no-switch ()
  "Send line at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'line 'python nil 'no-switch))

(defun gd-execute-line-gdscript-dedicated ()
  "Send line at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'line 'python t nil))

(defun gd-execute-line-gdscript-dedicated-switch ()
  "Send line at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'line 'python t 'switch))

(defun gd-execute-line-python2 ()
  "Send line at point to Python2 interpreter. "
  (interactive)
  (gd--execute-prepare 'line 'python2 nil nil))

(defun gd-execute-line-python2-switch ()
  "Send line at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'line 'python2 nil 'switch))

(defun gd-execute-line-python2-no-switch ()
  "Send line at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'line 'python2 nil 'no-switch))

(defun gd-execute-line-python2-dedicated ()
  "Send line at point to Python2 unique interpreter. "
  (interactive)
  (gd--execute-prepare 'line 'python2 t nil))

(defun gd-execute-line-python2-dedicated-switch ()
  "Send line at point to Python2 unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'line 'python2 t 'switch))

(defun gd-execute-line-python3 ()
  "Send line at point to Python3 interpreter. "
  (interactive)
  (gd--execute-prepare 'line 'python3 nil nil))

(defun gd-execute-line-python3-switch ()
  "Send line at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'line 'python3 nil 'switch))

(defun gd-execute-line-python3-no-switch ()
  "Send line at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'line 'python3 nil 'no-switch))

(defun gd-execute-line-python3-dedicated ()
  "Send line at point to Python3 unique interpreter. "
  (interactive)
  (gd--execute-prepare 'line 'python3 t nil))

(defun gd-execute-line-python3-dedicated-switch ()
  "Send line at point to Python3 unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'line 'python3 t 'switch))

(defun gd-execute-minor-block ()
  "Send minor-block at point to  interpreter. "
  (interactive)
  (gd--execute-prepare 'minor-block nil  nil nil))

(defun gd-execute-minor-block-switch ()
  "Send minor-block at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'minor-block nil  nil 'switch))

(defun gd-execute-minor-block-no-switch ()
  "Send minor-block at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'minor-block nil  nil 'no-switch))

(defun gd-execute-minor-block-dedicated ()
  "Send minor-block at point to  unique interpreter. "
  (interactive)
  (gd--execute-prepare 'minor-block nil  t nil))

(defun gd-execute-minor-block-dedicated-switch ()
  "Send minor-block at point to  unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'minor-block nil  t 'switch))

(defun gd-execute-minor-block-ipython ()
  "Send minor-block at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'minor-block 'ipython nil nil))

(defun gd-execute-minor-block-ipython-switch ()
  "Send minor-block at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'minor-block 'ipython nil 'switch))

(defun gd-execute-minor-block-ipython-no-switch ()
  "Send minor-block at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'minor-block 'ipython nil 'no-switch))

(defun gd-execute-minor-block-ipython-dedicated ()
  "Send minor-block at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'minor-block 'ipython t nil))

(defun gd-execute-minor-block-ipython-dedicated-switch ()
  "Send minor-block at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'minor-block 'ipython t 'switch))

(defun gd-execute-minor-block-ipython2.7 ()
  "Send minor-block at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'minor-block 'ipython2.7 nil nil))

(defun gd-execute-minor-block-ipython2.7-switch ()
  "Send minor-block at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'minor-block 'ipython2.7 nil 'switch))

(defun gd-execute-minor-block-ipython2.7-no-switch ()
  "Send minor-block at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'minor-block 'ipython2.7 nil 'no-switch))

(defun gd-execute-minor-block-ipython2.7-dedicated ()
  "Send minor-block at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'minor-block 'ipython2.7 t nil))

(defun gd-execute-minor-block-ipython2.7-dedicated-switch ()
  "Send minor-block at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'minor-block 'ipython2.7 t 'switch))

(defun gd-execute-minor-block-ipython3 ()
  "Send minor-block at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'minor-block 'ipython3 nil nil))

(defun gd-execute-minor-block-ipython3-switch ()
  "Send minor-block at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'minor-block 'ipython3 nil 'switch))

(defun gd-execute-minor-block-ipython3-no-switch ()
  "Send minor-block at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'minor-block 'ipython3 nil 'no-switch))

(defun gd-execute-minor-block-ipython3-dedicated ()
  "Send minor-block at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'minor-block 'ipython3 t nil))

(defun gd-execute-minor-block-ipython3-dedicated-switch ()
  "Send minor-block at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'minor-block 'ipython3 t 'switch))

(defun gd-execute-minor-block-jython ()
  "Send minor-block at point to Jython interpreter. "
  (interactive)
  (gd--execute-prepare 'minor-block 'jython nil nil))

(defun gd-execute-minor-block-jython-switch ()
  "Send minor-block at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'minor-block 'jython nil 'switch))

(defun gd-execute-minor-block-jython-no-switch ()
  "Send minor-block at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'minor-block 'jython nil 'no-switch))

(defun gd-execute-minor-block-jython-dedicated ()
  "Send minor-block at point to Jython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'minor-block 'jython t nil))

(defun gd-execute-minor-block-jython-dedicated-switch ()
  "Send minor-block at point to Jython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'minor-block 'jython t 'switch))

(defun gd-execute-minor-block-python ()
  "Send minor-block at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'minor-block 'python nil nil))

(defun gd-execute-minor-block-gdscript-switch ()
  "Send minor-block at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'minor-block 'python nil 'switch))

(defun gd-execute-minor-block-gdscript-no-switch ()
  "Send minor-block at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'minor-block 'python nil 'no-switch))

(defun gd-execute-minor-block-gdscript-dedicated ()
  "Send minor-block at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'minor-block 'python t nil))

(defun gd-execute-minor-block-gdscript-dedicated-switch ()
  "Send minor-block at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'minor-block 'python t 'switch))

(defun gd-execute-minor-block-python2 ()
  "Send minor-block at point to Python2 interpreter. "
  (interactive)
  (gd--execute-prepare 'minor-block 'python2 nil nil))

(defun gd-execute-minor-block-python2-switch ()
  "Send minor-block at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'minor-block 'python2 nil 'switch))

(defun gd-execute-minor-block-python2-no-switch ()
  "Send minor-block at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'minor-block 'python2 nil 'no-switch))

(defun gd-execute-minor-block-python2-dedicated ()
  "Send minor-block at point to Python2 unique interpreter. "
  (interactive)
  (gd--execute-prepare 'minor-block 'python2 t nil))

(defun gd-execute-minor-block-python2-dedicated-switch ()
  "Send minor-block at point to Python2 unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'minor-block 'python2 t 'switch))

(defun gd-execute-minor-block-python3 ()
  "Send minor-block at point to Python3 interpreter. "
  (interactive)
  (gd--execute-prepare 'minor-block 'python3 nil nil))

(defun gd-execute-minor-block-python3-switch ()
  "Send minor-block at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'minor-block 'python3 nil 'switch))

(defun gd-execute-minor-block-python3-no-switch ()
  "Send minor-block at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'minor-block 'python3 nil 'no-switch))

(defun gd-execute-minor-block-python3-dedicated ()
  "Send minor-block at point to Python3 unique interpreter. "
  (interactive)
  (gd--execute-prepare 'minor-block 'python3 t nil))

(defun gd-execute-minor-block-python3-dedicated-switch ()
  "Send minor-block at point to Python3 unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'minor-block 'python3 t 'switch))

(defun gd-execute-paragraph ()
  "Send paragraph at point to  interpreter. "
  (interactive)
  (gd--execute-prepare 'paragraph nil  nil nil))

(defun gd-execute-paragraph-switch ()
  "Send paragraph at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'paragraph nil  nil 'switch))

(defun gd-execute-paragraph-no-switch ()
  "Send paragraph at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'paragraph nil  nil 'no-switch))

(defun gd-execute-paragraph-dedicated ()
  "Send paragraph at point to  unique interpreter. "
  (interactive)
  (gd--execute-prepare 'paragraph nil  t nil))

(defun gd-execute-paragraph-dedicated-switch ()
  "Send paragraph at point to  unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'paragraph nil  t 'switch))

(defun gd-execute-paragraph-ipython ()
  "Send paragraph at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'paragraph 'ipython nil nil))

(defun gd-execute-paragraph-ipython-switch ()
  "Send paragraph at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'paragraph 'ipython nil 'switch))

(defun gd-execute-paragraph-ipython-no-switch ()
  "Send paragraph at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'paragraph 'ipython nil 'no-switch))

(defun gd-execute-paragraph-ipython-dedicated ()
  "Send paragraph at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'paragraph 'ipython t nil))

(defun gd-execute-paragraph-ipython-dedicated-switch ()
  "Send paragraph at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'paragraph 'ipython t 'switch))

(defun gd-execute-paragraph-ipython2.7 ()
  "Send paragraph at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'paragraph 'ipython2.7 nil nil))

(defun gd-execute-paragraph-ipython2.7-switch ()
  "Send paragraph at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'paragraph 'ipython2.7 nil 'switch))

(defun gd-execute-paragraph-ipython2.7-no-switch ()
  "Send paragraph at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'paragraph 'ipython2.7 nil 'no-switch))

(defun gd-execute-paragraph-ipython2.7-dedicated ()
  "Send paragraph at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'paragraph 'ipython2.7 t nil))

(defun gd-execute-paragraph-ipython2.7-dedicated-switch ()
  "Send paragraph at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'paragraph 'ipython2.7 t 'switch))

(defun gd-execute-paragraph-ipython3 ()
  "Send paragraph at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'paragraph 'ipython3 nil nil))

(defun gd-execute-paragraph-ipython3-switch ()
  "Send paragraph at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'paragraph 'ipython3 nil 'switch))

(defun gd-execute-paragraph-ipython3-no-switch ()
  "Send paragraph at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'paragraph 'ipython3 nil 'no-switch))

(defun gd-execute-paragraph-ipython3-dedicated ()
  "Send paragraph at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'paragraph 'ipython3 t nil))

(defun gd-execute-paragraph-ipython3-dedicated-switch ()
  "Send paragraph at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'paragraph 'ipython3 t 'switch))

(defun gd-execute-paragraph-jython ()
  "Send paragraph at point to Jython interpreter. "
  (interactive)
  (gd--execute-prepare 'paragraph 'jython nil nil))

(defun gd-execute-paragraph-jython-switch ()
  "Send paragraph at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'paragraph 'jython nil 'switch))

(defun gd-execute-paragraph-jython-no-switch ()
  "Send paragraph at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'paragraph 'jython nil 'no-switch))

(defun gd-execute-paragraph-jython-dedicated ()
  "Send paragraph at point to Jython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'paragraph 'jython t nil))

(defun gd-execute-paragraph-jython-dedicated-switch ()
  "Send paragraph at point to Jython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'paragraph 'jython t 'switch))

(defun gd-execute-paragraph-python ()
  "Send paragraph at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'paragraph 'python nil nil))

(defun gd-execute-paragraph-gdscript-switch ()
  "Send paragraph at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'paragraph 'python nil 'switch))

(defun gd-execute-paragraph-gdscript-no-switch ()
  "Send paragraph at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'paragraph 'python nil 'no-switch))

(defun gd-execute-paragraph-gdscript-dedicated ()
  "Send paragraph at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'paragraph 'python t nil))

(defun gd-execute-paragraph-gdscript-dedicated-switch ()
  "Send paragraph at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'paragraph 'python t 'switch))

(defun gd-execute-paragraph-python2 ()
  "Send paragraph at point to Python2 interpreter. "
  (interactive)
  (gd--execute-prepare 'paragraph 'python2 nil nil))

(defun gd-execute-paragraph-python2-switch ()
  "Send paragraph at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'paragraph 'python2 nil 'switch))

(defun gd-execute-paragraph-python2-no-switch ()
  "Send paragraph at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'paragraph 'python2 nil 'no-switch))

(defun gd-execute-paragraph-python2-dedicated ()
  "Send paragraph at point to Python2 unique interpreter. "
  (interactive)
  (gd--execute-prepare 'paragraph 'python2 t nil))

(defun gd-execute-paragraph-python2-dedicated-switch ()
  "Send paragraph at point to Python2 unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'paragraph 'python2 t 'switch))

(defun gd-execute-paragraph-python3 ()
  "Send paragraph at point to Python3 interpreter. "
  (interactive)
  (gd--execute-prepare 'paragraph 'python3 nil nil))

(defun gd-execute-paragraph-python3-switch ()
  "Send paragraph at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'paragraph 'python3 nil 'switch))

(defun gd-execute-paragraph-python3-no-switch ()
  "Send paragraph at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'paragraph 'python3 nil 'no-switch))

(defun gd-execute-paragraph-python3-dedicated ()
  "Send paragraph at point to Python3 unique interpreter. "
  (interactive)
  (gd--execute-prepare 'paragraph 'python3 t nil))

(defun gd-execute-paragraph-python3-dedicated-switch ()
  "Send paragraph at point to Python3 unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'paragraph 'python3 t 'switch))

(defun gd-execute-partial-expression ()
  "Send partial-expression at point to  interpreter. "
  (interactive)
  (gd--execute-prepare 'partial-expression nil  nil nil))

(defun gd-execute-partial-expression-switch ()
  "Send partial-expression at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'partial-expression nil  nil 'switch))

(defun gd-execute-partial-expression-no-switch ()
  "Send partial-expression at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'partial-expression nil  nil 'no-switch))

(defun gd-execute-partial-expression-dedicated ()
  "Send partial-expression at point to  unique interpreter. "
  (interactive)
  (gd--execute-prepare 'partial-expression nil  t nil))

(defun gd-execute-partial-expression-dedicated-switch ()
  "Send partial-expression at point to  unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'partial-expression nil  t 'switch))

(defun gd-execute-partial-expression-ipython ()
  "Send partial-expression at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'partial-expression 'ipython nil nil))

(defun gd-execute-partial-expression-ipython-switch ()
  "Send partial-expression at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'partial-expression 'ipython nil 'switch))

(defun gd-execute-partial-expression-ipython-no-switch ()
  "Send partial-expression at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'partial-expression 'ipython nil 'no-switch))

(defun gd-execute-partial-expression-ipython-dedicated ()
  "Send partial-expression at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'partial-expression 'ipython t nil))

(defun gd-execute-partial-expression-ipython-dedicated-switch ()
  "Send partial-expression at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'partial-expression 'ipython t 'switch))

(defun gd-execute-partial-expression-ipython2.7 ()
  "Send partial-expression at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'partial-expression 'ipython2.7 nil nil))

(defun gd-execute-partial-expression-ipython2.7-switch ()
  "Send partial-expression at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'partial-expression 'ipython2.7 nil 'switch))

(defun gd-execute-partial-expression-ipython2.7-no-switch ()
  "Send partial-expression at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'partial-expression 'ipython2.7 nil 'no-switch))

(defun gd-execute-partial-expression-ipython2.7-dedicated ()
  "Send partial-expression at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'partial-expression 'ipython2.7 t nil))

(defun gd-execute-partial-expression-ipython2.7-dedicated-switch ()
  "Send partial-expression at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'partial-expression 'ipython2.7 t 'switch))

(defun gd-execute-partial-expression-ipython3 ()
  "Send partial-expression at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'partial-expression 'ipython3 nil nil))

(defun gd-execute-partial-expression-ipython3-switch ()
  "Send partial-expression at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'partial-expression 'ipython3 nil 'switch))

(defun gd-execute-partial-expression-ipython3-no-switch ()
  "Send partial-expression at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'partial-expression 'ipython3 nil 'no-switch))

(defun gd-execute-partial-expression-ipython3-dedicated ()
  "Send partial-expression at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'partial-expression 'ipython3 t nil))

(defun gd-execute-partial-expression-ipython3-dedicated-switch ()
  "Send partial-expression at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'partial-expression 'ipython3 t 'switch))

(defun gd-execute-partial-expression-jython ()
  "Send partial-expression at point to Jython interpreter. "
  (interactive)
  (gd--execute-prepare 'partial-expression 'jython nil nil))

(defun gd-execute-partial-expression-jython-switch ()
  "Send partial-expression at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'partial-expression 'jython nil 'switch))

(defun gd-execute-partial-expression-jython-no-switch ()
  "Send partial-expression at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'partial-expression 'jython nil 'no-switch))

(defun gd-execute-partial-expression-jython-dedicated ()
  "Send partial-expression at point to Jython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'partial-expression 'jython t nil))

(defun gd-execute-partial-expression-jython-dedicated-switch ()
  "Send partial-expression at point to Jython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'partial-expression 'jython t 'switch))

(defun gd-execute-partial-expression-python ()
  "Send partial-expression at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'partial-expression 'python nil nil))

(defun gd-execute-partial-expression-gdscript-switch ()
  "Send partial-expression at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'partial-expression 'python nil 'switch))

(defun gd-execute-partial-expression-gdscript-no-switch ()
  "Send partial-expression at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'partial-expression 'python nil 'no-switch))

(defun gd-execute-partial-expression-gdscript-dedicated ()
  "Send partial-expression at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'partial-expression 'python t nil))

(defun gd-execute-partial-expression-gdscript-dedicated-switch ()
  "Send partial-expression at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'partial-expression 'python t 'switch))

(defun gd-execute-partial-expression-python2 ()
  "Send partial-expression at point to Python2 interpreter. "
  (interactive)
  (gd--execute-prepare 'partial-expression 'python2 nil nil))

(defun gd-execute-partial-expression-python2-switch ()
  "Send partial-expression at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'partial-expression 'python2 nil 'switch))

(defun gd-execute-partial-expression-python2-no-switch ()
  "Send partial-expression at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'partial-expression 'python2 nil 'no-switch))

(defun gd-execute-partial-expression-python2-dedicated ()
  "Send partial-expression at point to Python2 unique interpreter. "
  (interactive)
  (gd--execute-prepare 'partial-expression 'python2 t nil))

(defun gd-execute-partial-expression-python2-dedicated-switch ()
  "Send partial-expression at point to Python2 unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'partial-expression 'python2 t 'switch))

(defun gd-execute-partial-expression-python3 ()
  "Send partial-expression at point to Python3 interpreter. "
  (interactive)
  (gd--execute-prepare 'partial-expression 'python3 nil nil))

(defun gd-execute-partial-expression-python3-switch ()
  "Send partial-expression at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'partial-expression 'python3 nil 'switch))

(defun gd-execute-partial-expression-python3-no-switch ()
  "Send partial-expression at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'partial-expression 'python3 nil 'no-switch))

(defun gd-execute-partial-expression-python3-dedicated ()
  "Send partial-expression at point to Python3 unique interpreter. "
  (interactive)
  (gd--execute-prepare 'partial-expression 'python3 t nil))

(defun gd-execute-partial-expression-python3-dedicated-switch ()
  "Send partial-expression at point to Python3 unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'partial-expression 'python3 t 'switch))

(defun gd-execute-region (beg end)
  "Send region at point to  interpreter. "
  (interactive "r")
  (gd--execute-prepare 'region nil  nil nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-switch (beg end)
  "Send region at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive "r")
  (gd--execute-prepare 'region nil  nil 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-no-switch (beg end)
  "Send region at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive "r")
  (gd--execute-prepare 'region nil  nil 'no-switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-dedicated (beg end)
  "Send region at point to  unique interpreter. "
  (interactive "r")
  (gd--execute-prepare 'region nil  t nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-dedicated-switch (beg end)
  "Send region at point to  unique interpreter and switch to result. "
  (interactive "r")
  (gd--execute-prepare 'region nil  t 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython (beg end)
  "Send region at point to IPython interpreter. "
  (interactive "r")
  (gd--execute-prepare 'region 'ipython nil nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython-switch (beg end)
  "Send region at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive "r")
  (gd--execute-prepare 'region 'ipython nil 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython-no-switch (beg end)
  "Send region at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive "r")
  (gd--execute-prepare 'region 'ipython nil 'no-switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython-dedicated (beg end)
  "Send region at point to IPython unique interpreter. "
  (interactive "r")
  (gd--execute-prepare 'region 'ipython t nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython-dedicated-switch (beg end)
  "Send region at point to IPython unique interpreter and switch to result. "
  (interactive "r")
  (gd--execute-prepare 'region 'ipython t 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython2.7 (beg end)
  "Send region at point to IPython interpreter. "
  (interactive "r")
  (gd--execute-prepare 'region 'ipython2.7 nil nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython2.7-switch (beg end)
  "Send region at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive "r")
  (gd--execute-prepare 'region 'ipython2.7 nil 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython2.7-no-switch (beg end)
  "Send region at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive "r")
  (gd--execute-prepare 'region 'ipython2.7 nil 'no-switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython2.7-dedicated (beg end)
  "Send region at point to IPython unique interpreter. "
  (interactive "r")
  (gd--execute-prepare 'region 'ipython2.7 t nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython2.7-dedicated-switch (beg end)
  "Send region at point to IPython unique interpreter and switch to result. "
  (interactive "r")
  (gd--execute-prepare 'region 'ipython2.7 t 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython3 (beg end)
  "Send region at point to IPython interpreter. "
  (interactive "r")
  (gd--execute-prepare 'region 'ipython3 nil nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython3-switch (beg end)
  "Send region at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive "r")
  (gd--execute-prepare 'region 'ipython3 nil 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython3-no-switch (beg end)
  "Send region at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive "r")
  (gd--execute-prepare 'region 'ipython3 nil 'no-switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython3-dedicated (beg end)
  "Send region at point to IPython unique interpreter. "
  (interactive "r")
  (gd--execute-prepare 'region 'ipython3 t nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-ipython3-dedicated-switch (beg end)
  "Send region at point to IPython unique interpreter and switch to result. "
  (interactive "r")
  (gd--execute-prepare 'region 'ipython3 t 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-jython (beg end)
  "Send region at point to Jython interpreter. "
  (interactive "r")
  (gd--execute-prepare 'region 'jython nil nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-jython-switch (beg end)
  "Send region at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive "r")
  (gd--execute-prepare 'region 'jython nil 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-jython-no-switch (beg end)
  "Send region at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive "r")
  (gd--execute-prepare 'region 'jython nil 'no-switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-jython-dedicated (beg end)
  "Send region at point to Jython unique interpreter. "
  (interactive "r")
  (gd--execute-prepare 'region 'jython t nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-jython-dedicated-switch (beg end)
  "Send region at point to Jython unique interpreter and switch to result. "
  (interactive "r")
  (gd--execute-prepare 'region 'jython t 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-python (beg end)
  "Send region at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive "r")
  (gd--execute-prepare 'region 'python nil nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-gdscript-switch (beg end)
  "Send region at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive "r")
  (gd--execute-prepare 'region 'python nil 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-gdscript-no-switch (beg end)
  "Send region at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive "r")
  (gd--execute-prepare 'region 'python nil 'no-switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-gdscript-dedicated (beg end)
  "Send region at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive "r")
  (gd--execute-prepare 'region 'python t nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-gdscript-dedicated-switch (beg end)
  "Send region at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive "r")
  (gd--execute-prepare 'region 'python t 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-python2 (beg end)
  "Send region at point to Python2 interpreter. "
  (interactive "r")
  (gd--execute-prepare 'region 'python2 nil nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-python2-switch (beg end)
  "Send region at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive "r")
  (gd--execute-prepare 'region 'python2 nil 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-python2-no-switch (beg end)
  "Send region at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive "r")
  (gd--execute-prepare 'region 'python2 nil 'no-switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-python2-dedicated (beg end)
  "Send region at point to Python2 unique interpreter. "
  (interactive "r")
  (gd--execute-prepare 'region 'python2 t nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-python2-dedicated-switch (beg end)
  "Send region at point to Python2 unique interpreter and switch to result. "
  (interactive "r")
  (gd--execute-prepare 'region 'python2 t 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-python3 (beg end)
  "Send region at point to Python3 interpreter. "
  (interactive "r")
  (gd--execute-prepare 'region 'python3 nil nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-python3-switch (beg end)
  "Send region at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive "r")
  (gd--execute-prepare 'region 'python3 nil 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-python3-no-switch (beg end)
  "Send region at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive "r")
  (gd--execute-prepare 'region 'python3 nil 'no-switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-python3-dedicated (beg end)
  "Send region at point to Python3 unique interpreter. "
  (interactive "r")
  (gd--execute-prepare 'region 'python3 t nil (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-region-python3-dedicated-switch (beg end)
  "Send region at point to Python3 unique interpreter and switch to result. "
  (interactive "r")
  (gd--execute-prepare 'region 'python3 t 'switch (or beg (region-beginning)) (or end (region-end))))

(defun gd-execute-statement ()
  "Send statement at point to  interpreter. "
  (interactive)
  (gd--execute-prepare 'statement nil  nil nil))

(defun gd-execute-statement-switch ()
  "Send statement at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'statement nil  nil 'switch))

(defun gd-execute-statement-no-switch ()
  "Send statement at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'statement nil  nil 'no-switch))

(defun gd-execute-statement-dedicated ()
  "Send statement at point to  unique interpreter. "
  (interactive)
  (gd--execute-prepare 'statement nil  t nil))

(defun gd-execute-statement-dedicated-switch ()
  "Send statement at point to  unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'statement nil  t 'switch))

(defun gd-execute-statement-ipython ()
  "Send statement at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'statement 'ipython nil nil))

(defun gd-execute-statement-ipython-switch ()
  "Send statement at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'statement 'ipython nil 'switch))

(defun gd-execute-statement-ipython-no-switch ()
  "Send statement at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'statement 'ipython nil 'no-switch))

(defun gd-execute-statement-ipython-dedicated ()
  "Send statement at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'statement 'ipython t nil))

(defun gd-execute-statement-ipython-dedicated-switch ()
  "Send statement at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'statement 'ipython t 'switch))

(defun gd-execute-statement-ipython2.7 ()
  "Send statement at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'statement 'ipython2.7 nil nil))

(defun gd-execute-statement-ipython2.7-switch ()
  "Send statement at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'statement 'ipython2.7 nil 'switch))

(defun gd-execute-statement-ipython2.7-no-switch ()
  "Send statement at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'statement 'ipython2.7 nil 'no-switch))

(defun gd-execute-statement-ipython2.7-dedicated ()
  "Send statement at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'statement 'ipython2.7 t nil))

(defun gd-execute-statement-ipython2.7-dedicated-switch ()
  "Send statement at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'statement 'ipython2.7 t 'switch))

(defun gd-execute-statement-ipython3 ()
  "Send statement at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'statement 'ipython3 nil nil))

(defun gd-execute-statement-ipython3-switch ()
  "Send statement at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'statement 'ipython3 nil 'switch))

(defun gd-execute-statement-ipython3-no-switch ()
  "Send statement at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'statement 'ipython3 nil 'no-switch))

(defun gd-execute-statement-ipython3-dedicated ()
  "Send statement at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'statement 'ipython3 t nil))

(defun gd-execute-statement-ipython3-dedicated-switch ()
  "Send statement at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'statement 'ipython3 t 'switch))

(defun gd-execute-statement-jython ()
  "Send statement at point to Jython interpreter. "
  (interactive)
  (gd--execute-prepare 'statement 'jython nil nil))

(defun gd-execute-statement-jython-switch ()
  "Send statement at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'statement 'jython nil 'switch))

(defun gd-execute-statement-jython-no-switch ()
  "Send statement at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'statement 'jython nil 'no-switch))

(defun gd-execute-statement-jython-dedicated ()
  "Send statement at point to Jython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'statement 'jython t nil))

(defun gd-execute-statement-jython-dedicated-switch ()
  "Send statement at point to Jython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'statement 'jython t 'switch))

(defun gd-execute-statement-python ()
  "Send statement at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'statement 'python nil nil))

(defun gd-execute-statement-gdscript-switch ()
  "Send statement at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'statement 'python nil 'switch))

(defun gd-execute-statement-gdscript-no-switch ()
  "Send statement at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'statement 'python nil 'no-switch))

(defun gd-execute-statement-gdscript-dedicated ()
  "Send statement at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'statement 'python t nil))

(defun gd-execute-statement-gdscript-dedicated-switch ()
  "Send statement at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'statement 'python t 'switch))

(defun gd-execute-statement-python2 ()
  "Send statement at point to Python2 interpreter. "
  (interactive)
  (gd--execute-prepare 'statement 'python2 nil nil))

(defun gd-execute-statement-python2-switch ()
  "Send statement at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'statement 'python2 nil 'switch))

(defun gd-execute-statement-python2-no-switch ()
  "Send statement at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'statement 'python2 nil 'no-switch))

(defun gd-execute-statement-python2-dedicated ()
  "Send statement at point to Python2 unique interpreter. "
  (interactive)
  (gd--execute-prepare 'statement 'python2 t nil))

(defun gd-execute-statement-python2-dedicated-switch ()
  "Send statement at point to Python2 unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'statement 'python2 t 'switch))

(defun gd-execute-statement-python3 ()
  "Send statement at point to Python3 interpreter. "
  (interactive)
  (gd--execute-prepare 'statement 'python3 nil nil))

(defun gd-execute-statement-python3-switch ()
  "Send statement at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'statement 'python3 nil 'switch))

(defun gd-execute-statement-python3-no-switch ()
  "Send statement at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'statement 'python3 nil 'no-switch))

(defun gd-execute-statement-python3-dedicated ()
  "Send statement at point to Python3 unique interpreter. "
  (interactive)
  (gd--execute-prepare 'statement 'python3 t nil))

(defun gd-execute-statement-python3-dedicated-switch ()
  "Send statement at point to Python3 unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'statement 'python3 t 'switch))

(defun gd-execute-top-level ()
  "Send top-level at point to  interpreter. "
  (interactive)
  (gd--execute-prepare 'top-level nil  nil nil))

(defun gd-execute-top-level-switch ()
  "Send top-level at point to  interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'top-level nil  nil 'switch))

(defun gd-execute-top-level-no-switch ()
  "Send top-level at point to  interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'top-level nil  nil 'no-switch))

(defun gd-execute-top-level-dedicated ()
  "Send top-level at point to  unique interpreter. "
  (interactive)
  (gd--execute-prepare 'top-level nil  t nil))

(defun gd-execute-top-level-dedicated-switch ()
  "Send top-level at point to  unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'top-level nil  t 'switch))

(defun gd-execute-top-level-ipython ()
  "Send top-level at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'top-level 'ipython nil nil))

(defun gd-execute-top-level-ipython-switch ()
  "Send top-level at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'top-level 'ipython nil 'switch))

(defun gd-execute-top-level-ipython-no-switch ()
  "Send top-level at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'top-level 'ipython nil 'no-switch))

(defun gd-execute-top-level-ipython-dedicated ()
  "Send top-level at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'top-level 'ipython t nil))

(defun gd-execute-top-level-ipython-dedicated-switch ()
  "Send top-level at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'top-level 'ipython t 'switch))

(defun gd-execute-top-level-ipython2.7 ()
  "Send top-level at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'top-level 'ipython2.7 nil nil))

(defun gd-execute-top-level-ipython2.7-switch ()
  "Send top-level at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'top-level 'ipython2.7 nil 'switch))

(defun gd-execute-top-level-ipython2.7-no-switch ()
  "Send top-level at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'top-level 'ipython2.7 nil 'no-switch))

(defun gd-execute-top-level-ipython2.7-dedicated ()
  "Send top-level at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'top-level 'ipython2.7 t nil))

(defun gd-execute-top-level-ipython2.7-dedicated-switch ()
  "Send top-level at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'top-level 'ipython2.7 t 'switch))

(defun gd-execute-top-level-ipython3 ()
  "Send top-level at point to IPython interpreter. "
  (interactive)
  (gd--execute-prepare 'top-level 'ipython3 nil nil))

(defun gd-execute-top-level-ipython3-switch ()
  "Send top-level at point to IPython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'top-level 'ipython3 nil 'switch))

(defun gd-execute-top-level-ipython3-no-switch ()
  "Send top-level at point to IPython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'top-level 'ipython3 nil 'no-switch))

(defun gd-execute-top-level-ipython3-dedicated ()
  "Send top-level at point to IPython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'top-level 'ipython3 t nil))

(defun gd-execute-top-level-ipython3-dedicated-switch ()
  "Send top-level at point to IPython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'top-level 'ipython3 t 'switch))

(defun gd-execute-top-level-jython ()
  "Send top-level at point to Jython interpreter. "
  (interactive)
  (gd--execute-prepare 'top-level 'jython nil nil))

(defun gd-execute-top-level-jython-switch ()
  "Send top-level at point to Jython interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'top-level 'jython nil 'switch))

(defun gd-execute-top-level-jython-no-switch ()
  "Send top-level at point to Jython interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'top-level 'jython nil 'no-switch))

(defun gd-execute-top-level-jython-dedicated ()
  "Send top-level at point to Jython unique interpreter. "
  (interactive)
  (gd--execute-prepare 'top-level 'jython t nil))

(defun gd-execute-top-level-jython-dedicated-switch ()
  "Send top-level at point to Jython unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'top-level 'jython t 'switch))

(defun gd-execute-top-level-python ()
  "Send top-level at point to default interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'top-level 'python nil nil))

(defun gd-execute-top-level-gdscript-switch ()
  "Send top-level at point to default interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'top-level 'python nil 'switch))

(defun gd-execute-top-level-gdscript-no-switch ()
  "Send top-level at point to default interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'top-level 'python nil 'no-switch))

(defun gd-execute-top-level-gdscript-dedicated ()
  "Send top-level at point to default unique interpreter. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'top-level 'python t nil))

(defun gd-execute-top-level-gdscript-dedicated-switch ()
  "Send top-level at point to default unique interpreter and switch to result. 

For `default' see value of `gd-shell-name'"
  (interactive)
  (gd--execute-prepare 'top-level 'python t 'switch))

(defun gd-execute-top-level-python2 ()
  "Send top-level at point to Python2 interpreter. "
  (interactive)
  (gd--execute-prepare 'top-level 'python2 nil nil))

(defun gd-execute-top-level-python2-switch ()
  "Send top-level at point to Python2 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'top-level 'python2 nil 'switch))

(defun gd-execute-top-level-python2-no-switch ()
  "Send top-level at point to Python2 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'top-level 'python2 nil 'no-switch))

(defun gd-execute-top-level-python2-dedicated ()
  "Send top-level at point to Python2 unique interpreter. "
  (interactive)
  (gd--execute-prepare 'top-level 'python2 t nil))

(defun gd-execute-top-level-python2-dedicated-switch ()
  "Send top-level at point to Python2 unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'top-level 'python2 t 'switch))

(defun gd-execute-top-level-python3 ()
  "Send top-level at point to Python3 interpreter. "
  (interactive)
  (gd--execute-prepare 'top-level 'python3 nil nil))

(defun gd-execute-top-level-python3-switch ()
  "Send top-level at point to Python3 interpreter. 

Switch to output buffer. Ignores `gd-switch-buffers-on-execute-p'. "
  (interactive)
  (gd--execute-prepare 'top-level 'python3 nil 'switch))

(defun gd-execute-top-level-python3-no-switch ()
  "Send top-level at point to Python3 interpreter. 

Keep current buffer. Ignores `gd-switch-buffers-on-execute-p' "
  (interactive)
  (gd--execute-prepare 'top-level 'python3 nil 'no-switch))

(defun gd-execute-top-level-python3-dedicated ()
  "Send top-level at point to Python3 unique interpreter. "
  (interactive)
  (gd--execute-prepare 'top-level 'python3 t nil))

(defun gd-execute-top-level-python3-dedicated-switch ()
  "Send top-level at point to Python3 unique interpreter and switch to result. "
  (interactive)
  (gd--execute-prepare 'top-level 'python3 t 'switch))

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

(defun gd--add-abbrev-propose (table type arg &optional dont-ask)
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
    (gd--add-abbrev-propose
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

(defun gd--in-or-behind-or-before-a-docstring ()
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
      (and n8pps (gd--docstring-p n8pps)))))

(defun gd--string-fence-delete-spaces (&optional start)
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

(defun gd--skip-raw-string-front-fence ()
  "Skip forward chars u, U, r, R followed by string-delimiters. "
  (when (member (char-after) (list ?u ?U ?r ?R))
    (forward-char 1))
  (skip-chars-forward "\'\""))

(defun gd--fill-fix-end (thisend orig docstring delimiters-style)
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

(defun gd--fill-docstring-base (thisbeg thisend style multi-line-p first-line-p beg end gd-current-indent orig docstring)
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
      (gd--skip-raw-string-front-fence)
      (skip-chars-forward "\'\"")
      (when
	  (car delimiters-style)
	(unless (or (empty-line-p)(eolp))
	  (newline (car delimiters-style))))
      (indent-region beg end gd-current-indent))
    (when multi-line-p
      (goto-char thisbeg)
      (gd--skip-raw-string-front-fence) 
      (skip-chars-forward " \t\r\n\f")
      (forward-line 1)
      (beginning-of-line)
      (unless (empty-line-p) (newline)))
    (gd--fill-fix-end thisend orig docstring delimiters-style)))

(defun gd--fill-docstring-last-line (thisbeg thisend beg end style orig first-line-p gd-current-indent)
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
    (gd--fill-docstring-base thisbeg thisend style multi-line-p first-line-p beg end gd-current-indent orig docstring))
  (goto-char orig))

(defun gd--fill-docstring-first-line (beg end thisbeg thisend style)
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

(defun gd--fill-docstring (justify style docstring orig gd-current-indent)
  ;; Delete spaces after/before string fence
  (gd--string-fence-delete-spaces docstring)
  (let* ((thisbeg (copy-marker docstring))
         (thisend (copy-marker
                   (progn
                     (goto-char thisbeg)
		     (gd--skip-raw-string-front-fence)
		     (skip-syntax-forward "^\|")
                     (point))))
         (parabeg (progn (goto-char orig) (gd--beginning-of-paragraph-position)))
         (paraend (progn (goto-char orig) (gd--end-of-paragraph-position)))
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
           (gd--fill-docstring-first-line beg end thisbeg thisend style))
          ((save-excursion (goto-char end)
			   (or (member (char-after) (list ?\" ?\'))
			       (member (char-before) (list ?\" ?\'))))
           (gd--fill-docstring-last-line thisbeg thisend beg end style orig first-line-p gd-current-indent))
          (t ;; (narrow-to-region beg end)
	     (fill-region beg end justify)))
    (gd--fill-docstring-base thisbeg thisend style multi-line-p first-line-p beg end gd-current-indent orig docstring)))

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
    (or docstring (gd--in-or-behind-or-before-a-docstring))))
  (let ((gd-current-indent (save-excursion (or (gd--beginning-of-statement-p) (gd-backward-statement)) (current-indentation)))
	;; fill-paragraph sets orig
	(orig (if (boundp 'orig) (copy-marker orig) (copy-marker (point))))
	(docstring (if (and docstring (not (number-or-marker-p docstring)))
		       (gd--in-or-behind-or-before-a-docstring)
		     docstring)))
    (if docstring
	(gd--fill-docstring justify style docstring orig gd-current-indent)
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
	       (docstring (unless (not gd-docstring-style)(gd--in-or-behind-or-before-a-docstring))))
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
  (let ((erg (gd--shift-intern (- count) start end)))
    (when (and (called-interactively-p 'any) gd-verbose-p) (message "%s" erg))
    erg))

(defalias 'gd-shift-region-right 'gd-shift-right)
(defun gd-shift-right (&optional count beg end)
  "Indent region according to `gd-indent-offset' by COUNT times.

If no region is active, current line is indented.
Returns indentation reached. "
  (interactive "p")
  (let ((erg (gd--shift-intern count beg end)))
    (when (and (called-interactively-p 'any) gd-verbose-p) (message "%s" erg))
    erg))

(defun gd--shift-intern (count &optional start end)
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

(defun gd--shift-forms-base (form arg &optional beg end)
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
         (erg (gd--shift-intern arg beg end)))
    (goto-char orig)
    erg))

(defun gd-shift-block-right (&optional arg)
  "Indent block by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (gd--shift-forms-base "block" (or arg gd-indent-offset))))
        (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-block-left (&optional arg)
  "Dedent block by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (gd--shift-forms-base "block" (- (or arg gd-indent-offset)))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-block-or-clause-right (&optional arg)
  "Indent block-or-clause by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (gd--shift-forms-base "block-or-clause" (or arg gd-indent-offset))))
        (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-block-or-clause-left (&optional arg)
  "Dedent block-or-clause by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (gd--shift-forms-base "block-or-clause" (- (or arg gd-indent-offset)))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-class-right (&optional arg)
  "Indent class by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (gd--shift-forms-base "class" (or arg gd-indent-offset))))
        (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-class-left (&optional arg)
  "Dedent class by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (gd--shift-forms-base "class" (- (or arg gd-indent-offset)))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-clause-right (&optional arg)
  "Indent clause by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (gd--shift-forms-base "clause" (or arg gd-indent-offset))))
        (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-clause-left (&optional arg)
  "Dedent clause by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (gd--shift-forms-base "clause" (- (or arg gd-indent-offset)))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-comment-right (&optional arg)
  "Indent comment by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (gd--shift-forms-base "comment" (or arg gd-indent-offset))))
        (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-comment-left (&optional arg)
  "Dedent comment by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (gd--shift-forms-base "comment" (- (or arg gd-indent-offset)))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-def-right (&optional arg)
  "Indent def by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (gd--shift-forms-base "def" (or arg gd-indent-offset))))
        (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-def-left (&optional arg)
  "Dedent def by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (gd--shift-forms-base "def" (- (or arg gd-indent-offset)))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-def-or-class-right (&optional arg)
  "Indent def-or-class by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (gd--shift-forms-base "def-or-class" (or arg gd-indent-offset))))
        (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-def-or-class-left (&optional arg)
  "Dedent def-or-class by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (gd--shift-forms-base "def-or-class" (- (or arg gd-indent-offset)))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-indent-right (&optional arg)
  "Indent indent by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (gd--shift-forms-base "indent" (or arg gd-indent-offset))))
        (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-indent-left (&optional arg)
  "Dedent indent by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (gd--shift-forms-base "indent" (- (or arg gd-indent-offset)))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-minor-block-right (&optional arg)
  "Indent minor-block by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (gd--shift-forms-base "minor-block" (or arg gd-indent-offset))))
        (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-minor-block-left (&optional arg)
  "Dedent minor-block by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (gd--shift-forms-base "minor-block" (- (or arg gd-indent-offset)))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-paragraph-right (&optional arg)
  "Indent paragraph by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (gd--shift-forms-base "paragraph" (or arg gd-indent-offset))))
        (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-paragraph-left (&optional arg)
  "Dedent paragraph by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (gd--shift-forms-base "paragraph" (- (or arg gd-indent-offset)))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-region-right (&optional arg)
  "Indent region by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (gd--shift-forms-base "region" (or arg gd-indent-offset))))
        (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-region-left (&optional arg)
  "Dedent region by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (gd--shift-forms-base "region" (- (or arg gd-indent-offset)))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-statement-right (&optional arg)
  "Indent statement by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (gd--shift-forms-base "statement" (or arg gd-indent-offset))))
        (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-statement-left (&optional arg)
  "Dedent statement by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (gd--shift-forms-base "statement" (- (or arg gd-indent-offset)))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-top-level-right (&optional arg)
  "Indent top-level by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (gd--shift-forms-base "top-level" (or arg gd-indent-offset))))
        (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd-shift-top-level-left (&optional arg)
  "Dedent top-level by COUNT spaces.

COUNT defaults to `gd-indent-offset',
use \[universal-argument] to specify a different value.

Returns outmost indentation reached. "
  (interactive "*P")
  (let ((erg (gd--shift-forms-base "top-level" (- (or arg gd-indent-offset)))))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

;; gdscript-components-execute-file

;;  Execute file commands

(defun gd-execute-file-python (&optional filename)
  "Send file to GDScript default interpreter."
  (interactive "fFile: ")
  (gd--execute-prepare filename "python" nil nil nil nil t))

(defun gd-execute-file-gdscript-switch (&optional filename)
  "Send file to GDScript default interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (gd--execute-prepare filename "python" nil 'switch nil nil t))

(defun gd-execute-file-gdscript-no-switch (&optional filename)
  "Send file to GDScript default interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"nil\""
  (interactive "fFile: ")
  (gd--execute-prepare filename "python" nil 'no-switch nil nil t))

(defun gd-execute-file-gdscript-dedicated (&optional filename)
  "Send file to GDScript default interpreter.

Uses a dedicated shell."
  (interactive "fFile: ")
  (gd--execute-prepare filename "python" 'dedicated nil nil nil t))

(defun gd-execute-file-gdscript-dedicated-switch (&optional filename)
  "Send file to GDScript default interpreter.

Uses a dedicated shell.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (gd--execute-prepare filename "python" 'dedicated 'switch nil nil t))

(defun gd-execute-file-ipython (&optional filename)
  "Send file to a Ipython interpreter."
  (interactive "fFile: ")
  (gd--execute-prepare filename "ipython" nil nil nil nil t))

(defun gd-execute-file-ipython-switch (&optional filename)
  "Send file to a Ipython interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (gd--execute-prepare filename "ipython" nil 'switch nil nil t))

(defun gd-execute-file-ipython-no-switch (&optional filename)
  "Send file to a Ipython interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"nil\""
  (interactive "fFile: ")
  (gd--execute-prepare filename "ipython" nil 'no-switch nil nil t))

(defun gd-execute-file-ipython-dedicated (&optional filename)
  "Send file to a Ipython interpreter.

Uses a dedicated shell."
  (interactive "fFile: ")
  (gd--execute-prepare filename "ipython" 'dedicated nil nil nil t))

(defun gd-execute-file-ipython-dedicated-switch (&optional filename)
  "Send file to a Ipython interpreter.

Uses a dedicated shell.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (gd--execute-prepare filename "ipython" 'dedicated 'switch nil nil t))

(defun gd-execute-file-python3 (&optional filename)
  "Send file to a Python3 interpreter."
  (interactive "fFile: ")
  (gd--execute-prepare filename "python3" nil nil nil nil t))

(defun gd-execute-file-python3-switch (&optional filename)
  "Send file to a Python3 interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (gd--execute-prepare filename "python3" nil 'switch nil nil t))

(defun gd-execute-file-python3-no-switch (&optional filename)
  "Send file to a Python3 interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"nil\""
  (interactive "fFile: ")
  (gd--execute-prepare filename "python3" nil 'no-switch nil nil t))

(defun gd-execute-file-python3-dedicated (&optional filename)
  "Send file to a Python3 interpreter.

Uses a dedicated shell."
  (interactive "fFile: ")
  (gd--execute-prepare filename "python3" 'dedicated nil nil nil t))

(defun gd-execute-file-python3-dedicated-switch (&optional filename)
  "Send file to a Python3 interpreter.

Uses a dedicated shell.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (gd--execute-prepare filename "python3" 'dedicated 'switch nil nil t))

(defun gd-execute-file-python2 (&optional filename)
  "Send file to a Python2 interpreter."
  (interactive "fFile: ")
  (gd--execute-prepare filename "python2" nil nil nil nil t))

(defun gd-execute-file-python2-switch (&optional filename)
  "Send file to a Python2 interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (gd--execute-prepare filename "python2" nil 'switch nil nil t))

(defun gd-execute-file-python2-no-switch (&optional filename)
  "Send file to a Python2 interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"nil\""
  (interactive "fFile: ")
  (gd--execute-prepare filename "python2" nil 'no-switch nil nil t))

(defun gd-execute-file-python2-dedicated (&optional filename)
  "Send file to a Python2 interpreter.

Uses a dedicated shell."
  (interactive "fFile: ")
  (gd--execute-prepare filename "python2" 'dedicated nil nil nil t))

(defun gd-execute-file-python2-dedicated-switch (&optional filename)
  "Send file to a Python2 interpreter.

Uses a dedicated shell.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (gd--execute-prepare filename "python2" 'dedicated 'switch nil nil t))

(defun gd-execute-file-python2.7 (&optional filename)
  "Send file to a Python2.7 interpreter."
  (interactive "fFile: ")
  (gd--execute-prepare filename "python2.7" nil nil nil nil t))

(defun gd-execute-file-python2.7-switch (&optional filename)
  "Send file to a Python2.7 interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (gd--execute-prepare filename "python2.7" nil 'switch nil nil t))

(defun gd-execute-file-python2.7-no-switch (&optional filename)
  "Send file to a Python2.7 interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"nil\""
  (interactive "fFile: ")
  (gd--execute-prepare filename "python2.7" nil 'no-switch nil nil t))

(defun gd-execute-file-python2.7-dedicated (&optional filename)
  "Send file to a Python2.7 interpreter.

Uses a dedicated shell."
  (interactive "fFile: ")
  (gd--execute-prepare filename "python2.7" 'dedicated nil nil nil t))

(defun gd-execute-file-python2.7-dedicated-switch (&optional filename)
  "Send file to a Python2.7 interpreter.

Uses a dedicated shell.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (gd--execute-prepare filename "python2.7" 'dedicated 'switch nil nil t))

(defun gd-execute-file-jython (&optional filename)
  "Send file to a Jython interpreter."
  (interactive "fFile: ")
  (gd--execute-prepare filename "jython" nil nil nil nil t))

(defun gd-execute-file-jython-switch (&optional filename)
  "Send file to a Jython interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (gd--execute-prepare filename "jython" nil 'switch nil nil t))

(defun gd-execute-file-jython-no-switch (&optional filename)
  "Send file to a Jython interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"nil\""
  (interactive "fFile: ")
  (gd--execute-prepare filename "jython" nil 'no-switch nil nil t))

(defun gd-execute-file-jython-dedicated (&optional filename)
  "Send file to a Jython interpreter.

Uses a dedicated shell."
  (interactive "fFile: ")
  (gd--execute-prepare filename "jython" 'dedicated nil nil nil t))

(defun gd-execute-file-jython-dedicated-switch (&optional filename)
  "Send file to a Jython interpreter.

Uses a dedicated shell.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (gd--execute-prepare filename "jython" 'dedicated 'switch nil nil t))

(defun gd-execute-file-python3.2 (&optional filename)
  "Send file to a Python3.2 interpreter."
  (interactive "fFile: ")
  (gd--execute-prepare filename "python3.2" nil nil nil nil t))

(defun gd-execute-file-python3.2-switch (&optional filename)
  "Send file to a Python3.2 interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (gd--execute-prepare filename "python3.2" nil 'switch nil nil t))

(defun gd-execute-file-python3.2-no-switch (&optional filename)
  "Send file to a Python3.2 interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"nil\""
  (interactive "fFile: ")
  (gd--execute-prepare filename "python3.2" nil 'no-switch nil nil t))

(defun gd-execute-file-python3.2-dedicated (&optional filename)
  "Send file to a Python3.2 interpreter.

Uses a dedicated shell."
  (interactive "fFile: ")
  (gd--execute-prepare filename "python3.2" 'dedicated nil nil nil t))

(defun gd-execute-file-python3.2-dedicated-switch (&optional filename)
  "Send file to a Python3.2 interpreter.

Uses a dedicated shell.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (gd--execute-prepare filename "python3.2" 'dedicated 'switch nil nil t))

(defun gd-execute-file-python3.3 (&optional filename)
  "Send file to a Python3.3 interpreter."
  (interactive "fFile: ")
  (gd--execute-prepare filename "python3.3" nil nil nil nil t))

(defun gd-execute-file-python3.3-switch (&optional filename)
  "Send file to a Python3.3 interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (gd--execute-prepare filename "python3.3" nil 'switch nil nil t))

(defun gd-execute-file-python3.3-no-switch (&optional filename)
  "Send file to a Python3.3 interpreter.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"nil\""
  (interactive "fFile: ")
  (gd--execute-prepare filename "python3.3" nil 'no-switch nil nil t))

(defun gd-execute-file-python3.3-dedicated (&optional filename)
  "Send file to a Python3.3 interpreter.

Uses a dedicated shell."
  (interactive "fFile: ")
  (gd--execute-prepare filename "python3.3" 'dedicated nil nil nil t))

(defun gd-execute-file-python3.3-dedicated-switch (&optional filename)
  "Send file to a Python3.3 interpreter.

Uses a dedicated shell.
Ignores default of `gd-switch-buffers-on-execute-p', uses it with value \"non-nil\""
  (interactive "fFile: ")
  (gd--execute-prepare filename "python3.3" 'dedicated 'switch nil nil t))

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
  (let ((erg (gd--mark-base "block")))
    (gd--forms-report-result erg (called-interactively-p 'any))))

(defun gd-block-or-clause ()
  "Block-Or-Clause at point.

Return code of `gd-block-or-clause' at point, a string. "
  (interactive)
  (let ((erg (gd--mark-base "block-or-clause")))
    (gd--forms-report-result erg (called-interactively-p 'any))))

(defun gd-buffer ()
  "Buffer at point.

Return code of `gd-buffer' at point, a string. "
  (interactive)
  (let ((erg (gd--mark-base "buffer")))
    (gd--forms-report-result erg (called-interactively-p 'any))))

(defun gd-class ()
  "Class at point.

Return code of `gd-class' at point, a string. "
  (interactive)
  (let ((erg (gd--mark-base "class")))
    (gd--forms-report-result erg (called-interactively-p 'any))))

(defun gd-clause ()
  "Clause at point.

Return code of `gd-clause' at point, a string. "
  (interactive)
  (let ((erg (gd--mark-base "clause")))
    (gd--forms-report-result erg (called-interactively-p 'any))))

(defun gd-def ()
  "Def at point.

Return code of `gd-def' at point, a string. "
  (interactive)
  (let ((erg (gd--mark-base "def")))
    (gd--forms-report-result erg (called-interactively-p 'any))))

(defun gd-def-or-class ()
  "Def-Or-Class at point.

Return code of `gd-def-or-class' at point, a string. "
  (interactive)
  (let ((erg (gd--mark-base "def-or-class")))
    (gd--forms-report-result erg (called-interactively-p 'any))))

(defun gd-expression ()
  "Expression at point.

Return code of `gd-expression' at point, a string. "
  (interactive)
  (let ((erg (gd--mark-base "expression")))
    (gd--forms-report-result erg (called-interactively-p 'any))))

(defun gd-indent ()
  "Indent at point.

Return code of `gd-indent' at point, a string. "
  (interactive)
  (let ((erg (gd--mark-base "indent")))
    (gd--forms-report-result erg (called-interactively-p 'any))))

(defun gd-line ()
  "Line at point.

Return code of `gd-line' at point, a string. "
  (interactive)
  (let ((erg (gd--mark-base "line")))
    (gd--forms-report-result erg (called-interactively-p 'any))))

(defun gd-minor-block ()
  "Minor-Block at point.

Return code of `gd-minor-block' at point, a string. "
  (interactive)
  (let ((erg (gd--mark-base "minor-block")))
    (gd--forms-report-result erg (called-interactively-p 'any))))

(defun gd-paragraph ()
  "Paragraph at point.

Return code of `gd-paragraph' at point, a string. "
  (interactive)
  (let ((erg (gd--mark-base "paragraph")))
    (gd--forms-report-result erg (called-interactively-p 'any))))

(defun gd-partial-expression ()
  "Partial-Expression at point.

Return code of `gd-partial-expression' at point, a string. "
  (interactive)
  (let ((erg (gd--mark-base "partial-expression")))
    (gd--forms-report-result erg (called-interactively-p 'any))))

(defun gd-region ()
  "Region at point.

Return code of `gd-region' at point, a string. "
  (interactive)
  (let ((erg (gd--mark-base "region")))
    (gd--forms-report-result erg (called-interactively-p 'any))))

(defun gd-statement ()
  "Statement at point.

Return code of `gd-statement' at point, a string. "
  (interactive)
  (let ((erg (gd--mark-base "statement")))
    (gd--forms-report-result erg (called-interactively-p 'any))))

(defun gd-top-level ()
  "Top-Level at point.

Return code of `gd-top-level' at point, a string. "
  (interactive)
  (let ((erg (gd--mark-base "top-level")))
    (gd--forms-report-result erg (called-interactively-p 'any))))

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

(defun gd--fast-send-string-no-output (string proc output-buffer)
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
      ;; (when gd-verbose-p (message "gd--fast-send-string-intern comint-prompt-read-only: %s" comint-prompt-read-only))
      (delete-region orig (point-max))
      ;; (setq comint-prompt-read-only comint-prompt-read-only-old)
      ;;)
      )))

(defun gd--filter-result (string)
  "Set `gd-result' according to `gd-fast-filter-re'.

Remove trailing newline"
    (replace-regexp-in-string (format "[ \n]*%s[ \n]*" gd-fast-filter-re) "" (ansi-color-filter-apply string)))

(defun gd--fast-send-string-intern (string proc output-buffer store return)
  (with-current-buffer output-buffer
    (process-send-string proc "\n")
    (let ((orig (point)))
      (process-send-string proc string)
      (process-send-string proc "\n")
      (accept-process-output proc 5)
      (sit-for gd-fast-completion-delay t)
      ;; sets gd-result
      (unless gd-ignore-result-p
	(setq gd-result (gd--filter-result (gd--fetch-result orig))))
      (when return
	gd-result))))

(defun gd--fast-send-string (string)
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
    (gd--execute-prepare 'block)))

(defun gd-execute-block-or-clause-fast ()
  "Process block-or-clause at point by a GDScript interpreter.

Suitable for large output, doesn't mess up interactive shell.
Output buffer not in comint-mode, displays \"Fast\"  by default"
  (interactive)
  (let ((gd-fast-process-p t))
    (gd--execute-prepare 'block-or-clause)))

(defun gd-execute-class-fast ()
  "Process class at point by a GDScript interpreter.

Suitable for large output, doesn't mess up interactive shell.
Output buffer not in comint-mode, displays \"Fast\"  by default"
  (interactive)
  (let ((gd-fast-process-p t))
    (gd--execute-prepare 'class)))

(defun gd-execute-clause-fast ()
  "Process clause at point by a GDScript interpreter.

Suitable for large output, doesn't mess up interactive shell.
Output buffer not in comint-mode, displays \"Fast\"  by default"
  (interactive)
  (let ((gd-fast-process-p t))
    (gd--execute-prepare 'clause)))

(defun gd-execute-def-fast ()
  "Process def at point by a GDScript interpreter.

Suitable for large output, doesn't mess up interactive shell.
Output buffer not in comint-mode, displays \"Fast\"  by default"
  (interactive)
  (let ((gd-fast-process-p t))
    (gd--execute-prepare 'def)))

(defun gd-execute-def-or-class-fast ()
  "Process def-or-class at point by a GDScript interpreter.

Suitable for large output, doesn't mess up interactive shell.
Output buffer not in comint-mode, displays \"Fast\"  by default"
  (interactive)
  (let ((gd-fast-process-p t))
    (gd--execute-prepare 'def-or-class)))

(defun gd-execute-expression-fast ()
  "Process expression at point by a GDScript interpreter.

Suitable for large output, doesn't mess up interactive shell.
Output buffer not in comint-mode, displays \"Fast\"  by default"
  (interactive)
  (let ((gd-fast-process-p t))
    (gd--execute-prepare 'expression)))

(defun gd-execute-partial-expression-fast ()
  "Process partial-expression at point by a GDScript interpreter.

Suitable for large output, doesn't mess up interactive shell.
Output buffer not in comint-mode, displays \"Fast\"  by default"
  (interactive)
  (let ((gd-fast-process-p t))
    (gd--execute-prepare 'partial-expression)))

(defun gd-execute-section-fast ()
  "Process section at point by a GDScript interpreter.

Suitable for large output, doesn't mess up interactive shell.
Output buffer not in comint-mode, displays \"Fast\"  by default"
  (interactive)
  (let ((gd-fast-process-p t))
    (gd--execute-prepare 'section)))

(defun gd-execute-statement-fast ()
  "Process statement at point by a GDScript interpreter.

Suitable for large output, doesn't mess up interactive shell.
Output buffer not in comint-mode, displays \"Fast\"  by default"
  (interactive)
  (let ((gd-fast-process-p t))
    (gd--execute-prepare 'statement)))

(defun gd-execute-top-level-fast ()
  "Process top-level at point by a GDScript interpreter.

Suitable for large output, doesn't mess up interactive shell.
Output buffer not in comint-mode, displays \"Fast\"  by default"
  (interactive)
  (let ((gd-fast-process-p t))
    (gd--execute-prepare 'top-level)))

;; gdscript-components-narrow

(defun gd-narrow-to-block ()
  "Narrow to block at point."
  (interactive)
  (gd--narrow-prepare "block"))

(defun gd-narrow-to-block-or-clause ()
  "Narrow to block-or-clause at point."
  (interactive)
  (gd--narrow-prepare "block-or-clause"))

(defun gd-narrow-to-class ()
  "Narrow to class at point."
  (interactive)
  (gd--narrow-prepare "class"))

(defun gd-narrow-to-clause ()
  "Narrow to clause at point."
  (interactive)
  (gd--narrow-prepare "clause"))

(defun gd-narrow-to-def ()
  "Narrow to def at point."
  (interactive)
  (gd--narrow-prepare "def"))

(defun gd-narrow-to-def-or-class ()
  "Narrow to def-or-class at point."
  (interactive)
  (gd--narrow-prepare "def-or-class"))

(defun gd-narrow-to-statement ()
  "Narrow to statement at point."
  (interactive)
  (gd--narrow-prepare "statement"))

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
           (beg (or beg (or (funcall (intern-soft (concat "gd--beginning-of-" form "-p")))
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
           (beg (or beg (or (funcall (intern-soft (concat "gd--beginning-of-" form "-p")))
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
           (beg (or beg (or (funcall (intern-soft (concat "gd--beginning-of-" form "-p")))
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

(defun gd--fast-completion-get-completions (input process completion-code)
  "Retrieve available completions for INPUT using PROCESS.
Argument COMPLETION-CODE is the python code used to get
completions on the current context."
  (let ((completions
	 (gd--fast-send-string-intern
	  (format completion-code input) process gd-buffer-name nil t)))
    (when (> (length completions) 2)
      (split-string completions "^'\\|^\"\\|;\\|'$\\|\"$" t))))

(defun gd--fast--do-completion-at-point (process imports input orig gd-exception-buffer code output-buffer)
  "Do completion at point for PROCESS."
  ;; send setup-code
  (let (gd-return-result-p)
    (when imports
      ;; (message "%s" imports)
      (gd--fast-send-string-no-output imports process output-buffer)))
  (let* ((completion
	  (gd--fast-completion-get-completions input process code))
	 ;; (completion (when completions
	 ;; (try-completion input completions)))
	 newlist erg)
    ;; (message "%s" (current-buffer))
    ;; (sit-for 1 t)
    (cond ((eq completion t)
	   (and gd-verbose-p (message "gd--fast--do-completion-at-point %s" "`t' is returned, not completion. Might be a bug."))
	   nil)
	  ((null completion)
	   (and gd-verbose-p (message "gd--fast--do-completion-at-point %s" "Don't see a completion"))
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
	  (t (gd--try-completion input completion)))

    nil))

(defun gd--fast-complete-base (shell pos beg end word imports debug gd-exception-buffer)
  (let* ((shell (or shell (gd-choose-shell)))
	 (gd-buffer-name (gd-shell nil nil shell nil t))
	 (proc (get-buffer-process gd-buffer-name))
	 (code (if (string-match "[Ii][Pp]ython*" shell)
		   (gd-set-ipython-completion-command-string shell)
		 gd-shell-module-completion-code)))
    (with-current-buffer gd-buffer-name
      (erase-buffer))
    (gd--fast--do-completion-at-point proc imports word pos gd-exception-buffer code gd-buffer-name)))

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
    (gd--complete-prepare shell debug beg end word t)))

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

(defun gd--buffer-filename-remote-maybe (&optional buffer)
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

(defun gd--execute-prepare (form &optional shell dedicated switch beg end file)
  "Used by gdscript-extended-executes ."
  (save-excursion
    (let* ((form (prin1-to-string form))
	   (origline (gd-count-lines))
	   (beg (unless file
                  (prog1
                      (or beg (funcall (intern-soft (concat "gd--beginning-of-" form "-p")))

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
                (gd--execute-file-base nil filename nil nil (or (and (boundp 'gd-orig-buffer-or-file) gd-orig-buffer-or-file) filename origline))
              (message "%s not readable. %s" file "Do you have write permissions?")))
        (gd--execute-base beg end shell)))))


(defun gd--kill-emacs-hook ()
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
         (erg (gd--string-strip (shell-command-to-string (concat executable " --version")))))
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
  (gd--execute-file-base (get-buffer-process (get-buffer (gd-shell))) file-name))

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
(defun gd--shell-simple-send (proc string)
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
(add-hook 'kill-emacs-hook 'gd--kill-emacs-hook)

(when gd--warn-tmp-files-left-p
  (add-hook 'gdscript-mode-hook 'gd--warn-tmp-files-left))


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
                     (gd--string-strip
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
                 gd-which-bufname (gd--choose-buffer-name)
                 msg "CPython"
                 mode-name (gd--choose-buffer-name)))
          ((string-match "jython" name)
           (setq gd-shell-name name
                 gd-which-bufname (gd--choose-buffer-name)
                 msg "Jython"
                 mode-name (gd--choose-buffer-name)))
          ((string-match "python" name)
           (setq gd-shell-name name
                 gd-which-bufname (gd--choose-buffer-name)
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

(defun gd--input-filter (str)
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

(defun gd--uncomment-intern (beg end)
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
        (gd--uncomment-intern beg (point))))))

(defun gd--set-auto-fill-values ()
  "Internal use by `gd--run-auto-fill-timer'"
  (let ((pps (parse-partial-sexp (point-min) (point))))
    (cond ((and (nth 4 pps)(numberp gd-comment-fill-column))
           (setq fill-column gd-comment-fill-column))
          ((and (nth 3 pps)(numberp gd-docstring-fill-column))
           (set (make-local-variable 'fill-column) gd-docstring-fill-column))
          (t (setq fill-column gd-fill-column-orig)))))

(defun gd--run-auto-fill-timer ()
  "Set fill-column to values of `gd-docstring-fill-column' resp. to `gd-comment-fill-column' according to environment. "
  (when gd-auto-fill-mode
    (unless gd-autofill-timer
      (setq gd-autofill-timer
            (run-with-idle-timer
             gd-autofill-timer-delay t
             'gd--set-auto-fill-values)))))

;;  unconditional Hooks
;;  (orgstruct-mode 1)
(add-hook 'gdscript-mode-hook
	  (lambda ()
	    (setq imenu-create-index-function gd--imenu-create-index-function)
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
	      (cancel-timer gd--auto-complete-timer)))))))

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

(defun gd--empty-arglist-indent (nesting gd-indent-offset indent-offset)
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

(defun gd--line-backward-maybe ()
  "Return result of (< 0 (abs (skip-chars-backward \" \\t\\r\\n\\f\"))) "
  (let ((orig (point)))
    (skip-chars-backward " \t\f" (line-beginning-position))
    (< 0 (abs (skip-chars-backward " \t\r\n\f")))))

(defun gd--after-empty-line ()
  "Return `t' if line before contains only whitespace characters. "
  (save-excursion
    (beginning-of-line)
    (forward-line -1)
    (beginning-of-line)
    (looking-at "\\s-*$")))

(defun gd--compute-indentation-in-string (pps)
  (save-restriction
    ;; (narrow-to-region (nth 8 pps) (point))
    (cond
     ((gd--docstring-p)
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
	(when (gd--line-backward-maybe) (setq line t))
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
			 (if (gd--docstring-p)
			     (gd--compute-indentation-in-string pps)
			   0))
			((and (looking-at "\"\"\"\\|'''")(not (bobp)))
			 (gd-backward-statement)
			 (gd-compute-indentation orig origline closing line nesting repeat indent-offset liep))
			;; comments
			((nth 8 pps)
			 (if (eq liep (line-end-position))
			     (progn
			       (goto-char (nth 8 pps))
			       (when (gd--line-backward-maybe) (setq line t))
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
				     (gd--empty-arglist-indent nesting gd-indent-offset indent-offset))
				    ((looking-at "\\s([ \t]*\\([^ \t]+.*\\)$")
				     (goto-char (match-beginning 1))
				     (if gd-indent-paren-spanned-multilines-p
					 (+ (current-column) gd-indent-offset)
				       (current-column)))
				    (t (gd--fetch-previous-indent orig))))
				  ;; already behind a dedented element in list
				  ((<= 2 (- origline this-line))
				   (gd--fetch-previous-indent orig))
				  ((< (current-indentation) (current-column))
				   (+ (current-indentation) gd-indent-offset))
				  (t (gd--fetch-previous-indent orig)))
			       (cond ((looking-at "\\s([ \t]*$")
				      (gd--empty-arglist-indent nesting gd-indent-offset indent-offset))
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
			    ((not (gd--beginning-of-statement-p))
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
			       (gd--fetch-previous-indent orig)
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
			       (when (gd--line-backward-maybe) (setq line t))
			       (gd-compute-indentation orig origline closing line nesting repeat indent-offset liep))
			   (current-indentation)))
			((and (looking-at gd-elif-re) (eq (gd-count-lines) origline))
			 (when (gd--line-backward-maybe) (setq line t))
			 (car (gd--clause-lookup-keyword gd-elif-re -1 nil orig origline)))
			((and (looking-at gd-clause-re)(not line)
			      (eq liep (line-end-position)))
			 (cond ((looking-at gd-finally-re)
				(car (gd--clause-lookup-keyword gd-finally-re -1 nil orig origline)))
			       ((looking-at gd-except-re)
				(car (gd--clause-lookup-keyword gd-except-re -1 nil orig origline)))
			       ((looking-at gd-else-re)
				(car (gd--clause-lookup-keyword gd-else-re -1 nil orig origline)))
			       ((looking-at gd-elif-re)
				(car (gd--clause-lookup-keyword gd-elif-re -1 nil orig origline)))
			       ;; maybe at if, try, with
			       (t (car (gd--clause-lookup-keyword gd-block-or-clause-re -1 nil orig origline)))))
			((looking-at gd-extended-block-or-clause-re)
			 (cond ((and (not line)
				     (eq liep (line-end-position)))
				(when (gd--line-backward-maybe) (setq line t))
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
			((and (not (gd--beginning-of-statement-p)) (not (and line (eq ?\# (char-after)))))
			 (if (bobp)
			     (current-column)
			   (if (eq (point) orig)
			       (progn
				 (when (gd--line-backward-maybe) (setq line t))
				 (gd-compute-indentation orig origline closing line nesting repeat indent-offset liep))
			     (gd-backward-statement)
			     (gd-compute-indentation orig origline closing line nesting repeat indent-offset liep))))
			((or (gd--statement-opens-block-p gd-extended-block-or-clause-re)(looking-at "@"))
			 (if (< (gd-count-lines) origline)
			     (+ (if gd-smart-indentation (gd-guess-indent-offset) indent-offset) (current-indentation))
			   (skip-chars-backward " \t\r\n\f")
			   (setq line t)
			   (back-to-indentation)
			   (gd-compute-indentation orig origline closing line nesting repeat indent-offset liep)))
			((and gd-empty-line-closes-p (gd--after-empty-line))
			 (progn (gd-backward-statement)
				(- (current-indentation) gd-indent-offset)))
			;; still at orignial line
			((and (eq liep (line-end-position))
			      (save-excursion
				(and (setq erg (gd--go-to-keyword gd-extended-block-or-clause-re))
				     (if gd-smart-indentation (setq indent-offset (gd-guess-indent-offset)) t)
				     (ignore-errors (< orig (or (gd-forward-block-or-clause)(point)))))))
			 (+ (car erg) (if gd-smart-indentation
					  (or indent (gd-guess-indent-offset))
					indent-offset)))
			((and (not line)
			      (eq liep (line-end-position))
			      (gd--beginning-of-statement-p))
			 (gd-backward-statement)
			 (gd-compute-indentation orig origline closing line nesting repeat indent-offset liep))
			(t (current-indentation))))
	    (when (and gd-verbose-p (called-interactively-p 'any)) (message "%s" indent))
	    indent))))))

(defun gd--fetch-previous-indent (orig)
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
               (or (gd--beginning-of-statement-p)
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

(defun gd--in-comment-p ()
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
    (and (gd--beginning-of-statement-p)
         (eq 0 (current-column))
         (setq erg (point))
      erg)))

(defun gd--beginning-of-line-p ()
  "Returns position, if cursor is at the beginning of a line, nil otherwise. "
  (when (bolp)(point)))

(defun gd--beginning-of-buffer-p ()
  "Returns position, if cursor is at the beginning of buffer, nil otherwise. "
  (when (bobp)(point)))

(defun gd--beginning-of-paragraph-p ()
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
(defun gd--end-of-line-p ()
  "Returns position, if cursor is at the end of a line, nil otherwise. "
  (when (eolp)(point)))

(defun gd--end-of-paragraph-p ()
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
(defun gd--statement-opens-block-p (&optional regexp)
  "Return position if the current statement opens a block
in stricter or wider sense.

For stricter sense specify regexp. "
  (let* ((regexp (or regexp gd-block-or-clause-re))
         (erg (gd--statement-opens-base regexp)))
    (when (called-interactively-p 'any) (message "%s" erg))
    erg))

(defun gd--statement-opens-base (regexp)
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

(defun gd--statement-opens-clause-p ()
  "Return position if the current statement opens block or clause. "
  (gd--statement-opens-base gd-clause-re))

(defun gd--statement-opens-block-or-clause-p ()
  "Return position if the current statement opens block or clause. "
  (gd--statement-opens-base gd-block-or-clause-re))

(defun gd--statement-opens-class-p ()
  "Return `t' if the statement opens a functions or class definition, nil otherwise. "
  (gd--statement-opens-base gd-class-re))

(defun gd--statement-opens-def-p ()
  "Return `t' if the statement opens a functions or class definition, nil otherwise. "
  (gd--statement-opens-base gd-def-re))

(defun gd--statement-opens-def-or-class-p ()
  "Return `t' if the statement opens a functions or class definition, nil otherwise. "
  (gd--statement-opens-base gd-def-or-class-re))

(defun gd--record-list-error (pps)
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

(defun gd--message-error (err)
  "Receives a list (position line) "
  (message "Closing paren missed: line %s pos %s" (cadr err) (car err)))

(defun gd--end-base-look-upward (thisregexp regexp)
  (progn (back-to-indentation)
	 (let ((bofst (gd--beginning-of-statement-p)))
	   (cond ((and bofst (eq regexp 'gd-clause-re)(looking-at gd-extended-block-or-clause-re))
		  (point))
		 ((and bofst (looking-at thisregexp))
		  (point))
		 (t
		  (when
		      (cdr-safe
		       (gd--go-to-keyword
			thisregexp))
		    (when (gd--statement-opens-block-p gd-extended-block-or-clause-re)
		      (point))))))))

(defun gd--go-down-when-found-upward (regexp)
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
(defun gd--end-base (regexp &optional orig decorator)
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
             (this (unless (eq regexp 'gd-paragraph-re)(gd--end-base-look-upward thisregexp regexp)))
             ind erg last pps thisindent done err)
        (cond ((eq regexp 'gd-paragraph-re)
	       (while (and (not (eobp)) (re-search-forward gd-paragraph-re nil 'move 1)(nth 8 (parse-partial-sexp (point-min) (point))))))
	      (this (gd--go-down-when-found-upward regexp))
              (t (goto-char orig)))
        (when (and (<= (point) orig)(not (looking-at thisregexp)))
          ;; found the end above
          ;; gd--travel-current-indent will stop of clause at equal indent
          (when (gd--look-downward-for-beginning thisregexp)
	    (gd--end-base regexp orig)))
        (setq pps (parse-partial-sexp (point-min) (point)))
        ;; (catch 'exit)
        (and err gd-verbose-p (gd--message-error err))
        (if (and (< orig (point)) (not (or (looking-at comment-start) (nth 8 pps) (nth 1 pps))))
            (point)
          (goto-char (point-max))
          nil)))))

(defun gd--look-downward-for-beginning (regexp)
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
                     (if (gd--statement-opens-block-p)
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
	(insert (gd--join-words-wrapping (remove "" sorted-imports) "," "    " 78))
	(insert ")")))))

(defun gd--in-literal (&optional lim)
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
(defun gd--point (position)
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

(defun gd--until-found (search-string liste)
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

(defun gd--delay-process-dependent (process)
  "Call a `gd-ipython-send-delay' or `gd-gdscript-send-delay' according to process"
  (if (string-match "ipython" (prin1-to-string process))
      (sit-for gd-ipython-send-delay t)
    (sit-for gd-gdscript-send-delay t)))

(defun gd--send-string-no-output (string &optional process msg)
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
    ;; (gd--delay-process-dependent process)
    (when (and output (not (string= "" output)))
	    (gd--string-strip
	     (format "[ \n]*%s[ \n]*" gd-fast-filter-re)))))

(defun gd--send-string-return-output (string &optional process msg)
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

(defun gd--beginning-of-form-intern (regexp &optional iact indent orig lc)
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
                                  (or (gd--beginning-of-statement-p)
                                      (gd-backward-statement))
                                  (current-indentation)))))
        (setq erg (cond ((and (< (point) orig) (looking-at (symbol-value regexp)))
                         (point))
                        ((and (eq 0 (current-column)) (numberp indent) (< 0 indent))
                         (when (< 0 (abs (skip-chars-backward " \t\r\n\f")))
                           (gd-backward-statement)
                           (unless (looking-at (symbol-value regexp))
                             (cdr (gd--go-to-keyword (symbol-value regexp) (current-indentation))))))
                        ((numberp indent)
			 (cdr (gd--go-to-keyword (symbol-value regexp) indent)))
                        (t (ignore-errors
                             (cdr (gd--go-to-keyword (symbol-value regexp)
                                                    (- (progn (if (gd--beginning-of-statement-p) (current-indentation) (save-excursion (gd-backward-statement) (current-indentation)))) gd-indent-offset)))))))
        (when lc (beginning-of-line) (setq erg (point)))))
    (when (and gd-verbose-p iact) (message "%s" erg))
    erg))

(defun gd--backward-prepare (&optional indent final-re inter-re iact lc)
  (let ((orig (point))
        (indent
         (or indent
	     (cond ((looking-back "^[ \t]*")
		    (current-indentation))
		   (t (progn (back-to-indentation)
			     (or (gd--beginning-of-statement-p)
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
      (gd--beginning-of-form-intern final-re iact indent orig lc))))

(defun gd--fetch-first-gdscript-buffer ()
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

(defmacro gd--kill-buffer-unconditional (buffer)
  "Kill buffer unconditional, kill buffer-process if existing. "
  `(let ((proc (get-buffer-process ,buffer))
	 kill-buffer-query-functions)
     (ignore-errors
       (and proc (kill-process proc))
       (set-buffer ,buffer)
       (set-buffer-modified-p 'nil)
       (kill-buffer (current-buffer)))))

(defun gd--skip-to-semicolon-backward (&optional limit)
  "Fetch the beginning of statement after a semicolon.

Returns position reached if point was moved. "
  (prog1
      (< 0 (abs (skip-chars-backward "^;" (or limit (line-beginning-position)))))
    (skip-chars-forward " \t" (line-end-position))))

(defun gd--end-of-comment-intern (pos)
  (while (and (not (eobp))
              (forward-comment 99999)))
  ;; forward-comment fails sometimes
  (and (eq pos (point)) (prog1 (forward-line 1) (back-to-indentation))
       (while (member (char-after) (list ?# 10))(forward-line 1)(back-to-indentation))))

(defun gd--skip-to-comment-or-semicolon (done)
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

(defun gd--beginning-of-top-level-p ()
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
      (unless (gd--beginning-of-statement-p)
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
          ((gd--beginning-of-statement-p) (gd--beginning-of-form-intern 'gd-extended-block-or-clause-re (called-interactively-p 'any) t))
          (t (gd-backward-statement)))))

(defun gd-down (&optional indent)

  "Go to beginning one level below of compound statement or definition at point.

If no statement or block below, but a delimited form --string or list-- go to its beginning. Repeated call from there will behave like down-list.

Returns position if successful, nil otherwise"
  (interactive "P")
  (let* ((orig (point))
         erg
         (indent (if
                     (gd--beginning-of-statement-p)
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

(defun gd--beginning-of-line-form (erg)
  "Internal use: Go to beginning of line following end of form. "
  (when erg
    (unless (eobp)
      (forward-line 1)
      (beginning-of-line)
      (setq erg (point)))))

(defun gd--mark-base (form &optional gd-mark-decorators)
  "Returns boundaries of FORM, a cons.

If PY-MARK-DECORATORS, `def'- and `class'-forms include decorators
If BOL is t, mark from beginning-of-line"
  (let* ((begform (intern-soft (concat "gd-backward-" form)))
         (endform (intern-soft (concat "gd-forward-" form)))
         (begcheckform (intern-soft (concat "gd--beginning-of-" form "-p")))
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

(defun gd--mark-base-bol (form &optional gd-mark-decorators)
  (let* ((begform (intern-soft (concat "gd-backward-" form "-bol")))
         (endform (intern-soft (concat "gd-forward-" form "-bol")))
         (begcheckform (intern-soft (concat "gd--beginning-of-" form "-bol-p")))
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
  "Calls gd--mark-base, returns bounds of form, a cons. "
  (let* ((bounds (gd--mark-base form gd-mark-decorators))
         (beg (car bounds)))
    (push-mark beg t t)
    bounds))

(defun gd-beginning (&optional indent)
 "Go to beginning of compound statement or definition at point.

With \\[universal-argument], go to beginning one level above.
Returns position if successful, nil otherwise"
  (interactive "P")
  (gd--beginning-of-form-intern gd-extended-block-or-clause-re (called-interactively-p 'any) indent))

(defun gd-end (&optional indent)
 "Go to end of of compound statement or definition at point.

Returns position block if successful, nil otherwise"
  (interactive "P")
    (let* ((orig (point))
           (erg (gd--end-base 'gd-extended-block-or-clause-re orig)))
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
          ((gd--beginning-of-statement-p) (gd--beginning-of-form-intern 'gd-extended-block-or-clause-re (called-interactively-p 'any)))
          (t (gd-backward-statement)))))

(defun gd--end-of-buffer-p ()
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
	  (start (when (or (gd--beginning-of-section-p)
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

(defun gd--narrow-prepare (name)
  "Used internally. "
  (save-excursion
    (let ((start (cond ((string= name "statement")
			(if (gd--beginning-of-statement-p)
			    (point)
			  (gd-backward-statement-bol)))
		       ((funcall (car (read-from-string (concat "gd--statement-opens-" name "-p")))))
		       (t (funcall (car (read-from-string (concat "gd-backward-" name "-bol"))))))))
      (funcall (car (read-from-string (concat "gd-forward-" name))))
      (narrow-to-region (point) start))))

(defun gd--forms-report-result (erg &optional iact)
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
  (gd--shell-setup-fontification gd-shell-fontify-style)
  (when msg (message "gd-shell-fontify-style set to: %s" gd-shell-fontify-style)))

(defun gd-toggle-execute-use-temp-file ()
  (interactive)
  (setq gd--execute-use-temp-file-p (not gd--execute-use-temp-file-p)))

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
	     (setq gd--warn-tmp-files-left-p
		   (not gd--warn-tmp-files-left-p))
	     :help "Messages a warning, when `gd-temp-directory' contains files susceptible being left by previous GDScript-mode sessions. See also lp:987534 Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd--warn-tmp-files-left-p])

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
	      (setq gd--imenu-create-index-p
		    (not gd--imenu-create-index-p))
	      :help "Non-nil means GDScript mode creates and displays an index menu of functions and global variables. Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd--imenu-create-index-p]

	     ["Imenu show method args "
	      (setq gd-imenu-show-method-args-p
		    (not gd-imenu-show-method-args-p))
	      :help "Controls echoing of arguments of functions & methods in the Imenu buffer.
When non-nil, arguments are printed.Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-imenu-show-method-args-p]
	     ["Switch index-function" gd-switch-imenu-index-function
	      :help "`gd-switch-imenu-index-function'
Switch between `gd--imenu-create-index' from 5.1 series and `gd--imenu-create-index-new'."])

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
	     (setq gd--warn-tmp-files-left-p
		   (not gd--warn-tmp-files-left-p))
	     :help "Messages a warning, when `gd-temp-directory' contains files susceptible being left by previous GDScript-mode sessions. See also lp:987534 Use `M-x customize-variable' to set it permanently"
	     :style toggle :selected gd--warn-tmp-files-left-p])

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
	      (setq gd--imenu-create-index-p
		    (not gd--imenu-create-index-p))
	      :help "Non-nil means GDScript mode creates and displays an index menu of functions and global variables. Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd--imenu-create-index-p]

	     ["Imenu show method args "
	      (setq gd-imenu-show-method-args-p
		    (not gd-imenu-show-method-args-p))
	      :help "Controls echoing of arguments of functions & methods in the Imenu buffer.
When non-nil, arguments are printed.Use `M-x customize-variable' to set it permanently"
	      :style toggle :selected gd-imenu-show-method-args-p]
	     ["Switch index-function" gd-switch-imenu-index-function
	      :help "`gd-switch-imenu-index-function'
Switch between `gd--imenu-create-index' from 5.1 series and `gd--imenu-create-index-new'."])

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
	(when (timerp gd--auto-complete-timer)(cancel-timer gd--auto-complete-timer)))
    (setq gd-auto-completion-mode-p t
	  gd-auto-completion-buffer (current-buffer))
    (setq gd--auto-complete-timer
	  (run-with-idle-timer
	   gd--auto-complete-timer-delay
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
					. gd--font-lock-syntactic-face-function)))
    (set (make-local-variable 'font-lock-defaults)
         '(gdscript-font-lock-keywords nil nil nil nil
				     (font-lock-syntactic-keywords
				      . gd-font-lock-syntactic-keywords))))
  ;; avoid to run gd-choose-shell again from `gd--fix-start'
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
  (set (make-local-variable 'comment-indent-function) #'gd--comment-indent-function)
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
  (when gd-trailing-whitespace-smart-delete-p
    (add-hook 'before-save-hook 'delete-trailing-whitespace nil 'local))
  ;; caused insert-file-contents error lp:1293172
  ;;  (add-hook 'after-change-functions 'gd--after-change-function nil t)
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
  (when (and gd--imenu-create-index-p
             (fboundp 'imenu-add-to-menubar)
             (ignore-errors (require 'imenu)))
  (setq imenu-create-index-function 'gd--imenu-create-index-function)
  (setq imenu--index-alist (funcall gd--imenu-create-index-function))
  ;; fallback
  (unless imenu--index-alist
    (setq imenu--index-alist (gd--imenu-create-index-new)))
    ;; (message "imenu--index-alist: %s" imenu--index-alist)
    (imenu-add-to-menubar "PyIndex"))
  ;; add the menu
  (when gd-menu
    (easy-menu-add gd-menu))
  (when gd-hide-show-minor-mode-p (hs-minor-mode 1))
  (when gd-outline-minor-mode-p (outline-minor-mode 1))
  (when (called-interactively-p 'any) (message "gdscript-mode loaded from: %s" gdscript-mode-message-string))
  (force-mode-line-update))

(defun gd--shell-setup-fontification (&optional style)
  "Expected values are either nil, 'all or 'input. "
  (setq style (or style gd-shell-fontify-style))
  (if style
      (progn
	(cond ((eq 'all style)
	       (remove-hook 'change-major-mode-hook 'font-lock-defontify)
	       (set (make-local-variable 'gd--shell-unfontify) 'gd-shell-unfontify-p)
	       (when gd--shell-unfontify
	       	 (add-hook 'gd-gdscript-shell-mode-hook #'gd--run-unfontify-timer (current-buffer)))
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
    (remove-hook 'gd-gdscript-shell-mode-hook 'gd--run-unfontify-timer t)
    (remove-hook 'post-command-hook 'gd-shell-fontify t)))


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
  (gd--all-shell-mode-setting)
  (gd--gdscript-send-completion-setup-code)
  (gd--gdscript-send-ffap-setup-code)
  (gd--gdscript-send-eldoc-setup-code)
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
  ;;                      (concat (getenv "PYTHONHISTORY") "/" (gd--report-executable gd-buffer-name) "_history")
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
  (gd--all-shell-mode-setting)
  (gd--gdscript-send-completion-setup-code)
  (gd--gdscript-send-ffap-setup-code)
  (gd--gdscript-send-eldoc-setup-code)
  (gd--ipython-import-module-completion)
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