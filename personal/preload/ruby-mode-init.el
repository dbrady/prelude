;; M-x package-install <RET> ruby-hash-syntax <RET>
;;
;; NOTE: I am trying to move all the ruby-editing commands to the prefix C-c C-r
;; which is currently unused on my installation, e.g. C-c C-r i for

(defun insert-ruby-new-script-boilerplate ()
  (interactive)
  "Insert my new-ruby script boilerplate"
  ;; TODO: Replace scriptname with buffer-name?
  ;; TODO: Reload and/or force ruby-mode?
  (save-excursion t
                  (beginning-of-buffer)
                  (insert-file "~/bin/new-ruby")
                  (ruby-mode)))

(add-hook 'ruby-mode-hook
          (lambda ()
            (local-set-key (kbd "\C-c }") 'ruby-toggle-hash-syntax)
            (local-set-key (kbd "\C-c #") 'puts-selection-as-interpolation)
            ;; (fci-mode 't) - removed 2025-07-28, this conflicts with font-lock-mode in emacs 30
            ))



;; align-json-hash
;; Okay, you can do proper json-style alignment (adding spaces AFTER the colon)
;; with this command:
;; C-u M-x align-regexp <RET> \(\s-*\):\(\s-*\) <RET> <BKSP> 2 <RET> <RET>
(fset 'align-json-hash
      (lambda (&optional arg) "Keyboard macro." (interactive "p")
        (kmacro-exec-ring-item (quote
                                ("xalign-regexp:\\(\\s-*\\)2y" 0 "%d")) arg)))
(global-set-key (kbd "\C-x :") 'align-json-hash)

(defun ruby-wrap-current-line-in-puts-inspect ()
  "Replace the expression on the current line with a puts inspect statement.
Example: '   do_thing(x)' becomes '    puts \"do_thing(x): #{do_thing(x).inspect}\"'
Example: '   do_thing x'  becomes '    puts \"do_thing x: #{(do_thing x).inspect}\"'"
  (interactive)
  (let* ((line-start (line-beginning-position))
         (line-end (line-end-position))
         (line-text (buffer-substring-no-properties line-start line-end))
         (indentation (save-excursion
                        (goto-char line-start)
                        (skip-chars-forward " \t")
                        (- (point) line-start)))
         (indent-str (make-string indentation ?\s))
         (expr (string-trim (substring line-text indentation)))
         (has-spaces (string-match-p " " expr))
         (wrapped-expr (if has-spaces (format "(%s)" expr) expr)))
    (delete-region line-start line-end)
    (insert (format "%sputs \"%s: #{%s.inspect}\"" indent-str expr wrapped-expr))))

(global-set-key (kbd "\C-c C-r i") 'ruby-wrap-current-line-in-puts-inspect)
