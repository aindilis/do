:- use_module(do_convert,[generate_load_script/1,getShoppinglist/1,renderShoppinglist/0]).

print :-
	generate_load_script('/var/lib/myfrdcsa/codebases/internal/do/scripts/convert/data/results').

compile :-
	qcompile('/var/lib/myfrdcsa/codebases/internal/do/scripts/convert/prolog/generate-qlf-helper.pl').

load :-
	consult('/var/lib/myfrdcsa/codebases/internal/do/scripts/convert/prolog/generate-qlf-helper.qlf').
