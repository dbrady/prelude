;; cmm emergency hacks - stuff I jammed into prelude in 2017, probably
;; in a panic while onsite, probably after another accidental
;; force-upgrade to a major emacs version. It is now 2022, 2 jobs
;; later, and I just got accidentally upgraded to Emacs 28.
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
