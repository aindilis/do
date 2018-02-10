;; CREATE A mode for do files, in the mean time, make an alist

;; "Add stuff to .do mode, (actually create .do, .notes modes, etc) to
;; be able to highlight important items in red or something."'

(let ((dir "/var/lib/myfrdcsa/codebases/internal/do/frdcsa/emacs"))
 (if (file-exists-p dir)
  (setq load-path
   (cons dir load-path))))

(require 'do-notes)
(require 'do-dated)
(require 'do-prioritize-mode)

(require 'do-terms)
(require 'do-new-keywords)
(require 'do-fontify)
(require 'do-convert)

(setq auto-mode-alist
 (cons '("\\.do$" . do-todo-list-mode) auto-mode-alist)
 )

(setq auto-mode-alist
 (cons '("\\.notes$" . do-notes-list-mode) auto-mode-alist)
 )

;; FIXME: bind C-x C-e to do-todo-list-eval-last-sexp in do-todo-list
;; mode.

(global-set-key "\C-cdll" 'do-todo-list-load-tasks-in-region)
(global-set-key "\C-cdex" 'do-todo-list-edit-file)
(global-set-key "\C-cdep" 'do-todo-pretty-print-sexp-at-point)

(global-set-key "\C-cdjs" 'do-todo-list-jump-to-schedule)

(global-set-key "\C-cdim" 'do-todo-list-insert-new-scrum)
(global-set-key "\C-cdcm" 'do-todo-list-add-to-scrums)
(global-set-key "\C-cdcd" 'do-todo-list-add-to-appropriate)
(global-set-key "\C-cdca" 'do-todo-list-add-to-subsection)
(global-set-key "\C-cdcc" 'do-todo-list-add-to-completed)
(global-set-key "\C-cdce" 'do-todo-list-add-to-deleted)
(global-set-key "\C-cdcp" 'do-todo-list-add-to-progress)
(global-set-key "\C-cdcP" 'do-todo-list-add-to-postponed)
(global-set-key "\C-cdcf" 'do-todo-list-add-to-frdcsa)
(global-set-key "\C-cdcl" 'do-todo-list-add-to-personal)
(global-set-key "\C-cdcL" 'do-todo-list-add-to-projects)
(global-set-key "\C-cdcr" 'do-todo-list-add-to-rants)
(global-set-key "\C-cdcs" 'do-todo-list-add-to-solutions)
(global-set-key "\C-cdcW" 'do-todo-list-add-to-work-slash-personal)
(global-set-key "\C-cdcu" 'do-todo-list-add-to-unknown)
(global-set-key "\C-cdcw" 'do-todo-list-add-to-work)
(global-set-key "\C-cdcS" 'do-todo-list-add-to-shoppinglist)
(global-set-key "\C-cdch" 'do-todo-list-add-to-completed-schedule)

(global-set-key "\C-cdctw" 'do-todo-list-add-to-when-category)

(global-set-key "\C-cdtR" 'do-todo-list-add-to-read-completing-read-last)
(global-set-key "\C-cdtr" 'do-todo-list-add-to-read-completing-read)
(global-set-key "\C-cdtk" 'do-todo-list-sexp-keyword)
(global-set-key "\C-cdtc" 'do-todo-list-sexp-completed)
(global-set-key "\C-cdtd" 'do-todo-list-sexp-depends-on-new-task)
(global-set-key "\C-cdtD" 'do-todo-list-sexp-is-depended-on-by-new-task)
(global-set-key "\C-cdte" 'do-todo-list-sexp-deleted)
(global-set-key "\C-cdth" 'do-todo-list-sexp-habitual)
(global-set-key "\C-cdts" 'do-todo-list-sexp-solution)
(global-set-key "\C-cdtS" 'do-todo-list-sexp-sequester-to)
(global-set-key "\C-cdtp" 'do-todo-list-sexp-in-progress)
(global-set-key "\C-cdtP" 'do-todo-list-sexp-postponed)
(global-set-key "\C-cdti" 'do-todo-list-sexp-skipped)
(global-set-key "\C-cdto" 'do-todo-list-sexp-obsoleted)
(global-set-key "\C-cdtn" 'do-todo-list-sexp-noted-elsewhere)
(global-set-key "\C-cdtN" 'do-todo-list-sexp-note-elsewhere)
(global-set-key "\C-cdtw" 'do-todo-list-sexp-when)
(global-set-key "\C-cdta" 'do-todo-list-sexp-assign-to-project)


(global-set-key "\C-cduf" 'do-todo-list-util-fix-old-comment-syntax)
(global-set-key "\C-cdse" 'do-todo-list-search-todos)

(global-set-key "\C-cdok" 'do-todo-list-open-keywords-file)
(global-set-key "\C-cdak" 'do-todo-list-add-new-keyword)

(global-set-key "\C-cdar" 'do-todo-insert-reviewed-region)
(global-set-key "\C-cdid" 'do-todo-insert-current-date)

(global-set-key "\C-cdmr" 'do-todo-list-move-reschedule-entry)
(global-set-key "\C-cdmR" 'do-todo-list-move-reschedule-entry-to-next-day)

(global-set-key "\C-cdmo" 'do-todo-list-move-sexp-to-other)
(global-set-key "\C-cdmn" 'do-todo-list-move-sexp-to-node)

(global-set-key "\C-cdtI" 'do-todo-list-assert-task-important)

(global-set-key "\C-cdtT" 'do-todo-list-toggle-protection-mode)

;; protect the initial segment

(defvar do-todo-list-completing-read-list nil)

(define-derived-mode do-todo-list-mode
 emacs-lisp-mode "Do"
 "Major mode for interacting with .do files.
\\{do-todo-list-mode-map}"
 (define-key do-todo-list-mode-map "\C-cdp" 'do-todo-list-prioritize-mode)
 (define-key do-todo-list-mode-map "\C-x\C-e" 'do-todo-list-eval-last-sexp)
 (define-key do-todo-list-mode-map "\C-x\C-E" 'eval-last-sexp)
 (define-key do-todo-list-mode-map "\M-<" 'do-todo-list-beginning-of-buffer)
 (define-key do-todo-list-mode-map "\C-p" 'do-todo-list-previous-line)
 ;; (define-key do-todo-list-mode-map "DEL" 'do-todo-list-backward-delete-char-untabify)



 ;; (define-key do-todo-list-mode-map "\C-cdll" 'do-todo-list-load-tasks-in-region)
 ;; (define-key do-todo-list-mode-map "\C-cdex" 'do-todo-list-edit-file)

 ;; (define-key do-todo-list-mode-map "\C-cdim" 'do-todo-list-insert-new-scrum)
 ;; (define-key do-todo-list-mode-map "\C-cdcm" 'do-todo-list-add-to-scrums)
 ;; (define-key do-todo-list-mode-map "\C-cdcd" 'do-todo-list-add-to-appropriate)
 ;; (define-key do-todo-list-mode-map "\C-cdca" 'do-todo-list-add-to-subsection)
 ;; (define-key do-todo-list-mode-map "\C-cdcc" 'do-todo-list-add-to-completed)
 ;; (define-key do-todo-list-mode-map "\C-cdcf" 'do-todo-list-add-to-frdcsa)
 ;; (define-key do-todo-list-mode-map "\C-cdcp" 'do-todo-list-add-to-personal)
 ;; (define-key do-todo-list-mode-map "\C-cdcP" 'do-todo-list-add-to-projects)
 ;; (define-key do-todo-list-mode-map "\C-cdcr" 'do-todo-list-add-to-rants)
 ;; (define-key do-todo-list-mode-map "\C-cdcs" 'do-todo-list-add-to-work-slash-personal)
 ;; (define-key do-todo-list-mode-map "\C-cdcu" 'do-todo-list-add-to-unknown)
 ;; (define-key do-todo-list-mode-map "\C-cdcw" 'do-todo-list-add-to-work)
 ;; (define-key do-todo-list-mode-map "\C-cdcS" 'do-todo-list-add-to-shoppinglist)
 ;; (define-key do-todo-list-mode-map "\C-cdtw" 'do-todo-list-add-to-when-category)

 ;; (define-key do-todo-list-mode-map "\C-cdtc" 'do-todo-list-sexp-completed)
 ;; (define-key do-todo-list-mode-map "\C-cdtd" 'do-todo-list-sexp-deleted)
 ;; (define-key do-todo-list-mode-map "\C-cdts" 'do-todo-list-sexp-solution)
 ;; (define-key do-todo-list-mode-map "\C-cdtp" 'do-todo-list-sexp-in-progress)

 (make-local-variable 'font-lock-defaults)
 (setq font-lock-defaults '(do-todo-list-font-lock-keywords nil nil))
 (re-font-lock)
 )

(defvar do-todo-list-protection-mode-on t)

;; (kmax-toggle-boolean 'do-todo-list-protection-mode-on)

;; (let ((tmp1 t)
;;       (tmp2 'tmp1))
;;  ;; (setq-macro tmp2 nil)
;;  (kmax-toggle-boolean tmp2))

;; (defmacro setq-macro (var value)
;;  (list 'setq var value))

;; (defun kmax-toggle-boolean (var)
;;  (interactive)
;;  (if (see (eval (see var 0.5)) 0.5)
;;   (setq-macro var nil)
;;   (setq-macro var t))
;;  (see (concat "Res: " (prin1-to-string (eval var)))))

(defun do-todo-list-toggle-protection-mode ()
 (interactive)
 ""
 (if do-todo-list-protection-mode-on
  (setq do-todo-list-protection-mode-on nil)
  (setq do-todo-list-protection-mode-on t))
 ;; (kmax-toggle-boolean 'do-todo-list-protection-mode-on)
 (see do-todo-list-protection-mode-on 0.5))

;; enable toggling of protected mode

;; highlight this sexp

(defun do-todo-list-beginning-of-buffer ()
 ""
 (interactive)
 (beginning-of-buffer)
 (if do-todo-list-protection-mode-on
  (progn
   (forward-sexp 2)
   (backward-sexp 1))))

(defun do-todo-list-previous-line (&optional arg try-vscroll)
 ""
 (interactive "^p\np")
 (if (or
      (not do-todo-list-protection-mode-on)
      (> (current-line) 12))
  (previous-line arg try-vscroll)))

(defun do-todo-list-backward-delete-char-untabify (arg &optional killp)
 ""
 (interactive "*p\nP")
 (kmax-not-yet-implemented))

(defun do-todo-list-load-tasks-in-region ()
 ""
 (interactive)
 (shell-command
  (concat "/var/lib/myfrdcsa/codebases/internal/do/do --index2"
   " --contents " (shell-quote-argument (kmax-util-quote-carriage-returns (buffer-substring-no-properties (point) (mark))))
   " -c " freekbs2-context)
  )
 ;; (comment-region (point) (mark))
 ;; (comment-region (point) (mark))
 )

(defun kmax-util-quote-carriage-returns (string)
 (interactive)
 (while (string-match "\n" string)
  (setq string (replace-match " " nil t string)))
 string)


(defun do-todo-list-sexp-obsoleted ()
 "While editing a todo file, use this to mark the solution for a particular task."
 ;; have the option of moving it to the end
 ;; also use the elisp prett
 (interactive)
 (save-excursion
  (let*
   ((reason (read-from-minibuffer "Reason for Obsolescence: ")))
   (do-todo-list-assert-about-sexp "obsoleted" nil (concat "(reason: " reason ")"))
   )))

;; (defun do-todo-list-obsolete-sexp-at-point ()
;;  "While editing a todo file, use this to mark the reason for a particular task."
;;  ;; have the option of moving it to the end
;;  ;; also use the elisp pretty printer (when the git repos are synced)
;;  (interactive)
;;  (save-excursion
;;   (let*
;;    ((problem (substring-no-properties (thing-at-point 'sexp)))
;;     (reason (read-from-minibuffer "Reason for obsolescence: "))
;;     (reason-sexp
;;      (concat
;;       "(obsolete\n\t"
;;       problem
;;       "\n\t(" reason "))")))
;;    (kill-sexp)
;;    (if nil (end-of-buffer))
;;    (insert reason-sexp)
;;    )))

(defun do-todo-list-edit-file (&optional dirs)
 "Edit to.do file for given system"
 ;; prompt for the creation of the file if it does not already exist
 (interactive)
 (let* ((lists (if dirs
		dirs
		radar-radar-dirs))
	(directory
	 (radar-select-directory lists)))
  (if directory
   (find-file (concat directory "/to.do"))
   (find-file "~/to.do"))))

(defun do-todo-list-kill-sexp-at-point ()
 ""
 (let*
  ((sexp (substring-no-properties (thing-at-point 'sexp)))) 
  (kill-sexp)
  ;; (delete-char 1)
  ;; (delete-blank-lines)
  sexp))

(defun do-todo-list-copy-sexp-at-point ()
 ""
 (substring-no-properties (thing-at-point 'sexp)))

(defun do-todo-list-add-to-completed ()
 ""
 (interactive)
 (do-todo-list-add-to-item "(COMPLETED ITEMS\\b")
 )

(defun do-todo-list-add-to-deleted ()
 ""
 (interactive)
 (do-todo-list-add-to-item "(DELETED\\b")
 )

(defun do-todo-list-add-to-in-progress ()
 ""
 (interactive)
 (do-todo-list-add-to-item "(IN PROGRESS\\b")
 )

(defun do-todo-list-add-to-postponed ()
 ""
 (interactive)
 (do-todo-list-add-to-item "(POSTPONED\\b")
 )

(defun do-todo-list-add-to-projects ()
 ""
 (interactive)
 (do-todo-list-add-to-item "(PROJECTS\\b")
 )

(defun do-todo-list-add-to-solutions ()
 ""
 (interactive)
 (do-todo-list-add-to-item "(SOLUTIONS\\b")
 )

(defun do-todo-list-add-to-shoppinglist (&optional arg)
 ""
 (interactive "P")
 (do-todo-list-add-to-item "(SHOPPINGLIST\\b" arg)
 )

(defun do-todo-list-add-to-rants ()
 ""
 (interactive)
 (do-todo-list-add-to-item "(RANTS\\b")
 )

(defun do-todo-list-add-to-personal ()
 ""
 (interactive)
 (do-todo-list-add-to-item "(PERSONAL\\b")
 )

(defun do-todo-list-add-to-work ()
 ""
 (interactive)
 (do-todo-list-add-to-item "(WORK\\b")
 )

(defun do-todo-list-add-to-unknown ()
 ""
 (interactive)
 (do-todo-list-add-to-item "(UNKNOWN\\b")
 )

(defun do-todo-list-add-to-work-slash-personal ()
 ""
 (interactive)
 (do-todo-list-add-to-item "(WORK/PERSONAL\\b")
 )

(defun do-todo-list-add-to-frdcsa ()
 ""
 (interactive)
 (do-todo-list-add-to-item "(FRDCSA\\b")
 )

(defun do-todo-list-add-to-completed-schedule (&optional arg)
 ""
 (interactive "P")
 (do-todo-list-add-to-item "(COMPLETED SCHEDULE\\b" arg t)
 )

(defun do-todo-list-add-to-appropriate ()
 ""
 (interactive)
 ;; how to figure out which item it is
 (let*
  ((sexp (read (substring-no-properties (thing-at-point 'sexp))))
   (keyword (prin1-to-string (nth 0 sexp))))
  (cond 
   ((string= keyword "completed") (do-todo-list-add-to-completed))
   ((string= keyword "deleted") (do-todo-list-add-to-deleted))
   ((string= keyword "solution") (do-todo-list-add-to-solved))
   ;; ((string= keyword "noted elsewhere") (do-todo-list-add-to-noted-elsewhere))
   )
  )
 )

(defun do-todo-list-add-to-solved ()
 ""
 (interactive)
 (do-todo-list-add-to-item "(SOLUTIONS\\b")
 )

(defun do-todo-list-add-to-scrums ()
 ""
 (interactive)
 (do-todo-list-add-to-item "(SCRUMS\\b")
 )

(defun do-todo-list-ensure-regex-matches (regex &optional bound noerror count)
 (not (not (string-match regex (kmax-buffer-contents)))))

(defun do-todo-list-add-to-item (regex-arg &optional start-from-beginning-of-buffer move-to-end-of-buffer)
 ""
 (kmax-fixme "next check that the things that are added are appropriate, i.e. (completed X) to (COMPLETED )")
 (let* ((regex (or regex-arg (read-from-minibuffer "Regex: ")))
	(display-regex
	 (progn
	  (string-match "^\\(.*\\).b$" regex)
	  (match-string 1 regex))))
  (if (not (do-todo-list-ensure-regex-matches regex))
   (if (yes-or-no-p (concat "Create section for regex (" display-regex ") at end of file?: "))
    (save-excursion
     (end-of-buffer)
     (insert (concat "\n\n" display-regex "\n\t)")))))
  (if (do-todo-list-ensure-regex-matches regex)     
   (let* ((sexp (do-todo-list-kill-sexp-at-point)))
    (indent-for-tab-command)
    (save-excursion
     ;; (indent-for-tab-command)
     (if start-from-beginning-of-buffer
      (beginning-of-buffer))
     (do-todo-list-re-search-forward regex)
     (if move-to-end-of-buffer
      (progn
       (backward-up-list)
       (forward-sexp)
       (backward-char)
       ))
     (newline)
     (lisp-indent-line)
     (insert sexp)
     (if move-to-end-of-buffer
      (progn
       (newline)
       (backward-sexp)
       (previous-line)
       (delete-blank-lines)
       (backward-up-list)
       (indent-sexp))))
    (delete-blank-lines)
    (indent-for-tab-command)
    (next-line)))))

(defun do-todo-list-sexp-completed ()
 "While editing a todo file, use this to mark the solution for a particular task."
 (interactive)
 (do-todo-list-assert-about-sexp "completed"))

(defun do-todo-list-sexp-skipped ()
 "While editing a todo file, use this to mark the solution for a particular task."
 (interactive)
 (do-todo-list-assert-about-sexp "skipped"))

(defun do-todo-list-sexp-deleted ()
 "While editing a todo file, use this to mark the solution for a particular task."
 (interactive)
 (do-todo-list-assert-about-sexp "deleted"))

(defun do-todo-list-sexp-depends-on-new-task ()
 "While editing a todo file, use this to mark a dependency for a particular task."
 ;; have the option of moving it to the end
 ;; also use the elisp pretty printer (when the git repos are synced)
 (interactive)
 (save-excursion
  (let*
   ((dependency (read-from-minibuffer "Depends on: ")))
   (do-todo-list-assert-about-sexp "depends" nil (concat "(" dependency ")"))
   )))

(defun do-todo-list-sexp-is-depended-on-by-new-task ()
 "While editing a todo file, use this to mark a dependency for a particular task."
 ;; have the option of moving it to the end
 ;; also use the elisp pretty printer (when the git repos are synced)
 (interactive)
 (save-excursion
  (let*
   ((dependency (read-from-minibuffer "Is depended on: ")))
   (do-todo-list-assert-about-sexp "depends" (concat "(" dependency ")") nil)
   )))

(defun do-todo-list-sexp-in-progress ()
 "While editing a todo file, use this to mark the solution for a particular task."
 (interactive)
 (do-todo-list-assert-about-sexp "in progress"))

(defun do-todo-list-sexp-postponed ()
 ""
 (interactive)
 (do-todo-list-assert-about-sexp "postponed"))

(defun do-todo-list-sexp-solution ()
 "While editing a todo file, use this to mark the solution for a particular task."
 ;; have the option of moving it to the end
 ;; also use the elisp pretty printer (when the git repos are synced)
 (interactive)
 (save-excursion
  (let*
   ((solution (read-from-minibuffer "Solution: ")))
   (do-todo-list-assert-about-sexp "solution" nil (concat "(" solution ")"))
   ;; (do-todo-list-add-to-solved)
   )))

(defun do-todo-list-sexp-noted-elsewhere ()
 "While editing a todo file, use this to mark the solution for a particular task."
 ;; have the option of moving it to the end
 ;; also use the elisp pretty printer (when the git repos are synced)
 (interactive)
 (save-excursion
  (let*
   ((solution (read-from-minibuffer "Where is this noted: ")))
   (do-todo-list-assert-about-sexp "noted elsewhere" nil (concat "(" solution ")"))
   ;; (do-todo-list-add-to-solved)
   )))

(defun do-todo-list-sexp-note-elsewhere ()
 "While editing a todo file, use this to mark the solution for a particular task."
 ;; have the option of moving it to the end
 ;; also use the elisp pretty printer (when the git repos are synced)
 (interactive)
 (save-excursion
  (let*
   ((solution (read-from-minibuffer "Where should this be noted: ")))
   (do-todo-list-assert-about-sexp "note elsewhere" nil (concat "(" solution ")"))
   ;; (do-todo-list-add-to-solved)
   )))

(defun do-todo-list-sexp-assign-to-project ()
 "While editing a todo file, use this to mark the solution for a particular task."
 ;; have the option of moving it to the end
 ;; also use the elisp pretty printer (when the git repos are synced)
 (interactive)
 (save-excursion
  (let*
   ((project-dir (radar-select-directory (append radar-radar-dirs radar-radar-work-dirs))))
   (do-todo-list-assert-about-sexp "assigned project" nil (concat "(" project-dir ")"))
   ;; (do-todo-list-add-to-solved)
   )))

(defun do-todo-list-sexp-sequester-to ()
 "While editing a todo file, use this to mark the solution for a particular task."
 ;; have the option of moving it to the end
 ;; also use the elisp pretty printer (when the git repos are synced)
 (interactive)
 (save-excursion
  (let*
   ((location (read-from-minibuffer "Where should this be sequestered to: ")))
   (do-todo-list-assert-about-sexp "sequester to" nil (concat "(" location ")"))
   ;; (do-todo-list-add-to-solved)
   )))

(defun do-todo-list-sexp-when ()
 "While editing a todo file, use this to mark the solution for a particular task."
 ;; have the option of moving it to the end
 ;; also use the elisp pretty printer (when the git repos are synced)
 (interactive)
 (save-excursion
  (let*
   ((clause (read-from-minibuffer "When: ")))
   (do-todo-list-assert-about-sexp "when" (concat "(" clause ")"))
   )))

(defun do-todo-list-sexp-habitual ()
 "While editing a todo file, use this to mark the solution for a particular task."
 ;; have the option of moving it to the end
 ;; also use the elisp pretty printer (when the git repos are synced)
 (interactive)
 (do-todo-list-assert-about-sexp "habitual"))

;; (defun do-todo-list-util-fix-old-comment-syntax ()
;;  "Take the items in region, uncomment them, and add a (completed
;;  <sexp>) to each sexp"
;;  (interactive)
;;  (narrow-to-region (point) (mark))
;;  (uncomment-region (point) (mark))
;;  (beginning-of-buffer)
;;  (while (do-todo-list-util-sexp-at-point-p)
;;   (do-todo-list-re-search-forward "[^[:blank:]\n]" nil t)
;;   (backward-char)
;;   (if (do-todo-list-util-sexp-at-point-p)
;;    (progn 
;;     (do-todo-list-sexp-completed) 
;;     (ignore-errors (forward-sexp))
;;     )))
;;  (mark-whole-buffer)
;;  (indent-region (point) (mark))
;;  (widen))

(defun do-todo-list-util-sexp-at-point-p ()
 ""
 (interactive)
 (save-excursion
  (do-todo-list-re-search-forward "[^[:blank:]\n]" nil t)
  (backward-char)
  (not (not (sexp-at-point)))))

;; have the option of moving it to the end
;; also use the elisp pretty printer (when the git repos are synced)

;; (defun clean-todo-file );; move all the completed/deleted to a separate area, maybe even add timestamp info to them when completing them

;; here is the syntax

;; WHEN-STATEMENT := "(" "When" <WHEN-COND-AND-BODY>... ")"
;; WHEN-COND-AND-BODY := "(" <WHEN-COND> <WHEN-BODY> ")"
;; WHEN-COND := <PREDICATE>
;; WHEN-BODY := "(" <EXPRESSION>... ")"

;; TASK := <SEXP>

;; PREDICATE := <SEXP>
;; EXPRESSION := <SEXP>

(defun do-todo-list-re-search-forward (regex &optional bound noerror count)
 (let ((case case-fold-search))
  (setq case-fold-search nil)
  (re-search-forward regex (or bound nil) (or noerror nil) (or count nil))
  (setq case-fold-search case)))

(defun do-todo-list-add-to-when-category ()
 (interactive)
 (let* ((sexp (do-todo-list-kill-sexp-at-point)))
  (save-excursion
   (do-todo-list-re-search-forward "(WHEN\\b" nil nil)
   (backward-up-list)
   (let* ((my-sexp (sexp-at-point))
	  ;; (tmp (and (switch-to-buffer (get-buffer-create "test")) (insert (prin1-to-string my-sexp))))
	  (category (completing-read "Please select a when category " (mapcar (lambda (list) (join " " (mapcar 'prin1-to-string (car list)))) (cdr my-sexp))))
	  )
    (do-todo-list-re-search-forward category)
    (backward-up-list)
    (forward-sexp)
    (down-list)
    (lisp-indent-line)
    (insert sexp)
    (newline)
    (lisp-indent-line)
    )
   )
  )
 )

;; miscellaneous

(defun do-todo-list-select-and-print-to-printer-section ()
 "Quickly print a section to the printer"
 )

(defun do-todo-list-add-to-subsection ()
 "This is a completing read menu system for the todo files, allowing rapid classification of tasks"
 (interactive)
 (let* ((char (do-todo-list-submenu-search)))
  (if (non-nil 'char)
   (let* ((sexp (do-todo-list-copy-sexp-at-point)))
    (save-excursion
     (goto-char (1+ char))
     (newline)
     (lisp-indent-line)
     (insert sexp))
    (do-todo-list-kill-sexp-at-point)
    (delete-blank-lines)))))

(defun do-todo-list-submenu-search ()
 "return the character position or nil"
 (interactive)
 (let* (
	(buffer-contents (save-excursion (mark-whole-buffer) (buffer-substring-no-properties (point) (mark))))
	(menu (read (kmax-do-command-on-data-to-file "/var/lib/myfrdcsa/codebases/internal/do/scripts/generate-menu-alist.pl" buffer-contents "string")))
	(offset (do-todo-list-submenu-search-get-submenu-or-location menu nil))
	)
  (string-to-number offset)))

(defun do-todo-list-submenu-search-get-submenu-or-location (menu endloc)
 (let* (
	(menuoptions nil)
	(endvalues nil)
	(tmp1 (mapcar (lambda (alist)
		       (push (list (car (cdr (assoc "Entry" alist))) (cdr (assoc "Submenu" alist))) menuoptions)
		       (push (list (car (cdr (assoc "Entry" alist))) (cdr (assoc "End" alist))) endvalues)
		       ) menu))
	(choice (org-frdcsa-manager-dialog--choose menuoptions))
	(subendloc (caar (cdr (assoc choice endvalues))))
	(submenu (caar (cdr (assoc choice menuoptions))))
	)
  (if (kmax-util-non-empty-list-p submenu)
   (do-todo-list-submenu-search-get-submenu-or-location submenu subendloc)
   (if (= (length choice) 0)
    endloc
    (caar (cdr (assoc choice endvalues)))))))


(defun do-todo-classify-entry ()
 ""
 (interactive)
 ;; eventually do this semi automatically, for now, just query
 (let* ((sexp (do-todo-list-kill-sexp-at-point))
	(menu '(
		(":category" . '("Work"))
		(":priority" . '("Highest" "Medium")
		))))
  (insert (concat "(" sexp " (:sample \"item\"))"))))


;; figure out how to choose from a recursive alist, I think I wrote
;; something to do this in the do system.

(setq do-todo-classify-entry-menu
 '(
   (":category" . (("Work" . 1)))
   (":priority" . (("Highest" . 1) ("Medium" . 1) ("Low" . 1)))
   ))

;; (do-todo-choose-menu-recursively do-todo-classify-entry-menu)

(defun do-todo-choose-menu-recursively (menu)
 ""
 (interactive)
 (let* (
	(choicekey (completing-read "Key?: " menu))
	(submenu (cdr (assoc choicekey menu)))
	(choicevalue (completing-read "Value?: " submenu))
	)
  (see (concat "(" choicekey " \"" choicevalue "\")"))))

;; (defun substring-no-properties (string)
;;   "a replacement function for the missing function"
;;   ;; remove the properties from this string
;;   (set-text-properties 0 (length string) nil string)
;;   ;; (message string)
;;   ;; (string-match "\\(.+\\)" string)
;;   ;; (match-string-no-properties 0 string)
;;   string
;;   )

(defun do-assert-has-greater-priority ()
 ""
 (interactive)
 
 )

(defun current-date-and-time ()
  ""
  (chomp (shell-command-to-string "date")))

(defun do-todo-list-insert-new-scrum ()
  "insert the current scrum"
  (interactive)
  (insert (concat "(Date: " (current-date-and-time) "
  (see /var/lib/myfrdcsa/codebases/internal/posi/scrum-manual.notes)
  (Pay attention to everyone's status)
  (This is Andrew)
  (What I've been doing
	(Previously
		(TA)
		)
	(Today
		(TA)
		)
         )
  (What I will be doing
	)
  (Blockers if any
	    )
  (QNA
   )
  (That's it for me)
  (Pay attention to everyone's status)
  )"		  
  ))
  (beginning-of-defun)
  )

(defun do-todo-list-assert-about-sexp-new (predicate &optional previous additional)
 "While editing a todo file, use this to mark the solution for a particular task."
 ;; have the option of moving it to the end
 ;; also use the elisp pretty printer (when the git repos are synced)
 (interactive)
 (if (do-todo-list-util-sexp-at-point-p)
  (save-excursion
   (do-todo-list-re-search-forward "[^[:blank:]\n]" nil t) 
   (backward-char)
   (let*
    ((sexp (do-todo-list-kill-sexp-at-point))
     (modified-sexp
      (concat
       "(" predicate " "
       (if previous (concat previous " "))
       sexp
       (if additional (concat " " additional))
       ")")))
    (insert (url-eat-trailing-space (pp (read modified-sexp))))))))

(defun do-todo-list-assert-about-sexp (predicate &optional previous additional)
 "While editing a todo file, use this to mark the solution for a particular task."
 ;; have the option of moving it to the end
 ;; also use the elisp pretty printer (when the git repos are synced)
 (interactive)
 (if (do-todo-list-util-sexp-at-point-p)
  (save-excursion
   (do-todo-list-re-search-forward "[^[:blank:]\n]" nil t) 
   (backward-char)
   (let*
    ((sexp (do-todo-list-kill-sexp-at-point))
     (modified-sexp
      (concat
       "(" predicate " "
       (if previous (concat previous " "))
       sexp
       (if additional (concat " " additional))
       ")")))
    (insert modified-sexp))))
 (do-todo-pretty-print-sexp-at-point))

(defun do-todo-list-kill-sexp ()
 "While editing a todo file, use this to mark the solution for a particular task."
 ;; have the option of moving it to the end
 ;; also use the elisp pretty printer (when the git repos are synced)
 (interactive)
 (if (do-todo-list-util-sexp-at-point-p)
  (save-excursion
   (do-todo-list-re-search-forward "[^[:blank:]\n]" nil t) 
   (backward-char)
   (kill-sexp))))

(defun do-todo-list-eval-last-sexp ()
 ""
 (interactive)
 (see "FIXME: integrate frdcsal with do to-do.  so that we can eval sexps from do and they just execute.  write do-eval-sexp")
 (kmax-not-yet-implemented))

(defun do-todo-list-search-todos (&optional search-arg)
 ""
 (interactive)
 (run-in-shell
  (concat
   "cd /var/lib/myfrdcsa/codebases/internal/do/scripts && ./search-todos "
   (shell-quote-argument
    (or search-arg
     (read-from-minibuffer "Search Todos for: "))))
  "*Do-Todo Search Results*"))

;; dob-todo-list-generate-schedule-for-date-window

(global-set-key "\C-cdsd" 'kmax-select-date)
(global-set-key "\C-cdsD" 'kmax-select-date-helper)

(defun kmax-select-date ()
 (interactive)
 (see "Please move the cursor to a date from the calendar, then run C-c d i D")
 (calendar))

(defun kmax-select-date-helper ()
 ""
 (interactive)
 (let* ((date (mapcar 'number-to-string (calendar-cursor-to-date t))))
  (exit-calendar)
  (set kmax-current-date date)
  (see date)))

(defun do-todo-insert-current-date ()
 ""
 (interactive)
 (insert (do-todo-get-current-date)))

(defun do-todo-get-current-date ()
 ""
 (chomp (shell-command-to-string "date \"+\%a \%b \%d\"")))

;; (defun do-todo-list-generate-schedule-for-date-window ()
;;  ""
;;  (interactive)
;;  (see "Please select a starting date, followed by an ending date, for the schedule to run through.")
;;  (let* ((start-date (progn (kmax-select-date))
;; 	(end-date (kmax-select-date)))

;; (2016 1 20)

(defun do-todo-get-trailingspace ()
 (interactive)
 (save-excursion
  (forward-sexp)
  (set-mark (point))
  (condition-case nil
   (progn
    (forward-sexp)
    (backward-sexp)
    (buffer-substring-no-properties (point) (mark))
    )
   (error nil))))

(defun do-todo-pretty-print-sexp-at-point ()
 (interactive)
 (do-todo-pretty-print-sexp-at-point-20170126175113))

(defun do-todo-pretty-print-sexp-at-point-20170126175113 ()
 ""
 (interactive)
 (let* ((trailing-space (do-todo-get-trailingspace)))
  (fill-paragraph)
  (mark-sexp)
  (narrow-to-region (point) (mark))
  (indent-for-tab-command)
  (pp-buffer)
  (end-of-buffer)
  (widen)
  (set-mark (point))
  (backward-sexp)
  (indent-region (point) (mark))
  (condition-case nil
   (progn
    (forward-sexp)
    (delete-blank-lines)
    (delete-blank-lines)
    (delete-horizontal-space)
    (delete-char 1)
    (insert trailing-space)
    )
   (error nil))
  (indent-for-tab-command)
  (backward-sexp)))

(defun do-todo-pretty-print-sexp-at-point-20170126175119 ()
 ""
 (interactive)
 (let* ((trailing-space (do-todo-get-trailingspace)))
  (fill-paragraph)
  (mark-sexp)
  (narrow-to-region (point) (mark))
  (indent-for-tab-command)
  (pp-buffer)
  (end-of-buffer)
  (widen)
  (set-mark (point))
  (backward-sexp)
  (indent-region (point) (mark))
  (condition-case nil
   (progn
    (forward-sexp)
    (delete-blank-lines)
    (delete-blank-lines)
    (delete-horizontal-space)
    (delete-char 1)
    (insert trailing-space)
    )
   (error nil))
  ;; (indent-for-tab-command)
  ;; (backward-sexp)
  ))

(defun do-todo-pretty-print-sexp-at-point-20170126175202 ()
 ""
 (interactive)
 (save-excursion
  (fill-paragraph)
  (mark-sexp)
  (narrow-to-region (point) (mark))
  (indent-for-tab-command)
  (pp-buffer)
  (end-of-buffer)
  (widen)
  (set-mark (point))
  (backward-sexp)
  (indent-region (point) (mark))
  (condition-case nil
   (progn
    (forward-sexp)
    (delete-blank-lines)
    (delete-horizontal-space)
    )
   (error nil))
  (forward-char)
  (indent-for-tab-command)
  (backward-sexp)
  ))

(defun do-todo-keyword-already-exists (keyword)
 ""
 (interactive)
 (non-nil (assoc keyword do-new-keywords)))

(defun do-todo-list-add-new-keyword (&optional keyword-arg)
 ""
 (interactive)
 (let
  ((keyword
    (or
     keyword-arg
     (ido-completing-read "Choose Keyword: "
      (mapcar #'first do-new-keywords)))))
  (if (do-todo-keyword-already-exists keyword)
   (message (concat "Already exists: " keyword))
   (do-todo-list-add-new-keyword-helper keyword))))

(defun do-todo-list-add-new-keyword-helper (keyword)
 (progn
  (do-edit-list "^(setq do-new-keywords")
  (insert keyword)
  (save-excursion
   (mark-whole-buffer)
   (indent-region (point) (mark))
   (do-eval-list "^(setq do-new-keywords")
   (backward-up-list)
   (forward-sexp)
   (eval-last-sexp nil))
  (save-buffer)))

(defun do-todo-list-open-keywords-file ()
 ""
 (interactive)
 (ffap "/var/lib/myfrdcsa/codebases/internal/do/frdcsa/emacs/do-new-keywords.el"))

(defun do-edit-list (search)
 ""
 (interactive)
 (do-todo-list-open-keywords-file)
 (beginning-of-buffer)
 (re-search-forward search)
 (beginning-of-line)
 (forward-sexp)
 (beginning-of-line)
 (open-line 1)
 (indent-for-tab-command)
 (insert "(\"\" . ((\"desc\" . \"\")\n(\"arity\" . nil)))")
 (beginning-of-line)
 (indent-for-tab-command)
 (beginning-of-line)
 (previous-line)
 (indent-for-tab-command)
 (forward-char 2))

(defun do-eval-list (search)
 ""
 (interactive)
 (do-todo-list-open-keywords-file)
 (beginning-of-buffer)
 (re-search-forward search))

(defun kmax-get-point-mark-min ()
 (if (<= (point) (mark))
  (point)
  (mark)))

(defun kmax-get-point-mark-max ()
 (if (>= (point) (mark))
  (point)
  (mark)))

(defun do-todo-insert-reviewed-region ()
 ""
 (interactive)
 (let* ((min (kmax-get-point-mark-min))
	(max (kmax-get-point-mark-max)))
  (goto-char max)
  (insert (concat "\n\n(ENDED READING at \"" (kmax-timestamp) "\")\n\n"))
  (goto-char min)
  (insert (concat "\n\n(BEGAN READING at \"" (kmax-timestamp) "\")\n\n"))))

;; after-save-hook

;; (do-todo-list-or-notes-p (kmax-chase "~/to.do"))
;; (see (cdr (assoc "/home/andrewdo/.do/to.do" do-todo-list-or-notes-p-hash)))
;; (shell-command-to-string
;;  (concat "/var/lib/myfrdcsa/codebases/internal/do/systems/convert/scripts/do-todo-list-or-notes-p.pl -ef " (shell-quote-argument "~/to.do")))


(defvar do-check-parses nil)

(defun do-todo-after-save-hook ()
 ""
 (interactive)
 (if (derived-mode-p 'do-todo-list-mode)
  (let ((chased-file (kmax-chase (buffer-file-name))))
   (if (string-match "^/home/andrewdo/.do/" "/home/andrewdo/.do/todo/20160909.do")
    (if (or (not do-check-parses) (do-todo-list-or-notes-parses-p chased-file))
     (message (shell-command-to-string "cd /home/andrewdo/.do && (git add .; git commit -m \"Nice (auto)\" .)"))
     (error (concat "File not parsing: " chased-file)))))))

(defun do-todo-list-or-notes-parses-p (file)
 ""
 (kmax-fixme "need to get this to check whether the file actually parses correctly all the way through")
 (do-todo-list-or-notes-p file))

(defun do-todo-list-or-notes-p (file)
 ""
 (setq do-todo-list-or-notes-p-hash nil)
 (eval
  (read
   (shell-command-to-string
    (concat
     "/var/lib/myfrdcsa/codebases/internal/do/systems/convert/scripts/do-todo-list-or-notes-p.pl -ef "
     (shell-quote-argument file)))))
 (if (> (length do-todo-list-or-notes-p-hash) 0)
  (cdr (assoc file do-todo-list-or-notes-p-hash))))


(defun do-todo-list-sexp-keyword ()
 "While editing a todo file, use this to mark the solution for a particular task."
 ;; have the option of moving it to the end
 ;; also use the elisp pretty printer (when the git repos are synced)
 (interactive)
 (let ((predicate (completing-read "Keyword: " do-new-keywords)))
  (if (not (do-todo-keyword-already-exists predicate))
   (do-todo-list-add-new-keyword predicate))
  (do-todo-list-assert-about-sexp predicate)
  ))

(defvar do-todo-list-completing-read-last nil)

(defun do-todo-list-add-to-read-completing-read-last ()
 ""
 (interactive)
 (do-todo-list-add-to-item (concat "(" do-todo-list-completing-read-last"\\b") t))

(defun do-todo-list-add-to-read-completing-read ()
 ""
 (interactive)
 (let
  ((item
    (setq do-todo-list-completing-read-last
     (completing-read "Item?: " (mapcar #'first do-new-keywords)))))
  ;; eventually have this be the initial segments of all the items,
  ;; fix the function names too
  (if (not (do-todo-keyword-already-exists item))
   (do-todo-list-add-new-keyword-helper item))
  (do-todo-list-add-to-item (concat "(" item"\\b") t)))

(defun do-todo-list-jump-to-schedule ()
 ""
 (interactive)
 (do-todo-list-jump-to-entry "(SCHEDULE\\b"))

(defun do-todo-list-jump-to-entry (regex-arg &optional bound noerror count)
 ""
 (let ((case case-fold-search))
  (setq case-fold-search nil)
  (if (not (re-search-forward regex-arg (or bound nil) (or noerror nil) (or count nil)))
   (progn
    (beginning-of-buffer)
    (if (not (re-search-forward regex-arg (or bound nil) (or noerror nil) (or count nil)))
     (error (concat "Connot find regex in current buffer: " regex)))))
  (setq case-fold-search case)))

(defun do-todo-list-move-reschedule-entry ()
 ""
 (interactive)
 (kmax-not-yet-implemented)
 ;; (do-todo-list-list-dates-in-schedule file)
 )

;; (defun do-todo-list-list-dates-in-schedule (&optional file)
;;  ""
;;  (interactive)
;;  (formalog-query (list 'var-Dates) (list listDatesInSchedule 'var-Dates)))

 ;; (let ((sexp (do-todo-list-kill-sexp)))
 ;;  ;; should we use do_convert to query here?  get the different dates,
 ;;  ;; then search for it, and put it at the end or beginning as needed
 ;;  (kmax-not-yet-implemented)))

(defun classify-load-outbound-node-to-do ()
 ""
 (interactive)
 (ffap "/var/lib/myfrdcsa/codebases/internal/classify/data/outbound/systems/node/to.do"))

(defvar do-todo-list-files (list "/home/andrewdo/.do/features.do" "/home/andrewdo/.do/to-2.do"))

(defun do-todo-list-move-sexp-to-other (&optional other-do-mode-file-arg cp)
 "While editing a todo file, use this to mark the solution for a particular task."
 ;; have the option of moving it to the end
 ;; also use the elisp pretty printer (when the git repos are synced)
 (interactive)
 (kmax-fixme "spacing is still wonkey")
 (let* ((sexp (do-todo-list-kill-sexp)))
  (if cp (insert sexp))
  (save-excursion
   (ffap (or
	  other-do-mode-file-arg
	  (ido-completing-read "Please select a do-todo-list mode file: " do-todo-list-files)))
   (beginning-of-buffer)
   (forward-sexp)
   (insert (concat "\n\n\n" (kmax-top-of-kill-ring) "\n\n\n"))
   (delete-blank-lines)
   (backward-sexp)
   (delete-blank-lines))))

(defun do-todo-list-move-sexp-to-node ()
 ""
 (interactive)
 (do-todo-list-move-sexp-to-other "/var/lib/myfrdcsa/codebases/internal/classify/data/outbound/systems/node/to.do"))

(add-hook 'after-save-hook 'do-todo-after-save-hook)

(defvar do-todo-list-current-important-file "/home/andrewdo/.do/important-20170625.do")

(defun do-todo-list-assert-task-important ()
 ""
 (do-todo-list-move-sexp-to-other do-todo-list-current-important-file t))

(defun do-todo-list-reload-mode
 ""
 (interactive)
 (kmax-not-yet-implemented))
 
;; (load-if-exists "/var/lib/myfrdcsa/codebases/internal/do/do.el")
;; (let (()))

(provide 'do)
