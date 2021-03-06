% Ciapponi Stefano 844811
% De Pianto Gioele 845002
%*******************************************************************************
% IS_REGEXP Caso base atomico
is_regexp(RE):- atomic(RE).
%caso base e passo or
is_regexp(RE):- RE=..[or, X, Y],!,
                is_regexp(X),
                is_regexp(Y).
is_regexp(RE):- RE=..[or, X | Xs],!,
                is_regexp(X),
                Z=..[or | Xs],
                is_regexp(Z).
%caso base e passo seq
is_regexp(RE):- RE=..[seq, X, Y],!,
                is_regexp(X),
                is_regexp(Y).
is_regexp(RE):- RE=..[seq, X | Xs],!,
                is_regexp(X),
                Z=..[seq | Xs],
                is_regexp(Z).
%caso base star
is_regexp(RE):- RE=..[star, X],!,
                is_regexp(X).
%caso base star
is_regexp(RE):- RE=..[plus, X],!,
                is_regexp(X).

%caso compound
is_regexp(RE):- compound(RE),not(is_list(RE)).

%NFA_REGEXP_COMP
%ATOMICO: scrive delta per un atomo
nfa_regexp_comp(FA_Id, RE):- nonvar(FA_Id),
                             atomic(RE), !,
                             gensym(q, X),
                             gensym(q, Y),
                             assert(nfa_initial(FA_Id, X)),
                             assert(nfa_final(FA_Id, Y)),
                             assert(nfa_delta(FA_Id, X, RE, Y)).
%STAR
%-Controlla che la RE sia star e lancia comp su i suoi argomenti
%-Genera un nuovo nodo iniziale e un nuovo nodo finale
%-Prende i nodi iniziali e finale dell automa precendetemente costruito
%-Agiunge alla base di conoscenza i delta con epsilon mosse
%-Rende i vecchi nodi inizialie  finali dei nodi semplici
%-Rende i nuovi nodi inizali e finali tali
nfa_regexp_comp(FA_Id, RE):- nonvar(FA_Id),
                             is_regexp(RE),
                             RE=.. [star, X],
                             nfa_regexp_comp(FA_Id, X),
                             gensym(q, In),
                             gensym(q, Fin),
                             nfa_initial(FA_Id, OldIn),
                             nfa_final(FA_Id, OldFin),
                             assert(nfa_delta(FA_Id, In, epsilon, OldIn)),
                             assert(nfa_delta(FA_Id, OldFin, epsilon, Fin)),
                             assert(nfa_delta(FA_Id, In, epsilon, Fin)),
                             assert(nfa_delta(FA_Id, OldFin, epsilon, OldIn)),
                             retract(nfa_initial(FA_Id, OldIn)),
                             retract(nfa_final(FA_Id, OldFin)),
                             assert(nfa_initial(FA_Id, In)),
                             assert(nfa_final(FA_Id, Fin)).
%SEQ
%Caso base:
%-Controlla che il predicato sia seq.
%-Genera due Id sostitutivi per compilare due sottoautomi separatamente.
%-Connette il nodo finale del primo sottoautoma a quello iniziale del secondo
% con una epsilon mossa.
%-Fa in modo che questi due nodi non siano più considerati iniziali e finali
%-Sostituisce l FA_Id originale ai due Id sostitutivi
nfa_regexp_comp(FA_Id, RE):-nonvar(FA_Id),
                            is_regexp(RE),
                            RE=.. [seq, X, Y],!,
                            gensym(FA_Id, NewId1),
                            gensym(FA_Id, NewId2),
                            nfa_regexp_comp(NewId1, X),
                            nfa_regexp_comp(NewId2, Y),
                            nfa_final(NewId1, Fin1),
                            nfa_initial(NewId2, In2),
                            assert(nfa_delta(FA_Id, Fin1, epsilon, In2)),
                            retract(nfa_final(NewId1, Fin1)),
                            retract(nfa_initial(NewId2, In2)),
                            nfa_list(NewId1,L1),
                            nfa_list(NewId2,L2),
                            rename(FA_Id,L1),
                            rename(FA_Id,L2).

%Passo:
%-Creo il sotto automa formato da seq(Xs), Xs sono tutti gli argomenti tranne il
% primo
%-Creo automa per il primo elemento utilizzando un Id nuovo
%-Collego il final del primo automa al restante
%-Rinomino il primo automa con l Id correto.
nfa_regexp_comp(FA_Id, RE):- nonvar(FA_Id),
                             is_regexp(RE),
                             RE=.. [seq, X | Xs],!,
                             SubRE=.. [seq | Xs],
                             nfa_regexp_comp(FA_Id, SubRE),
                             gensym(FA_Id, NewId),
                             nfa_regexp_comp(NewId, X),
                             nfa_final(NewId, OldFin1),
                             nfa_initial(FA_Id, OldIn2),
			                       assert(nfa_delta(FA_Id, OldFin1, epsilon, OldIn2)),
			                       retract(nfa_final(NewId, OldFin1)),
                             retract(nfa_initial(FA_Id, OldIn2)),
                             nfa_list(NewId,L),
                             rename(FA_Id,L).

%OR
%Caso base:
%-Crea due nuovi Id per i due casi
%-Crea due nuovi stati iniziali e finali fasulli
%-Genera i due sotto-automi
%-Collega i due dfa ai nuovi stati iniziali e finali
%-Elimina initial e final dei sotto alberi e rinomina i delta
nfa_regexp_comp(FA_Id, RE):- nonvar(FA_Id),
                             is_regexp(RE),
                             RE=.. [or, X, Y],!,
                             gensym(FA_Id, NewId1),
                             gensym(FA_Id, NewId2),
                             gensym(q, FinState),
                             gensym(q, InState),
                             nfa_regexp_comp(NewId1, X),
                             nfa_regexp_comp(NewId2, Y),
			     nfa_initial(NewId1, In1),
                             nfa_initial(NewId2, In2),
                             nfa_final(NewId1, Fin1),
                             nfa_final(NewId2, Fin2),
			     assert(nfa_delta(FA_Id, InState, epsilon, In1)),
                             assert(nfa_delta(FA_Id, InState, epsilon, In2)),
			     assert(nfa_delta(FA_Id, Fin1, epsilon, FinState)),
                             assert(nfa_delta(FA_Id, Fin2, epsilon, FinState)),
			     retract(nfa_initial(NewId1, In1)),
                             retract(nfa_initial(NewId2, In2)),
                             retract(nfa_final(NewId1, Fin1)),
                             retract(nfa_final(NewId2, Fin2)),
			     assert(nfa_initial(FA_Id, InState)),
                             assert(nfa_final(FA_Id, FinState)),
                             nfa_list(NewId1,L1),
                             nfa_list(NewId2,L2),
                             rename(FA_Id,L1),
                             rename(FA_Id,L2).

%Passo:
%-Creo il sotto automa formato da or(Xs), Xs sono tutti gli argomenti tranne il
% primo.
%-Genera un nuovo Id per il primo elemento.
%-Compila X col nuovo Id
%-Recupera i nodi iniziali e finali del primo elemento e del sotto automa or(Xs)
%-Collega l automa X all Automa Xs con epsilon mosse
%-Cancella nodi iniziali e finali del nuovo ID
%-Rinomina i delta dell automa X
nfa_regexp_comp(FA_Id, RE):- nonvar(FA_Id),
                             is_regexp(RE),
                             RE=.. [or, X | Xs],!,
                             SubRE=.. [or | Xs],
                             nfa_regexp_comp(FA_Id, SubRE),
                             gensym(FA_Id, NewId),
                             nfa_regexp_comp(NewId, X),
                             nfa_final(NewId, OldFin),
                             nfa_initial(NewId, OldIn),
                             nfa_final(FA_Id, NewFin),
                             nfa_initial(FA_Id, NewIn),
                             assert(nfa_delta(FA_Id, NewIn, epsilon, OldIn)),
                             assert(nfa_delta(FA_Id, OldFin, epsilon, NewFin)),
                             retract(nfa_final(NewId, OldFin)),
                             retract(nfa_initial(NewId, OldIn)),
                             nfa_list(NewId,L),
                             rename(FA_Id,L).

%PLUS
%Si può svolgere in due modi:
%1. Chiamando la compilazione di una nuova regexp: "seq(X, star(X)".
%2. In maniera simile allo star, ma con un delta in meno (commentato).
nfa_regexp_comp(FA_Id, RE):- nonvar(FA_Id),
                             is_regexp(RE),
                             RE=.. [plus, X],!,
                             nfa_regexp_comp(FA_Id, seq(X, star(X))).

%COMPOUND
nfa_regexp_comp(FA_Id, RE):- nonvar(FA_Id),
                             compound(RE),
                             gensym(q, X),
                             gensym(q, Y),
                             assert(nfa_initial(FA_Id, X)),
                             assert(nfa_final(FA_Id, Y)),
                             assert(nfa_delta(FA_Id, X, RE, Y)).

%RENAME
%Predicati per semplificare la rinominazione dei nodi
rename(_, []).
rename(NewId, [X | Xs]):- X =.. [T, _ | Ts],
                          Y =.. [T, NewId | Ts],
                          retract(X),
                          assert(Y),
                          rename(NewId, Xs).

%NFA_TEST
nfa_test(FA_Id, Input):- nfa_initial(FA_Id, S),
                         accept(FA_Id, Input, S).
%accept
accept(FA_Id, [], Q):- nfa_final(FA_Id, Q).

accept(FA_Id, Xs, Q):- nfa_delta(FA_Id, Q, epsilon, S),
                       accept(FA_Id, Xs, S).

accept(FA_Id, [X | Xs], Q):- nfa_delta(FA_Id, Q, X, S),
                             accept(FA_Id, Xs, S).
%NFA_LISTING
nfa_listing(FA_Id):- listing(nfa_initial(FA_Id, _)),
                     listing(nfa_final(FA_Id, _)),
                     listing(nfa_delta(FA_Id, _, _, _)).

nfa_list(FA_Id, L):- findall(X, nfa_list_deltas(FA_Id, X), L1),
                     findall(Y, nfa_list_final(FA_Id, Y), L2),
                     findall(Z, nfa_list_initial(FA_Id, Z), L3),
                     appendi(L1, L2, L4),
                     appendi(L3, L4, L).

nfa_list(L):- findall(X, nfa_list_deltas(X), L1),
              findall(Y, nfa_list_final(Y), L2),
              findall(Z, nfa_list_initial(Z), L3),
              appendi(L1, L2, L4),
              appendi(L3, L4, L).

nfa_list_deltas(FA_Id, X):- X =.. [nfa_delta, FA_Id, _, _, _], call(X).
nfa_list_final(FA_Id, X):- X =.. [nfa_final, FA_Id, _], call(X).
nfa_list_initial(FA_Id, X):- X =.. [nfa_initial, FA_Id, _], call(X).

nfa_list_deltas(X):- X =.. [nfa_delta, _, _, _, _], call(X).
nfa_list_final(X):- X =.. [nfa_final, _, _], call(X).
nfa_list_initial(X):- X =.. [nfa_initial, _, _], call(X).

%NFA_CLEAR

nfa_clear():- nfa_list(L), rimuovi(L).
nfa_clear(FA_Id):- nfa_list(FA_Id, L), rimuovi(L).

rimuovi([]).
rimuovi([X|Xs]):- retract(X), rimuovi(Xs).

%APPENDI
appendi([], X, X).
appendi([X | Xs], Ys, [X | Zs]):- appendi(Xs, Ys, Zs).
