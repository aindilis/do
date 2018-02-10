#!/usr/bin/perl -w

use BOSS::Config;
use KBS::Util;
use Manager::Dialog qw(SubsetSelect);
use Manager::Misc::Light;
use PerlLib::UI;
use PerlLib::MySQL;
use UniLang::Util::TempAgent;

use Data::Dumper;

$specification = q(
	-f <files>...		Todo list files for processing
	--contents <contents>	Use this instead of a file if need be

	-c <context>		Context for domain, defaults to "default"
  );

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
$UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/todo-list-processor";

my $light = Manager::Misc::Light->new();
# my $f = "/var/lib/myfrdcsa/codebases/internal/manager/scripts/normal-form/svrs-checklist.el";
# my $f = "constraints";

my $context = exists $conf->{'-c'} ? $conf->{'-c'} : "default";

my $mysql = PerlLib::MySQL->new
  (DBName => "unilang");

my $res = $mysql->Do
  (
   Statement => "select * from messages",
  );

my $unilangentryids = {};
foreach my $entryid (keys %$res) {
  $unilangentryids->{$res->{$entryid}->{Contents}} = $entryid;
}

my $tempagent = UniLang::Util::TempAgent->new
  (Name => "PSE-X");

if (exists $conf->{'-f'}) {
  my @files = @{$conf->{'-f'}};
  foreach my $f (@files) {
    my $c = `cat "$f"`;
    # print $c."\n";
    my $domain = $light->Parse
      (Contents => $c);
    # print Dumper($domain);
    ProcessDomain(Domain => $domain);
  }
}

if (exists $conf->{'--contents'}) {
  my $domain = $light->Parse
    (Contents => $conf->{'--contents'});
  # print Dumper($domain);
  ProcessDomain(Domain => $domain);
}

sub ProcessDomain {
  my %args = @_;
  my $last;
  my @list;
  my @lists;
  my @rets;
  my $myentryid;
  foreach my $entry (@{$args{Domain}}) {
    my $ref = ref $entry;
    if (defined $last and $last ne $ref) {
      if (scalar @list) {
	$myentryid = Add(join(" ",@list));
	push @rets, $myentryid;
	@list = ();
      }
    }
    if ($ref eq "") {
      push @list, $entry;
    } elsif ($ref eq "ARRAY") {
      # check if there is
      # assert these as depended-on goals?
      foreach my $entryid (ProcessDomain(Domain => $entry)) {
	# assert depends goal
	if (defined $myentryid) {
	  my $contents = "$context assert (\"depends\" \"$myentryid\" \"$entryid\")";
	  print "$contents\n";
	  $tempagent->Send
	    (
	     Receiver => "KBS",
	     Contents => $contents,
	    );
	}
      }
    }
    $last = $ref;
  }
  if (scalar @list) {
    push @rets, Add(join(" ",@list));
  }
  return @rets;
}

sub Add {
  my $entry = shift;
  my $entryid =
    GetUniLangEntryID
      (Entry => $entry);
  print "UniLang, $entryid - $entry\n";
  return $entryid;
}

foreach my $assertion (@$assertions) {
  my @list;
  my @error;
  my $fail = 0;
  foreach my $arg (@$assertion) {
    if ($arg =~ /^\d+$/) {
      my $res = $myentryids->{$arg};
      if (! defined $res) {
	push @error, $arg;
	$fail = 1;
      }
      push @list, $res;
    } else {
      push @list, '"'.DumperQuote($arg).'"';
    }
  }
  if ($fail) {
    print "ERROR:\n".Dumper(\@error);
  } else {
    my $contents = "$context assert (".join(" ",@list).")";
    print "$contents\n";
    $tempagent->Send
      (
       Receiver => "KBS",
       Contents => $contents,
      );
  }
}

sub GetUniLangEntryID {
  my %args = @_;
  my $entry = $args{Entry};
  my $entryid;
  if (exists $unilangentryids->{$entry}) {
    $entryid = $unilangentryids->{$entry};
  } else {
    my $message = $tempagent->MyAgent->QueryAgent
      (
       Receiver => "UniLang",
       Contents => $entry,
       Data => {
		_GetEntryID => 1,
		_DoNotAct => 1,
	       },
      );
    if (defined $message) {
      $entryid = $message->Data->{EntryID};
    }
  }
  if (defined $entryid) {
    $tempagent->Send
      (
       Receiver => "KBS",
       Contents => "$context assert (\"critic-unilang-classification\" \"$entryid\" \"goal\")",
      );
  }
  return $entryid;
}
