#!/bin/bash

OUTPUT_FILE=/var/lib/myfrdcsa/codebases/internal/do/scripts/convert/data/files.txt

locate -r '\.do$' >> $OUTPUT_FILE
locate -r '\.notes$' >> $OUTPUT_FILE
