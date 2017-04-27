;; Some modes that should auto-fill by default
(add-hook 'markdown-mode-hook 'auto-fill-mode)

;; Use Github-Flavored-Markdown
;; This will need the "flavor" script written by Brett Terpstra:
;; http://brettterpstra.com/2012/09/16/easy-command-line-github-flavored-markdown/
;;
;; Brett has published his script here: https://gist.github.com/ttscoff/3732963
;;
;; And I have a copy of it in my personal bin folder at https://github.com/dbrady/bin/blob/master/flavor
;;
;; Stick that in the path and make sure whatever ruby emacs tries to reach for
;; has the json gem installed, e.g. on a new machine try
;;
;; rvm @global do rvm gem install json
;; (setq markdown-command "/usr/local/bin/flavor")
