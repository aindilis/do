#!/usr/bin/perl -w

# this  is  a  feeble  but  interesting  attempt  to  extract  various
# semantics from the entries, based  on the observation that there are
# recurring  patters to  them.   This is  not  so much  intended as  a
# permanent kind of investigatation so  much as a way of bootstrapping
# data as well as getting interesting results.

use Corpus;

use Data::Dumper;
use Lingua::EN::Sentence qw(get_sentences);
# use Lingua::En::Tagger;

use String::Tokenizer;
use Lingua::LinkParser;

$corpus = Corpus->new;
$parser = Lingua::LinkParser->new;
# my $tagger = Lingua::EN::Tagger->new
#   (stem => 0);
$tokenizer = String::Tokenizer->new();

my $ret = $corpus->ListRecent
  (Depth => 10000);

foreach my $entry (@$ret) {
  ProcessEntry($entry);
}

sub ProcessEntry {
  my $entry = shift;
  my $sentences = get_sentences($entry);
  foreach my $sentence (@$sentences) {
    ProcessSentence($sentence);
  }
}

sub ProcessSentence {
  my $sentence = shift;
  # for when
  if ($sentence =~ /^(.+?)\s*\b(if|when|so that|because)\b,?\s*(.+?)$/i) {
    print Dumper([$2,$1,$3]);
  } else {
    # print "fail\n";
  }
}

sub ProcessSentenceWithLinkParser {
  # do whens
  # we want to at least diagram the damn thing?
  # get the linkparser
  # activate the linkparser
  # all hands to the linkparser!!!
  my $sentence = shift;
  if (length($sentence) < 60) {
    print "<$sentence>\n";
    my $ls = $parser->create_sentence
      ($sentence);
    my @linkages = $ls->linkages;
    foreach $linkage (@linkages) {
      print ($parser->get_diagram($linkage));
      foreach $sublinkage ($linkage->sublinkages) {
	my $i = 0;
	foreach my $link ($sublinkage->links) {
	  ++$i;
	  # 		my $l = $sublinkage->get_word($link->lword);
	  # 		my $r = $sublinkage->get_word($link->lword);
	  # 		if ($l eq "when" or
	  # 		    $r eq "when") {
	  # 		  print Dumper($link->{linkage});
	  # 		  print "LINK\n";
	  # 		}
	}
	print "<$i>\n";
      }
    }
  }
}

sub ViewPostscriptLinkage {
  my $linkage = shift;
  my $OUT;
  open(OUT,">/tmp/linkage.ps") or die "cannot\n";
  my $ps = $parser->get_postscript($linkage, MODE); 
  print OUT $ps;
  close(OUT);
  system "gv /tmp/linkage.ps";
}
