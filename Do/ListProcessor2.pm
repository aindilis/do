package Do::ListProcessor2;

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
	TempEntryIDCounter Debug Quiet When Verbose /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyLight(Manager::Misc::Light->new());
  $self->TempEntryIDCounter(0);
  $self->Debug(1);
  $self->Quiet(1);
  $self->Verbose(0);
  $self->UniLangEntryIDs({});
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
      if (! $self->Debug) {
	$UNIVERSAL::agent->SendContents
	  (
	   Receiver => "KBS",
	   Contents => $contents,
	  );
      } else {
	print Dumper($contents) if $self->Verbose;
      }
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
  # foreach my $entryid (keys %$res) {
  # $self->UniLangEntryIDs->{$res->{$entryid}->{Contents}} = $entryid;
  # }
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
	  my %funcargs =
	    (
	     Receiver => "KBS2",
	     Data => {
		      Command => "assert",
		      Context => $self->Context,
		      Formula => $formula,
		     }
	    );
	  if (! $self->Debug) {
	    $UNIVERSAL::agent->SendContents
	      (%funcargs);
	  } else {
	    print Dumper(\%funcargs) if $self->Verbose;
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
  if (exists $self->UniLangEntryIDs->{$entry}) {
    $entryid = $self->UniLangEntryIDs->{$entry};
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
      $self->UniLangEntryIDs->{$entry} = $entryid;
      $self->TempEntryIDCounter($entryid + 1);
    }
  }
  if (defined $entryid) {
    my $formula = ["critic-unilang-classification",["unilang-entry", $entryid],"goal"];
    my %funcargs = 	(
			 Receiver => "KBS2",
			 Data => {
				  Command => "assert",
				  Context => $self->Context,
				  Formula => $formula,
				 },
			);
    if (! $self->Debug) {
      $UNIVERSAL::agent->SendContents
	(%funcargs);
    } else {
      print Dumper(\%funcargs) if $self->Verbose;
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
    print Dumper({Text => $text}) if $self->Verbose;
  }
}

sub ProcessDomainNew {
  my ($self,%args) = @_;
  my $last;
  my @list;
  my @lists;
  my @entryids;
  my @returndomain;
  my @assertions;
  my $myentryid;
  foreach my $entry (@{$args{Domain}}) {
    my $ref = ref $entry;
    if (defined $last and $last ne $ref) {
      if (scalar @list) {
	my $text = join(" ",@list);
	$myentryid = $self->Add
	  (Entry => $text);
	push @returndomain, $text;
	push @entryids, $myentryid;
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
      my $results = $self->ProcessDomainNew(Domain => $entry);
      push @returndomain, $results->{ReturnDomain};
      push @assertions, @{$results->{Assertions}};
      foreach my $entryid (@{$results->{EntryIDs}}) {
	# assert depends goal
	if (defined $myentryid) {
	  my $formula = ["depends", $myentryid, $entryid];
	  my %funcargs =
	    (
	     Receiver => "KBS2",
	     Data => {
		      Command => "assert",
		      Context => $self->Context,
		      Formula => $formula,
		     }
	    );
	  if (! $self->Debug) {
	    $UNIVERSAL::agent->SendContents
	      (%funcargs);
	  } else {
	    print Dumper(\%funcargs) if $self->Verbose;
	  }
	  if (! $self->Quiet) {
	    print Dumper(Formula => $formula) if $self->Verbose;
	  }
	}
      }
    }
    $last = $ref;
  }
  if (scalar @list) {
    my $text = join(" ",@list);
    push @returndomain, $text;
    push @entryids, $self->Add
      (Entry => $text);
    $self->ProcessText
      (Text => $text);
  }

  my $res2 = $self->ProcessReturnDomain
    (
     Assertions => \@assertions,
     ReturnDomain => \@returndomain,
    );

  return {
	  EntryIDs => \@entryids,
	  ReturnDomain => \@returndomain,
	  Assertions => $res2->{Assertions},
	 };
}

sub ProcessReturnDomain {
  my ($self,%args) = @_;
  my @assertion;
  if ($args{ReturnDomain}->[0] eq "because-of") {
    push @assertion, "because-of";
    # $self->Convert(Item => $args{ReturnDomain}->[1]);
    my $ref = ref $args{ReturnDomain}->[1];
    if ($ref eq "ARRAY") {
      foreach my $item (@{$args{ReturnDomain}->[1]}) {
	my $ref2 = ref $item;
	if ($ref2 eq "") {
	  my $id = $self->GetUniLangEntryID
	    (Entry => $item);
	  push @assertion, ["do-entry", $id, $item];
	} elsif ($ref2 eq "ARRAY") {
	  # chances are this is a
	  # process it for items to extract
	}
      }
    }
  }
  if (scalar @assertion) {
    push @{$args{Assertions}}, \@assertion;
  }
  return {
	  Assertions => $args{Assertions},
	 };
}

sub GetStrings {
  my ($self,%args) = @_;
  my $ds = $args{DataStructure};
  my @strings;
  my $ref = ref $ds;
  if ($ref eq "") {
    push @strings, $ds;
  } elsif ($ref eq "ARRAY") {
    foreach $item (@$ds) {
      my $res = $self->GetStrings
	(
	 DataStructure => $item,
	);
      if ($res->{Success}) {
	push @strings, @{$res->{Result}};
      }
    }
  } elsif ($ref eq "HASH") {
    foreach $key (%$ds) {
      my $res = $self->GetStrings
	(
	 DataStructure => $ds->{$key},
	);
      if ($res->{Success}) {
	push @strings, $key, @{$res->{Result}};
      }
    }
  }
  return {
	  Success => 1,
	  Result => \@strings,
	 };
}

1;
