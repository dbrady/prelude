;; Org-mode settings
;; (require 'org-install)
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)


(setq org-todo-keywords
      '((sequence "TODO(t)"
                  "|" "BLOCKED(b)"
                  "|" "DELEGATED(g)" "WAITING(w)"
                  "|" "DONE(d)" "CANCELLED(c)" "DEFERRED(f)")))
(setq org-tag-alist '(("@work" . ?w) ("@home" . ?h) ("computer" . ?c)
          ("errands" . ?e) ("costco" . ?t) ("grocery" . ?g)
          ("project" . ?p) ("agenda" . ?a)))
(setq org-latex-to-pdf-process '("texi2dvi --pdf --clean --verbose --batch %f"))

(setf org-adapt-indentation t)

(add-hook 'org-mode-hook '(lambda ()
                             (show-all)))


;; ----------------------------------------------------------------------
;; Hat Tip to Tim Harper for code to add checkbox to org-mode when
;; hitting M-enter in a checklist
(defadvice org-insert-item (before org-insert-item-autocheckbox activate)
  (save-excursion
    (org-beginning-of-item)
    (when (org-at-item-checkbox-p)
      (ad-set-args 0 '(checkbox)))))

;;if you auto-load emacs... this will patch org-mode after it loads:
(eval-after-load "org-mode"
  '(defadvice org-insert-item (before org-insert-item-autocheckbox activate)
     (save-excursion
       (when (org-at-item-p)
         (org-beginning-of-item)
         (when (org-at-item-checkbox-p)
           (ad-set-args 0 '(checkbox)))))))

;; ----------------------------------------------------------------------
;; KWM: org-insert-journal-title

;; insert e.g. "* 2014-05-09 Fri TODO\n\n\n" at the top of the
;; document. I usually also begin my journal by copying the previous
;; day's journal, so ideally also search for the existence of "*
;; \d\d\d\d-\d\d-\d\d .* TODO" at the top of the document, and if
;; found, delete that line first.
;;
;; Thought: a better defun here might actually be
;; save-journal-as-today or similar, that updates the string, and also
;; writes the file to the new name of YYYY-MM-DD-todo.org.
;; ----------------------------------------------------------------------
(defun replace-first-line-with (string)
  (save-excursion
    (beginning-of-buffer)
    (kill-line)
    (insert string)))

(defun org-insert-journal-title ()
  (interactive)
  (beginning-of-buffer)
  (insert (format-time-string "* %F %a TODO [/]\n"))
  ;; ideally, have a daily template down at the bottom
  ;; search document for * DAILY TEMPLATE, if found, copy that section
  ;; then go back to top, see if it starts with "This Week", if so skip that section
  ;; past the daily template at the top. Yay.
  (insert "
M-x oij RET

|----+------+-----+-------|
| Hr | Plan | Log | Notes |
|----+------+-----+-------|
| TD |      |     |       |
|----+------+-----+-------|
|  8 |      |     |       |
|  9 |      |     |       |
| 10 |      |     |       |
| 11 |      |     |       |
| 12 |      |     |       |
|  1 |      |     |       |
|  2 |      |     |       |
|  3 |      |     |       |
|  4 |      |     |       |
|----+------+-----+-------|

")
  (previous-line))

(defun oij ()
  (interactive)
  (org-insert-journal-title))

;; (defun org-journal-archive-and-make-new-title ()
;;   (interactive)
;;   (beginning-of-buffer)
;;   ;; beginning of document
;;   ;; mark
;;   ;; search for END CURRENT TODO
;;   (search-forward "END CURRENT TODO" nil t -1)
;;   ;; beginning of line
;;   ;; cut
;;   ;; org-insert-journal-title
;;   ;; newline
;;   ;; yank
;;   ;; yank
;;   ;;
;;     (move-end-of-line 1)
;;     (org-ctrl-c-ctrl-c))))
;;
;;   (insert (format-time-string "* %F %a TODO [/]\nM-x o-i-j RET\n\n"))
;;   (previous-line))

(defun org-save-journal-as-today ()
  (interactive)
  (org-insert-journal-title)
  (write-file (format-time-string "%F-todo.org")))

;; ----------------------------------------------------------------------
;; org-uncheck-region-or-section
;;
;; Unchecks items in an org tree checkbox task list. If no region is selected,
;; operates on the section under the current heading.
;;
;; vibecoded with Claude 4 Sonnet.
;; ----------------------------------------------------------------------
(defun org-uncheck-region-or-section ()
  "Uncheck all checkboxes in region (if active) or current top-level section.
Works backwards to avoid parent/child dependency issues."
  (interactive)
  (let ((start-pos (if (use-region-p)
                       (region-beginning)
                     (save-excursion
                       (org-back-to-heading t)
                       (point))))
        (end-pos (if (use-region-p)
                     (region-end)
                   (save-excursion
                     (org-back-to-heading t)
                     (org-end-of-subtree t t)
                     (point))))
        (items-to-uncheck '()))
    ;; First pass: collect all checked items (working backwards for parent/child safety)
    (save-excursion
      (goto-char end-pos)
      (while (re-search-backward "^\\s-*\\([-+*]\\|[0-9]+[.)]\\)\\s-+\\[X\\]" start-pos t)
        (when (org-at-item-checkbox-p)
          (push (point) items-to-uncheck))))
    ;; Second pass: uncheck all collected items
    (dolist (pos items-to-uncheck)
      (save-excursion
        (goto-char pos)
        (org-toggle-checkbox)))))

(provide 'org-config)
