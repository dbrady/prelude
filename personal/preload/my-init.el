;; My Init Stuff

(add-to-list 'load-path (concat "~/.emacs.d/personal/preload"))


;; Color theme crap
(setq monokai-user-variable-pitch t)
;; edit core/prelude-editor.el to fix this if you reinstall prelude!
(global-hl-line-mode -1)

;; Always follow symlinks to source-controlled file
(setq vc-follow-symlinks t)

;; show matching parens all the time
(show-paren-mode 1)

(require 'toggle-case)

;; toggle-quotes installed from melpa. They recommend binding it to C-' but
;; something in Prelude binds that violently to self-insert-command
;;
;; M-x package-install <RET> toggle-quotes <RET>
(global-set-key (kbd "C-c '") 'toggle-quotes)

;; toggle linum-mode - SUPER hard finding a key prefix that isn't being squatted
;; by ruby-mode, lisp-mode, or especially org-mode. I hate taking C-x but pretty
;; much anything in org-mode in C-c is taken.
(global-set-key (kbd "C-x #") 'linum-mode)

;; investigate thing-at-point
(defun what-is-thing-at-point (arg)
  "Examine thing-at-point and display it in the echo area"
  (interactive "p")
  (let* ((bounds (bounds-of-thing-at-point 'symbol))
	 (word   (buffer-substring (car bounds) (cdr bounds))))
    (message "Thing at point is: %s" word)))

(global-set-key (kbd "C-c ?") 'what-is-thing-at-point)


(defun toggle-thing-at-point-dwim (arg)
  "interpret thing-at-point and replace it with its logical opposite, e.g. true/false, True/False, 0/1, first/last, to/to_not (TODO: WRITE ME!)"
  ;; TODO: WRITE ME!
  ;; TODO: first <=> last
  )

;; TODO: also toggle string/symbol. This will need a separate binding as
;; what-is-thing-at-point returns the current word inside a string and can't
;; parse it at all if the point is after the closing quote


;; er/expand-region is awesome, and in theory is bound to C-=, but in practice
;; this also often gets overwritten with self-insert-command to insert =
;; instead. Binding it here to C-c =.
;; TODO: Consider setting a subprefix for commands that SHOULDN'T be bound to
;; self-insert-command but ARE. E.g. 'C-c C-/', so if C-' doesn't work, you can
;; expect to find it on "C-c C-/ '", and C-= is also on C-c C-/ =, etc. Why do
;; this? Because C-c is pretty well populated already, and this can't go on
;; forever. If these are the only two commands bound, then we're okay, but if we
;; get many (any?) more, consider moving them to C-c C-/ or C-c C-- etc.


(global-set-key (kbd "C-c =") 'er/expand-region)

(defun toggle-night-color-theme ()
  "Switch to/from night color scheme."
  (interactive)
  (require 'color-theme)
  (if (eq (frame-parameter (next-frame) 'background-mode) 'dark)
      (color-theme-snapshot) ; restore default (light) colors
    ;; create the snapshot if necessary
    (when (not (commandp 'color-theme-snapshot))
      (fset 'color-theme-snapshot (color-theme-make-snapshot)))
    (color-theme-dark-laptop)))

(global-set-key (kbd "<f9> n") 'toggle-night-color-theme)


(defun my-web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-markup-indent-offset 2)
  )
(add-hook 'web-mode-hook  'my-web-mode-hook)

(add-to-list 'auto-mode-alist '("\\.html.erb\\'" . web-mode))

(add-to-list 'auto-mode-alist '("\\.ino\\'" . c++-mode))

(setq js-indent-level 2)

(global-set-key (kbd "\C-c M-f") 'auto-fill-mode)

;; org-mode likes to override this. Let's fix that.
(add-hook 'org-mode-hook
	  (lambda ()
	    (local-set-key (kbd "\C-c M-f") 'auto-fill-mode)))

(add-hook 'org-mode-hook 'auto-fill-mode)

;; 2022-04-28 Emacs 28 appears to have a new linum mode of its own,
;; and prelude mucks with it, but it's better than prelude's.
;;
;; 2023-09-15 Emacs 29 appears to have removed it. Sort out your life man
;; (global-linum-mode 1)

(global-set-key (kbd "\C-x C-r") 'recentf-open-files)
(global-set-key (kbd "\C-c /") 'comment-dwim)

(set-face-attribute 'default nil :height 140)

(add-hook 'before-save-hook 'whitespace-cleanup)

(setq-default fill-column 80)

;; Add sorting to C-x <down> and C-x <up>
(global-set-key (kbd "\C-x <down>") 'sort-lines)

;; Sort words on a line
(defun sort-words-in-region (beg end)
  "Sort comma-separated symbols in the region alphabetically.
Keeps a single space after each comma."
  (interactive "r")
  (let* ((text (buffer-substring-no-properties beg end))
         (items (split-string text "," t "[ \t\n]+"))
         (sorted (sort items #'string<))
         (joined (mapconcat #'string-trim sorted ", ")))
    (delete-region beg end)
    (insert joined)))
;; Add sorting words to C-x C-S-<down>
(global-set-key (kbd "\C-x C-S-<down>") 'sort-words-in-region)

;; Disable guru-mode, that's the thing that bitches when you use
;; non-idiomatic keybindings. I am fluent in the idiomatic
;; keybindings, so when I don't use them I have a reason. When I want
;; your opinion I'll beat you until you shut up and go away because it
;; was a trap I didn't actually want your opinion.
(setq prelude-guru nil)

;; I have never ever tried to open a symlink without wanting to follow
;; it. Don't stop me to check; just do it.
(setq vc-follow-symlinks t)

;; This isn't getting picked up from data-team-init.el
(setq js-indent-level 4)
