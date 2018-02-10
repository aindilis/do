#!/usr/bin/perl -w

use KBS2::Client;
use KBS2::ImportExport;
use PerlLib::SwissArmyKnife;
use UniLang::Util::TempAgent;

my $context = "Org::FRDCSA::Verber::PSEx2::test";
my $client = KBS2::Client->new
  (
   Debug => 0,
   Method => "MySQL",
   Database => "freekbs2",
   Context => $context,
  );

my $importexport = KBS2::ImportExport->new();

$client->ClearContext
  (
   Context => $context,
  );

my $res1 = $client->Send
  (
   QueryAgent => 1,
   Assert => '("has-parent" ("entry-fn" "sayer-index" "17") ("entry-fn" "sayer-index" "16"))',
   InputType => "Emacs String",
  );

my $res2 = $client->Send
  (
   QueryAgent => 1,
   Query => '(has-parent ?X ?Y)',
   InputType => "KIF String",
  );

my @actualresult;
foreach my $entry (@{$res2->{Data}->{Result}->{Results}->[-1]->{Models}}) {
  push @actualresult, $entry->{Formulae}->[0];
}

See({
     Actual => \@actualresult,
     # Res2 => $res2,
    });
