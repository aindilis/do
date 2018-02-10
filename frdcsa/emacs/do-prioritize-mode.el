;; This mode is for rapidly prioritizing todo list items.  It binds a
;; lot of single keys to functions that can quickly add a
;; classification

;; Note this is very similar to the corresponding ?PSE?/?Critic?
;; stuff, research that.

(global-set-key "\C-cdpr" 'do-todo-list-prioritize-region)

(define-derived-mode do-todo-list-prioritize-mode
 do-todo-list-mode "Do-Prioritize"
 "Major mode for prioritizing in .do files.
\\{do-todo-list-prioritize-mode-map}"
 ;; (define-key do-notes-list-mode-map "\C-c+" 'do-todo-list-prioritize-next-file)
 
 )

(defun do-todo-list-prioritize-region (start end)
 ""
 (interactive "r")
 (let ((filename "/tmp/prioritize.do"))
  (kmax-write-string-to-file (buffer-substring-no-properties start end) filename)
  (run-in-shell
   (concat
    "/var/lib/myfrdcsa/codebases/minor/free-life-planner/projects/prioritize-features/prioritize-tasks.pl -f "
    (shell-quote-argument filename))
   "*Do-Todo List Prioritization*")))

(provide 'do-prioritize-mode)
