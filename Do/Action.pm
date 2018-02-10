package Do::Action;

# This is a primitive state system

# Events  can  happen.  When  they  do,  they  are asserted  into  the
# knowledge base.

# Actions are simply assertions???

use Do::Cyc::NL;
use Manager::Dialog qw(QueryUser SubsetSelect);

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / CommonActions MyNL /

  ];

sub init {
  my ($self,%args) = @_;
  $self->CommonActions
    ({
     "(attend AndrewDougherty Bathroom)" => 1,
     "(attend AndrewDougherty Upstairs)" => 2,
     });
  $self->MyNL
    (Do::Cyc::NL->new);
  $self->MyNL->Load;
}

sub Execute {
  my ($self,%args) = @_;
  $self->ActionRequest;
}

sub RequestAction {
  my ($self,%args) = @_;
  # request an action to be taken, schedule the action if permissible,
  # and develop associated plans
  my @actions =
    SubsetSelect
      (Set => [
	       sort {$self->CommonActions->{$b} <=>
		       $self->CommonActions->{$a}}
	       keys %{$self->CommonActions}],
       Selection => {},
       Desc => $self->CommonActions);
  if (! @actions) {
    my @a = $self->BuildAction;
    push @actions, @a;
  }
  # take these actions and see if we can do them
  if (@actions) {
    print Dumper(\@actions);
  }
}

sub RecordAction {
  my ($self,%args) = @_;
  # action has already occured, record it, and update all states
  # accordingly
}

sub RetrievePossibleMeanings {
  my ($self,%args) = @_;
  my $searches = $args{Searches};
  # whatever we retrieve should satisfy all the meanings
  if (scalar @{$searches} == 1) {
    # iterate across and through cyc finding possible meanings
    # have to go to opencyc or whatever, for now just use the Do::Cyc::NL;
    return $self->MyNL->GetPossibleMeanings
      ($searches->[0]);
  } else {
    # ensure all meanings intersect
    my $set = {};
    foreach my $m1 (@$searches) {
      foreach my $m2
	(@{$self->RetrievePossibleMeanings
	     (Searches => [$m1])}) {
	  if (exists $set->{$m2}) {
	    $set->{$m2}++;
	  } else {
	    $set->{$m2} = 1;
	  }
	}
    }
    foreach my $k (keys %$set) {
      if (scalar @{$set->{$k}} == scalar @$searches) {
	push @ret, $k;
      }
    }
    return \@ret;
  }
}

sub BuildAction {
  my ($self,%args) = @_;
  my $a;

  # attempt to get the various parts of the entry
  $self->ProcessContents(Contents => $a);

  do {
    $a = QueryUser("Action: ");
  } while (! $self->WFF($a));
  push @actions, $a;
  return @actions;
}

sub WFF {
  my ($self,%args) = @_;
  return 1;
}

1;
