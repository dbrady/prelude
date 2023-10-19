;; cmm emergency hacks - stuff I jammed into prelude in 2017, probably
;; in a panic while onsite, probably after another accidental
;; force-upgrade to a major emacs version. It is now 2022, 2 jobs
;; later, and I just got accidentally upgraded to Emacs 28.
;;
;; 2023-09-21: And now Emacs 29. It's not that I never clean things up. It's
;; that there is value in not maintaining something that isn't broken. If I only
;; ever have to hack on this file once every six years, not refactoring this
;; file is pure "opportunity value".
;;
;; TODO: Sort these out, move them into the proper init files and kill
;; this file.

(global-set-key (kbd "\C-c M-f") 'auto-fill-mode)
;; (global-linum-mode 1)

(global-set-key (kbd "\C-x C-r") 'recentf-open-files)
(global-set-key (kbd "\C-c /") 'comment-dwim)

(set-face-attribute 'default nil :height 140)

(add-hook 'before-save-hook 'whitespace-cleanup)

(setq-default fill-column 80)
