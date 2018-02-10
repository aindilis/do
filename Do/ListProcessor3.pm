package Do::ListProcessor3;

# OBJECTS

# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";

# put the whole thing in Sayer, to keep context

# DATA

# CONTROL

use PerlLib::ServerManager::UniLang::Client;

use BOSS::Config;
use Data::Dumper;
use Do::ListProcessor2;
use Formalize2::UniLang::Client;
use KBS2::Client;
use KBS2::ImportExport;
use LOL::Classifier;
use Manager::Dialog qw(SubsetSelect);
use PerlLib::SwissArmyKnife;
use Sayer;

use Tk;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Axioms Config Conf ImportExport MyListProcessor
	PSEEntryIDCounter PSEEntryIDs Res2 MySayer Specification
	UseFormalize UseSpeechAct UseClassifier MyFormalize
	MyClassifier MyClient Context ContinueLoop
	PerformManualClassification /

  ];

sub init {
  my ($self,%args) = @_;
  my $specification = q(
	-c <context>				Load into this context

	-l					Use LOL::Classifier
	-f					Use Formalize
	-s					Use SpeechActClassifier

	-m					Perform Manual Classification

	--files [<files>...]			Load the contents of these files
	--contents <contents> [<sourcefile>] 	Use this as the contents
);
  $self->Config
    (BOSS::Config->new
     (Spec => $specification));
  $self->Conf
    ($self->Config->CLIConfig);
  $self->UseClassifier
    ($self->Conf->{'-l'});
  $self->UseFormalize
    ($self->Conf->{'-f'});
  $self->UseSpeechAct
    ($self->Conf->{'-s'});
  $self->PerformManualClassification
    ($self->Conf->{'-m'} ||
     $args{PerformManualClassification});
  $self->MyListProcessor
    (Do::ListProcessor2->new
     ());
  $self->ImportExport
    (KBS2::ImportExport->new
     ());
  $self->MySayer
    (Sayer->new
     (
      DBName => "sayer_org_frdcsa_do",
     ));
  $self->SetContext
    (
     Context => $args{Context} || $self->Conf->{'-c'} || "Org::FRDCSA::Verber::PSEx2::Do",
     SkipComputingPSEEntryIDCounter => $args{SkipComputingPSEEntryIDCounter},
    );
  $self->Axioms([]);
}

sub SetContext {
  my ($self,%args) = @_;
  if (defined $self->Context and $self->Context eq $args{Context}) {
    return;
  }
  $self->Context
    ($args{Context});
  $self->MyClient
    (KBS2::Client->new
     (Context => $self->Context));
  $self->PSEEntryIDs({});
  if (! $args{SkipComputingPSEEntryIDCounter}) {
    $self->GetPSEEntryIDCounter();
  }
}

sub GetPSEEntryIDCounter {
  my ($self,%args) = @_;
  my $res = $self->MyClient->Send
    (
     Query => "(or (goal (entry-fn pse ?X)) (condition (entry-fn pse ?X)))",
     Context => $self->Context,
     QueryAgent => 1,
     InputType => "KIF String",
     ResultType => "object",
    );
  my $res2 = $res->MatchBindings
    (
     VariableName => "?X",
    );
  my $max = 0;
  foreach my $item (@$res2) {
    if ($item > $max) {
      $max = $item;
    }
  }
  $self->PSEEntryIDCounter
    ($max + 1);
  print Dumper
    ({
      # Res => $res,
      # Res2 => $res2,
      Context => $self->Context,
      PSEEntryIDCounter => $self->PSEEntryIDCounter,
     });
}

sub Execute {
  my ($self,%args) = @_;
  if ($self->UseClassifier) {
    $self->MyClassifier
      (LOL::Classifier->new);
    $self->MyClassifier->StartServer;
  }
  if ($self->UseSpeechAct) {
    $speechactclassification = PerlLib::ServerManager::UniLang::Client->new
      (
       AgentName => "Org-FRDCSA-Capability-SpeechActClassification",
      );
    $speechactclassification->StartServer
      ();
  }
  if ($self->UseFormalize) {
    $self->MyFormalize
      (Formalize2::UniLang::Client->new
       ());
  }
  my @files;
  if ($args{Files}) {
    push @files, @{$args{Files}};
  }
  if (exists $self->Conf->{'--files'}) {
    push @files, @{$self->Conf->{'--files'}};
  }
  if (scalar @files) {
    foreach my $file (@files) {
      next unless -f $file;

      # see if this is encrypted, if it is, get the encryption key from
      # Audience, or what not
      my $signature = undef;

      my $c = read_file($file);
      push @contents, {
		       Contents => $c,
		       File => $file,
		      };
    }
  }
  if (exists $self->Conf->{'--contents'}) {
    push @contents, {
		     Contents => $self->Conf->{'--contents'}->{'<contents>'},
		     File => $self->Conf->{'--contents-file'}->{'<source-file>'} || "supplied-from-contents",
		    };
  }
  foreach my $entry (@contents) {
    my $c = $entry->{Contents};
    my $file = $entry->{File};
    my $domain = $self->MyListProcessor->MyLight->Parse
      (Contents => $c);
    my $res1 = $self->MyListProcessor->ProcessDomainNew
      (Domain => $domain);
    my $returndomain = $res1->{ReturnDomain};

    # add statements for each extracted unit
    $self->GenerateStatementsAbout
      (
       Domain => $returndomain,
       File => $file,
       Signature => $signature,
      );
  }

  $self->PrintAxioms;
  $self->AssertAxioms
    (
     AssertWithoutCheckingConsistency => 1,
    );
}

sub PrintAxioms {
  my ($self,%args) = @_;
  my $res2 = $self->ImportExport->Convert
    (
     Input => $self->Axioms,
     InputType => "Interlingua",
     OutputType => "Emacs String",
    );
  if ($res2->{Success}) {
    print $res2->{Output}."\n";
  } else {
    print Dumper($res2);
  }
}

sub AssertAxioms {
  my ($self,%args) = @_;
  # now assert these
  print Dumper($self->Axioms);
  foreach my $axiom (@{$self->Axioms}) {
    my %sendargs =
      (
       Assert => [$axiom],
       Context => $self->Context,
       QueryAgent => 1,
       InputType => "Interlingua",
       Flags => {
		 AssertWithoutCheckingConsistency => $args{AssertWithoutCheckingConsistency},
		},
      );
    print Dumper(\%sendargs);
    my $res3 = $self->MyClient->Send(%sendargs);
  }
  $self->Axioms([]);
}

sub GenerateStatementsAbout {
  my ($self,%args) = @_;
  # have context assertions, so that we can always refer back...
  my $domain = $args{Domain};
  my $dumper = Dumper([$domain]);

  if (! exists $self->MySayer->IData->{$dumper}) {
    $self->MySayer->AddData(Data => [$domain]);
    if ($self->UseClassifier) {
      my $classification = "unknown";
      my $res = $self->MyClassifier->Classify(Text => $dumper);

      my $classification = [sort {$res->{$b} <=> $res->{$a}} keys %$res]->[0];
      $classification =~ s/^.+\///;
      $classification =~ s/\.txt$//;
      # add the assertions to the axioms
      $self->AddAxioms
	(
	 Axioms => [
		    ["has-classification", ["entry-fn", "sayer-index", $self->SayerIndex(Data => [$domain])], $classification],
		   ],
	);
    }
  }
  if ($args{File}) {
    $self->AddAxioms
      (
       Axioms => [
		  ["has-parent-file", ["entry-fn", "sayer-index", $self->SayerIndex(Data => [$domain])], $args{File}],
		 ],
      );
  }
  if ($args{Parent}) {
    $self->AddAxioms
      (
       Axioms => [
		  ["has-parent", ["entry-fn", "sayer-index", $self->SayerIndex(Data => [$domain])], ["entry-fn", "sayer-index", $args{Parent}]],
		 ],
      );
    my $res = $self->DecideRelationship
      (
       Child => $self->SayerIndex(Data => [$domain]),
       Parent => $args{Parent},
      );
  }
  my $ref = ref $args{Domain};
  if ($ref eq "ARRAY") {
    # now go ahead and add all the sublists
    foreach my $subdomain (@{$args{Domain}}) {
      $self->GenerateStatementsAbout
	(
	 Domain => $subdomain,
	 Parent => $self->SayerIndex(Data => [$domain]),
	);
    }
  } elsif ($ref eq "") {
    print Dumper(Huh => $args{Type});
    my $res2 = $self->AddEntry
      (
       Type => $args{Type},
       Entry => $args{Domain},
       Parent => $self->SayerIndex(Data => [$domain]),
       Signature => $args{Signature},
      );
    if (exists $args{ReturnEntries}) {
      my @axioms = @{$self->Axioms};
      print Dumper({Axioms => $self->Axioms});
      $self->Axioms([]);
      my @functions;
      foreach my $entry (@$res2) {
	push @functions, sub {
	  $args{Self}->AddEntryPart2
	    (
	     Type => $entry->{Type},
	     Source => $entry->{Source},
	     EntryID => $entry->{EntryID},
	     Description => $entry->{Description},
	     Render => $args{Render},
	    );
	};
      }
      # clear the axioms
      return {
	      Success => 1,
	      Entries => [
			  {
			   Assertions => \@axioms,
			   Functions => \@functions,
			  },
			 ],
	     };
    }
  }
}

sub AddEntry {
  my ($self,%args) = @_;
  # use the Goal Extractor based perhaps at least partially on the
  # Speech Act Classifier to extract goals and add these to the system

  # go ahead and extract the goals

  # I thought I saw something to this effect, just search for whatever
  # uses

  my $entry = $args{Entry};
  my $parent = $args{Parent};
  my $sayerindexid = $args{SayerIndexID};
  my $signature = $args{Signature};

  # extract the list of entries
  my $res = $self->ExtractPSEEntries
    (
     Entry => $entry,
    );

  if ($res->{Success}) {
    my @entries;
    foreach my $extractedentry (@{$res->{Results}}) {
      my $pseentry = $extractedentry->{PSEEntry};
      my $pseentryid = $extractedentry->{PSEEntryID};
      push @entries, {
		      Type => $args{Type},
		      EntryID => $pseentryid,
		      Description => $pseentry,
		      Source => "pse",
		     };
      if ($parent) {
	$self->AddAxioms
	  (
	   Axioms => [
		      ["has-source", ["entry-fn", "pse", $pseentryid], ["entry-fn", "sayer-index", $parent]],
		     ],
	  );
      }
      # then use the system I designed that is currently on the laptop
      if (! defined $args{Type}) {
	die "Type not defined!\n";
      }
      my $toadd = [
		   [$args{Type}, ["entry-fn", "pse", $pseentryid]],
		   ["asserter", ["entry-fn", "pse", $pseentryid], $args{Asserter} || "unknown"],
		   ["has-NL", ["entry-fn", "pse", $pseentryid], $entry],
		  ];
      $self->AddAxioms
	(
	 Axioms => $toadd,
	);

      if (defined $signature) {
	$self->AddAxioms
	  (
	   Axioms => [
		      ["has-signature", ["entry-fn", "pse", $pseentryid], $signature],
		     ],
	  );
      }
      if ($self->UseFormalize) {
	my $formalization = $self->MyFormalize->FormalizeText
	  (
	   Text => $pseentry,
	  );
	# print Dumper($formalization);
	if ($formalization->{Success}) {
	  # have to unify all items, just do it in a silly way for now
	  my @formalization;
	  foreach my $entry (@{$formalization->{Results}}) {
	    if ($entry->{Success}) {
	      # add to the whome thing the Output
	      foreach my $entry2 (@{$entry->{Output}}) {
		# add this
		shift @$entry2;
		push @formalization, @$entry2;
	      }
	    }
	  }
	  unshift @formalization, "formalization";
	  # unshift @formalization, "and";
	  $self->AddAxioms
	    (
	     Axioms => [
			["has-formalization",
			 ["entry-fn", "pse", $pseentryid],
			 ["software-version-fn", "formalize", "2.00"],
			 # ["quote", \@formalization],
			 \@formalization,
			],
		       ],
	    );
	}
      }
    }
    return \@entries;
  }
}

sub AddAxioms {
  my ($self,%args) = @_;
  # look into the relation ontology (ignore this for now)
  # extract out everything
  push @{$self->Axioms}, @{$args{Axioms}};
}

sub ExtractPSEEntries {
  my ($self,%args) = @_;
  my @results;
  if ($self->UseSpeechAct) {
    my $res = $speechactclassification->GetSpeechActs
      (Text => $args{Entry});
    print Dumper
      ({
	Entry => $args{Entry},
	SpAct => $res,
       }) if 0;
    if ($res->{Success}) {
      foreach my $entry (@{$res->{Result}}) {
	my $pseentry = $entry->{Item};
	if (! exists $self->PSEEntryIDs->{$pseentry}) {
	  $self->PSEEntryIDs->{$pseentry} = $self->PSEEntryIDCounter;
	  $self->PSEEntryIDCounter($self->PSEEntryIDCounter + 1);
	}
	push @results,
	  {
	   PSEEntry => $pseentry,
	   PSEEntryID => $self->PSEEntryIDs->{$pseentry},
	   # deal with Type and Mode later on
	  };
      }
    }
  } else {
    my $pseentry = $args{Entry};
    # if (! exists $self->PSEEntryIDs->{$pseentry}) {
      $self->PSEEntryIDs->{$pseentry} = $self->PSEEntryIDCounter;
      $self->PSEEntryIDCounter($self->PSEEntryIDCounter + 1);
      if ($self->UseClassifier) {
	my $classification = "unknown";
	my $res = $self->MyClassifier->Classify(Item => $pseentry);
	print Dumper($res);
	# add the assertions to the axioms
	$self->AddAxioms
	  (
	   Axioms => [
		      ["has-classification", ["entry-fn", "pse", $self->PSEEntryIDs->{$pseentry}], $classification],
		     ],
	  );
      }
    # }
    push @results,
      {
       PSEEntry => $pseentry,
       PSEEntryID => $self->PSEEntryIDs->{$pseentry},
      };
  }
  return {
	  Success => 1,
	  Results => \@results,
	 };
}

sub DecideRelationship {
  my ($self,%args) = @_;
  my $childcontent = Dumper
    ($self->MySayer->GetDataFromID
     (DataID => $args{Child}));
  my $parentcontent = Dumper
    ($self->MySayer->GetDataFromID
      (DataID => $args{Parent}));
  if ($self->PerformManualClassification) {
    if (! defined $UNIVERSAL::managerdialogtkwindow) {
      $UNIVERSAL::managerdialogtkwindow = MainWindow->new
	(
	 -title => "Do ListProcessor3",
	);
      $UNIVERSAL::managerdialogtkwindow->withdraw();
    }
    my @responses = $self->ListProcessorSubsetSelect
      (
       Title => "Classify Relationship",
       ParentContent => $parentcontent,
       ChildContent => $childcontent,
       Set => [
	       "Other",
	       "precondition-for",
	       "precondition-of",
	       "eases",
	      ],
       Selection => {},
      );
    my $other = 0;
    foreach my $response (@responses) {
      if ($response eq "Other") {
	$other = 1;
	last;
      }
    }
    if ($other) {
      my $result = QueryUser("What is the new \"relationship\" category?");
      push @responses, $result;
    }
    if (scalar @responses) {
      # we probably want to store this adjudication, also, use it to
      # train relationship classifying in the future
      foreach my $relationship (@responses) {
	if ($relationship eq "depends") {
	  $self->AddAxioms
	    (
	     Axioms => [
			# ["precondition-for", ["entry-fn", "pse", $parentid], ["entry-fn", "pse", $pseentryid]],
		       ],
	    );
	}
      }
    }
  }
}

sub SayerIndex {
  my ($self,%args) = @_;
  return $self->MySayer->AddData
    (Data => $args{Data});
}

sub ListProcessorSubsetSelect {
  my ($self,%args) = (@_);
  my $title = $args{Title} || undef;
  my $top1 = $UNIVERSAL::managerdialogtkwindow->Toplevel
    (
     -title => $title,
    );
  my $topframe = $top1->Frame();

  my $label1 = $topframe->Label(-text => "Child")->pack();;
  my $text1 = $topframe->Text
    (
     -width => 80,
     -height => 10,
    );
  $text1->Contents($args{ChildContent});
  $text1->configure(-state => "disabled");
  $text1->pack();

  my $label2 = $topframe->Label(-text => "Parent")->pack();;
  my $text2 = $topframe->Text
    (
     -width => 80,
     -height => 10,
    );
  $text2->Contents($args{ParentContent});
  $text2->configure(-state => "disabled");
  $text2->pack();

  my $ourresults;
  my @availableargs =
    (
     "Desc",
     "MenuOffset",
     "NoAllowWrap",
     "Processor",
     "Prompt",
     "Selection",
     "Set",
     "Type",
    );

  my $selectionframe = $topframe->Scrolled
    ('Frame',
     -scrollbars => 'e',
    )->pack
      (
       -expand => 1,
       -fill => "both",
      );
  foreach my $item (@{$args{Set}}) {
    my $button = $selectionframe->Checkbutton
      (
       -text => $item,
      );
    $button->pack(-side => "top", -expand => 1, -fill => "both");
    if (exists $args{Selection}->{$item}) {
      $button->{Value} = 1;
    }
  }
  $selectionframe->pack(-side => "top", -expand => 1, -fill => "both");

  my $buttonframe = $topframe->Frame;
  $buttonframe->Button
    (
     -text => "Select",
     -command => sub {
       my @results;
       foreach my $child ($selectionframe->children) {
	 print Dumper([keys %$child]);
	 if (defined $child->{'Value'} and $child->{'Value'}) {
	   push @results, $child->cget('-text');
	 }
       }
       $self->ContinueLoop(0);
       $ourresults = \@results;
     },
    )->pack(-side => "right");
  $buttonframe->Button
    (
     -text => "Cancel",
     -command => sub { $top1->destroy(); },
    )->pack(-side => "right");
  $buttonframe->pack(-side => "bottom");
  $topframe->pack(-fill => "both", -expand => 1);

  $self->MyMainLoop();
  $top1->destroy();
  DoOneEvent(0);
  return @$ourresults;
}

sub MyMainLoop {
  my ($self,%args) = (@_);
  unless ($inMainLoop) {
    local $inMainLoop = 1;
    $self->ContinueLoop(1);
    while ($self->ContinueLoop) {
      DoOneEvent(0);
    }
  }
}

1;
