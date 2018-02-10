#!/usr/bin/perl -w

use BOSS::Config;
use KBS2::Util;
use Manager::Misc::Light;
use PerlLib::SwissArmyKnife;

$specification = q(
	-f <files>...		Files to check
	-t			Run tests
	-e			Output Emacs data structure
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";

my $light = Manager::Misc::Light->new();

sub Test {
  my @res1;
  push @res1, IsDoFile(File => '/var/lib/myfrdcsa/codebases/internal/do/systems/convert/scripts/test/compile.do');
  push @res1,   IsDoFile(File => '/Doug/data/posi.frdcsa.org/sda1/gitroot/minor-1.1/poverty-survival-system/to.do');
  print Dumper(\@res1);
}

sub IsDoFile {
  my (%args) = @_;
  my $c = read_file($args{File});
  my @res1 = $light->Parse(Contents => $c);
  VerifyDoFile(Item => \@res1);
}

sub VerifyDoFile {
  my (%args) = @_;
  my $item = $args{Item};
  if (exists $item->[0][0][0]) {
    return 1;
  } else {
    return 0;
  }
}

if ($conf->{'-t'}) {
  Test();
}

if ($conf->{'-f'}) {
  if ($conf->{'-e'}) {
    print "(setq do-todo-list-or-notes-p-hash\n '(";
  }
  my $indent = "";
  foreach my $file (@{$conf->{'-f'}}) {
    if (-f $file) {
      if ($conf->{'-e'}) {
	print "$indent(".EmacsQuote(Arg => $file)." . ".IsDoFile(File => $file).")\n";
	$indent = "   ";
      } else {
	print IsDoFile(File => $file)."\t".$file."\n";
      }
    }
  }
  if ($conf->{'-e'}) {
    print "   ))\n";
  }
}
