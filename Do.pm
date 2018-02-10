package Do;

use BOSS::Config;
use Do::Correlator;
use Do::ListProcessor1;
use Do::ListProcessor2;
use Do::ListProcessor3;
use Do::ListProcessor4;
use MyFRDCSA;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Config MyCorrelator MyListProcessor /

  ];

sub init {
  my ($self,%args) = @_;
  $specification = "
	-i 			Interactive simulation
	-t 			Load test

	--when			Process when stuff

	--index1		Index todo list relationships with ListProcessor1
	--index2		Index todo list relationships with ListProcessor2
	--index3		Index todo list relationships with ListProcessor3
	--index4		Index todo list relationships with ListProcessor4

	-f <files>...		Todo list files for processing
	--contents <contents>	Use this instead of a file if need be

	-c <context>		Context for domain, defaults to \"default\"

	-u [<host> <port>]	Run as a UniLang agent

	-w			Require user input before exiting
";
  $UNIVERSAL::agent->DoNotDaemonize(1);
  $UNIVERSAL::systemdir = ConcatDir(Dir("internal codebases"),"do");
  $self->Config(BOSS::Config->new
		(Spec => $specification,
		 ConfFile => ""));
  my $conf = $self->Config->CLIConfig;
  $UNIVERSAL::agent->Register
    (Host => defined $conf->{-u}->{'<host>'} ?
     $conf->{-u}->{'<host>'} : "localhost",
     Port => defined $conf->{-u}->{'<port>'} ?
     $conf->{-u}->{'<port>'} : "9000");
  if (exists $conf->{'-t'} or
      exists $conf->{'-i'} or
      exists $conf->{'--when'}) {
    $self->MyCorrelator(Do::Correlator->new);
  }
  if (exists $conf->{'--when'}) {
    die "Not currently implemented\n";
  }
  if (exists $conf->{'--index1'}) {
    $self->MyListProcessor(Do::ListProcessor1->new);
  } elsif (exists $conf->{'--index2'}) {
    $self->MyListProcessor(Do::ListProcessor2->new);
  } elsif (exists $conf->{'--index3'}) {
    $self->MyListProcessor(Do::ListProcessor3->new);
  } elsif (exists $conf->{'--index4'}) {
    $self->MyListProcessor(Do::ListProcessor4->new);
  }
}

sub Execute {
  my ($self,%args) = @_;
  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'-t'}) {
    $self->MyCorrelator->DoTest;
  }
  if (exists $conf->{'-i'}) {
    $self->MyCorrelator->Interactive;
  }
  if (exists $conf->{'--when'}) {
    die "Oops!\n";
  }
  if (exists $conf->{'--index1'}) {
    $self->MyListProcessor->Index
      (
       When => exists $conf->{'--when'},
      );
  } elsif (exists $conf->{'--index2'}) {
    $self->MyListProcessor->Index
      (
       When => exists $conf->{'--when'},
      );
  } elsif (exists $conf->{'--index3'}) {
    $self->MyListProcessor->Index
      (
       When => exists $conf->{'--when'},
      );
  }
}

sub ProcessMessage {
  my ($self,%args) = @_;
  my $m = $args{Message};
  my $it = $m->Contents;
  if ($it) {
    if ($it =~ /^echo\s*(.*)/) {
      $UNIVERSAL::agent->SendContents
	(Contents => $1,
	 Receiver => $m->{Sender});
    } elsif ($it =~ /^(quit|exit)$/i) {
      $UNIVERSAL::agent->Deregister;
      exit(0);
    }
  }
}

1;
