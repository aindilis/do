#!/usr/bin/perl -w

print join("\n",split /\s+/,`cat cyc-constants`);
