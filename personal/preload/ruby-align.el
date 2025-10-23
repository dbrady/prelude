;; ruby-align.el - ruby-mode alignment tools-helps

;; -----------------------------------------------------------------------------
;; toggle-ruby-indentation-style
;;
;; I like Oklahoma style, my team demands K&R
(defun toggle-ruby-indentation-style ()
  "Toggle between Oklahoma style (deep indentation) and K&R style for Ruby."
  (interactive)
  (setq ruby-align-to-stmt-keywords (not ruby-align-to-stmt-keywords))
  (message "Ruby indentation style: %s"
           (if ruby-align-to-stmt-keywords "K&R" "Oklahoma")))

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
