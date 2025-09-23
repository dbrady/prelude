;; ruby-align.el - ruby-mode alignment tools-helps

;; ruby-align/sort-constants-with-fill
;; Finds constants in selected region, sorts them and fills the region.
;;
;; e.g. if you have these lines selected:
;;
;;   attr_accessor :page, :pants, :face, :quick, :foo, :bar, :baz, :cheese,
;;     :qux, :quux
;;
;; The region would be changed to:
;;
;;   attr_accessor :bar, :baz, :cheese, :face, :foo, :page, :pants, :quick,
;;     :quux, :qux
;;
;; Okay, this seems pretty easy, just narrow-to-region, move all the constants
;; to one-per-line, call sort-lines, then glue them all back together... EXCEPT
;; for a couple of fiddly little issues:
;; - [ ] Maintain the indentation of the leading keyword
;; - [ ] Even if the region does not go to beginning-of-line on the first line
;; - [ ] Do not sort the keyword into the constants
;; - [ ] Do not sort MULTIPLE keywords (I can't think of an example of more than
;;       one method call at the start of the list but there you go)
;; - [ ] All symbols but the last should have a comma after it (E.g. note that
;;       :qux, :quux became :quux, :qux.


;; FOR NOW: Can we quick and dirty this, perhaps with a macro, or a ruby
;; script... bleh, Dunno. Here's what I'm thinking right now:

(defun sort-constants ()
  (interactive)
    (beginning-of-line)
    (re-search-forward ":" nil t)
    (backward-char)
    (set-mark (point))
    (re-search-forward "^[[:space:]]*$" nil t)
    (narrow-to-region (mark) (point))

    ;; strip commas
    (beginning-of-buffer)
    (while (search-forward "," nil t)
      (replace-match "\n"))
    ;; This would be better if it actually worked (I HAVE NO IDEA WHAT I AM DOING):
    ;; (perform-replace "," "\n" nil t nil nil (beginning-of-buffer) (end-of-buffer))

    ;; remove double newlines
    (beginning-of-buffer)
    (while (search-forward "\n\n" nil t)
      (replace-match "\n"))

    ;; strip leading space on each line
    (beginning-of-buffer)
    (while (re-search-forward "^[[:space:]]+" nil t)
      (replace-match ""))

    ;; add commas back in to every line except last
    (beginning-of-buffer)
    (while (re-search-forward "$" nil t)
      (replace-match ",")
      (forward-char)) ;; need the forward char or we'll recurse
    ;; infinitely. Probably better to use something like (goto-char (match-end))
    ;; assuming match-end is actually a function that actually exists. I HAVE NO
    ;; IDEA WHAT I AM DOING

    ;; This works interactively with query-replace-regexp but not
    ;; programmatically with re-search-forward/replace-match I HAVE NO IDEA WHAT
    ;; I AM DOING
    ;; (while (re-search-forward "\([[:alnum:]]\)$" nil t)
    ;;   (replace-match "\1,")
    ;;   (forward-char 2))


    ;; (deactivate-mark)
    ;; (end-of-buffer) ; should already be here
    ;; (delete-backward-char 3)

    ;; This does not work. I HAVE NO IDEA WHAT I AM DOING
    (sort-lines nil (mark) (point))
    ;; (pop-mark)
    ;; (end-of-buffer)
    ;; (set-mark (point))
    ;; (re-search-backward "[[:alnum:]]," nil t)
    )

;;
;; 1. widen region to beginning-of-line at start and end-of-line at end copy
;;    leading space and keyword(s) with something like /^(.*?):/ (use positive
;;    lookahead if necessary to keep the : from being consumed: /^(.*?)(?=:)/
;;
;; 2. narrow-to-region if necessary
;;
;; 3. Flatten all the symbols to a single line, single-space separating them,
;;    and remove their commas
;;
;; 4. Break all the symbols to one-per-line
;;
;; 5. Put commas on all but the last one
;;
;; 6. replace the region with the original leading stuff and then the symbols
;;
;; 7. fill-region
;;
;; 8. widen if we did a narrow-to-region in 2
;
;; (defun ruby/sort-constants
;;     (interactive))


;; stolen from https://github.com/daveyeu/emacs-dot-d/blob/master/custom/ruby-align.el

;; Steals align setup for ruby from Emacs-Rails:
;;   http://github.com/remvee/emacs-rails/tree/master/rails-ruby.el

;; (require 'align)

;; (defconst align-ruby-modes '(ruby-mode)
;;   "align-perl-modes is a variable defined in `align.el'.")

;; (defconst ruby-align-rules-list
;;   '((ruby-comma-delimiter
;;      (regexp . ",\\(\\s-*\\)[^/ \t\n]")
;;      (modes  . align-ruby-modes)
;;      (repeat . t))
;;     (ruby-string-after-func
;;      (regexp . "^\\s-*[a-zA-Z0-9.:?_]+\\(\\s-+\\)['\"]\\w+['\"]")
;;      (modes  . align-ruby-modes)
;;      (repeat . t))
;;     (ruby-symbol-after-func
;;      (regexp . "^\\s-*[a-zA-Z0-9.:?_]+\\(\\s-+\\):\\w+")
;;      (modes  . align-ruby-modes))
;;     (ruby-new-style-hash
;;      (regexp . "^\\s-*[a-zA-Z0-9.:?_]+:\\(\\s-+\\)[a-zA-Z0-9:'\"]") ;; This guy needs more work.
;;      (modes  . align-ruby-modes)))
;;   "Alignment rules specific to the ruby mode.
;; See the variable `align-rules-list' for more details.")

;; (add-to-list 'align-perl-modes 'ruby-mode)
;; (add-to-list 'align-dq-string-modes 'ruby-mode)
;; (add-to-list 'align-sq-string-modes 'ruby-mode)
;; (add-to-list 'align-open-comment-modes 'ruby-mode)
;; (dolist (it ruby-align-rules-list)
;;   (add-to-list 'align-rules-list it))

(defun toggle-ruby-indentation-style ()
  "Toggle between Oklahoma style (deep indentation) and K&R style for Ruby."
  (interactive)
  (setq ruby-align-to-stmt-keywords (not ruby-align-to-stmt-keywords))
  (message "Ruby indentation style: %s"
           (if ruby-align-to-stmt-keywords "K&R" "Oklahoma")))

(global-unset-key (kbd "C-x C-i")) ;; Unbind indent-rigidly
(global-set-key (kbd "C-x C-i") 'toggle-ruby-indentation-style)

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
