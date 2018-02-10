#!/usr/bin/perl -w

use KBS::Util;
use KBS2::ImportExport;
use Manager::Misc::Light;
use Manager::Misc::Light::Index;

use Data::Dumper;
use File::Slurp;

my $light = Manager::Misc::Light->new;
my $lightidx = Manager::Misc::Light::Index->new;
my $ie = KBS2::ImportExport->new;

my $file = shift;
my $contents = read_file($file);

if (0) {
  my $domain = $light->Parse
    (
     Contents => $contents,
    );
  print join("\n",GetMenus
	     (
	      Domain => $domain,
	     ));
} else {
  my $domain = $lightidx->Parse
    (
     Contents => $contents,
    );
  # print Dumper($domain);
  my $menu = GetMenusIndex
    (
     Domain => $domain,
    );
  my $res = $ie->Convert
    (
     Input => [$menu],
     InputType => "Interlingua",
     OutputType => "Emacs String",
    );
  if ($res->{Success}) {
    print $res->{Output}."\n";
  }
}

sub GetMenus {
  my (%args) = @_;
  my $virgin = 1;
  my @menuitem;
  my @menus;
  foreach my $entry (@{$args{Domain}}) {
    my $item = ref $entry;
    if ($virgin) {
      if ($item eq "") {
	push @menuitem, $entry;
      }
    }
    if ($item eq "ARRAY") {
      $virgin = 0;
      push @menus, GetMenus
	(
	 Indent => " ".($args{Indent} || ""),
	 Domain => $entry,
	),
      }
    ;
  }
  return
    "(".
      EmacsQuote(Arg => join(" ",@menuitem)).
	" . (".
	  join("\n",map {($args{Indent} || "").$_} @menus).
	    "))";
}

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
	 Indent => " ".($args{Indent} || ""),
	 Domain => $entry,
	);
    }
  }
  if (! defined $args{Indent}) {
    return \@menus;
  } else {
    return [
	    ["Start", $start],
	    ["End", $end],
	    ["Entry", join(" ",@menuitem)],
	    ["Submenu", \@menus]
	   ];
  }
}
