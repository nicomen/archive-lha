#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use FindBin qw/$Bin/;

my $lha = "$Bin/data/_examples/MemLeakZ.lha";
my $output = `$^X -Iblib/lib -Iblib/arch bin/plha v $lha 2>&1`;

like $output, qr/MemLeakZ/, 'plha lists archive contents';
unlike $output, qr/Can't load|Can't locate/, 'No module loading errors';

done_testing;
