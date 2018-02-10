#!/bin/sh

export DOCONVERTDIR=/var/lib/myfrdcsa/codebases/minor/do-convert

$DOCONVERTDIR/scripts/generate-files-txt.sh

rm $DOCONVERTDIR/data/results/*.pl

$DOCONVERTDIR/convert-do-to-prolog
