;;; haiku.el --- Run haiku LLM queries from Emacs -*- lexical-binding: t; -*-

;;; Commentary:
;; C-c C-h prompts for a query and streams the result in a *haiku* buffer.
;; If a region is active, the region text is written to a temp file and
;; sent via --input-file=<file>.  Otherwise the minibuffer input is passed
;; as a quoted argument.

;;; Requirements:
;; haiku shell command in the path. https://github.com/dbrady/bin/blob/master/haiku

;;; Status:
;; Raw, in-progress, kinda crappy. There's proper emacs LLM modes now, maybe
;; look into them.

;;; Code:

(defvar haiku-buffer-name "*haiku*"
  "Name of the buffer used to display haiku output.")

(defun haiku--shell-quote (str)
  "Quote STR for bash, handling single quotes via the '\"'\"' idiom."
  (concat "'" (replace-regexp-in-string "'" "'\"'\"'" str t t) "'"))

(define-derived-mode haiku-mode special-mode "Haiku"
  "Major mode for haiku LLM output.
Inherits from `special-mode': `q' closes the window.")

(defun haiku--display-buffer ()
  "Get or create the haiku output buffer and display it.
Returns the buffer."
  (let ((buf (get-buffer-create haiku-buffer-name)))
    (with-current-buffer buf
      (haiku-mode)
      (read-only-mode -1)
      (erase-buffer)
      (insert "--- haiku ---\n\n"))
    (display-buffer buf '((display-buffer-reuse-window
                           display-buffer-below-selected)
                          (window-height . 0.35)))
    buf))

(defun haiku--run-command (cmd)
  "Run CMD asynchronously, streaming output into the *haiku* buffer."
  (let ((buf (haiku--display-buffer)))
    (let ((proc (start-process-shell-command "haiku" buf cmd)))
      (set-process-sentinel
       proc
       (lambda (process _event)
         (when (memq (process-status process) '(exit signal))
           (with-current-buffer (process-buffer process)
             (goto-char (point-max))
             (insert (format "\n\n--- exited %d ---"
                             (process-exit-status process)))
             (read-only-mode 1))))))))

(defun haiku-query (query)
  "Send QUERY string to haiku and display the streaming result.
If called interactively with an active region, use the region text
via a temp file (--input-file=FILE).  Otherwise prompt for input."
  (interactive
   (if (use-region-p)
       (list nil)
     (list (read-string "haiku: "))))
  (let (cmd)
    (if (and (not query) (use-region-p))
        (let ((tmpfile (make-temp-file "haiku-prompt-" nil ".txt")))
          (write-region (region-beginning) (region-end) tmpfile)
          (setq cmd (format "haiku --input-file=%s" (shell-quote-argument tmpfile))))
      (setq cmd (format "haiku %s" (haiku--shell-quote query))))
    (haiku--run-command cmd)))

(global-set-key (kbd "C-c C-h") #'haiku-query)

(provide 'haiku)
;;; haiku.el ends here
