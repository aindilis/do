#!/usr/bin/perl

use Data::Dumper;

my $f = "data.pl";
my $c = `cat "$f"`;
my $checklist = eval $c;
print Dumper($checklist);
