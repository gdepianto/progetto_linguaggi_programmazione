# progetto_lp
Progetto di linguaggi di programmazione
PROLOG

Descrizione del progetto:
    Il progetto consiste in un compilatore di Regexp (Espressioni regolari) in automi a stati finiti Non deterministici, con conseguente       simulazione dell'automa.
    Dato un determinato input l'automa specifica se tale input appartiene o meno al linguaggio definito dall'espressione regolare               utilizzata per compilare l'automa.

Predicati:
?-is_regexp(RE):
    Determina se un'espressione RE è o meno un'espressione regolare.
    Scompone la RE in lista utilizzato il predicato Univ e controlla che l'espressione sia conforme alla
    sintassi specificata nel testo di consegna.

?-nfa_regexp_comp(FA_Id, RE):
    Compila l'espressione regolare RE in un automa aggiungendo alla base di conoscenza degli elementi 
    "nfa_delta" costruiti in base all'algoritmo di costruzione di Thompson.
    Il predicato ha due casi base (atomic e compound) e vari casi ricorsivi che si occupano di costruire l'automa corrispondente ai             vari simboli (STAR, PLUS, OR e SEQ).
    In alcuni casi sono stati generati nuovi ID a partire dall'originale (FA_Id) per costruire sotto automi, necessari per la costruione       dell'automa principale. Per questo motivo sono stati scritti predicati ausiliari che facilitassero la sostituzione del nuovo ID             generato, con quello originale (nello specifico RENAME).

?-nfa_clear() e nfa_clear(FA_Id):
    Il primo rimuove tutti gli automi (ovvero le rispettive funzioni delta) dalla base di conoscenza.
    
