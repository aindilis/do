package Coach::Task;

use Coach::Task::Property;
use Manager::Dialog qw(SubsetSelect);

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Task Properties /

  ];

sub init {
  my ($self, %args) = @_;
  $self->Task($args{Task});
  $self->Properties($args{Properties} || {});
  if (! defined $UNIVERSAL::properties) {
    $UNIVERSAL::properties = ([
			       "I do not want to do this now",
			       "I plan to do this later",
			       "I don't feel like doing it now",
			       "It's unnecessary",
			       "It isn't as important as other things",
			       "I would like to do this immediately",
			       "This is absolutely essential",
			       "This needs to be done by a certain time",
			       "This cannot wait any longer",
			       "I'm not sure how important this is",
			       "I wish someone else would be able to do this",
			       "I'd like to pay someone to do this",
			       "I'm not sure there is enough time to do this",
			       "I don't think this will get done",
			       "I think the task is too complex",
			       "I do not think the task is worth the doing",
			       "I'd like to do this just as a change of pace",
			       "I'd like to do this, but other people are preventing me in some way from doing it",
			       "This task is too general",
			       "This task is necessary to another task",
			       "I would like to do this task if someone can help get me started",
			       "I would like to do this task if someone can explain it to me",
			       "I would like to do this task after I study about it",
			      ]);
  }
}

sub Comment {
  my ($self,$command) = @_;
  foreach my $p (SubsetSelect
		 (Set => $UNIVERSAL::properties,
		  Selection => $self->Properties)) {
    if (exists $self->Properties->{$p}) {
      delete $self->Properties->{$p};
    } else {
      $self->Properties->{$p} = Coach::Task::Property->new
	(Name => $p);
    }
  }
}

1;
