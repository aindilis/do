#!/usr/bin/perl -w

# use KBS::Util;
# use KBS2::ImportExport;

use Manager::Misc::Light;
use Manager::Misc::Light::Index;

use Data::Dumper;
use File::Slurp;

my $light = Manager::Misc::Light->new;
my $lightidx = Manager::Misc::Light::Index->new;
# my $ie = KBS2::ImportExport->new;

my $file = shift;
my $phrase = shift;
my $contents = read_file($file);

my $domain = $lightidx->Parse
  (
   Contents => $contents,
  );

my $searchresult;
my $menu = GetMenusIndex
  (
   Search => $phrase,
   Domain => $domain,
  );

my $domain2 = DeMenu
  (
   Menu => $searchresult,
  );

print Dumper($domain2);

sub GetMenusIndex {
  my (%args) = @_;
  my $virgin = 1;
  my @menuitem;
  my @menus;
  my $start;
  my $end;
  my $extravirgin = 1;
  foreach my $hash (@{$args{Domain}}) {
    my $entry = $hash->{Item};
    my $item = ref $entry;
    if ($item eq "") {
      $end = $hash->{End};
      if ($virgin) {
	push @menuitem, $entry;
	if ($extravirgin) {
	  $start = $hash->{Start};
	  $extravirgin = 0;
	}
      }
    }
    if ($item eq "ARRAY" and scalar @$entry) {
      $virgin = 0;
      push @menus, GetMenusIndex
	(
	 Search => $args{Search},
	 Indent => " ".($args{Indent} || ""),
	 Domain => $entry,
	);
    }
  }
  if (! defined $args{Indent}) {
    return \@menus;
  } else {
    my $entry = join(" ",@menuitem);
    if ($entry eq $args{Search}) {
      $searchresult = \@menus;
    }
    return [
	    ["Start", $start],
	    ["End", $end],
	    ["Entry", $entry],
	    ["Submenu", \@menus]
	   ];
  }
}

sub DeMenu {
  my (%args) = @_;
  my $ref = ref $args{Menu};
  my @res;
  if ($ref eq "ARRAY") {
    # determine what it is and print it
    foreach my $item (@{$args{Menu}}) {
      my @res2;
      foreach my $entry (@$item) {
	if ($entry->[0] eq "Entry") {
	  push @res2, $entry->[1];
	} elsif ($entry->[0] eq "Submenu") {
	  my $submenu = DeMenu(Menu => $entry->[1]);
	  if (scalar @$submenu) {
	    foreach my $item (@$submenu) {
	      push @res2, $item;
	    }
	  }
	}
      }
      push @res, \@res2;
    }
  }
  return \@res;
}
