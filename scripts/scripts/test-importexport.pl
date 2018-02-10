#!/usr/bin/perl -w

use KBS::ImportExport;

use Data::Dumper;

my $importexport = KBS::ImportExport->new;

my $it = "(\"and\" (\"start'\" var-e2 var-x1) (\"Dad#n#1'\" var-x1) (\"stories-SLASH-recollections-SLASH-etc#n#2'\" var-x1) (\"project#n#2'\" var-x1))";

my $res = $importexport->Convert
  (
   Input => $it,
   InputType => "Emacs String",
   OutputType => "KIF String",
  );

my $res2 = $importexport->Convert
  (
   Input => $res->{Output},
   InputType => "KIF String",
   OutputType => "Emacs String",
  );

print Dumper($res2);
