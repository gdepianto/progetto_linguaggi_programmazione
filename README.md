# Progetto di linguaggi di programmazione
Studenti:  
Ciapponi Stefano 844811  
De Pianto Gioele 845002

# LISP

Descrizione progetto:  
  Il progetto consiste in un compilatore di Regexp (Espressioni regolari)
  in automi a stati finiti Non deterministici,
  con conseguente simulazione dell'automa.  
  Dato un determinato input l'automa specifica se tale input appartiene o meno
  al linguaggio definito dall'espressione regolare utilizzata per compilare
  l'automa.

Funzioni:

(is-regexp RE)  
  questa  funzione verifica se l'input è un espressione regolare,
  in caso affermativo il valore di ritorno è T altrimenti è NIL
  Abbiamo considerato espressione regolari i seguenti elementi:  
  -atomi  
  -liste il cui primo elemento è l'atomo seq e ha almeno altri due elementi
      che sono a loro volta delle RE ad esempio (seq a b c)  
  -liste il cui primo elemento è l'atomo or e ha almeno altri due elementi
      che sono a loro volta delle RE ad esempio (or a b c)  
  -liste il cui primo elemento è l'atomo star e ha solo un altro elemento
      che è a sua volta una RE ad esempio (star a)  
  -liste il cui primo elemento è l'atomo plus e ha solo un altro elemento
      che è a sua volta una RE ad esempio (plus a)  
  -qualsiasi altra lista il cui primo elemento è diverso da seq,or,star e plus


(regexp-comp RE)  
  questa funzione ritorna l'automa non deterministico a stati finiti con
  epsilon transizioni che accetta il linguaggio descritto dalla RE in input
  la struttura dell'automa è una lista composta da tre elementi  
  1) un atomo rappresentante lo stato iniziale  
  2) un atomo rappresentante lo stato finale (gli automi generati da questa
      funzione hanno sempre un solo stato accettante)  
  3) una lista che rappresenta le transizioni della funzione delta dell'automa
      gli elementi della lista sono delle triple che descrivono le transizioni
      dove il primo elemento è lo stato di partenza, il secondo è il simbolo in
      input ed il terzo è lo stato di arrivo ad esempio (q0 a q1).  

  un esempio di automa è (q0 q1 ((q0 a q1))) che rappresenta l'automa per la RE
  'a'  

 le funzioni (atom-comp RE x y) (star comp-RE x y) (delta-star L x y)
            (seq-comp RE) (delta-seq nfa1 nfa2) (or-comp L x y) (delta-or RE)
            (build-deltas L x y) (delta-or L X Y)  
 sono funzioni usate da regexp-comp per costruire l'automa nei vari casi  


(is-automata L)  
  questa controlla che L sia una lista rappresentate un automa secondo la
  struttura precedentemente illustrata in caso positivo ritorna T altrimenti NIL  

(nfa-test nfa word)  
  questa funzione torna T se l'automa nfa accetta la stringa word. Se nfa non è
  un automa ritorna errore. Se l'automa non accetta la stringa ritorna NIL.
  questa funzione usa funzioni ausiliarie come nfa-accept, step-states,
  step-state, check-final per simulare l'accettazione di una stringa da parte di
  un automa non deterministico a stati finiti con epsilon transizioni
  
# PROLOG

Descrizione del progetto:  
    Il progetto consiste in un compilatore di Regexp (Espressioni regolari)
    in automi a stati finiti Non deterministici, con conseguente simulazione
    dell'automa.  
    Dato un determinato input l'automa specifica se tale input appartiene o meno
    al linguaggio definito dall'espressione regolare utilizzata nella
    compilazione.  

Predicati:  

?-is_regexp(RE):  
    Determina se un'espressione RE è o meno un'espressione regolare.
    Scompone la RE in lista utilizzato il predicato Univ e controlla che
    l'espressione sia conforme alla
    sintassi specificata nel testo di consegna.

?-nfa_regexp_comp(FA_Id, RE):  
    Compila l'espressione regolare RE in un automa aggiungendo alla base di
    conoscenza degli elementi "nfa_delta", "nfa_initial" e "nfa_final" generati
    attraverso l'algoritmo di costruzione di Thompson.  
    Il predicato ha due casi base (atomic e compound) e vari casi ricorsivi che
    si occupano di costruire l'automa corrispondente ai vari simboli
    (STAR, PLUS, OR e SEQ).  
    In alcuni casi sono stati generati nuovi ID a partire dall'originale (FA_Id)
    per costruire sotto automi, poi uniti in un unico automa principale.  
    Per questo motivo sono stati scritti predicati ausiliari che facilitassero
    la sostituzione del nuovo ID generato, con quello originale
    (nello specifico RENAME).

?-nfa_clear() e nfa_clear(FA_Id):  
    Il primo rimuove tutti gli automi (ovvero le rispettive funzioni delta,,
    stati iniziali e finali) dalla base di conoscenza.  
    Il secondo si comporta in maniera analoga al primo, ma effettua
    l'eliminazione del singolo automa specificato da FA_Id.  

?-nfa_test(Fa_Id, Input):  
    Simula l'automa non deterministico specificato da "FA_Id" utilizzando come
    input "Input".  
    Chiama un predicato "accept" passando il nodo iniziale, l'input e l'Id dell'
    automa.  
    Il predicato accept funziona in maniera analoga agli esempi delle slide
    del corso.  

Altri predicati ausiliari:  

    nfa_list(L)/nfa_list(Fa_Id, L):  
      crea una lista contenente tutti gli elementi
      caratterizzanti un automa. E' utilizzato da nfa_clear e invoca dei sotto
      predicati che recuperano dalla base di conoscenza gli "nfa_delta",
      "nfa_final" e "nfa_initial" nello specifico.  

    rimuovi():  
      utilizzato da nfa_clear per effettuare il reatract degli elementi della
      lista.  

    appendi():  
      utilizzato da nfa_list per unire le varie liste contenenti "nfa_delta",
      nfa_Initial e nfa_final.  

    rename():  
      Predicato utilizzato da nfa_regexp_comp per rinominare i sottoautomi
      generati da Id fasulli.  

