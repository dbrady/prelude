;; Disable flycheck's rubocop checker for Ruby files
(with-eval-after-load 'flycheck
  (setq-default flycheck-disabled-checkers '(ruby-rubocop)))
