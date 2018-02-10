#!/usr/bin/perl -w

# this is a script to look up cyc predicates for a given notion

e.g. "Do something about";

while ($notion = <>) {
  chomp $notion;
  LookupCycPredicateForNotion($notion);
}

sub LookupCycPredicateForNotion {
  # first do query expansion

  # maybe have word lists of related expressions

  
}
