package Coach::Task::Property;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Property Date /

  ];

sub init {
  my ($self, %args) = @_;
  $self->Properties($args{Properties} || {});
  my $date = `date '+%s'`;
  chomp $date;
  $self->Date($args{Date} || $date);
}

1;
