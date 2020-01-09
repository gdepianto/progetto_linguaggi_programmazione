Progetto di linguaggi di programmazione
Studenti:
Ciapponi Stefano 844811
De Pianto Gioele 845002
PROLOG

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
