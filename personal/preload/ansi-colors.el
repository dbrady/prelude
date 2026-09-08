(defvar ansi-colorize-fg-alist
  '((black . 30) (red . 31) (green . 32) (yellow . 33)
    (blue . 34) (magenta . 35) (cyan . 36) (white . 37)
    (bright-black . 90) (bright-red . 91) (bright-green . 92)
    (bright-yellow . 93) (bright-blue . 94) (bright-magenta . 95)
    (bright-cyan . 96) (bright-white . 97)))

(defvar ansi-colorize-bg-alist
  '((black . 40) (red . 41) (green . 42) (yellow . 43)
    (blue . 44) (magenta . 45) (cyan . 46) (white . 47)
    (bright-black . 100) (bright-red . 101) (bright-green . 102)
    (bright-yellow . 103) (bright-blue . 104) (bright-magenta . 105)
    (bright-cyan . 106) (bright-white . 107)))

(defvar ansi-colorize-mode-alist
  '((bold . 1) (dim . 2)))

(defun ansi-colorize (fg &optional bg mode)
  "Wrap selection or line in ANSI escape codes."
  (let* ((codes (delq nil
                      (list (and mode (cdr (assq mode ansi-colorize-mode-alist)))
                            (and fg   (cdr (assq fg ansi-colorize-fg-alist)))
                            (and bg   (cdr (assq bg ansi-colorize-bg-alist))))))
         (open  (format "\\033[%sm" (mapconcat #'number-to-string codes ";")))
         (close "\\033[0m"))
    (if (use-region-p)
        (let ((start (region-beginning))
              (end   (region-end)))
          (save-excursion
            (goto-char end)
            (insert close)
            (goto-char start)
            (insert open)))
      (let ((text (buffer-substring (point) (line-end-position))))
        (beginning-of-line)
        (kill-line)
        (insert (format "echo -e '%s%s %s'" open text close))
        (newline)
        (insert text)))))

(defun ansi-colorize-interactive ()
  "Prompt for fg, bg, mode then colorize."
  (interactive)
  (let* ((fg  (intern-soft (completing-read "FG (empty=none): "
                (mapcar #'car ansi-colorize-fg-alist) nil t)))
         (bg  (intern-soft (completing-read "BG (empty=none): "
                (mapcar #'car ansi-colorize-bg-alist) nil t)))
         (mode (intern-soft (completing-read "Mode (empty=none): "
                 (mapcar #'car ansi-colorize-mode-alist) nil t))))
    (ansi-colorize fg bg mode)))

;; FG shortcuts
(defun ansi-colorize-black ()          (interactive) (ansi-colorize 'black))
(defun ansi-colorize-red ()            (interactive) (ansi-colorize 'red))
(defun ansi-colorize-green ()          (interactive) (ansi-colorize 'green))
(defun ansi-colorize-yellow ()         (interactive) (ansi-colorize 'yellow))
(defun ansi-colorize-blue ()           (interactive) (ansi-colorize 'blue))
(defun ansi-colorize-magenta ()        (interactive) (ansi-colorize 'magenta))
(defun ansi-colorize-cyan ()           (interactive) (ansi-colorize 'cyan))
(defun ansi-colorize-white ()          (interactive) (ansi-colorize 'white))
(defun ansi-colorize-bright-black ()   (interactive) (ansi-colorize 'bright-black))
(defun ansi-colorize-bright-red ()     (interactive) (ansi-colorize 'bright-red))
(defun ansi-colorize-bright-green ()   (interactive) (ansi-colorize 'bright-green))
(defun ansi-colorize-bright-yellow ()  (interactive) (ansi-colorize 'bright-yellow))
(defun ansi-colorize-bright-blue ()    (interactive) (ansi-colorize 'bright-blue))
(defun ansi-colorize-bright-magenta () (interactive) (ansi-colorize 'bright-magenta))
(defun ansi-colorize-bright-cyan ()    (interactive) (ansi-colorize 'bright-cyan))
(defun ansi-colorize-bright-white ()   (interactive) (ansi-colorize 'bright-white))

;; BG shortcuts
(defun ansi-colorize-on-black ()          (interactive) (ansi-colorize nil 'black))
(defun ansi-colorize-on-red ()            (interactive) (ansi-colorize nil 'red))
(defun ansi-colorize-on-green ()          (interactive) (ansi-colorize nil 'green))
(defun ansi-colorize-on-yellow ()         (interactive) (ansi-colorize nil 'yellow))
(defun ansi-colorize-on-blue ()           (interactive) (ansi-colorize nil 'blue))
(defun ansi-colorize-on-magenta ()        (interactive) (ansi-colorize nil 'magenta))
(defun ansi-colorize-on-cyan ()           (interactive) (ansi-colorize nil 'cyan))
(defun ansi-colorize-on-white ()          (interactive) (ansi-colorize nil 'white))
(defun ansi-colorize-on-bright-black ()   (interactive) (ansi-colorize nil 'bright-black))
(defun ansi-colorize-on-bright-red ()     (interactive) (ansi-colorize nil 'bright-red))
(defun ansi-colorize-on-bright-green ()   (interactive) (ansi-colorize nil 'bright-green))
(defun ansi-colorize-on-bright-yellow ()  (interactive) (ansi-colorize nil 'bright-yellow))
(defun ansi-colorize-on-bright-blue ()    (interactive) (ansi-colorize nil 'bright-blue))
(defun ansi-colorize-on-bright-magenta () (interactive) (ansi-colorize nil 'bright-magenta))
(defun ansi-colorize-on-bright-cyan ()    (interactive) (ansi-colorize nil 'bright-cyan))
(defun ansi-colorize-on-bright-white ()   (interactive) (ansi-colorize nil 'bright-white))

;; My shortcuts - under C-c C-a
(global-set-key (kbd "\C-c C-a C-c") 'ansi-colorize-cyan)



(provide 'ansi-colors)
