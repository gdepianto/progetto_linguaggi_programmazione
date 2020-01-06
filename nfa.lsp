;; Ciapponi Stefano ######
;; De Pianto Gioele 845002


;;;IS_REGEXP
;ritorna T se RE è un'espressione regolare
;se RE non è un'espressione regolare ritorna nil
(defun is-regexp (RE)
  (cond ((atom RE) T)
        ((and (equal (first RE) 'seq)
	      (null (fourth RE))
	      (is-regexp (second RE))
	      (is-regexp (third RE)))
	 T)
        ((and (equal (first RE) 'or)
	      (null (fourth RE))
	      (is-regexp (second RE))
	      (is-regexp (third RE)))
	 T)
        ((and (equal (first RE) 'star)
	      (null (third RE))
	      (is-regexp (second RE)))
	 T)
        ((and (equal (first RE) 'plus)
	      (null (third RE))
	      (is-regexp (second RE)))
	 T)
        ((and (equal (first RE) 'seq)
	      (is-regexp (second RE)))
	 (is-regexp (append (list (first RE)) (cdr (cdr RE)))))
        ((and (equal (first RE) 'or) (is-regexp (second RE)))
	 (is-regexp (append (list (first RE)) (cdr (cdr RE)))))
        ((and (listp RE)
	      (not (or (equal (first RE) 'or)
		       (equal (first RE) 'seq)
		       (equal (first RE) 'star)
		       (equal (first RE) 'plus))))
	 T)))

;;;REGEXP-COMP
;crea una lista che rappresenta l'automa
;la lista è del tip (q0 q1 deltas) dove 10 è stato iniziale e q1 stato finale
;deltas è a sua volta una lista di triple del tipo (q0 a q1)
;la quale rappresenta la transizione dallo stato q0 al q1 con l'atomo 'a'
(defun nfa-regexp-comp (RE)
  (cond ((atom RE)
	 (atom-comp RE (gensym "q") (gensym "q")))
        ((and (is-regexp RE)
	      (equal (first RE) 'star))
	 (star-comp RE (gensym "q") (gensym "q")))
        ((and (is-regexp RE)
	      (equal (first RE) 'seq))
	 (seq-comp (cdr RE)))
        ((and (is-regexp RE)
	      (equal (first RE) 'or))
	 (or-comp (cdr RE) (gensym "q") (gensym "q")))
        ((and (is-regexp RE)
	      (equal (first RE) 'plus))
	 (nfa-regexp-comp (list 'seq (second RE) (list 'star (second RE))) ))
        ((is-regexp RE)
	 (atom-comp RE (gensym "q") (gensym "q")))))

;;;COMPILAZIONE ATOMO (o compound non riservato)
;genera l'automa per una RE atomica
(defun atom-comp (RE x y)
  (list x y (list (list x RE y))))

;;;COMPILAZIONE STAR
;genera l'automa per STAR
;prima genera ricorsivamente l'automa dell'argomento dello STAR
;tramite la funzione delta-star aggiunge le epsilon-transizioni necessarie
;sostituisce gli stati iniziali e finali
;aggiunge epsilon-transizione dal nuovo stato iniziale al vecchio stato iniziale
;aggiunge epsilon-transizione dal vecchio stato finale al nuovo stato finale
;aggiunge epsilon-transizione dallo stato iniziale a quello finale
;aggiunge epsilon-transizione dal vecchio stato finale al vecchio iniziale
(defun star-comp (RE x y)
  (delta-star (nfa-regexp-comp (second RE)) x y))

(defun delta-star (L x y)
  (list x y (append (third L)
		    (list (list x 'epsilon (first L))
		    (list (second L) 'epsilon y )
		    (list x 'epsilon y)
		    (list (second L) 'epsilon (first L))))))
;;;COMPILAZIONE SEQ
;genera gli automi degli elementi della sequenza
;tramite la funzione delta-seq li collega tramite epsilon-transizioni
;seq-comp è chiamata ricorsivamente con:
; caso base:è rimasto un solo elemento e quindi ne genera l'automat
; caso passo:genera l'automa del primo elemento e lo collega (tramite delta-seq)
;            alla chiamata ricorsiva di seq-comp
(defun seq-comp (RE)
  (cond ((null (cdr RE))
	 (nfa-regexp-comp (car RE)))
        (T
	 (delta-seq (nfa-regexp-comp (first RE)) (seq-comp (cdr RE) )))))

(defun delta-seq (nfa1 nfa2)
  (list (first nfa1)
	(second nfa2)
	(append (third nfa1)
		(third nfa2)
		(list (list (second nfa1) 'epsilon (first nfa2))))))

;;;COMPILAZIONE OR
;genera gli automi degli elementi dell'or
;crea l'or tramite l'aggiunta di epsilon-transizioni con le funzioni delta-or
;e build-deltas
;
;crea epsilon-transizioni dallo stato iniziale dell'automa agli stati iniziali
;degli automi dei singoli argomenti dell or
;
;crea epsilon-transizioni dagli stati finali degli automi dei singoli argomenti
;dell or allo stato finale dell'automa
(defun or-comp (RE x y)
  (delta-or (mapcar 'nfa-regexp-comp RE) x y)
)

(defun delta-or (L x y)
  (list x y (build-deltas L x y))
)

(defun build-deltas (L x y)
  (if (null (cdr L))
      (append (third (car L))
	      (list (list x 'epsilon (first (first L)))
		    (list (second (first L)) 'epsilon y)))
      (append (third (car L))
	      (list (list x 'epsilon (first (first L)))
		    (list (second (first L)) 'epsilon y) )
	      (build-deltas (cdr L) x y))))

;;NFA-TEST
(defun nfa-test (nfa word)
(if (listp word)
    (if (is-automata nfa)
	(nfa-accept (list (first nfa)) word nfa)
      (error "~S is not a Finite State Automata." nfa))
  nil))

;IS-AUTOMATA
;per essere un automa deve essere una lista composta da tre elementi
; 1) atomo che corrisponde allo stato iniziale
; 2) atomo che corrisponde allo stato finale
; 3) lista di triple che corrisponde alla funzione delta controllata tramie
;    la funzione are-deltas
(defun is-automata (L)
  (and (listp L)
       (atom (first L))
       (atom (second L))
       (listp (third L))
       (are-deltas (third L))))

(defun are-deltas (deltas)
(cond ((null deltas)
       nil)
      ((and (listp (first deltas))
	    (null (rest deltas))
	    (atom (first (first deltas)))
	    (atom (third (first deltas)))
	    (not (null (second (first deltas))))
	    (not (null (third (first deltas))))
	    (null (fourth (first deltas))))
       T)
      (T
       (and (listp (first deltas))
	    (atom (first (first deltas)))
	    (atom (third (first deltas)))
	    (not (null (second (first deltas))))
	    (not (null (third (first deltas))))
	    (null (fourth (first deltas)))
	    (are-deltas (rest deltas))))))


;NFA-ACCEPT
;accetta la stringa come fosse un epsilon-nfa
;accetta la stringa solo se quando si ferma uno degli stati in cui è arrivato
;è uno stato finale
;utilizza le funzione step-states, step-state e check-final

(defun nfa-accept (states word nfa)
  (cond ((null states) nil)
        ((null word)
        (or (check-final states nfa)
        (nfa-accept (step-states states 'epsilon nfa) word nfa)))
        (T
 (or (nfa-accept (step-states states (first word) nfa) (cdr word) nfa)
     (nfa-accept (step-states states 'epsilon nfa) word nfa)))))

;partendo da una lista di stati ritorna la lista degli stati applicando
;la funzione delta dell'automa con un simbolo passato
(defun step-states (states sym nfa)
  (mapcan (lambda (item)
            (step-state item sym (third nfa)))
          states))

;partendo da uno stato ed un simbolo applica la delta
(defun step-state (state sym deltas)
       (cond ((null deltas) nil)
             ((and (equal (first (first deltas)) state)
		   (equal (second (first deltas)) sym))
	      (append (list (third (first deltas)))
		      (step-state state sym (cdr deltas))))
             (t (step-state state sym (cdr deltas)))))

;ritorna T se almeno uno stato di quelli passati è finale
(defun check-final (states nfa)
  (cond ((null states) nil)
        ((equal (second nfa) (first states))
	 T)
        ((not (equal (second nfa) (first states)))
	 (check-final (cdr states) nfa))))
