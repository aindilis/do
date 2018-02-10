package Do::ListProcessor4::GUI;

# see Do::ListProcessor4

use KBS2::ImportExport;
use KBS2::Util;
use KMax::Util::KeyBindings;
use KMax::Util::Minibuffer;
use PerlLib::SwissArmyKnife;

use Tk;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / App Top1 TopFrame TextFrame Text1 Text2 Text1Frame Text2Frame
	TextWidget SelectionFrame Buttons ContinueLoop Tags
	MyMinibuffer MyKeyBindings MyMainWindow MyImportExport /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Tags({});
  $self->Buttons({});
  $self->App($args{App});
  $self->MyImportExport(KBS2::ImportExport->new());
  if (! defined $UNIVERSAL::managerdialogtkwindow) {
    $UNIVERSAL::managerdialogtkwindow = MainWindow->new
      (
       -title => "Do ListProcessor4",
       # -height => 600,
       # -width => 800,
      );
    $UNIVERSAL::managerdialogtkwindow->withdraw();
  }
  $self->MyMainWindow($UNIVERSAL::managerdialogtkwindow);
  my $title = $args{Title} || undef;
  $self->Top1
    ($UNIVERSAL::managerdialogtkwindow->Toplevel
     (
      -title => $title,
      # -height => 600,
      # -width => 800,
     ));

  $self->TopFrame($self->Top1->Frame());
  $self->TextFrame($self->TopFrame->Frame());

  $self->Text1Frame($self->TextFrame->Frame());
  my $label1 = $self->Text1Frame->Label(-text => "To-Do")->pack(-side => 'top');
  $self->Text1
    ($self->Text1Frame->Scrolled
     (
      'Text',
      -width => 80,
      -height => 40,
      -scrollbars=>'e',
     ))->pack(-side => 'bottom');

  $self->Text2Frame($self->TextFrame->Frame());
  my $label2 = $self->Text2Frame->Label(-text => "Assertions")->pack(-side => 'top');
  $self->Text2
    ($self->Text2Frame->Scrolled
     (
      'Text',
      -width => 80,
      -height => 40,
      -scrollbars=>'e',
     ))->pack(-side => 'bottom');

  $self->Text1->tagConfigure('parent', -background => "green");
  $self->Text1->tagConfigure('child', -background => "yellow");
  $self->Text1Frame->pack(-side => 'left');
  $self->Text2Frame->pack(-side => 'right');
  $self->TextFrame->pack(-side => 'top');

  my $ourresults;

  if (0) {
    $self->SelectionFrame
      ($self->TopFrame->Scrolled
       ('Frame',
	-scrollbars => 'e',
       )->pack
       (
	# -expand => 1,
	-fill => "x",
	-side => 'top',
       ));

    my $buttonframe = $self->TopFrame->Frame;
    $buttonframe->Button
      (
       -text => "Select",
       -command => sub {
	 my @results;
	 foreach my $key (%{$self->Buttons}) {
	   my $button = $self->Buttons->{$key};
	   if (defined $button->{'Value'} and $button->{'Value'}) {
	     push @results, $button->cget('-text');
	     $button->destroy;
	   }
	 }
	 print Dumper({OurResultsA => \@results});
	 $self->ContinueLoop(0);
	 $ourresults = \@results;
	 print Dumper({OurResultsB => $ourresults});
       },
      )->pack(-side => "right");
    $buttonframe->Button
      (
       -text => "Cancel",
       -command => sub { $self->Top1->destroy(); },
      )->pack(-side => "right");
    $buttonframe->pack(-side => "top");
  }

  $self->MyMinibuffer
    (KMax::Util::Minibuffer->new
     (Frame => $self->TopFrame,
      NameArgs => {
		   -side => 'right',
		  },
      FrameArgs => {
		    -side => 'bottom',
		   },
      Width => 168,
     ));
  $self->MyKeyBindings
    (KMax::Util::KeyBindings->new
     (
      KeyBindingsFile => "/var/lib/myfrdcsa/codebases/internal/do/data-git/keybindings-do.txt",
      MyGUI => $self,
     ));
  $self->MyKeyBindings->GenerateGUI
    (
     MyMainWindow => $self->MyMainWindow,
     Minibuffer => $self->MyMinibuffer,
    );
  $self->TopFrame->pack(-fill => "both", -expand => 1);
}

sub Redraw {
  my ($self,%args) = @_;
  if (defined $self->SelectionFrame) {
    foreach my $item (@{$args{Set}}) {
      my $button = $self->SelectionFrame->Checkbutton
	(
	 -text => $item,
	);
      $button->pack(-side => "top", -expand => 1, -fill => "both");
      if (exists $args{Selection}->{$item}) {
	$button->{Value} = 1;
      } else {
	$button->{Value} = 0;
      }
      $self->Buttons->{$item} = $button;
    }
    $self->SelectionFrame->pack(-side => "top", -expand => 1, -fill => "both");
  }
  $self->UpdateAxiomDisplay();
}

sub ListProcessorSubsetSelect {
  my ($self,%args) = @_;

  $self->Text1->configure(-state => "normal");
  $self->Text1->Contents($args{StartingDomain});
  $self->TagText();
  $self->Text1->configure(-state => "disabled");

  $self->Redraw(Set => $args{Set},Selection => $args{Selection});

  $self->MyMainLoop();
  return @$ourresults;
}

sub CleanUp {
  my ($self,%args) = (@_);
  $self->Top1->destroy();
  DoOneEvent(0);
}

sub MyMainLoop {
  my ($self,%args) = (@_);
  unless ($inMainLoop) {
    local $inMainLoop = 1;
    $self->ContinueLoop(1);
    while ($self->ContinueLoop) {
      DoOneEvent(0);
    }
  }
}

sub TagText {
  my ($self,%args) = (@_);
  my $contents = $self->Text1->Contents;
  my $res;
  $res = $self->GetPos(Contents => $contents, Tag => 'START-PARENTDATA');
  $self->Tags->{'ParentStartPos'} = $res->{Tag};
  $contents = $res->{Contents};

  $res = $self->GetPos(Contents => $contents, Tag => 'START-CHILDDATA');
  $self->Tags->{'ChildStartPos'} = $res->{Tag};
  $contents = $res->{Contents};

  $res = $self->GetPos(Contents => $contents, Tag => 'END-CHILDDATA');
  $self->Tags->{'ChildEndPos'} = $res->{Tag};
  $contents = $res->{Contents};

  $res = $self->GetPos(Contents => $contents, Tag => 'END-PARENTDATA');
  $self->Tags->{'ParentEndPos'} = $res->{Tag};
  $contents = $res->{Contents};

  $self->Text1->Contents($contents);

  if (defined $self->Tags->{'ParentStartPos'} and $self->Tags->{'ParentEndPos'}) {
    $self->Text1->tagAdd('parent', $self->Tags->{'ParentStartPos'},$self->Tags->{'ParentEndPos'});
  }
  if (defined $self->Tags->{'ChildStartPos'} and $self->Tags->{'ChildEndPos'}) {
    $self->Text1->tagAdd('child', $self->Tags->{'ChildStartPos'},$self->Tags->{'ChildEndPos'});
  }
  if (defined $self->Tags->{'ChildEndPos'}) {
    $self->Text1->see(AdvanceNLines($self->Tags->{'ChildEndPos'},5));
  }
}

sub GetPos {
  my ($self,%args) = @_;
  my $contents = $args{Contents};
  # print Dumper({Contents => $contents});
  my @lines = split /[\n\r]/, $contents;
  my $y = 1;
  my @newlines = ();
  my $tag = $args{Tag};
  my $result;
  print Dumper({Tag => $tag}) if $UNIVERSAL::debug;

  foreach my $line (@lines) {
    # print "<$line>\n";
    if ($line =~ /^(.*?)\s*($tag)\s*(.*?)$/) {
      my $prefix = $1;
      my $postfix = $3;
      push @newlines, "$prefix$postfix";
      $result = $y.'.'.length($prefix);
    } else {
      push @newlines, $line;
    }
    ++$y;
  }
  my $returncontents = join("\n",@newlines);
  my $retval =
    {
     Tag => $result,
     Contents => $returncontents,
    };
  print Dumper({Tag => $retval->{Tag}}) if $UNIVERSAL::debug;
  return $retval;
}

sub AdvanceNLines {
  my ($loc,$n) = @_;
  if ($loc =~ /^(\d+)\.(\d+)$/) {
    return ($1 + $n).'.'.$2;
  } else {
    print "ERROR\n";
    return $loc;
  }
}

sub DescribeBindings {
  my ($self,%args) = @_;
  # open instead a window with a scroll bar
  SPSE2::GUI::Util::TextWindow->new
      (
       MainWindow => $self->MyMainWindow,
       Title => "Describe Bindings",
       Contents => SeeDumper($self->MyKeyBindings->KeyBindings),
      );

  #   Message
  #     (
  #      Message => SeeDumper($self->MyKeyBindings->KeyBindings),
  #      GetSignalFromUserToProceed => 1,
  #     );
}

sub UpdateAxiomDisplay {
  my ($self,%args) = @_;
  my $relevantaxioms = $UNIVERSAL::listprocessor->GetRelevantAxioms();
  my $res1 = $self->MyImportExport->Convert
    (
     Input => [sort {ClearDumper($a) cmp ClearDumper($b)} @$relevantaxioms],
     InputType => "Interlingua",
     OutputType => "Emacs String",
    );
  $self->Text2->Contents($res1->{Output});
}

sub ActionNextRelationship {
  my ($self,%args) = @_;
  $UNIVERSAL::listprocessor->ActionNextRelationship();
  $self->ContinueLoop(0);
}

sub ActionPreviousRelationship {
  my ($self,%args) = @_;
  $UNIVERSAL::listprocessor->ActionPreviousRelationship();
  $self->ContinueLoop(0);
}

sub ActionSearchRelationships {
  my ($self,%args) = @_;
}

1;
