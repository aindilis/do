#!/usr/bin/perl -w

use KBS2::Client;
use KBS2::ImportExport;
use PerlLib::SwissArmyKnife;
use UniLang::Util::TempAgent;

my $context = "test-kbs2-vampire";
my $client = KBS2::Client->new
  (
   Debug => 0,
   Method => "MySQL",
   Database => "freekbs2",
   Context => $context,
  );

my $importexport = KBS2::ImportExport->new();

my $problemsets = [
		   {
		    Theory => [
			       '(temp a b c)',
			       '(temp d e f)',
			       '(temp g h i)',
			      ],
		    Queries => {
				'(temp ?X ?Y ?Z)' => [
						      '(temp a b c)',
						      '(temp d e f)',
						      '(temp g h i)',
						     ],
			       },
		   },
		   {
		    Theory => [
			       '(p x)',
			       '(=> (p ?X) (q ?Y))',
			      ],
		    Queries => {
				'(q x)' => "true",
			       },
		   },
		  ];

sub DoTests {
  my (%args) = @_;
  my $i = 1;
  foreach my $problemset (@$problemsets) {
    # clear the context
    print "Clearing the context...\n";
    $client->ClearContext
      (
       Context => $context,
      );
    print "Finished clearing the context.\n";
    print "problemset ".$i++."\n";
    foreach my $assertion (@{$problemset->{Theory}}) {
      my $res = $client->Send
	(
	 QueryAgent => 1,
	 Assert => $assertion,
	 InputType => "KIF String",
	);
      if ($res->Data->{Result}->{Success}) {
	if ($noisy) {
	  print "Successfully asserted: $assertion\n";
	}
      } else {
	if ($noisy) {
	  print "Not asserted: $assertion\n";
	}
      }
    }
    foreach my $query (keys %{$problemset->{Queries}}) {
      # convert the expected query result to the interlingua
      my @expectedresult;
      foreach my $formula (@{$problemset->{Queries}->{$query}}) {
	my $res2 = $importexport->Convert
	  (
	   Input => $formula,
	   InputType => "KIF String",
	   OutputType => "Interlingua",
	  );
	if ($res2->{Success}) {
	  push @expectedresult, $res2->{Output}->[0];
	} else {
	  # must fail here somehow
	  die "This should be noted as a failure somehow in the tests.\n";
	}
      }

      if ($noisy) {
	print "Querying: $query\n";
      }
      my $res = $client->Send
	(
	 QueryAgent => 1,
	 Query => $query,
	 InputType => "KIF String",
	);

      my @actualresult;
      foreach my $entry (@{$res->{Data}->{Result}->{Results}->[-1]->{Models}}) {
	push @actualresult, $entry->{Formulae}->[0];
      }
      See({
	   Expected => \@expectedresult,
	   Actual => \@actualresult,
	  });
    }
  }
}

DoTests();
