;; ruby-align.el - ruby-mode alignment tools-helps

;; Default to K&R style (team standard). Toggle with C-x C-i.
;; Emacs 30 SMIE-based ruby-mode has separate knobs for each construct:
;;   ruby-align-to-stmt-keywords  - if/unless/begin/case/def alignment
;;   ruby-method-call-indent      - method chain continuation (.foo\n.bar)
;;   ruby-after-operator-indent   - binary operator continuation (x ||\n y)
;; The old ruby-deep-indent-paren only works when ruby-use-smie is nil.
(setq ruby-align-to-stmt-keywords t)
(setq ruby-method-call-indent nil)
(setq ruby-after-operator-indent nil)

;; -----------------------------------------------------------------------------
;; toggle-ruby-indentation-style
;;
;; I like Oklahoma style, my team demands K&R
(defun toggle-ruby-indentation-style ()
  "Toggle between Oklahoma style (deep indentation) and K&R style for Ruby."
  (interactive)
  (let ((to-knr (not ruby-align-to-stmt-keywords)))
    (setq ruby-align-to-stmt-keywords to-knr)
    (setq ruby-method-call-indent (not to-knr))
    (setq ruby-after-operator-indent (not to-knr))
    (message "Ruby indentation style: %s" (if to-knr "K&R" "Oklahoma"))))

(global-unset-key (kbd "C-x C-i")) ;; Unbind indent-rigidly
(global-set-key (kbd "C-x C-i") 'toggle-ruby-indentation-style)

;; -----------------------------------------------------------------------------
;; default ruby-align-regexp will insert spaces BEFORE the match. Here's a
;; custom defun that inserts spaces AFTER it. Vibecoded with Claude Sonnet 4 on
;; 2025-09-19.
;;
;; You can do this with regular align-regexp, it's just a logic puzzle:
;; 1. Select region
;; 2. Hit C-u C-x \ (or C-u M-x align-regexp RET) to open "Complex align using
;;    regexp"
;; 3. Put parens around the regexp: \(,\)
;; 4. Choose parenthesis group 1
;; 5. Choose spacing 1
;; 6. When prompted to repeat, hit n
(defun right-align-regexp (regexp)
  "Align region on REGEXP, putting spaces after the match instead of before.
First normalizes existing spacing after the match."
  (interactive "sAlign after regexp: ")
  (save-excursion
    (let ((start (region-beginning))
          (end (region-end)))
      ;; First pass: normalize spacing after the regexp
      (goto-char start)
      (while (re-search-forward regexp end t)
        ;; Remove any whitespace immediately following the match
        (when (looking-at "\\s-+")
          (replace-match " ")))

      ;; Second pass: do the alignment
      (let ((group-regexp (if (string-match-p "\\\\(" regexp)
                              regexp
                            (concat "\\(" regexp "\\)"))))
        (align-regexp start end group-regexp 1 1 nil)))))

(global-unset-key (kbd "C-x C-|"))
(global-set-key (kbd "C-x C-\\") 'right-align-regexp)

(provide 'ruby-align)
