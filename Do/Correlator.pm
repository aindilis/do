package Do::Correlator;

use KBS2::Client;
use KBS2::ImportExport;
use KBS2::Util;
use Manager::Dialog qw(QueryUser);
use MyFRDCSA;

use Data::Dumper;
use File::Slurp;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / RuleNumber Context MyImportExport MyClient Samples InstantiateID /

  ];

sub init {
  my ($self,%args) = @_;
  $self->RuleNumber(1);
  $self->Context("Rule Knowledge");
  # $self->MyImportExport
  # (KBS2::ImportExport->new());
  $self->MyClient
    (KBS2::Client->new);
  $self->MyClient->ClearContext
    (
     Context => $self->Context,
    );
  $self->InstantiateID(1);
}

sub CompileRules {
  my ($self,%args) = @_;
  foreach my $entry (@{$self->Samples}) {
    foreach my $ruletext (@{$entry->{Rules}}) {
      $self->ProcessRule
	(Text => $ruletext);
    }
  }
}

sub ProcessRule {
  my ($self,%args) = @_;
  my $message = $UNIVERSAL::agent->QueryAgent
    (
     Receiver => "Formalize2",
     Data => {
	      Command => "formalize",
	      Text => $args{Text},
	     },
    );
  print Dumper({Message => $message});
  if ($message->Data->{Results}->{Success}) {
    # convert it to a more readable format
    my $interlingua = $message->Data->{Results}->{Results}->[0]->{Output};
    # now attempt to fix things, converting the "when (e2, e1)" to the
    # thing below
    # here we go
    my @copy;
    my @body;
    foreach my $item (@{$interlingua->[0]}) {
      if (ref $item eq "ARRAY") {
	if ($item->[0] =~ /^when\b/i) {
	  # this is a when, extract the arguments
	  @copy = @$item;
	  shift @copy;
	} else {
	  push @body, $item;
	}
      }
    }
    if (scalar @copy == 2) {
      my @whenforms;
      # now we have to find these components and split them
      foreach my $arg (@copy) {
	my @forms;
	my $seen = {};
	my $seenitem = {};
	my @queue = ($arg);
	# now find the item
	while (@queue) {
	  my $searchterm = shift @queue;
	  if (exists $seen->{$searchterm}) {
	    next;
	  } else {
	    $seen->{$searchterm} = 1;
	  }
	  foreach my $item (@body) {
	    my @copy2 = @$item;
	    shift @copy2;
	    my @potentialqueue;
	    my $addpotential = 0;
	    foreach my $arg (@copy2) {
	      if (Dumper($arg) eq Dumper($searchterm)) {
		$addpotential = 1;
	      } else {
		push @potentialqueue, $arg;
	      }
	    }
	    if ($addpotential) {
	      push @queue, @potentialqueue;
	      if (! exists $seenitem->{Dumper($item)}) {
		push @forms, $item;
		$seenitem->{Dumper($item)} = 1;
	      }
	    }
	  }
	}

	# now these forms should be the ones
	push @whenforms, \@forms;
      }
      my $formula = [
		     "=>",
		     [
		      "and",
		      @{$whenforms[1]},
		     ],
		     [
		      "activated-rule",
		      "rule-".$self->RuleNumber,
		     ],
		    ];
      $self->RuleNumber($self->RuleNumber + 1);
      # now assert this rule into the KB
      my $res4 = $self->MyClient->Send
	(
	 QueryAgent => 1,
	 Assert => [$formula],
	 InputType => "Interlingua",
	 Context => $self->Context,
	);
      return {
	      Success => 1,
	      Result => $res4,
	     };
    } else {
      return {
	      Success => 0,
	      Reasons => {
			  "Wrong number of args to WHEN" => 1,
			 },
	     };
    }
  }
}

sub ProcessConditions {
  my ($self,%args) = @_;
  foreach my $entry (@{$self->Samples}) {
    foreach my $condition (@{$entry->{Conditions}}) {
      $self->ProcessCondition
	(
	 Text => $condition->{Text},
	 Effects => $condition->{Effects},
	);
    }
  }
  return {
	  Success => 1,
	 };
}

sub ProcessCondition {
  my ($self,%args) = @_;
  my $message = $UNIVERSAL::agent->QueryAgent
    (
     Receiver => "Formalize2",
     Data => {
	      Command => "formalize",
	      Text => $args{Text},
	     },
    );
  if ($message->Data->{Results}->{Success}) {
    my $interlingua = $message->Data->{Results}->{Results}->[0]->{Output};
    # now instantiate variables
    my $res = $self->InstantiateVariables
      (
       Mapping => {},
       Interlingua => $interlingua,
      );
    if ($res->{Success}) {
      # now assert this to the KB
      my $res4 = $self->MyClient->Send
	(
	 QueryAgent => 1,
	 Assert => $res->{Result},
	 InputType => "Interlingua",
	 Context => $self->Context,
	);
      print Dumper($res4);
      return {
	      Success => 1,
	      Result => $res4,
	     };
    }
  }
  return {
	  Success => 0,
	 };
}

sub InstantiateVariables {
  my ($self,%args) = @_;
  my @res;
  foreach my $arg (@{$args{Interlingua}}) {
    my $ref = ref $arg;
    if ($ref eq "GLOB") {
      my $item = TermIsVariable($arg);
      $item =~ s/\?//g;
      if (! exists $args{Mapping}->{$item}) {
	$args{Mapping}->{$item} = "instance-".$item."-".$self->InstantiateID;
	$self->InstantiateID($self->InstantiateID + 1);
      }
      push @res, $args{Mapping}->{$item};
    } elsif ($ref eq "ARRAY") {
      my $res = $self->InstantiateVariables
	(
	 Interlingua => $arg,
	 Mapping => $args{Mapping},
	);
      if ($res->{Success}) {
	push @res, $res->{Result};
      }
    } else {
      push @res, $arg;
    }
  }
  return {
	  Success => 1,
	  Result => \@res,
	  };
}

sub CheckForActivatedRules {
  my ($self,%args) = @_;
  my $message = $self->MyClient->Send
    (
     QueryAgent => 1,
     Query => [["activated-rule", \*{'::?x1'}]],
     InputType => "Interlingua",
     Context => $self->Context,
    );
  print Dumper($message);
  # okay, now retrieve the conditions and effects of the activated
  # rule, convert to English and print

}

sub DoTest {
  my ($self,%args) = @_;
  my $conf = $UNIVERSAL::do->Config->CLIConfig;
  my $c = read_file(ConcatDir($UNIVERSAL::systemdir,"data","sample-correlations.pl"));
  eval $c;
  $self->Samples($samples);
  $self->CompileRules();
  $self->ProcessConditions();
  $self->CheckForActivatedRules();
}

sub Interactive {
  my ($self,%args) = @_;
  while (($input = QueryUser("Input: ")) !~ /(exit|quit)$/) {
    print Dumper({Input => $input});
    my $res;
    if ($input =~ /\bwhen\b/i) {
      $res = $self->ProcessRule(Text => $input);
    } else {
      $res = $self->ProcessCondition(Text => $input);
    }
    if ($res->{Success}) {
      $self->CheckForActivatedRules();
    } else {
      print Dumper($res);
    }
  }
}

1;
