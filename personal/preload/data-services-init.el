(defun wrap-selection-in-convert-timezone ()
  (interactive)
  (save-excursion t
                  (narrow-to-region (mark) (point))
                  (beginning-of-line)
                  ;; WATCH OUT: Make sure you're not replacing a reverse time zone, i.e. America/Denver to UTC.
                  (insert "CONVERT_TIMEZONE('UTC', 'America/Denver', ")
                  (end-of-line)
                  (insert ")")
                  (widen)))

;; yeah this is a stupid keybind but good lord they're all taken
;;
;; 2023-09-15 disabling, not on DS. Keeping the defun because it's a
;; good example of a simple interactive defun.
;;
;; (global-set-key (kbd "\C-x 4 4") 'wrap-selection-in-convert-timezone)
