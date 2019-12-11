;;;IS_REGEXP
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
;;;REGEXP-COMP
(defun nfa-regexp-comp (RE)
  (cond ((atom RE) (atom-comp RE (gensym "q") (gensym "q")))
        ((and (is-regexp RE) (equal (first RE) 'star)) (star-comp RE (gensym "q") (gensym "q")))
        ((and (is-regexp RE) (equal (first RE) 'seq)) (seq-comp (cdr RE)))
        ((and (is-regexp RE) (equal (first RE) 'or)) (or-comp (cdr RE) (gensym "q") (gensym "q")))
  )
)


(defun atom-comp (RE x y)
  (list x y (list (list x RE y))))

(defun star-comp (RE x y)
  (delta-star (nfa-regexp-comp (second RE)) x y))

(defun delta-star (L x y)
  (list x y (append (third L) (list (list x 'epsilon (first L))
                                            (list (second L) 'epsilon y )
                                            (list x 'epsilon y)
                                            (list (second L) 'epsilon (first L))))));scrivo delta nell'append
  ;(a b ((banana) (culo))) K
  ;(append (third K) (maracas))

(defun seq-comp (RE)
  (cond ((null (cdr RE)) (nfa-regexp-comp (car RE)))
        (T (delta-seq (nfa-regexp-comp (first RE)) (seq-comp (cdr RE) )))
  )
)

(defun delta-seq (nfa1 nfa2)
  (list (first nfa1) (second nfa2) (append (third nfa1) (third nfa2) (list (list (second nfa1) 'epsilon (first nfa2)))))
)

(defun or-comp (RE x y)
  (cond ((null (cdr RE)) (nfa-regexp-comp (car RE)))
        (T (delta-or (nfa-regexp-comp (first RE)) (or-comp (cdr RE) x y) x y))
  )
)

(defun delta-or (nfa1 nfa2 x y)
  (if (equal (first nfa2) 'blank)
    (list x y (append (third nfa1) (third nfa2) (list (list x 'epsilon (first nfa1)))
                                                                        (list (list (second nfa1) 'epsilon y))))
    (list 'blank 'blank (append (third nfa1) (third nfa2) (list (list x 'epsilon (first nfa1)))
                                                                        (list (list (second nfa1) 'epsilon y))
                                                                        (list (list x 'epsilon (first nfa2)))
                                                                        (list (list (second nfa2) 'epsilon y))))
    )
)

;;NNFA-TEST
(defun nfa-test (nfa word)
  (nfa-accept (list (first nfa)) word nfa)
)

(defun nfa-accept (states word nfa)
  (cond
    ((null states) nil)
    ((null word) (or (check-final states nfa) (nfa-accept (step-states states 'epsilon nfa) word nfa)))
    (T (or (nfa-accept (step-states states (first word) nfa) (cdr word) nfa) (nfa-accept (step-states states 'epsilon nfa) word nfa)) )
  )
)


(defun step-states (states sym nfa)
  (mapcan (lambda (item)

            (step-state item sym (third nfa))
          )
    states
  )
)

(defun step-state (state sym deltas)
  (cond
    ((null deltas) nil)
    ((and (equal (first (first deltas)) state) (equal (second (first deltas)) sym)) (append (list (third (first deltas))) (step-state state sym (cdr deltas))))
    (t (step-state state sym (cdr deltas)))
  )
)

(defun check-final (states nfa)
  (cond
    ((null states) nil)
    ((equal (second nfa) (first states)) T)
    ((not (equal (second nfa) (first states))) (check-final (cdr states) nfa))
  )
)
