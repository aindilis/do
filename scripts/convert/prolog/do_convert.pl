:- module(do_convert, [generate_load_script/1,getShoppinglist/1]).

:- consult('/var/lib/myfrdcsa/codebases/minor/do-convert/prolog/startup.pl').

directory_files_no_hidden(Dir,Files) :-
	directory_files(Dir,TmpFiles),
	findall(File,(member(File,TmpFiles),not(atom_concat('.',_,File))),Files).

sorted_directory_files(Dir,Files) :-
	directory_files(Dir,TmpFiles),
	sort(TmpFiles,Files).

sorted_directory_files_no_hidden(Dir,Files) :-
	directory_files_no_hidden(Dir,TmpFiles),
	sort(TmpFiles,Files).

generate_load_script(Dir) :-
	Extension = '.pl',
	sorted_directory_files_no_hidden(Dir,Files),
	member(File,Files),
	atom_concat(Thing,Extension,File),
	atomic_list_concat([Dir,'/',File],'',FullFileName),
	exists_file(FullFileName),
	write(':- consult(\''),write(FullFileName),write('\').'),nl,
	fail.
generate_load_script(Dir).
