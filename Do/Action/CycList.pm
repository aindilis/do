package Do::Action::CycList;

# use Manager::Dialog qw(QueryUser SubsetSelect);

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Items /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Items([])
}

sub Edit {
  my ($self,%args) = @_;
}

sub SPrintOneLiner {
  my ($self,%args) = @_;
  return "(".join(" ",map {"\#\$".$_} @{$self->Items}).")";
}

1;

