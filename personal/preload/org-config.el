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

|----+--------------+-----+-------|
| Hr | Plan         | Log | Notes |
|----+--------------+-----+-------|
| TD | (daily goal) |     |       |
|----+--------------+-----+-------|
|  8 |              |     |       |
|  9 |              |     |       |
| 10 |              |     |       |
| 11 |              |     |       |
| 12 |              |     |       |
|  1 |              |     |       |
|  2 |              |     |       |
|  3 |              |     |       |
|  4 |              |     |       |
|----+--------------+-----+-------|
TD:
E5/HA:
-

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
;;
;; BUG: Here's an interesting list:
;; - [-] Plan
;;   - [X] Comb through this list
;;   - [X] JIRA
;;     - [X] Clear Reviews
;;     - [X] Check board
;;   - [-] Scoreboard
;;     - [X] Existing
;;     - [ ] How would YOU score it, Clod?
;;     - [ ] Score tracking
;;     - [ ] Travis' Kanban board
;; - [X] Acumen
;; - [X] COR-3665 / COR-4194 - Shipt
;;   - [X] Check on Slack convo, users are ready for this interface contract
;;   - [X] Syed is questioning the controctt - check w/him
;; - [X] COR-4194 - Prefactorings
;;   - [X] Alphabetize/condense the where clause
;;   - [X] Superclass for Condition Satifiers
;;     - [X] Includes the monads
;;     - [X] Includes the includes
;; - [X] COR-4286: Ramses integration ticket (Abandoned)
;;   - [X] What was the new ticket Ramses assigned? Answer: COR-4334
;;   - [X] Link/abandon this ticket, merge/claim that one?
;;   - [X] Update Slork correctly?
;; - [X] EOD
;;   - [X] Slorks
;;   - [X] Daily time/goal/journal
;;   - [X] Clear all pending reviews
;;
;; If you select the whole section top-to-bottom (set mark at - [-] Plan and
;; select downward), this defun works. If you select bottom-to-top or just leave
;; the point in the block and let it find the selection itself, it SKIPS a
;; handful of entries. Also, if you do it JUST right, it will actually CHECK all
;; the boxes.
;;
;; Until I can vibedebug this, workaround 1: always select the region, and
;; always select top-to-bottom, or 2: run it twice, the second run clears it up.
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
