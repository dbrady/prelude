;; Rubocop - use the project's version of rubocop

;; This was to stop version mismatches in MP, and may cause problems with non-bundlered projects

;; make Emacs inherit your shell PATH (macOS)
(use-package exec-path-from-shell
  :init (exec-path-from-shell-initialize))

;; wrap flycheck commands with `bundle exec`
(setq flycheck-command-wrapper-function
      (lambda (cmd) (append '("bundle" "exec") cmd)))
(setq flycheck-ruby-rubocop-executable "rubocop")
