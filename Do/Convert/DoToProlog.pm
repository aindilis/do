package Do::Convert::DoToProlog;

use Do::Convert::DoToProlog::Parser;
use MyFRDCSA qw(Dir ConcatDir);
use PerlLib::EasyPersist;
use PerlLib::SwissArmyKnife;

use Linux::Inotify2;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyParser MyEasyPersist MyInotify Seen /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyParser
    (Do::Convert::DoToProlog::Parser->new());
  $self->MyEasyPersist
    (PerlLib::EasyPersist->new
     (
      CacheRoot => ConcatDir(Dir("internal codebases"),"do/data/persist/Cache"),
      Silent => 1,
     ));
}

sub IndexDocuments {
  my ($self,%args) = @_;
  $self->Seen({});
  my $c = read_file('/var/lib/myfrdcsa/codebases/internal/do/scripts/convert/data/files.txt');
  my @files = split /\n/, $c;
  my @dofiles;
  my @notdofiles;
  foreach my $file (@files) {
    print "trying: <<<$file>>>\n";
    if (-f $file) {
      print "file-exists\n";
      if ($self->IsDoFile(File => $file)) {
	print "is-do-file\n";
	push @dofiles, $file;
	$self->IndexDocument(File => $file);
      } else {
	print "is-not-do-file\n";
	push @notdofiles, $file;
      }
    } else {
      print "file-does-not-exist\n";
    }
  }

  my $fh1 = IO::File->new();
  $fh1->open(">/var/lib/myfrdcsa/codebases/internal/do/scripts/convert/data/files-do.txt") or die "Wowza1!\n";
  print $fh1 join("\n",@dofiles);
  $fh1->close;

  my $fh2 = IO::File->new();
  $fh2->open(">/var/lib/myfrdcsa/codebases/internal/do/scripts/convert/data/files-not-do.txt") or die "Wowza2!\n";
  print $fh2 join("\n",@notdofiles);
  $fh2->close;

  # $self->SetupInotify();
  # use formalog instead here

  # system "/var/lib/myfrdcsa/codebases/internal/do/scripts/convert/scripts/conversion.sh";
  system "/var/lib/myfrdcsa/codebases/internal/do/scripts/convert/scripts/generate-qlf.sh";
}

sub IndexDocument {
  my ($self,%args) = @_;
  my $argsfile = $args{File};
  my $qargsfile = shell_quote($argsfile);
  my $outputnameorig = `chase $qargsfile`;
  chomp $outputnameorig;
  $outputname1 = $argsfile;
  $outputname1 =~ s/[^a-zA-Z0-9]/_/sg;
  $outputname2 = $outputnameorig;
  $outputname2 =~ s/[^a-zA-Z0-9]/_/sg;

  my $outputfiledir = "/var/lib/myfrdcsa/codebases/internal/do/scripts/convert/data/results";
  my $outputfilename1 = "$outputfiledir/$outputname1.pl";
  my $outputfilename2 = "$outputfiledir/$outputname2.pl";
  MkDirIfNotExists(Directory => $outputfiledir);
  my $command = 'md5sum '.shell_quote($args{File});
  my $currentmd5sum = `$command`;
  $currentmd5sum =~ s/^([a-z0-9]+)\s.+$/$1/s;
  my $res1 = $self->MyEasyPersist->Get
    (
     Command => '`'.$command.'`',
    );
  my $md5sum;
  if ($res1->{Success}) {
    $md5sum = $res1->{Result};
    $md5sum =~ s/^([a-z0-9]+)\s.+$/$1/s;
    $self->Seen->{$md5sum} = 1;
  }
  print Dumper
    ({
      Res1 => $res1,
      CurrentMD5Sum => $currentmd5sum,
      OutputFilename2 => $outputfilename2,
      Seen => $self->Seen->{$currentmd5sum},
     });
  if (! $self->Seen->{$currentmd5sum} or ! -f $outputfilename2) {
    print "<$md5sum>\n<$currentmd5sum>\n<$argsfile>\n<$outputnameorig>\n<$outputfilename1>\n<$outputfilename2>\n";
    print "Not yet seen: processing.\n";
    $self->Seen->{$currentmd5sum} = 1;
    my $res3 = $self->MyEasyPersist->Get
      (
       Command => '`'.$command.'`',
       Overwrite => 1,
      );

    my $fh = IO::File->new();
    $fh->open(">$outputfilename2") or die "Ouch!\n";
    print $fh "hasSourceFile('".$args{File}."').\n";

    my $c = read_file($args{File});
    print $fh $self->MyParser->DoParsingOfDoTodoAndConvertIntoProlog(Contents => $c);
    $fh->close;
    print "\n";
  }
}

sub SetupInotify {
  my ($self,%args) = @_;
  # create a new object
  $self->MyInotify
    (Linux::Inotify2->new());

  # add watchers
  my $c = read_file('/var/lib/myfrdcsa/codebases/internal/do/scripts/convert/data/files.txt');
  foreach my $file (split /\n/, $c) {
    print "adding $file\n";
    $self->MyInotify->watch
      ($file, IN_MODIFY,
       sub {
	 my $e = shift;
	 my $name = $e->fullname;
	 print "$name was modified\n" if $e->IN_MODIFY;
       });
  }
  # 1 while $self->MyInotify->poll;
}

sub IsDoFile {
  my ($self,%args) = @_;
  my $c = read_file($args{File});
  my @res1 = $self->MyParser->MyListProcessor->MyLight->Parse(Contents => $c);
  $self->VerifyDoFile(Item => \@res1);
}

sub VerifyDoFile {
  my ($self,%args) = @_;
  my $item = $args{Item};
  if (exists $item->[0][0][0]) {
    return 1;
  } else {
    return 0;
  }
}

sub ConversionLogic {
  my ($self,%args) = @_;

  # # /var/lib/myfrdcsa/codebases/internal/do/new-keywords.el

  # (list
  #  ("reminded" . (("desc" . "for when you reminded someone to do something, track the time of the reminder")
  # 		("arity" . nil)))
  #  ("location" . (("desc" . "")
  # 		("arity" . nil)))
  #  ("already completed" . (("desc" . "")
  # 			 ("arity" . nil)))
  #  ("delayed" . (("desc" . "")
  # 	       ("arity" . nil)))
  #  ("fixed" . (("desc" . "")
  # 	     ("arity" . nil)))
  #  ("before" . (("desc" . "")
  # 	      ("arity" . nil)))
  #  ("always" . (("desc" . "")
  # 	      ("arity" . nil)))
  #  ("ordered" . (("desc" . "")
  # 	       ("arity" . nil)))
  #  ("shipped" . (("desc" . "")
  # 	       ("arity" . nil)))
  #  ("obtained instead at" . (("desc" . "")
  # 			   ("arity" . "2")))
  #  ("already owned" . (("desc" . "")
  # 		     ("arity" . nil)))
  #  ("partial solution" . (("desc" . "")
  # 			("arity" . nil)))
  #  ("cancelled" . (("desc" . "")
  # 		 ("arity" . nil)))
  #  ("answer" . (("desc" . "")
  # 	      ("arity" . nil)))
  #  )

  # (depends X Y)
  # (eases X Y)

  # (perseverate ON GOD &BODY)

  # (WHEN &BODY)
  # (BEFORE &BODY)

  # (SCHEDULE &BODY)
  #  # DATE FORMATS
  #  (wed &BODY)
  #  (Wed Jan 4 &BODY)
  #  (Mon Dec 26th &BODY)
  #  (<DAY_OF_WEEK> &BODY), <DAY_OF_WEEK> := Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
  #  (Fri Dec 23 15:58:45 CST 2016
  #  )

  # (wed &BODY)
  # (Wed Jan 4 &BODY)
  # (Mon Dec 26th &BODY)
  # (<DAY_OF_WEEK> &BODY), <DAY_OF_WEEK> := Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
  # (Fri Dec 23 15:58:45 CST 2016

  # (REVIEW X &BODY)

  # (SHOPPINGLIST &BODY)
  #  (stores &BODY)
  #   (wishlist &BODY)
  #   (<STORE> &BODY), <STORE> := Dollar Tree, Goodwill, Walmart, Five Below, Bed Bath and Beyond, WholeFoods, Aldi, Home Depot, Target, Oswalds, Babies R Us
  #   (Walgreens xor CVS &BODY)
  #   )
  #  (Eventually &BODY)
  #  (Anywhere &BODY)
  #  (Online &BODY)
  #  (Grocery &BODY)
  #  (Naperville &BODY)
  #  )


  # (wishlist &BODY)

  # (immediate &BODY)
  # (sometime &BODY)
  # (tonight &BODY)
  # (soon &BODY)

  # (work &BODY)
  # (plan &BODY)
  # (trip &BODY)

  # (FINANCES &BODY)
  # (RESEARCH &BODY)

  # (HABITUAL &BODY)
  #  (constantly &BODY)
  #  (as directed &BODY)
  #  (after &BODY)
  #  (three times a day &BODY)
  #  (twice a day &BODY)
  #  (daily &BODY)
  #  (every other day &BODY)
  #  (biweekly &BODY)
  #  (weekly &BODY)
  #  (monthly &BODY)
  #  )

  # (COMMUNICATIONS &BODY)
  #  (<PERSON> &BODY), <PERSON> := Justin
  #  )

  # (<PERSON> &BODY), <PERSON> := Justin
  # # Andy & Meredith

  # (read &BODY)

  # (scheduled X Y)

  # (CHORE CHART &BODY)

  # (POSTPONED &BODY)
  # (COMPLETED ITEMS &BODY)
  # (COMPLETED SCHEDULE &BODY)
  # (DELETED &BODY)
  # (DELETED &BODY)
  # (SOLUTIONS &BODY)
  # (ANSWERS &BODY)

  # (note &BODY)

  # (when X Y)
  # (before X Y)

  # (not found X)

  # (completed X)
  # (deleted X)
  # (postponed X)
  # (in progress X)
  # (obsoleted X)
  # (solution X Y)
  # (feature request X)
  # (incoming &BODY)
  # (noted elsewhere X Y)


  # (BEGAN READING at "20161231104529")
  # (ENDED READING at "20161231104529")
}

1;

