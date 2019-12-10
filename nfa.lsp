(defun is-regexp (RE)
  (cond ((atom RE) T)
        ((and (equal (first RE) 'seq) (null (fourth RE)) (is-regexp (second RE)) (is-regexp (third RE))) T)
        ((and (equal (first RE) 'or) (null (fourth RE)) (is-regexp (second RE)) (is-regexp (third RE))) T)
        ((and (equal (first RE) 'star) (null (third RE)) (is-regexp (second RE)) T))
        ((and (equal (first RE) 'plus) (null (third RE)) (is-regexp (second RE)) T))
        ((and (equal (first RE) 'seq) (is-regexp (second RE))) (is-regexp (append (list (first RE)) (cdr (cdr RE)))))
        ((and (equal (first RE) 'or) (is-regexp (second RE))) (is-regexp (append (list (first RE)) (cdr (cdr RE)))))
        ((and (listp RE) (not (or (equal (first RE) 'or) (equal (first RE) 'seq) (equal (first RE) 'star) (equal (first RE) 'plus) ) ) ) T)
        ))

(defun nfa-regexp-comp (RE)
  (cond ((atom RE) (atom-gen RE (gensym "q") (gensym "q")) )))


(defun atom-comp (RE x y)
  (list x y (list (list x RE y))))
