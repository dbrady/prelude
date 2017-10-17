;; M-x package-install <RET> ruby-hash-syntax <RET>

(add-hook 'ruby-mode-hook
          (lambda ()
            (local-set-key (kbd "\C-c }") 'ruby-toggle-hash-syntax)
            (local-set-key (kbd "\C-c C-t") 'comment-todo-erest-1895)))


;; simple align-regexp is the same as a complex align-regexp, matching on group
;; 1 of the regexp \(\s-*\). If we change the regexp to
;; Okay, you can do proper json-style alignment (adding spaces AFTER the colon)
;; with this command:
;; C-u M-x align-regexp <RET> \(\s-*\):\(\s-*\) <RET> <BKSP> 2 <RET> <RET>

(fset 'align-json-hash
      (lambda (&optional arg) "Keyboard macro." (interactive "p")
      (kmacro-exec-ring-item (quote
                              ("xalign-regexp:\\(\\s-*\\)2y" 0 "%d")) arg)))
(global-set-key (kbd "\C-x :") 'align-json-hash)
