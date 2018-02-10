%% :- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/free-life-planner/lib/util/util.pl').
%% :- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/universal-parser/languages/dcg/parseToDoListEntries.pl').

%% parseToDoListEntryHelper(Data,Parse) :-
%% 	Filename = '/tmp/parser.txt',
%% 	write_data_to_file(Data,Filename),
%% 	parseToDoListEntry(Filename,Parse),
%% 	view(Parse).

%% run :-
%% 	Tmp = '<REDACTED>',
%% 	parseToDoListEntryHelper(Tmp,Parse),
%% 	view(Parse).

%% run2 :-
%% 	Tmp = [
%%             '<REDACTED>'
%% 	       ],
%% 	findall([Sentence,Parse],(member(Sentence,Tmp),parseToDoListEntryHelper(Sentence,Parse)),Results),
%% 	view(Results).