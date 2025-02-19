;; M-x package-install <RET> ruby-hash-syntax <RET>

;; replace selection with interpolated variable
;; e.g. pants => puts "pants: #{pants}"
(fset 'puts-selection-as-interpolation
      (lambda (&optional arg) "Keyboard macro." (interactive "p") (kmacro-exec-ring-item (quote ("puts \": #{}\"" 0 "%d")) arg)))

(defun insert-ruby-new-script-boilerplate ()
  (interactive)
  "Insert my new-ruby script boilerplate"
  (let* (
         (script-name (file-name-nondirectory (buffer-file-name)))
         (command (format "cat ~/bin/new-ruby | sed -e 's/{{SCRIPT}}/%s/g' | sed -e 's/{{DEL}}//g'" script-name))
         (output (shell-command-to-string command)))
    (save-excursion
      (goto-char (point-min))
      (insert output)
      (ruby-mode))))
;; (defun insert-ruby-new-script-boilerplate ()
;;   (interactive)
;;   "Insert my new-ruby script boilerplate"
;;   (save-excursion t
;;                   (beginning-of-buffer)
;;                   (insert-file "~/bin/new-ruby")
;;                   (ruby-mode)))

(add-hook 'ruby-mode-hook
          (lambda ()
            (local-set-key (kbd "\C-c }") 'ruby-toggle-hash-syntax)
            (local-set-key (kbd "\C-c C-t") 'comment-todo-erest-1895)
            (local-set-key (kbd "\C-c #") 'puts-selection-as-interpolation)
            (fci-mode 't)
            ))

;; align-json-hash
;; Okay, you can do proper json-style alignment (adding spaces AFTER the colon)
;; with this command:
;; C-u M-x align-regexp <RET> \(\s-*\):\(\s-*\) <RET> <BKSP> 2 <RET> <RET>
(defun align-json-hash ()
  (interactive "r")
  "Align keys and values in a JSON hash in the region from BEGIN to END."
  (save-excursion
    (narrow-to-region begin end)
    (goto-char (point-min))
    (while (re-search-forward "[:,]" nil t)
      (when (re-search-forward "\\S-" (line-end-position) t)
        (backward-char)
        (insert " ")
        (forward-char))))
  (widen))

(global-set-key (kbd "\C-x :") 'align-json-hash)

;; rubocop stuff
;; C-c C-x C-r - rubocop
;;

;; C-c C-x C-r m a - Metrics/AbcSize
(defun rubocop-disable-metrics-abcsize ()
  (interactive)
  "Disable Metrics/AbcSize cop around the current function"
  (save-excursion
    (ruby-end-of-block) ;; go to end and back up to ensure correct positioning
    (ruby-beginning-of-block)
    (insert "# rubocop:disable Metrics/AbcSize\n")
    ;; (ruby-indent-line) ; Y U NO IDNAT
    ;; (insert "PANTS")

    ;; go to end, append the re-enable
    ;; (ruby-end-of-block)
    ;; (move-end-of-line)
    ;; (newline)
    ;; (indent-for-tab-column)
    ;; (insert "# rubocop:enable Metrics/AbcSize")
    )
  )
