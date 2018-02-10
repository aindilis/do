#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

use Linux::Inotify2;

# create a new object
my $inotify = new Linux::Inotify2
  or die "unable to create new inotify object: $!";

# add watchers
my $c = read_file('/var/lib/myfrdcsa/codebases/internal/do/scripts/convert/data/files.txt');
foreach my $file (split /\n/, $c) {
  print "adding $file\n";
  $inotify->watch
    ($file, IN_MODIFY,
     sub {
       my $e = shift;
       my $name = $e->fullname;
       print "$name was modified\n" if $e->IN_MODIFY;
     });
}

1 while $inotify->poll;

# after updatedbs, search for new .do or .notes files, and add to
# list, then load, then monitor
