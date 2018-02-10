#!/usr/bin/perl -w

use Do;

use UniLang::Agent::Agent;
use UniLang::Util::Message;

$UNIVERSAL::agent = UniLang::Agent::Agent->new
  (Name => "Do",
   ReceiveHandler => \&Receive);
$UNIVERSAL::do = Do->new();

sub Receive {
  my %args = @_;
  $UNIVERSAL::do->ProcessMessage
    (Message => $args{Message});
}

$UNIVERSAL::do->Execute();
