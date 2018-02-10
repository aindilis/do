#!/usr/bin/perl -w

use KBS2::Client;
use KBS2::ImportExport;
use PerlLib::SwissArmyKnife;
use UniLang::Util::TempAgent;

my $context = "Org::FRDCSA::CHAP";
my $client = KBS2::Client->new
  (
   Debug => 0,
   Method => "MySQL",
   Database => "freekbs2",
   Context => $context,
  );

my $importexport = KBS2::ImportExport->new();

print "Querying: $query\n";
my $res = $client->Send
  (
   QueryAgent => 1,
   Query => '(diagonal ?X ?Y)',
   InputType => "KIF String",
   Flags => {
	     Debug => 0,
	    },
  );

my @actualresult;
foreach my $entry (@{$res->{Data}->{Result}->{Results}->[-1]->{Models}}) {
  push @actualresult, $entry->{Formulae}->[0];
}

See({
     Actual => \@actualresult,
     # Res => $res,
    });
