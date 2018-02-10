package Do::ListProcessor4;

use BOSS::Config;
use Data::Dumper;
use Capability::TextAnalysis;
use Do::ListProcessor2;
use Do::ListProcessor4::GUI;
use Do::ListProcessor4::Relationship;
use Formalize2::UniLang::Client;
use KBS2::Client;
use KBS2::ImportExport;
use KBS2::Util;
use LOL::Classifier;
use Manager::Dialog qw(SubsetSelect);
use PerlLib::Collection;
use PerlLib::ServerManager::UniLang::Client;
use PerlLib::SwissArmyKnife;
use Sayer;

use Tk;

use Error qw(:try);

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Axioms Config Conf ImportExport MyListProcessor
	PSEEntryIDCounter PSEEntryIDs Res2 MySayer Specification
	UseFormalize UseSpeechAct UseClassifier MyFormalize
	MyClassifier MyClient Context PerformManualClassification
	MyGUI Relationships CurrentRelationshipID DontQuit
	SpeechActClassification AssertionTemplateCollection
	ActuallyAssert /

  ];

sub init {
  my ($self,%args) = @_;
  my $specification = q(
	-c <context>				Load into this context

	-a					Actually assert axioms

	--all					Use all text analysis tools
	-l					Use LOL::Classifier
	--formalize				Use Formalize
	-s					Use SpeechActClassifier

	-m					Perform manual classification

	--files [<files>...]			Load the contents of these files
	--contents <contents> [<sourcefile>] 	Use this as the contents
);
  $self->Config
    (BOSS::Config->new
     (Spec => $specification));
  $self->Conf
    ($self->Config->CLIConfig);
  $self->ActuallyAssert
    ($self->Conf->{'-a'});
  $self->UseClassifier
    (# $self->Conf->{'--all'} ||
     $self->Conf->{'-l'});
  $self->UseFormalize
    ($self->Conf->{'--all'} || $self->Conf->{'--formalize'});
  $self->UseSpeechAct
    ($self->Conf->{'--all'} || $self->Conf->{'-s'});
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
     Context => $args{Context} || $self->Conf->{'-c'} || "Org::FRDCSA::Verber::PSEx2::Do::Temp",
     SkipComputingPSEEntryIDCounter => $args{SkipComputingPSEEntryIDCounter},
    );
  $self->Axioms([]);
  $self->Relationships
    (PerlLib::Collection->new
     (
      Type => 'Do::ListProcessor4::Relationship',
      StorageMethod => 'none',
     ));
  $self->Relationships->Contents({});
  $self->AssertionTemplateCollection(['New'])
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
    $self->SpeechActClassification
      (PerlLib::ServerManager::UniLang::Client->new
       (
	AgentName => "Org-FRDCSA-Capability-SpeechActClassification",
       ));
    print "Remember to start Semanta if it hasn't been already (launch-semanta.sh).  Need to wait until it says: NEPOMUK-Lite Running\n";
    # $self->SpeechActClassification->StartServer
    # ();
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
  if ($self->PerformManualClassification) {
    $self->MyGUI(Do::ListProcessor4::GUI->new(App => $self));
  }
  foreach my $entry (@contents) {
    $self->IndexDocument(Entry => $entry);
    # print Dumper({Relationships => $self->Relationships});
    if ($self->PerformManualClassification) {
      $self->InteractivelyExamineDocument();
    }
    $self->PrintAxioms;
    $self->AssertAxioms
      (
       AssertWithoutCheckingConsistency => 1,
      ) if $self->ActuallyAssert;
  }
}

sub IndexDocument {
  my ($self,%args) = @_;
  my $entry = $args{Entry};
  my $c = $entry->{Contents};
  my $file = $entry->{File};
  # print Dumper({C => $c});
  my $domain = $self->MyListProcessor->MyLight->Parse
    (Contents => $c);
  # print Dumper({Domain => $domain});
  my $res1 = $self->MyListProcessor->ProcessDomainNew
    (Domain => $domain);
  my $returndomain = $res1->{ReturnDomain};
  # add statements for each extracted unit
  my $startingdomainid = $self->MySayer->AddData(Data => [$returndomain]);
  $self->GenerateStatementsAbout
    (
     File => $file,
     StartingDomainID => $startingdomainid,
     Domain => $returndomain,

     Signature => $signature,
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
    print Dumper({Res2 => $res2});
  }
}

sub AssertAxioms {
  my ($self,%args) = @_;
  # now assert these
  print Dumper({Axioms => $self->Axioms});
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
    print Dumper({SendArgs => \%sendargs});
    my $res3 = $self->MyClient->Send(%sendargs);
  }
  $self->Axioms([]);
}

sub GenerateStatementsAbout {
  my ($self,%args) = @_;
  # have context assertions, so that we can always refer back...
  my $domain = $args{Domain};
  my $dumper = Dumper([$domain]);
  my $do = 1;
  if (! exists $self->MySayer->IData->{$dumper}) {
    $self->MySayer->AddData(Data => [$domain]);
    $do = 1;
  }
  my $childid = $self->SayerIndex(Data => [$domain]);
  if ($do) {
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
		    ["has-classification", ["entry-fn", "sayer-index", $childid], $classification],
		   ],
	);
    }
  }
  if ($args{File}) {
    $self->AddAxioms
      (
       Axioms => [
		  ["has-parent-file", ["entry-fn", "sayer-index", $childid], $args{File}],
		 ],
      );
  }
  if ($args{ParentID}) {
    $self->AddAxioms
      (
       Axioms => [
		  ["has-parent", ["entry-fn", "sayer-index", $childid], ["entry-fn", "sayer-index", $args{ParentID}]],
		 ],
      );
    my @childdata = $self->MySayer->GetDataFromID(DataID => $childid);
    if (scalar @{@childdata[0]}) {
      $self->Relationships->AddAutoIncrement
	(
	 Item => Do::ListProcessor4::Relationship->new
	 (
	  StartingDomainID => $args{StartingDomainID},
	  ParentID => $args{ParentID},
	  ChildID => $childid,
	  ParentKey => $args{ParentKey},
	  ChildKey => $args{ChildKey},
	 )
	);
    }
  }
  my $ref = ref($args{Domain});
  if ($ref eq "ARRAY") {
    # now go ahead and add all the sublists
    my $i = 0;
    foreach my $subdomain (@{$args{Domain}}) {
      my $res1 =
	$self->GetPosOfSubdomain
	(
	 Domain => $domain,
	 SubDomain => $subdomain,
	);
      my $childkeypos;
      if ($res1->{Success}) {
	$childkeypos = $res1->{Result}[0];
      }
      my @startingdomaindata = $self->MySayer->GetDataFromID(DataID => $args{StartingDomainID});
      my $res2 =
	$self->GetPosOfSubdomain
	(
	 Domain => @startingdomaindata[0],
	 SubDomain => $domain,
	 Depth => $args{Depth},
	);
      my @pos;
      if ($res2->{Success}) {
	foreach my $item (@{$res2->{Result}}) {
	  push @pos, $item - 1;
	}
      }
      print "<chd:$childkeypos><par:$parentkeypos>\n";
      # my $pos = pop @pos;
      $self->GenerateStatementsAbout
	(
	 ParentID => $self->SayerIndex(Data => [$domain]),
	 Domain => $subdomain,
	 ChildKey => join('',map {'['.$_.']'} @pos)."[$childkeypos]",
	 ParentKey => join('',map {'['.$_.']'} @pos),
	 StartingDomainID => $args{StartingDomainID},
	);
      ++$i;
    }
  } elsif ($ref eq "") {
    my $res2 = $self->AddEntry
      (
       Type => $args{Type},
       Entry => $args{Domain},
       ParentID => $self->SayerIndex(Data => [$domain]),
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

sub InteractivelyExamineDocument {
  my ($self,%args) = @_;
  $self->DontQuit(1);
  $self->CurrentRelationshipID(0);
  while ($self->DontQuit) {
    my $relationshipid = $self->CurrentRelationshipID;
    my $relationship = $self->Relationships->Contents->{$relationshipid};
    $self->CritiqueRelationship
      (
       StartingDomainID => $relationship->StartingDomainID,
       ParentID => $relationship->ParentID,
       ChildID => $relationship->ChildID,
       ParentKey => $relationship->ParentKey,
       ChildKey => $relationship->ChildKey,
      );
  }
}

sub ActionNextRelationship {
  my ($self,%args) = @_;
  my $relationshipid = $self->CurrentRelationshipID + 1;
  if (! exists $self->Relationships->Contents->{$relationshipid}) {
    throw Error "Relationship does not exists <$relationshipid>\n";
  } else {
    $self->CurrentRelationshipID($relationshipid);
  }
}

sub ActionPreviousRelationship {
  my ($self,%args) = @_;
  my $relationshipid = $self->CurrentRelationshipID - 1;
  if (! exists $self->Relationships->Contents->{$relationshipid}) {
    throw Error "Relationship does not exists <$relationshipid>\n";
  } else {
    $self->CurrentRelationshipID($relationshipid);
  }
}

sub CurrentRelationship {
  my ($self,%args) = @_;
  if (exists $self->Relationships->Contents->{$self->CurrentRelationshipID}) {
    return $self->Relationships->Contents->{$self->CurrentRelationshipID};
  } else {
    # FIXME: throw Error
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
  my $parentid = $args{ParentID};
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
      if ($parentid) {
	$self->AddAxioms
	  (
	   Axioms => [
		      ["has-source", ["entry-fn", "pse", $pseentryid], ["entry-fn", "sayer-index", $parentid]],
		     ],
	  );
      }
      # then use the system I designed that is currently on the laptop
      if (! defined $args{Type}) {
	print "Type not defined! FIXME: die when we know what to do\n";
	# die "Type not defined!\n";
      }
      my $toadd = [
		   # [$args{Type}, ["entry-fn", "pse", $pseentryid]],
		   ["asserter", ["entry-fn", "pse", $pseentryid], $args{Asserter} || "unknown"],
		   ["has-NL", ["entry-fn", "pse", $pseentryid], $entry],
		   ["goal", ["entry-fn", "pse", $pseentryid]],
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
	foreach my $engine (qw(ResearchCyc1_0)) {
	  print Dumper({PSEEntry => $pseentry});
	  my $formalization = $self->MyFormalize->FormalizeText
	    (
	     Text => $pseentry,
	     Engines => [$engine],
	    );
	  print Dumper({Formalization => $formalization});
	  if ($formalization->{Success}) {
	    # have to unify all items, just do it in a silly way for now
	    my @formalization = ('#$or');
	    foreach my $entry (@{$formalization->{Results}{ResearchCyc1_0}}) {
	      my $ref = ref($entry);
	      if ($ref eq 'ARRAY') {
		push @formalization, @$entry;
	      } elsif ($entry eq 'NIL') {

	      }
	    }
	    if (scalar @formalization > 1) {
	      $self->AddAxioms
		(
		 Axioms => [
			    ["has-formalization",
			     ["entry-fn", "pse", $pseentryid],
			     ["software-version-fn", "formalize", "2.00"],
			     ["software-engine-fn", $engine],
			     \@formalization,
			    ],
			   ],
		);
	    }
	  }
	}
      }
    }
    return \@entries;
  } else {
    print "Fail: <$entry>\n";
  }
}

sub AddAxioms {
  my ($self,%args) = @_;
  # look into the relation ontology (ignore this for now)
  # extract out everything
  print Dumper({AddingAxiom => $args{Axioms}[0]});
  push @{$self->Axioms}, @{$args{Axioms}};
}

sub ExtractPSEEntries {
  my ($self,%args) = @_;
  my @results;
  if ($self->UseSpeechAct) {
    my $res = $self->SpeechActClassification->GetSpeechActs
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
	print Dumper({MyRes => $res});
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

sub CritiqueRelationship {
  my ($self,%args) = @_;
  print Dumper
    ({
      ChildKey => $args{ChildKey},
      ParentKey => $args{ParentKey},
     }) if $UNIVERSAL::debug;

  my @childdata = $self->MySayer->GetDataFromID(DataID => $args{ChildID});
  if (scalar @{@childdata[0]}) {
    my $childpretty  = $self->MyListProcessor->MyLight->PrettyGenerate
      (
       Structure => @childdata[0],
      );
    SeePretty('ChildPretty',$childpretty) if $UNIVERSAL::debug;
    my @newchilddata = ('START-CHILDDATA', @{$childdata[0]}, 'END-CHILDDATA');

    my @parentdata = $self->MySayer->GetDataFromID(DataID => $args{ParentID});
    my $parentpretty  = $self->MyListProcessor->MyLight->PrettyGenerate
      (
       Structure => @parentdata[0],
      );
    SeePretty('ParentPretty',$parentpretty) if $UNIVERSAL::debug;
    my @newparentdata = ('START-PARENTDATA', @{$parentdata[0]}, 'END-PARENTDATA');

    my @startingdomaindata = $self->MySayer->GetDataFromID(DataID => $args{StartingDomainID});
    my $startingdomainpretty  = $self->MyListProcessor->MyLight->PrettyGenerate
      (
       Structure => @startingdomaindata[0],
      );
    SeePretty('StartingDomainPretty',$startingdomainpretty) if $UNIVERSAL::debug;

    my $startingdomaindata = $startingdomaindata[0];

    my $parentkey = '$startingdomaindata->'.$args{ParentKey};
    $parentkey =~ s/->$//;
    my $c1 = $parentkey.' = \@newparentdata;';
    my $c2 = '$startingdomaindata->'.$args{ChildKey}.' = \@newchilddata;';
    print "<$c1>\n" if $UNIVERSAL::debug;
    eval $c1;
    print "<$c2>\n" if $UNIVERSAL::debug;
    eval $c2;
    my $startingdomaincontent  = $self->MyListProcessor->MyLight->PrettyGenerate
      (
       Structure => $startingdomaindata,
      );

    if ($self->PerformManualClassification) {
      my @responses = $self->MyGUI->ListProcessorSubsetSelect
	(
	 Title => "Classify Relationship",
	 StartingDomain => $startingdomaincontent,
	 ParentContent => $parentcontent,
	 ChildContent => $childcontent,
	 Set => [
		 "Other",
		 "precondition-for",
		 "precondition-of",
		 "eases",
		 "goal"
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
  } else {
    throw Error "Not sure what happened\n";
  }
}

sub SayerIndex {
  my ($self,%args) = @_;
  return $self->MySayer->AddData
    (Data => $args{Data});
}

sub SeePretty {
  my ($a,$b) = @_;
  my @lines = split /[\n\r]/, $b;
  my @newlines = splice @lines, 0, 10;
  print Dumper
    ({
      $a => join("\n",@newlines),
     });
}

sub OneLess {
  my $key = shift;
  $key =~ s/\[(\d+)\]$/\[$((\1-1))\]/;
  return $key;
}

sub Substitute {
  my ($key,$parentkeypos) = @_;
  $key =~ s/\[(\d+)\]$/\[$parentkeypos\]/;
  return $key;
}

sub GetPosOfSubdomain {
  my ($self,%args) = @_;
  my $i = 1;
  my @res;
  return if $args{SubDomain} eq '';
  foreach my $subdomaintmp (@{$args{Domain}}) {
    if (ClearDumper($subdomaintmp) eq ClearDumper($args{SubDomain})) {
      unshift @res, $i;
      # print Dumper({ResA => \@res});
      return {
	      Success => 1,
	      Result => \@res,
	     };
    } else {
      my $res = $self->GetPosOfSubdomain(Domain => $subdomaintmp, SubDomain => $args{SubDomain});
      if ($res->{Success}) {
	push @res, $i;
	push @res, @{$res->{Result}};
	# print Dumper({ResB => \@res});
	return {
		Success => 1,
		Result => \@res,
	       };
      }
    }
    ++$i;
  }
}

sub EntryFn {
  my (@args) = @_;
  ['entry-fn', @args];
}

sub GetCorrectID {
  my ($self,%args) = @_;
  my @matches;
  print Dumper({Relationship => $args{Relationship}}) if $UNIVERSAL::debug;
  foreach my $entry (@{$UNIVERSAL::listprocessor->Axioms}) {
    # print Dumper({Entry => $entry}) if $UNIVERSAL::debug;
    if ($entry->[0] eq 'has-parent' and $entry->[2][2] eq $args{ID}) {
      return $entry->[1][2];
    }
  }
}

sub GetPSEEntriesForRelationship {
  my ($self,%args) = @_;
  my @matches;
  my $id = $self->GetCorrectID(ID => $args{Relationship}->ChildID);
  # ['has-source', ['entry-fn', 'pse', Var('?ID')], ['entry-fn', 'sayer-index', $r->ChildID]]
  print Dumper({Relationship => $args{Relationship}}) if $UNIVERSAL::debug;
  foreach my $entry (@{$UNIVERSAL::listprocessor->Axioms}) {
    # print Dumper({Entry => $entry}) if $UNIVERSAL::debug;
    if ($entry->[0] eq 'has-source' and $entry->[2][2] == $id) {
      push @matches, $entry->[1];
      print Dumper({Match => $entry->[1]}) if $UNIVERSAL::debug;
    }
  }
  return \@matches;
}

sub GetNLForPSEEntry {
  my ($self,%args) = @_;
  my @matches;
  # ['has-NL', ['entry-fn', 'pse', Var('?ID')], Var('?NL')]
  $UNIVERSAL::debug = 1;
  foreach my $entry (@{$UNIVERSAL::listprocessor->Axioms}) {
    # print Dumper({Entry => $entry}) if $UNIVERSAL::debug;
    if ($entry->[0] eq 'has-NL' and (ClearDumper($entry->[1]) eq ClearDumper($args{EntryFn}))) {
      push @matches, $entry->[2];
      print Dumper({Match => $entry->[2]}) if $UNIVERSAL::debug;
    }
  }
  return \@matches;
}

sub GetRelevantAxioms {
  my ($self,%args) = @_;
  if (0) {
    return $self->Axioms;
  } else {
    my $r = $self->CurrentRelationship;
    my $matches = $self->GetPSEEntriesForRelationship
      (
       Relationship => $r,
      );
    print Dumper({Matches => $matches}) if $UNIVERSAL::debug;
    my @lists;
    foreach my $pseentry (@$matches) {
      my $result1 = GetAllReferringFormulae
	(
	 Formulae => $self->Axioms,
	 Subformula => $pseentry,
	);
      print Dumper({Result1 => $result1}) if $UNIVERSAL::debug;
      push @lists, $result1;
    }
    my $result2 = GetAllReferringFormulae
      (
       Formulae => $self->Axioms,
       Subformula => ['entry-fn','sayer-index',$r->ChildID],
      );
    push @lists, $result2;
    my $result3 = GetAllReferringFormulae
      (
       Formulae => $self->Axioms,
       Subformula => '#$goals',
      );
    push @lists, $result3;
    return ListUnion
      (@lists);
  }
}

sub CurrentChildEntryFn {
  my ($self,%args) = @_;
  EntryFn('sayer-index',$UNIVERSAL::listprocessor->CurrentRelationship->ChildID);
}

sub CurrentParentEntryFn {
  my ($self,%args) = @_;
  EntryFn('sayer-index',$UNIVERSAL::listprocessor->CurrentRelationship->ParentID);
}

sub Assert {
  my ($self,%args) = @_;
  my $lp = $UNIVERSAL::listprocessor;
  my @templates;
  if (exists $args{New}) {
    my $res1 = $self->MyGUI->MyMinibuffer->CompletingRead
      (
       Collection => $self->AssertionTemplateCollection,
      );
    if ($res1->{Success}) {
      if ($res1->{Result} eq 'New') {
	my $res2 = QueryUser2
	  (
	   Message => 'Assertion Template?',
	  );
	if (! $res2->{Cancel}) {
	  push @{$self->AssertionTemplateCollection}, $res2->{Value};
	}
      } else {
	my $res3 = $self->ImportExport->Convert
	  (
	   Input => $res1->{Result},
	   OutputType => "Interlingua",
	  );
	if ($res3->{Success}) {
	  push @templates, $res3->{Output};
	}
	$res1->{Result};
      }
    }
  }
  if ($args{Templates}) {
    push @templates, @{$args{Templates}};
  }
  my @axioms;
  foreach my $template (@templates) {
    push @axioms, $template;
  }
  $lp->AddAxioms
    (
     Axioms => \@axioms,
    );
  $self->MyGUI->ContinueLoop(0);
}

sub CycCurrentChildEntryFn {
  my ($self,%args) = @_;
  print "Bloat\n";
  my $rel = $self->GetPSEEntriesForRelationship(Relationship => $self->CurrentRelationship);
  print "Bloat\n";
  print Dumper({fudge => $rel});
  print "Bloat\n";
  my $nl = $self->GetNLForPSEEntry(EntryFn => EntryFn('pse',$rel->[0][2]));
  print "Bloat\n";
  print Dumper({toppings => $nl});
  print "Bloat\n";
  '#$PSEEntry-'.join('',map {$self->Capitalize(Word => $_)} split /\W+/, $nl->[0]);
}

sub CycCurrentUserFn {
  '#$AndrewDougherty-AIResearcher'
}

sub Clean {
  my ($self,%args) = @_;
  $args{Text} =~ s/\W//sg;
  $args{Text};
}

sub Capitalize {
  my ($self,%args) = @_;
  my $t = $args{Word};
  my @l = split //, $t;
  my $firstletter = shift @l;
  if (lc($firstletter) eq $firstletter) {
    return join('',(uc($firstletter),@l));
  } else {
    return $t;
  }
}


1;

