package Do::ListProcessor1;

use BOSS::Config;
use KBS::Util;
use Manager::Dialog qw(SubsetSelect);
use Manager::Misc::Light;
use MyFRDCSA;
use PerlLib::UI;
use PerlLib::MySQL;

use Data::Dumper;
use Lingua::EN::Sentence qw(get_sentences);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Config MyLight Context MyMySQL UniLangEntryIDs
   TempEntryIDCounter Debug Quiet When /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyLight(Manager::Misc::Light->new());
  $self->TempEntryIDCounter(0);
  $self->Debug(1);
  $self->Quiet(1);
}

sub Index {
  my ($self,%args) = @_;
  $self->When($args{When});
  my $conf = $UNIVERSAL::do->Config->CLIConfig;
  my $context = exists $conf->{'-c'} ? $conf->{'-c'} : "default";
  $self->Context($context);
  if (exists $conf->{'-f'}) {
    my @files = @{$conf->{'-f'}};
    foreach my $f (@files) {
      my $c = `cat "$f"`;
      # print $c."\n";
      my $domain = $self->MyLight->Parse
	(Contents => $c);
      $self->ProcessDomain(Domain => $domain);
    }
  }
  if (exists $conf->{'--contents'}) {
    my $domain = $self->MyLight->Parse
      (Contents => $conf->{'--contents'});
    # print Dumper($domain);
    $self->ProcessDomain(Domain => $domain);
  }

  foreach my $assertion (@$assertions) {
    my @list;
    my @error;
    my $fail = 0;
    foreach my $arg (@$assertion) {
      if ($arg =~ /^\d+$/) {
	my $res = $myentryids->{$arg};
	if (! defined $res) {
	  push @error, $arg;
	  $fail = 1;
	}
	push @list, $res;
      } else {
	push @list, '"'.DumperQuote($arg).'"';
      }
    }
    if ($fail) {
      print "ERROR:\n".Dumper(\@error);
    } else {
      my $contents = "$context assert (".join(" ",@list).")";
      print "$contents\n";
      $UNIVERSAL::agent->SendContents
	(
	 Receiver => "KBS",
	 Contents => $contents,
	);
    }
  }
}

sub ProcessUniLangEntries {
  my ($self,%args) = @_;
  #   my $mysql = PerlLib::MySQL->new
  #     (
  #      DBName => "unilang",
  #      Debug => 1,
  #     );
  #   $self->MyMySQL($mysql);

  #   my $res = $mysql->Do
  #     (
  #      Statement => "select * from messages",
  #     );

  #   my $unilangentryids = {};
  #   foreach my $entryid (keys %$res) {
  #     $unilangentryids->{$res->{$entryid}->{Contents}} = $entryid;
  #   }
  #   $self->UniLangEntryIDs($unilangentryids);
}

sub ProcessDomain {
  my ($self,%args) = @_;
  my $last;
  my @list;
  my @lists;
  my @rets;
  my $myentryid;
  foreach my $entry (@{$args{Domain}}) {
    my $ref = ref $entry;
    if (defined $last and $last ne $ref) {
      if (scalar @list) {
	my $text = join(" ",@list);
	$myentryid = $self->Add
	  (Entry => $text);
	push @rets, $myentryid;
	$self->ProcessText
	  (Text => $text);
	@list = ();
      }
    }
    if ($ref eq "") {
      push @list, $entry;
    } elsif ($ref eq "ARRAY") {
      # check if there is
      # assert these as depended-on goals?
      foreach my $entryid ($self->ProcessDomain(Domain => $entry)) {
	# assert depends goal
	if (defined $myentryid) {
	  my $formula = ["depends", $myentryid, $entryid];
	  if (! $self->Debug) {
	    $UNIVERSAL::agent->SendContents
	      (
	       Receiver => "KBS2",
	       Data => {
			Command => "assert",
			Context => $self->Context,
			Formula => $formula,
		       });
	  }
	  if (! $self->Quiet) {
	    print Dumper(Formula => $formula);
	  }
	}
      }
    }
    $last = $ref;
  }
  if (scalar @list) {
    my $text = join(" ",@list);
    push @rets, $self->Add
      (Entry => $text);
    $self->ProcessText
      (Text => $text);
  }
  return @rets;
}

sub Add {
  my ($self,%args) = @_;
  my $entry = $args{Entry};
  my $entryid =
    $self->GetUniLangEntryID
      (Entry => $entry);
  if (! $self->Quiet) {
    print "UniLang, $entryid - $entry\n";
  }
  return $entryid;
}

sub GetUniLangEntryID {
  my ($self,%args) = @_;
  my $entry = $args{Entry};
  my $entryid;
  if (exists $unilangentryids->{$entry}) {
    $entryid = $unilangentryids->{$entry};
  } else {
    if (! $self->Debug) {
      my $message = $UNIVERSAL::agent->MyAgent->QueryAgent
	(
	 Receiver => "UniLang",
	 Contents => $entry,
	 Data => {
		  _GetEntryID => 1,
		  _DoNotAct => 1,
		 },
	);
      if (defined $message) {
	$entryid = $message->Data->{EntryID};
      }
    } else {
      $entryid = $self->TempEntryIDCounter;
      $unilangentryids->{$entry} = $entryid;
      $self->TempEntryIDCounter($entryid + 1);
    }
  }
  if (defined $entryid) {
    my $formula = ["critic-unilang-classification",["unilang-entry", $entryid],"goal"];
    if (! $self->Debug) {
      $UNIVERSAL::agent->SendContents
	(
	 Receiver => "KBS2",
	 Data => {
		  Command => "assert",
		  Context => $self->Context,
		  Formula => $formula,
		 },
	);
    }
    if (! $self->Quiet) {
      print Dumper({Formula => $formula});
    }
  }
  return $entryid;
}

sub ProcessText {
  my ($self,%args) = @_;
  my $text = $args{Text};
  if ($self->When) {
    my $sentences = get_sentences($text);
    foreach my $sentence (@$sentences) {
      if ($sentence =~ /\bwhen\b/i) {
	my $res = $UNIVERSAL::do->MyCorrelator->ProcessRule
	  (Text => $sentence);
	if ($res->{Success}) {
	  print Dumper({RES => $res});
	}
      }
    }
  } else {
    print Dumper({Text => $text});
  }
}

# related systems

# # Corpus

# we need to incorporate Verber and nl-to-pddl into this process

# Verber::PSEx, Verber

# PSE, suppos*, thinker, formalize, FRDCSAL, whatever is using
# Do::Misc::ListProcessor2, KBS2/Rules, agenda, ?critic?,
# ?SetantaAgent::Library::Util?, CHAP, ?XWN?

# we're going to want to have some functions here

sub InterpretItem {
  # okay, we're going to want to take a look at the context, and
  # especially the interlist relationships and how to govern them

  # locate the various stuff for making dependencies from sublist
  # relations, and also for making another relation that I forget what
  # it was now, think it was with the new Do::Misc::ListProcessor2
  # (because-of relation), also the When relation where needed, and
  # also custom stuff relating to do.el (i.e. the different types of
  # triggers)

  # should incorporate all suppositions for given item - allow user to
  # collapse these as needed. suppose suppose should also consider
  # what is said by various programs, don't know exactly how to fit
  # that in - maybe in formalize?

  # ProcessReturnDomain from ListProcessor2
}

sub AddAsGoal {
  # add as goal

  # try to develop a format that works with both UniLang entries, and
  # todo files, and also works with the old PSE and related stuff for asserting things about goals

  # corpus -a -u [<host> <port>]		Run as a UniLang agent classifying messages
  # corpus -s <search> -k [<context>]  -g?	Augment search results with all asserted knowledge

  # note this seems somewhat similar to Audience

  # maybe recognize goals according to the type of sentence, for
  # instance "get blah blah blah" is elliptical, and possibly
  # imperative

  # first, classify the item - is it a goal, or is it a statement of
  # something accomplished, etc.  Is it already marked completed, or
  # are there other informations from it.  Is it relevant to some
  # specific context, or a general assertion

  # classify the apparent importance of the item, it's urgency, its
  # relevance to various projects, etc.

  # classify if it belongs to list-of-lists or not

  # try to formalize the statement into an appropriate logic

  # add an item to the todo list (first, see what other functions are
  # already out there that essentially do the same thing)

  # okay, check whether it has already been added, i.e., if any
  # specific goal text already textually entails it, and or if the
  # entire goal context entails it...

  # if the goal is inconsistent, look into fault isolation to
  # determine why it is inconsistent with our goals.  also consider
  # paraconsistency

  # if the goal can be asserted, do so, then deal with record keeping
  # and logging

  # is it a when or because-of, etc?

}

sub Diff {
  # produce a difference of the information contained in a given todo
  # file and the information that should be contained in it
}

# handle .notes format as well

1;
