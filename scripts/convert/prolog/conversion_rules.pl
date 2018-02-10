task(newTask1,X,critical) :-
	completed(X) ;
	deleted(X) ;
	depends(X,_) ;
	depends(_,X) ;
	postponed(X).

getSchedule(Results) :-
	findall([Date,Tasks],getTasks(Date,Tasks),Results).

getAggregatedSchedule(Result) :-
	setof(Date,Tasks^(getSchedule(Results),member([Date,Tasks],Results)),Aggregated),
	member(Date2,Aggregated),
	findall(Tasks,getTasks(Date2,Tasks),TaskLists),
	Result = [Date2,TaskLists].

genSched(Date,AllTasks) :-
	getAggregatedSchedule([Date,TaskLists]),
	findall(Task,(member(Tasks,TaskLists),member(Task,Tasks)),Tasks),
	getHabitual(daily,DailyTasks),
	append(Tasks,DailyTasks,AllTasks).

renderSchedule :-
	write('('),nl,
	findall([Date,Tasks],genSched(Date,Tasks),Schedule),
	member([Date,Tasks],Schedule),
	write('('),write(Date),nl,
	renderTasks(Tasks),
	fail.
renderSchedule :-
	write(')'),nl.
	
renderTasks(Tasks) :-
	member(Task,Tasks),
	tab(4),write('('),write(Task),write(')'),nl,
	fail.
renderTasks(Tasks) :-
	tab(3),write(')'),nl.
	
getTasks(Parse,Tasks) :-
	get_all_instances_of_predicate_with_n_args(schedule,N,Results),
	member(Args1,Results),
	member(SubTerm,Args1),
	SubTerm =.. [Pred|Tasks],
	parseDoDate(Pred,Parse).
getTasks(Parse,Tasks) :-
	get_all_instances_of_predicate_with_n_args('COMPLETED SCHEDULE',N,Results),
	member(Args1,Results),
	member(SubTerm,Args1),
	SubTerm =.. [Pred|Tasks],
	parseDoDate(Pred,Parse).

month(jan,1,31).
month(feb,2,29).
month(mar,3,31).
month(apr,4,30).
month(may,5,31).
month(jun,6,30).
month(jul,7,31).
month(aug,8,31).
month(sep,9,30).
month(oct,10,31).
month(nov,11,30).
month(dec,12,31).

number_addendum(1,'st').
number_addendum(2,'nd').
number_addendum(3,'rd').
number_addendum(4,'th').
number_addendum(5,'th').
number_addendum(6,'th').
number_addendum(7,'th').
number_addendum(8,'th').
number_addendum(9,'th').
number_addendum(10,'th').
number_addendum(11,'th').
number_addendum(12,'th').
number_addendum(12,'th').
number_addendum(13,'th').
number_addendum(14,'th').
number_addendum(15,'th').
number_addendum(16,'th').
number_addendum(17,'th').
number_addendum(18,'th').
number_addendum(19,'th').
number_addendum(20,'th').
number_addendum(21,'st').
number_addendum(22,'nd').
number_addendum(23,'rd').
number_addendum(24,'th').
number_addendum(25,'th').
number_addendum(26,'th').
number_addendum(27,'th').
number_addendum(28,'th').
number_addendum(29,'th').
number_addendum(30,'th').
number_addendum(31,'st').

long_to_short_day_of_month(L,S) :-
	number_addendum(S,Ext),
	atomic_list_concat([S,Ext],'',L).

parseDoDate(Atom,Parse) :-
	atomic_list_concat([DayOfWeek,Month,Tmp],' ',Atom),
	(atom_number(Tmp,DayOfMonth) ->
	 true ;
	 long_to_short_day_of_month(Tmp,DayOfMonth)),
	member(DayOfWeek,[mon,tue,wed,thu,fri,sat,sun]),
	member(Month,[jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec]),
	number(DayOfMonth),
	DayOfMonth >= 1,
	month(Month,MonthOfYear,Days),
	DayOfMonth =< Days,
	Parse = [2017-MonthOfYear-DayOfMonth,12:0:0].

parseDoDate(Atom,Parse) :-
	atomic_list_concat([DayOfWeek,Tmp],' ',Atom),
	(atom_number(Tmp,DayOfMonth) ->
	 true ;
	 long_to_short_day_of_month(Tmp,DayOfMonth)),
	member(DayOfWeek,[mon,tue,wed,thu,fri,sat,sun]),
	Month = jan, %% this should be to get the current month
	number(DayOfMonth),
	DayOfMonth >= 1,
	month(Month,MonthOfYear,Days),
	DayOfMonth =< Days,
	Parse = [2017-MonthOfYear-DayOfMonth,12:0:0].

parseDoDate(eventually,Parse) :-
	false.

%% need to add stuff that if we parse out a schedule date, and on that
%% date it says postponed(X), that we promote that to the next day, or
%% look to see if there is some deferment (completed, deleted, etc) of
%% it at a later date, and if so, whether it is not recurrent,
%% habitual, etc, and deal accordingly. %%

%% need to take in the date of the file.  also the git history of the
%% file if one can be found. %%

predicatesStillNeedingToParse([
			       communications/1
			      ]).

getHabitual(Type,Output) :-
	get_all_instances_of_predicate_with_n_args(habitual,N,Results),
	findall(Tmp,(member(Result,Results),member(Item,Result),processItem(Item,Type,Tmp)),Tmp1),
	findall(Tmp2,member(Tmp2,Tmp1),[Output]).

processItem(Item,Type,Output) :-
	Item =.. [Type|Output].

%% we need to retrieve the schedule, from
%% generateScheduleForDate(Date,Schedule)

%% get_all_instances_of_predicate_with_n_args('completed schedule',N,Results),see(Results).

%% need to formalize (sequester( to)? X Y).

%% getShoppingList(ShoppingList) :-
%% 	sub_var(Term,)