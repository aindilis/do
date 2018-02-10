;;; do-fontify.el --- a part of the simple Do mode

(defgroup do-todo-list-faces nil "faces used for Do mode"  :group 'faces)
(defgroup normal-form-faces nil "faces used for Normal-Form mode"  :group 'faces)

(defvar in-xemacs-p "" nil)

;;; GNU requires that the face vars be defined and point to themselves

(defvar do-todo-list-main-keyword-face 'do-todo-list-main-keyword-face
  "Face to use for Do relations.")
(defface do-todo-list-main-keyword-face
  '((((class color)) (:foreground "red" :bold t)))
  "Font Lock mode face used to highlight class refs."
  :group 'do-todo-list-faces)

(defvar do-todo-list-function-nri-and-class-face 'do-todo-list-function-nri-and-class-face
  "Face to use for Do keywords.")
(defface do-todo-list-function-nri-and-class-face
    (if in-xemacs-p 
	'((((class color)) (:foreground "red"))
	  (t (:foreground "gray" :bold t)))
      ;; in GNU, no bold, so just use color
      '((((class color))(:foreground "red"))))
  "Font Lock mode face used to highlight property names."
  :group 'do-todo-list-faces)

(defvar do-todo-list-normal-face 'do-todo-list-normal-face "regular face")
(defface do-todo-list-normal-face
 '((t (:foreground "grey")))
 "Font Lock mode face used to highlight property names."
 :group 'do-todo-list-faces)

(defvar do-todo-list-string-face 'do-todo-list-string-face "string face")
(defface do-todo-list-string-face
    '((t (:foreground "green4")))
  "Font Lock mode face used to highlight strings."
  :group 'do-todo-list-faces)

;; (defvar do-todo-list-logical-operator-face 'do-todo-list-logical-operator-face
;;   "Face to use for Do logical operators (and, or, not, exists, forall, =>, <=>)")
;; ;; same as function name face
;; (defface do-todo-list-logical-operator-face
;;  '((((class color)) (:foreground "blue")))
;;   "Font Lock mode face used to highlight class names in class definitions."
;;   :group 'do-todo-list-faces)

(defvar do-todo-list-completed-face 'do-todo-list-completed-face
  "Face to use for completed items")
;; same as function name face
(defface do-todo-list-completed-face
 '((((class color)) (:foreground "blue")))
  "Font Lock mode face used to highlight class names in class definitions."
  :group 'do-todo-list-faces)

(defvar do-todo-list-depends-face 'do-todo-list-depends-face
  "Face to use for completed items")
;; same as function name face
(defface do-todo-list-depends-face
 '((((class color)) (:foreground "red")))
  "Font Lock mode face used to highlight class names in class definitions."
  :group 'do-todo-list-faces)


(defvar do-todo-list-deleted-face 'do-todo-list-deleted-face
  "Face to use for deleted items")
;; same as function name face
(defface do-todo-list-deleted-face
 '((((class color)) (:foreground "brown")))
  "Font Lock mode face used to highlight class names in class definitions."
  :group 'do-todo-list-faces)

(defvar do-todo-list-in-progress-face 'do-todo-list-in-progress-face
  "Face to use for in progress items")
;; same as function name face
(defface do-todo-list-in-progress-face
 '((((class color)) (:foreground "green")))
  "Font Lock mode face used to highlight class names in class definitions."
  :group 'do-todo-list-faces)

(defvar do-todo-list-postponed-face 'do-todo-list-postponed-face
  "Face to use for postponed items")
;; same as function name face
(defface do-todo-list-postponed-face
 '((((class color)) (:foreground "yellow")))
  "Font Lock mode face used to highlight class names in class definitions."
  :group 'do-todo-list-faces)

(defvar do-todo-list-when-face 'do-todo-list-when-face
  "Face to use for in progress items")
;; same as function name face
(defface do-todo-list-when-face
 '((((class color)) (:foreground "red")))
  "Font Lock mode face used to highlight class names in class definitions."
  :group 'do-todo-list-faces)

(defvar do-todo-list-priority-critical-modal-face 'do-todo-list-priority-critical-modal-face
  "Face to use for in progress items")
;; same as function name face
(defface do-todo-list-priority-critical-modal-face
 '((((class color)) (:foreground "bright green" :italic t)))
  "Font Lock mode face used to highlight class names in class definitions."
  :group 'do-todo-list-faces)


;; FIXME: urgent, non-urgent, etc

(defvar do-todo-list-priority-very-important-modal-face 'do-todo-list-priority-very-important-modal-face
  "Face to use for in progress items")
;; same as function name face
(defface do-todo-list-priority-very-important-modal-face
 '((((class color)) (:foreground "green" :italic t)))
  "Font Lock mode face used to highlight class names in class definitions."
  :group 'do-todo-list-faces)

(defvar do-todo-list-priority-important-modal-face 'do-todo-list-priority-important-modal-face
  "Face to use for in progress items")
;; same as function name face
(defface do-todo-list-priority-important-modal-face
 '((((class color)) (:foreground "dark green" :italic t)))
  "Font Lock mode face used to highlight class names in class definitions."
  :group 'do-todo-list-faces)

(defvar do-todo-list-priority-neutral-modal-face 'do-todo-list-priority-neutral-modal-face
  "Face to use for in progress items")
;; same as function name face
(defface do-todo-list-priority-neutral-modal-face
 '((((class color)) (:foreground "yellow" :italic t)))
  "Font Lock mode face used to highlight class names in class definitions."
  :group 'do-todo-list-faces)

(defvar do-todo-list-priority-unimportant-modal-face 'do-todo-list-priority-unimportant-modal-face
  "Face to use for in progress items")
;; same as function name face
(defface do-todo-list-priority-unimportant-modal-face
 '((((class color)) (:foreground "orange" :italic t)))
  "Font Lock mode face used to highlight class names in class definitions."
  :group 'do-todo-list-faces)

(defvar do-todo-list-priority-wishlist-modal-face 'do-todo-list-priority-wishlist-modal-face
  "Face to use for in progress items")
;; same as function name face
(defface do-todo-list-priority-wishlist-modal-face
 '((((class color)) (:foreground "pink" :italic t)))
  "Font Lock mode face used to highlight class names in class definitions."
  :group 'do-todo-list-faces)

(defvar do-todo-list-generic-face 'do-todo-list-generic-face
  "Face to use for in progress items")
;; same as function name face
(defface do-todo-list-generic-face
 '((((class color)) (:foreground "orange")))
  "Font Lock mode face used to highlight class names in class definitions."
  :group 'do-todo-list-faces)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar normal-form-task-face 'normal-form-task-face
  "Face to use for in progress items")
;; same as function name face
(defface normal-form-task-face
 '((((class color)) (:foreground "green")))
  "Font Lock mode face used to highlight class names in class definitions."
  :group 'normal-form-faces)

(defvar normal-form-mistake-face 'normal-form-mistake-face
  "Face to use for in progress items")
;; same as function name face
(defface normal-form-mistake-face
 '((((class color)) (:foreground "red")))
  "Font Lock mode face used to highlight class names in class definitions."
  :group 'normal-form-faces)

;; (defvar do-todo-list-main-relation-face 'do-todo-list-main-relation-face
;;   "Face to use for Do relations.")
;; (defface do-todo-list-main-relation-face
;;   '((((class color)) (:foreground "black" :bold t)))
;;   "Font Lock mode face used to highlight class refs."
;;   :group 'do-todo-list-faces)

;; (defvar do-todo-list-relation-face 'do-todo-list-relation-face
;;   "Face to use for Do relations.")
;; (defface do-todo-list-relation-face
;;   '((((class color)) (:foreground "darkgrey")))
;;   "Font Lock mode face used to highlight class refs."
;;   :group 'do-todo-list-faces)

;; (defvar do-todo-list-property-face 'do-todo-list-property-face
;;   "Face to use for Do property names in property definitions.")
;; (defface do-todo-list-property-face
;;   (if in-xemacs-p  
;;      '((((class color)) (:foreground "darkviolet" :bold t))
;;        (t (:italic t)))
;;     ;; in gnu, just magenta
;;     '((((class color)) (:foreground "darkviolet"))))
;;      "Font Lock mode face used to highlight property names."
;;      :group 'do-todo-list-faces)

;; (defvar do-todo-list-variable-face 'do-todo-list-variable-face
;;   "Face to use for Do property name references.")
;; (defface do-todo-list-variable-face
;;   '((((class color)) (:foreground "darkviolet" ))
;;     (t (:italic t)))
;;   "Font Lock mode face used to highlight property refs."
;;   :group 'do-todo-list-faces)

;; (defvar do-todo-list-comment-face 'do-todo-list-comment-face
;;   "Face to use for Do comments.")
;; (defface do-todo-list-comment-face
;;   '((((class color) ) (:foreground "red" :italic t))
;;     (t (:foreground "DimGray" :italic t)))
;;   "Font Lock mode face used to highlight comments."
;;   :group 'do-todo-list-faces)

;; (defvar do-todo-list-other-face 'do-todo-list-other-face
;;   "Face to use for other keywords.")
;; (defface do-todo-list-other-face
;;   '((((class color)) (:foreground "peru")))
;;   "Font Lock mode face used to highlight other Do keyword."
;;   :group 'do-todo-list-faces)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar normal-form-section-heading-face 'normal-form-section-heading-face
  "Face to use for completed items")
;; same as function name face
(defface normal-form-section-heading-face
 '((((class color)) (:foreground "black" :bold t)))
  "Font Lock mode face used to highlight class names in class definitions."
  :group 'do-todo-list-faces)

(defvar normal-form-request-permission-face 'normal-form-request-permission-face
  "Face to use for completed items")
;; same as function name face
(defface normal-form-request-permission-face
 '((((class color)) (:foreground "yellow")))
  "Font Lock mode face used to highlight class names in class definitions."
  :group 'do-todo-list-faces)

(defvar normal-form-request-permission-granted-face 'normal-form-request-permission-granted-face
  "Face to use for completed items")
;; same as function name face
(defface normal-form-request-permission-granted-face
 '((((class color)) (:foreground "green")))
  "Font Lock mode face used to highlight class names in class definitions."
  :group 'do-todo-list-faces)

(defvar normal-form-request-permission-denied-face 'normal-form-request-permission-denied-face
  "Face to use for completed items")
;; same as function name face
(defface normal-form-request-permission-denied-face
 '((((class color)) (:foreground "red")))
  "Font Lock mode face used to highlight class names in class definitions."
  :group 'do-todo-list-faces)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar normal-form-attribute-face 'normal-form-attribute-face
  "Face to use for completed items")
;; same as function name face
(defface normal-form-attribute-face
 '((((class color)) (:foreground "gray")))
  "Font Lock mode face used to highlight class names in class definitions."
  :group 'do-todo-list-faces)

;; (defvar do-todo-list-tag-face 'do-todo-list-tag-face
;;   "Face to use for tags.")
;; (defface do-todo-list-tag-face
;;     '((((class color)) (:foreground "violetred" ))
;;       (t (:foreground "black")))
;;   "Font Lock mode face used to highlight other untyped tags."
;;   :group 'do-todo-list-faces)

;; (defvar do-todo-list-substitution-face 'do-todo-list-substitution-face "face to use for substitution strings")
;; (defface do-todo-list-substitution-face
;;     '((((class color)) (:foreground "orangered"))
;;       (t (:foreground "lightgrey")))
;;   "Face to use for Do substitutions"
;;   :group 'do-todo-list-faces)


(defvar do-todo-list-incoming-predicate-face 'do-todo-list-incoming-predicate-face
  "Face to use for in progress items")
;; same as function name face
(defface do-todo-list-incoming-predicate-face
 '((((class color)) (:foreground "deep pink")))
  "Font Lock mode face used to highlight class names in class definitions."
  :group 'do-todo-list-faces)


;;;================================================================
;;; these are the regexp matches for highlighting Do 

(defvar do-todo-list-font-lock-prefix "\\b")
(defvar do-todo-list-font-lock-keywords
  (let ()
    (list 

     ;; (list
     ;;  "^[^;]*\\(;.*\\)$" '(1 do-todo-list-comment-face nil))

     (list 
      (do-todo-list-generate-regex-for-incoming-predicates)
      '(1 do-todo-list-incoming-predicate-face nil)
      )

     (list 
      (concat "(\\(completed\\|solution\\)\\b"
	      )
      '(1 do-todo-list-completed-face nil)
      )

     (list 
      (concat "(\\(depends\\)\\b"
	      )
      '(1 do-todo-list-depends-face nil)
      )

     (list 
      (concat "(\\(deleted\\)\\b"
	      )
      '(1 do-todo-list-deleted-face nil)
      )
     
     (list 
      (concat "(\\(in progress\\|partially completed\\|sequester to\\)\\b"
	      )
      '(1 do-todo-list-in-progress-face nil)
      )

     (list 
      (concat "(\\(postponed\\)\\b"
	      )
      '(1 do-todo-list-postponed-face nil)
      )

     (list 
      (concat "(\\(when\\)\\b"
	      )
      '(1 do-todo-list-when-face nil)
      )

     (list 
      (concat "(\\(task\\)\\b"
	      )
      '(1 normal-form-task-face nil)
      )

     (list 
      (concat "(\\(critical\\)\\b"
	      )
      '(1 do-todo-list-priority-critical-modal-face nil)
      )

     (list 
      (concat "(\\(very important\\)\\b"
	      )
      '(1 do-todo-list-priority-very-important-modal-face nil)
      )

     (list 
      (concat "(\\(important\\)\\b"
	      )
      '(1 do-todo-list-priority-important-modal-face nil)
      )

     (list 
      (concat "(\\(neutral\\)\\b"
	      )
      '(1 do-todo-list-priority-neutral-modal-face nil)
      )

     (list 
      (concat "(\\(unimportant\\)\\b"
	      )
      '(1 do-todo-list-priority-unimportant-modal-face nil)
      )

     (list 
      (concat "(\\(wishlist\\)\\b"
	      )
      '(1 do-todo-list-priority-wishlist-modal-face nil)
      )

     (list 
      (concat "(\\(request permission\\)\\b"
	      )
      '(1 normal-form-request-permission-face nil)
      )

     (list 
      (concat "(\\(granted\\)\\b"
	      )
      '(1 normal-form-request-permission-granted-face nil)
      )

     (list 
      (concat "(\\(denied\\)\\b"
	      )
      '(1 normal-form-request-permission-denied-face nil)
      )

     (list 
      (concat "(\\(mistake\\)\\b"
	      )
      '(1 normal-form-mistake-face nil)
      )

     (list 
      (concat "(\\(noted elsewhere\\|possible\\|necessary\\|habitual\\|obsoleted?\\|accidentally-forgotten\\)\\b"
	      )
      '(1 do-todo-list-generic-face nil)
      )

     (list 
      (concat "^(\\([-A-Z0-9_ ]+\\)\\b"
	      )
      '(1 normal-form-section-heading-face nil)
      )

     (list 
      (concat "(\\(reason\\|reward\\|penalty\\|location\\):"
	      )
      '(1 normal-form-attribute-face nil)
      )

     ;; (list 
     ;;  (concat do-todo-list-font-lock-prefix "\\(" (join "\\|"
     ;; 	      do-todo-list-mode-main-relation ) "\\)\\b" ) '(1
     ;; 	      do-todo-list-main-relation-face nil) )

     ;; (list
     ;;  (concat do-todo-list-font-lock-prefix "\\(" 
     ;;   (join "\\|"
     ;; 	do-todo-list-mode-functions-non-relational-instances-and-classes) "\\)\\b")
     ;;  '(1 do-todo-list-function-nri-and-class-face nil))

     ;; (list 
     ;;  (concat
     ;;   do-todo-list-font-lock-prefix "\\([_a-zA-Z0-9-]+Fn\\)\\b" )
     ;;   '(1 do-todo-list-function-nri-and-class-face nil) )

     ;; (list 
     ;;  (concat "\\(\\?[_A-Z0-9-]+\\)\\b"
     ;; 	      )
     ;;  '(1 do-todo-list-variable-face nil)
     ;;  )

     ;; (list 
     ;;  (concat "\\(\\&\\%[_A-Za-z0-9-]+\\)\\b"
     ;; 	      )
     ;;  '(1 do-todo-list-other-face nil)
     ;;  )

     ;; (list 
     ;;  (concat do-todo-list-font-lock-prefix "\\(" (join "\\|"
     ;; 	      do-todo-list-mode-relations) "\\)\\b" ) '(1
     ;; 	      do-todo-list-relation-face nil) )

     ;; (list 
     ;;  ;; (concat "^\s*[^;][^\n\r]*[\s\n\r(]\\(=>\\|<=>\\)"
     ;;  (concat "\\(=>\\|<=>\\)")
     ;;  '(1 do-todo-list-logical-operator-face nil)
     ;;  )

     ;; (list 
     ;;  (concat do-todo-list-font-lock-prefix "\\(" (join "\\|"
     ;; 	      do-todo-list-mode-main-keyword ) "\\)\\b" ) '(1
     ;; 	      do-todo-list-main-keyword-face nil) )
     
     ;; black for the def parts of PROPERTY DEFINITION
     ;; and of TransitiveProperty UnambiguousProperty UniqueProperty
;;; END OF LIST ELTS
     ))

    "Additional expressions to highlight in Do mode.")

(put 'do-todo-list-mode 'font-lock-defaults '(do-todo-list-font-lock-keywords nil nil))

(defun re-font-lock () (interactive) (font-lock-mode 0) (font-lock-mode 1))

(provide 'do-fontify)
