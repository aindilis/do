;; C-c r e N	radar-edit-todays-dated-daily-todo-file
;; C-c r e T	radar-edit-dated-daily-todo-file
;; C-c r e n	radar-edit-latest-dated-daily-todo-file

(define-derived-mode do-dated-todo-list-mode
 do-todo-list-mode "Do-Dated"
 "Major mode for interacting with .do files.
\\{do-dated-todo-list-mode-map}"
 (define-key do-notes-list-mode-map "\C-c+" 'do-dated-daily-todo-list-next-file)
 (define-key do-notes-list-mode-map "\C-cn" 'do-dated-daily-todo-list-next-file)
 (define-key do-notes-list-mode-map "\C-cp" 'do-dated-daily-todo-list-previous-file) 
 )

(provide 'do-dated)
