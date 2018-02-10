package Do::Convert::DoToProlog::Parser;

use Do::ListProcessor2;
use KBS2::ImportExport;
use PerlLib::SwissArmyKnife;
use System::EasyCCG;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyListProcessor MyImportExport MyEasyCCG UseEasyCCG /

  ];

sub init {
  my ($self,%args) = @_;
  $self->MyListProcessor
    (Do::ListProcessor2->new
     ());
  $self->MyImportExport
    (KBS2::ImportExport->new
     ());
  $self->UseEasyCCG($args{UseEasyCCG} || 0);
  if ($self->UseEasyCCG) {
    $self->MyEasyCCG
      (System::EasyCCG->new
       ());
    $self->MyEasyCCG->StartServer();
  }
}

sub DoParsingOfDoTodoAndConvertIntoProlog {
  my ($self,%args) = @_;
  my $domain = $self->MyListProcessor->MyLight->Parse
    (Contents => $args{Contents});
  # print Dumper({Domain => $domain});
  my $input = $self->ConvertParsedDoDomainToProtoProlog(Domain => $domain);
  my $res1 = $self->MyImportExport->Convert
    (
     Input => $input,
     InputType => 'Interlingua',
     OutputType => 'Prolog',
    );
  if ($res1->{Success}) {
    my @res1;
    foreach my $line (split /\n/, $res1->{Output}) {
      $line =~ s/\s+$//sg;
      if ($line !~ /\.$/) {
	$line .= '.';
      }
      if ($line =~ /^(.+?\'),?([^']+)\.$/) {
	push @res1, $1.'('.$2.').';
      } else {
	push @res1, $line;
      }
    }
    my @res2;
    foreach my $item (@res1) {
      $item =~ s/\(\)//sg;
      push @res2, $item;
    }
    my $res4 = "\n".join("\n",@res2)."\n";
    return $res4;
  }
}

sub ConvertParsedDoDomainToProtoProlog {
  my ($self,%args) = @_;
  my $ref1 = ref($args{Domain});
  if ($ref1 eq 'ARRAY') {
    my @res;
    my @acculumator;
    foreach my $subdomain (@{$args{Domain}}) {
      my $ref2 = ref($subdomain);
      if ($ref2 eq '') {
	push @acculumator, lc($subdomain);
      } else {
	if (scalar @acculumator) {
	  push @res, $self->PostProcess(Text => join(' ',@acculumator));
	  @acculumator = ();
	}
	push @res, $self->ConvertParsedDoDomainToProtoProlog(Domain => $subdomain);
      }
    }
    if (@acculumator) {
      push @res,$self->PostProcess(Text => join(' ',@acculumator));
    }
    return \@res;
  } else {
    return lc($args{Domain} || "");
  }
}

sub PostProcess {
  my ($self,%args) = @_;
  if ($self->UseEasyCCG) {
    my $res1 = $self->MyEasyCCG->GetCCG(Text => $args{Text}, N => 10);
    return $res1->[0]{Parse}[0];
  } else {
    return $args{Text};
  }
}

1;
