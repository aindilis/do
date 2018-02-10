#!/usr/bin/perl -w

use Do::ListProcessor4;

$UNIVERSAL::listprocessor = Do::ListProcessor4->new;
$UNIVERSAL::listprocessor->Execute();
