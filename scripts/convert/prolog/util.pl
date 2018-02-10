:- use_module(library(occurs)).

%% findAllTermsInListingMatchingSubterm(M,Term,Matches) :-
%% 	findall(Result,(current_predicate(_,M:P),catch(clause(M:P,Result),_,true)),Z),
%% 	findall(Clause,(member(Clause,Z),occurs:sub_term(Term,Clause)),Matches).

%% findAllFactsInListingMatchingSubterm(Term,Matches) :-
%% 	findall(Result,(current_predicate(_,M:P),catch(clause(M:P,true),_,true)),Z),
%% 	findall(Clause,(member(Clause,Z),occurs:sub_term(Term,Clause)),Matches).

get_all_instances_of_predicate_with_n_args(Predicate,N,Results) :-
	findall(X,(current_predicate(_,M:P),\+ predicate_property(M:P,imported_from(_)),predicate_property(M:P, number_of_clauses(_)),clause(M:P,B),P =.. [Predicate|X],length(X,N),B = true),Results).

fixFunction(get_all_instances_of_subpredicate_with_n_args/2).

%% get_all_instances_of_subpredicate_with_n_args(Predicate,N,Matches) :-
%% 	getFullListing(Clauses),
%% 	%% findall(Clause,(member(Clause,Clauses),occurs:sub_var(Term,Clause),Term =.. [Predicate|_]),Matches).
%% 	%% findall(Term,(member(Clause,Clauses),occurs:sub_var(Term,Clause)),Matches).
%% 	findall(Clause,(member(Clause,Clauses)),Matches).

get_all_instances_of_subpredicate_with_n_args(Predicate,N,Matches) :-
	findall(C,(predicate_property(user:P,file(_)),clause(P,B,R),C = :-(P,B)),Clauses),
	findall(Term,(member(Clause,Clauses),occurs:sub_var(Term,Clause),Term =..[Predicate|_]),Matches).

%% get_all_instances_of_subpredicate_with_n_args(Predicate,N,Matches) :-
%% 	findall(C,(predicate_property(user:P,file(_)),clause(P,B,R),C = :-(P,B)),Clauses),
%% 	findall(Term,(member(Clause,Clauses),occurs:sub_term(Term,Clause))),Terms).

%% findall(A,(predicate_property(user:P,file(_)),clause(P,B,R),C = :-(P,B),occurs:sub_var(A,P)),Clauses).



%%%% START WORKING

%% get_all_subterms(Matches) :-
%% 	findall(C,(predicate_property(user:P,file(_)),clause(P,B,R),C = :-(P,B)),Clauses),
%% 	findall(Term,(member(Clause,Clauses),occurs:sub_term(Term,Clause)),Matches).

%% list :-
%% 	get_all_subterms(Matches),
%% 	member(Match,Matches),
%% 	nonvar(Match),
%% 	%% catch(Match =.. [P|B],true,true),
%% 	Match =.. [P|B],
%% 	P = shoppinglist,
%% 	see([P,B]),
%% 	fail.
%% list.

%%%% END WORKING

%% get_all_subterms(Matches) :-
%% 	findall(C,(predicate_property(user:P,file(_)),clause(P,B,R),C = :-(P,B)),Clauses),
%% 	findall(Term,(member(Clause,Clauses),occurs:sub_term(Term,Clause),nonvar(Term),Term =.. [shoppinglist|B]),Matches).

getShoppingList(Items) :-
	get_all_subterms_with_leading_predicate(shoppinglist,Matches),
	findall(Item,(member(Match,Matches),Match =.. [shoppinglist|List],member(Item,List)),Items).

renderShoppingList :-
	getShoppingList(List),
	write_list(List).