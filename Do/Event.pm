package Do::Event;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Contents Properties Hooks /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Contents($args{Contents});
  $self->Properties($args{Properties});
  $self->Hooks($args{Hooks});
}

1;
