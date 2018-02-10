#!/usr/bin/perl -w

use KBS2::Client;
use KBS2::ImportExport;
use PerlLib::SwissArmyKnife;
use UniLang::Util::TempAgent;

my $context = "Org::FRDCSA::Verber::PSEx2::Do";
my $client = KBS2::Client->new
  (
   Debug => 0,
   Method => "MySQL",
   Database => "freekbs2",
   Context => $context,
  );

my $importexport = KBS2::ImportExport->new();

my $object = $client->Send
  (
   QueryAgent => 1,
   Query => '(has-formalization ?X ?Y ?Z)',
   InputType => "KIF String",
   Flags => {
	     # Debug => 1,
	    },
   ResultType => "object",
  );

# print Dumper($object);
my @res = $object->MatchBindings
  (
   VariableName => "?Z",
  );
print Dumper(\@res);
