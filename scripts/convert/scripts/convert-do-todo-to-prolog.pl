#!/usr/bin/perl -w

use BOSS::Config;
use Do::Convert::DoToProlog::Parser;
use PerlLib::SwissArmyKnife;

$specification = q(
	-f <file>	File to process
	<text>		Text to process
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";

my $parser = Do::Convert::DoToProlog::Parser->new();

my $c;
my $fn = $conf->{'-f'};
if (-f $fn) {
  $c = read_file($fn);
} else {
  $c = $conf->{'<text>'};
}
print $parser->DoParsingOfDoTodoAndConvertIntoProlog(Contents => $c);
