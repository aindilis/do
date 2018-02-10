#!/bin/sh

HELPERFILE="/var/lib/myfrdcsa/codebases/internal/do/scripts/convert/prolog/generate-qlf-helper.pl"
if [ ! -e $HELPERFILE ]; then
    swipl -s /var/lib/myfrdcsa/codebases/minor/do-convert/prolog/generate-qlf.pl -g "print,halt." > $HELPERFILE
else
    echo Helper file already exists: $HELPERFILE
fi

QLFFILE="/var/lib/myfrdcsa/codebases/internal/do/scripts/convert/prolog/generate-qlf-helper.qlf"
if [ ! -e $QLFFILE ]; then
    swipl -s /var/lib/myfrdcsa/codebases/minor/do-convert/prolog/generate-qlf.pl -g "compile,halt."
else
    echo QLF file already exists: $QLFFILE
fi

swipl -s /var/lib/myfrdcsa/codebases/minor/do-convert/prolog/generate-qlf.pl -g "load,module(user)."
