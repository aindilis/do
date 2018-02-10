#!/usr/bin/perl -w

# system to try to come up with mappings between cyc and a sentence.

# this may be destined to be in termios

use Manager::Dialog qw(Message);

use Data::Dumper;
use Lingua::EN::Sentence qw(get_sentences);
use Lingua::EN::Tagger;
use String::Tokenizer;

my $constants = {};
my $tokenizer = String::Tokenizer->new();
my $tagger = Lingua::EN::Tagger->new
  (stem => 0);
my $sentmap = {};

sub ProcessCycConstants {
  # these are initial starting points for a given term
  Message(Message => "Processing Cyc Constants");
  foreach my $l
    (split /\n/,
     `cat /var/lib/myfrdcsa/codebases/internal/do/data/consts`) {
    $constants->{$l} = {};
    $lc->{lc($l)} = $l;
  }
}

ProcessCycConstants;

sub ProcessFile {
  my $f = shift;
  Message(Message => "Processing File");
  my $c = `cat "$f"`;
  my $s = get_sentences($c);
  foreach my $sentence (@$s) {
    ProcessSentence($sentence);
    print Dumper($sentence,$sentmap->{$sentence});
  }
}

sub ProcessSentence {
  my $sentence = shift;

  # do noun phrases, see what that yields
  my %nps;
  if (1) {
    my $tagged_text = $tagger->add_tags( $sentence );
    %nps = $tagger->get_noun_phrases($tagged_text);
  } else {
    %nps = $tagger->get_words($sentence);
  }
  # print Dumper(\%nps);
  my $matches = {};
  foreach my $np (keys %nps) {
    my $args = MatchNP($np);
    if (ref $args eq "HASH") {
      $matches->{$args->{Phrase}} = $args->{GAF};
    }
  }
  $sentmap->{$sentence}->{Matches} = $matches;

  # now search for n-grams
  $tokenizer->tokenize($sentence);
  my @tokens = $tokenizer->getTokens();

  my @ngrams = GetAllNGrams
    (MaxLength => 3,
     Tokens => \@tokens);
  # print Dumper(\@ngrams);
  my $matches = {};
  foreach my $ngram (@ngrams) {
    my $np = join("",@$ngram);
    my $args = CheckConstant($np);
    if (ref $args eq "HASH") {
      $matches->{$args->{Phrase}} = $args->{GAF};
    }
  }
  foreach my $key (keys %$matches) {
    $sentmap->{$sentence}->{Matches}->{$key} = $matches->{$key};
  }
}

sub GetAllNGrams {
  my %args = @_;
  my @tokens = @{$args{Tokens}};
  my @res;
  foreach my $i (2..$args{MaxLength}) {
    my @cp = @tokens;
    my $size;
    do {
      my @ng;
      $size = scalar @cp;
      foreach my $j (1..$i) {
	push @ng, shift @cp;
      }
      if (scalar @ng == $i) {
	push @res, \@ng;
      }
      my @cp2 = @ng;
      shift @cp2;
      unshift @cp, @cp2;
    } while ($size >= $i);
  }
  return @res;
}

sub ConstantApropos {
  my $search = shift;
  my @res;
  foreach my $c (keys %$constants) {
    if ($c =~ /$search/i) {
      push @res, $c;
    }
  }
  return \@res;
}

sub MatchTokens {
  my $np = shift;
  # now we have to look at all of these constants and see which ones fit
  # best, if at all
  # first check for exact matches
  $tokenizer->tokenize($np);
  foreach my $w ($tokenizer->getTokens()) {
    if ($w) {
      if ($w =~ /^[\s\w]+$/) {
	if (exists $lc->{lc($w)}) {
	  return {Phrase => "$w",
		  GAF => "\#\$".$lc->{lc($w)}};
	} else {
	  #       my $matches = ConstantApropos($w);
	  #       foreach my $m (@$matches) {
	  #	print "$w -- $m\n"
	  #       }
	}
      }
    }
  }
}

sub CheckConstant {
  my $w = shift;
  if (exists $lc->{lc($w)}) {
    return {Phrase => "$w",
	    GAF => "\#\$".$lc->{lc($w)}};
  }
}

sub MatchNP {
  my $np = shift;
  my $m = CheckConstant($np);
  return $m if $m;
  my $st = $np;
  $st =~ s/\s+//g;
  # print $st."\n";
  my $m = CheckConstant($st);
  return $m if $m;
}

foreach my $f (@ARGV) {
  ProcessFile($f);
}

# print Dumper($sentmap);
