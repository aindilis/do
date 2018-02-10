#!/usr/bin/perl -w

# use the list processor

use BOSS::Config;
use Do::Misc::ListProcessor2;
use Formalize2::UniLang::Client;
use KBS2::ImportExport;
use PerlLib::ServerManager::UniLang::Client;
use PerlLib::SwissArmyKnife;
use Sayer;

use Data::Dumper;

# to process to.do lists, this is a good idea
# # get all the files

my $specification = q(
	-s					Use SpeechActClassifier
	-f					Use formalize
	--files [<files>...]			Load the contents of these files
	--contents <contents> [<sourcefile>] 	Use this as the contents
);

# OBJECTS
my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";
my $usespeechact = $conf->{'-s'};
my $useformalize = $conf->{'-f'};

my $speechactclassification;
if ($usespeechact) {
  $speechactclassification = PerlLib::ServerManager::UniLang::Client->new
    (
     AgentName => "Org-FRDCSA-Capability-SpeechActClassification",
    );
  $speechactclassification->StartServer
    ();
}
my $formalize;
if ($useformalize) {
  $formalize = Formalize2::UniLang::Client->new
    ();
}
my $listprocessor = Do::Misc::ListProcessor2->new
  ();
my $importexport = KBS2::ImportExport->new
  ();
# put the whole thing in Sayer, to keep context
my $sayer = Sayer->new
  (
   DBName => "sayer_org_frdcsa_do",
  );

# DATA
my $sayerindex = {};
my $datacounter = 0;
my $pseentryids = 0;
my $pseentryidcounter = 0;
my $axioms = [];

# CONTROL
my @entries;
if (exists $conf->{'--files'}) {
  # print Dumper($conf->{'--files'});
  foreach my $file (@{$conf->{'--files'}}) {
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
if (exists $conf->{'--contents'}) {
  push @contents, {
		   Contents => $conf->{'--contents'}->{'<contents>'},
		   File => $conf->{'--contents-file'}->{'<source-file>'} || "supplied-from-contents",
		  };
}

foreach my $entry (@contents) {
  my $c = $entry->{Contents};
  my $file = $entry->{File};
  my $domain = $listprocessor->MyLight->Parse
    (Contents => $c);
  my $res1 = $listprocessor->ProcessDomainNew
    (Domain => $domain);
  my $returndomain = $res1->{ReturnDomain};

  # add statements for each extracted unit
  GenerateStatementsAbout
    (
     Domain => $returndomain,
     File => $file,
     Signature => $signature,
    );
}

my $res2 = $importexport->Convert
  (
   Input => $axioms,
   InputType => "Interlingua",
   OutputType => "Emacs String",
  );
if ($res->{Success}) {
  print $res2->{Output}."\n";
} else {
  print Dumper($res2);
}


sub GenerateStatementsAbout {
  my (%args) = @_;
  # have context assertions, so that we can always refer back...
  my $dumper = Dumper($args{Domain});
  if (! exists $sayerindex->{$dumper}) {
    $sayerindex->{$dumper} = $datacounter++;
  }
  if ($args{File}) {
    AddAxioms
      (
       Axioms => [
		  ["has-parent-file", ["entry-fn", "sayer-index", $sayerindex->{$dumper}], $args{File}],
		 ],
      );
  }
  if ($args{Parent}) {
    AddAxioms
      (
       Axioms => [
		  ["has-parent", ["entry-fn", "sayer-index", $sayerindex->{$dumper}], ["entry-fn", "sayer-index", $args{Parent}]],
		 ],
      );
  }
  my $ref = ref $args{Domain};
  if ($ref eq "ARRAY") {
    # now go ahead and add all the sublists
    foreach my $subdomain (@{$args{Domain}}) {
      GenerateStatementsAbout
	(
	 Domain => $subdomain,
	 Parent => $sayerindex->{$dumper},
	);
    }
  } elsif ($ref eq "") {
    AddEntry
      (
       Entry => $args{Domain},
       Parent => $sayerindex->{$dumper},
       Signature => $args{Signature},
      );
  }
}

sub AddEntry {
  my (%args) = @_;
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
  my $res = ExtractPSEEntries
    (
     Entry => $entry,
    );

  if ($res->{Success}) {
    foreach my $extractedentry (@{$res->{Results}}) {
      my $pseentry = $extractedentry->{PSEEntry};
      my $pseentryid = $extractedentry->{PSEEntryID};
      if ($parent) {
	AddAxioms
	  (
	   Axioms => [
		      ["has-source", ["entry-fn", "pse", $pseentryid], ["entry-fn", "sayer-index", $parent]],
		     ],
	  );
      }
      # then use the system I designed that is currently on the laptop
      AddAxioms
	(
	 Axioms => [
		    ["goal", ["entry-fn", "pse", $pseentryid]],
		    ["asserter", ["entry-fn", "pse", $pseentryid], "Andrew Dougherty"],
		    ["has-NL", ["entry-fn", "pse", $pseentryid], $entry],
		   ],
	);
      if (defined $signature) {
	AddAxioms
	  (
	   Axioms => [
		      ["has-signature", ["entry-fn", "pse", $pseentryid], $signature],
		     ],
	  );
      }

      if ($useformalize) {
	my $formalization = $formalize->FormalizeText
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
		push @formalization, $entry2;
	      }
	    }
	  }
	  unshift @formalization, "and";
	  AddAxioms
	    (
	     Axioms => [
			["has-formalization",
			 ["entry-fn", "pse", $pseentryid],
			 ["software-version-fn", "formalize", "2.00"],
			 \@formalization,
			],
		       ],
	    );
	}
      }
    }
  }
}

sub AddAxioms {
  my (%args) = @_;
  # look into the relation ontology (ignore this for now)
  # extract out everything
  push @$axioms, @{$args{Axioms}};
}

sub ExtractPSEEntries {
  my (%args) = @_;
  my @results;
  if ($usespeechact) {
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
	if (! exists $pseentryids->{$pseentry}) {
	  $pseentryids->{$pseentry} = $pseentryidcounter++;
	}
	push @results,
	  {
	   PSEEntry => $pseentry,
	   PSEEntryID => $pseentryids->{$pseentry},
	   # deal with Type and Mode later on
	  };
      }
    }
  } else {
    my $pseentry = $args{Entry};
    if (! exists $pseentryids->{$pseentry}) {
      $pseentryids->{$pseentry} = $pseentryidcounter++;
    }
    push @results,
      {
       PSEEntry => $pseentry,
       PSEEntryID => $pseentryids->{$pseentry},
      };
  }
  return {
	  Success => 1,
	  Results => \@results,
	 };
}
