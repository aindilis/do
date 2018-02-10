package Do::ListProcessor4::Relationship;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / StartingDomainID ParentID ChildID ParentKey ChildKey /

  ];

sub init {
  my ($self,%args) = @_;
  $self->StartingDomainID($args{StartingDomainID});
  $self->ParentID($args{ParentID});
  $self->ChildID($args{ChildID});
  $self->ParentKey($args{ParentKey});
  $self->ChildKey($args{ChildKey});
}

sub DecideRelationship {
  my ($self,%args) = @_;
  $self->StartingDomainID($args{StartingDomainID});
  $self->ParentID($args{ParentID});
  $self->ChildID($args{ChildID});
  $self->ParentKey($args{ParentKey});
  $self->ChildKey($args{ChildKey});
}

1;
