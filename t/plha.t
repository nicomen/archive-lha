#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use FindBin qw/$Bin/;


my $lha = "$Bin/data/_examples/MemLeakZ.lha";
ok `bin/plha v $lha`;

done_testing;
