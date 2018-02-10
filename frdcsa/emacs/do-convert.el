(global-set-key "\C-cdvs" 'do-convert-start)
(global-set-key "\C-cdvb" 'do-convert-set-current-buffer-to-current-prolog-interactor-buffer)
(global-set-key "\C-cdvr" 'do-convert-reload-current-file)

(defvar do-convert-buffer-name "*Do Convert*")

(defun do-convert-start ()
 ""
 (interactive)
 (if (kmax-buffer-exists-p do-convert-buffer-name)
  (switch-to-buffer do-convert-buffer-name)
  (run-in-shell
   "cd /var/lib/myfrdcsa/codebases/internal/do/scripts/convert && do-convert"
   do-convert-buffer-name
   'formalog-repl-mode)
  (do-convert-set-current-buffer-to-current-prolog-interactor-buffer)
  (ffap "/var/lib/myfrdcsa/codebases/internal/do/scripts/convert/prolog/startup.pl")
  (do-convert-reload-current-file)))

(defvar do-convert-current-prolog-interactor-buffer "*Formalog-REPL*")

(defun do-convert-set-current-buffer-to-current-prolog-interactor-buffer ()
 (interactive)
 (setq do-convert-current-prolog-interactor-buffer (current-buffer)))

(defun do-convert-reload-current-file ()
 ""
 (interactive)
 (assert (derived-mode-p 'prolog-mode))
 (let* ((file buffer-file-name))
  (pop-to-buffer do-convert-current-prolog-interactor-buffer)
  (kmax-run-command-in-repl (concat "consult('" (shell-quote-argument file) "')."))))

(provide 'do-convert)
