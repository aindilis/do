:- include('/var/lib/myfrdcsa/codebases/internal/do/scripts/convert/prolog/startup.pl').

:- load_all_prolog_files_in_directory('/var/lib/myfrdcsa/codebases/internal/do/scripts/convert/data/results').

save_do_convert :-
	qsave_program('/var/lib/myfrdcsa/codebases/internal/do/scripts/convert/data/do-convert.qsave').
	
